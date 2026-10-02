"""Verify uncovered complete canonical closures sequentially, without duplicate subclosure runs."""
import argparse
import datetime
import json
import subprocess
import sys
from pathlib import Path
from check import ROOT, LIBRARY, check, digest
from status import build_status


def plan():
    registry=json.loads((LIBRARY/'registry.json').read_text())
    statuses={p['package']:p for p in build_status()['packages']}
    descriptors={p['id']:json.loads((ROOT/p['canonicalDescriptor']).read_text())
                 for p in registry['packages'] if p['selectionRole']=='proof-package'}
    pending={key:value for key,value in descriptors.items()
             if statuses[key]['canonicalNativeStatus']!='independently-reviewed-native'}
    closures={key:set(value['closureSha256'].items()) for key,value in pending.items()}
    maximal=[]
    for key,closure in closures.items():
        if any(closure < other or (closure==other and key>name)
               for name,other in closures.items() if name!=key):
            continue
        maximal.append({'package':key,'files':len(closure),
                        'covers':[name for name,other in closures.items() if other<=closure],
                        'descriptorSha256':digest(ROOT/next(p['canonicalDescriptor'] for p in registry['packages'] if p['id']==key))})
    return {'pendingPackages':len(pending),'campaigns':sorted(maximal,key=lambda p:(-len(p['covers']),-p['files'],p['package']))}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--run',action='store_true')
    args=parser.parse_args()
    check()
    receipt=plan()
    if not args.run:
        print(json.dumps(receipt,indent=2));return
    output=args.output.resolve()
    assert not output.exists(),'Campaign output must be fresh'
    output.mkdir(parents=True)
    receipt.update(status='running',startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                   runnerSha256=digest(Path(__file__)),results=[])
    def save():
        (output/'manifest.json').write_text(json.dumps(receipt,indent=2)+'\n')
    save()
    try:
        for item in receipt['campaigns']:
            package=item['package']
            evidence=output/package
            review=LIBRARY/'evidence/reviews'/(output.name+'-'+package+'.json')
            assert not review.exists(),'Review output must be fresh'
            with (output/(package+'.log')).open('w') as log:
                verify=subprocess.run([sys.executable,str(LIBRARY/'verify.py'),package,
                                       '--output',str(evidence),'--run'],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
                result={'package':package,'verifyExitCode':verify.returncode,'evidence':str(evidence.relative_to(ROOT))}
                if verify.returncode==0:
                    reviewed=subprocess.run([sys.executable,str(LIBRARY/'review.py'),package,
                                             '--evidence',str(evidence),'--output',str(review)],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
                    result['reviewExitCode']=reviewed.returncode
                    if reviewed.returncode==0:
                        result['review']=str(review.relative_to(ROOT))
                        result['reviewSha256']=digest(review)
            receipt['results'].append(result);save()
            print(json.dumps(result),flush=True)
        receipt['status']='finished' if all(r.get('reviewExitCode')==0 for r in receipt['results']) else 'finished-with-incomplete-closures'
        receipt['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();save()
    except BaseException as error:
        receipt['status']='interrupted-or-error';receipt['error']=str(error);save();raise

if __name__=='__main__':
    main()
