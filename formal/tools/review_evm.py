"""Independently replay the adoption evidence; never infer source/bytecode acceptance."""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from check import ROOT, LIBRARY, check, digest
from bootstrap_evm import validate_python
from evm_dependency import LOCK


def review(evidence, output):
    assert not output.exists(),'Review receipt must be fresh'
    check()
    manifest=json.loads((evidence/'manifest.json').read_text())
    assert manifest['status']=='adoption-gates-passed'
    assert manifest['nativePackage']=='dafnyevm-adoption'
    assert manifest['sourceAcceptance'] is False and manifest['bytecodeCredit'] is False
    expected=['native','native-review','generation','generation-review','capture','python-build','smoke']
    if manifest['affectedSourceRequired']:expected.append('affected-source')
    assert [c['gate'] for c in manifest['commands']]==expected,'Missing adoption gate'
    assert all(c['exitCode']==0 for c in manifest['commands'])
    assert digest(Path(sys.executable).resolve())==manifest['pythonExecutableSha256']
    for relative,value in manifest['producerInputs'].items():
        assert digest(ROOT/relative)==value==digest(evidence/'producer'/relative),'Producer binding drift'
    required={str(p.relative_to(ROOT)) for p in (LIBRARY/'tools').glob('*.py')}
    required.update(['formal/dependencies/dafnyevm/'+n for n in ['lock.json','generic.patch','crypto.patch','tools.json','requirements.lock']])
    required.update(['formal/migrations/dafnyevm.json','formal/bytecode/dafnyevm/runtime-binding.json','formal/claims.json','docs/claim-evidence.json'])
    assert set(manifest['producerInputs'])==required,'Incomplete producer binding'
    for relative,value in manifest['evidenceSha256'].items():assert digest(evidence/relative)==value,'Evidence drift: '+relative
    lock=json.loads(LOCK.read_text())
    assert validate_python(ROOT/'proof-tools/evm-python',lock['requirementsSha256'])==manifest['pythonDependencies']
    with tempfile.TemporaryDirectory(prefix='evm-review-') as directory:
        replay=Path(directory)
        def run(command):
            result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
            assert result.returncode==0,result.stdout+'\n'+result.stderr
        run([sys.executable,str(LIBRARY/'tools/review.py'),'dafnyevm-adoption','--evidence',str(evidence/'native'),'--output',str(replay/'native.json')])
        run([sys.executable,str(LIBRARY/'tools/review_generation.py'),'original-operations-scalars','--evidence',str(evidence/'generation'),'--output',str(replay/'generation.json')])
        # Recompile from the current frozen source/settings; compare exact compiler artifacts.
        run([sys.executable,str(LIBRARY/'tools/capture_evm.py'),'--output',str(replay/'runtime')])
        for name in ['solc-input.json','solc-output.json','runtime.hex']:
            assert (replay/'runtime'/name).read_bytes()==(evidence/'runtime'/name).read_bytes(),'Runtime replay mismatch'
        snapshot=evidence/'native/snapshot/proof-tools/dafnyevm/src/dafny/evm.dfy'
        run([str(ROOT/'proof-tools/assertions/dafny/dafny'),'build','--target','py','--no-verify',str(snapshot),'--output',str(replay/'interpreter/evm')])
        def generated_files(base):return {str(p.relative_to(base)):digest(p) for p in base.rglob('*.py')}
        assert generated_files(replay/'interpreter')==generated_files(evidence/'interpreter'),'Interpreter translation replay mismatch'
        run([sys.executable,str(LIBRARY/'tools/evm_smoke.py'),'--interpreter',str(replay/'interpreter/evm-py'),'--vendor',str(ROOT/'proof-tools/evm-python'),'--runtime',str(replay/'runtime/runtime.hex'),'--output',str(replay/'smoke.json')])
        smoke=json.loads((replay/'smoke.json').read_text())
        assert smoke==json.loads((evidence/'smoke.json').read_text()),'Smoke replay mismatch'
        assert smoke['status']=='passed' and len(smoke['cases'])==46 and len(smoke['mutations'])==4 and len(smoke['genericCases'])>=15
        assert all(c['agree'] and c['specMatches'] for c in smoke['cases']+smoke['genericCases'])
        assert all(c['agree'] and c['killed'] for c in smoke['mutations'])
        assert all(c['rejected'] for c in smoke['negativeProbes'])
        if manifest['affectedSourceRequired']:
            campaign=json.loads((evidence/'affected-source/manifest.json').read_text())
            assert campaign['status']=='finished' and campaign['results']
            for item in campaign['results']:
                assert item['reviewExitCode']==0
                run([sys.executable,str(LIBRARY/'tools/review.py'),item['package'],'--evidence',item['evidence'],'--output',str(replay/(item['package']+'.json'))])
        native=json.loads((replay/'native.json').read_text())
        assert native==json.loads((evidence/'native-review.json').read_text()), 'Native review receipt mismatch'
        assert json.loads((replay/'generation.json').read_text())==json.loads((evidence/'generation-review.json').read_text()), 'Generation review receipt mismatch'
    receipt={'status':'independently-reviewed-dafnyevm-adoption','evidence':str(evidence),'manifestSha256':digest(evidence/'manifest.json'),'reviewerSha256':digest(Path(__file__)),'nativeRows':native['nativeRows'],'helperCases':46,'mutants':4,'genericCases':len(smoke['genericCases']),'affectedSourceRequired':manifest['affectedSourceRequired'],'sourceAcceptance':False,'bytecodeCredit':False,'scope':manifest['scope']}
    output.parent.mkdir(parents=True,exist_ok=True);output.write_text(json.dumps(receipt,indent=2)+'\n')
    return receipt


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evidence',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();result=review(args.evidence.resolve(),args.output.resolve())
    print('PASS independent adoption replay:',result['nativeRows'],'native rows;',result['helperCases'],'helper cases;',result['mutants'],'mutants;',result['genericCases'],'generic cases.')
