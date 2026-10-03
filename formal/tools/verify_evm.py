"""Fresh, separately reviewed DafnyEVM adoption gates and concrete runtime smoke."""
import argparse
import datetime
import json
import shutil
import subprocess
import sys
from pathlib import Path
from check import ROOT, LIBRARY, check, digest
from evm_dependency import LOCK, external_sources
from bootstrap_evm import validate_python
from evm_inputs import producer_paths


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--run',action='store_true')
    parser.add_argument('--affected-source',action='store_true',help='Also require the full legacy affected source campaign, whose source acceptance is separate')
    args=parser.parse_args()
    check()
    lock=json.loads(LOCK.read_text())
    validate_python(ROOT/'proof-tools/evm-python',lock['requirementsSha256'])
    output=args.output.resolve()
    assert not output.exists(),'Adoption evidence must be fresh'
    plan={'scope':'Clean native semantics, all rewritten models and representation bridges; current runtime capture and complete concrete public RAW_BYTES resolve calls plus helper/generic validation. Universal public-entry bytecode correctness and legacy source acceptance remain separate.',
          'nativePackage':'dafnyevm-adoption','affectedSourceRequired':args.affected_source,
          'sourceAcceptance':False,'bytecodeCredit':False}
    if not args.run:
        print(json.dumps(plan,indent=2));return
    output.mkdir(parents=True)
    producers=producer_paths()
    producers={str(p.relative_to(ROOT)):digest(p) for p in producers}
    for relative in producers:
        dest=output/'producer'/relative;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/relative,dest)
    python_files=validate_python(ROOT/'proof-tools/evm-python',lock['requirementsSha256'])
    receipt=dict(plan,status='running',startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),producerInputs=producers,pythonDependencies=python_files,pythonExecutableSha256=digest(Path(sys.executable).resolve()),pythonVersion=sys.version,commands=[])
    def save():
        (output/'manifest.json').write_text(json.dumps(receipt,indent=2)+'\n')
    def run(label,command):
        with (output/(label+'.log')).open('w') as log:
            result=subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
        receipt['commands'].append({'gate':label,'command':command,'exitCode':result.returncode});save()
        assert result.returncode==0,'Failed gate: '+label
    save()
    try:
        native=output/'native';review=output/'native-review.json'
        run('native',[sys.executable,str(LIBRARY/'tools/verify.py'),'dafnyevm-adoption','--output',str(native),'--run'])
        run('native-review',[sys.executable,str(LIBRARY/'tools/review.py'),'dafnyevm-adoption','--evidence',str(native),'--output',str(review)])
        generation=output/'generation'
        run('generation',[sys.executable,str(LIBRARY/'tools/generate.py'),'original-operations-scalars','--output',str(generation)])
        run('generation-review',[sys.executable,str(LIBRARY/'tools/review_generation.py'),'original-operations-scalars','--evidence',str(generation),'--output',str(output/'generation-review.json')])
        run('capture',[sys.executable,str(LIBRARY/'tools/capture_evm.py'),'--output',str(output/'runtime')])
        # Translation has no proof credit. It uses only the already reviewed exact snapshot.
        root=native/'snapshot/formal/bytecode/dafnyevm/PublicResolve.dfy'
        run('python-build',[str(ROOT/'proof-tools/assertions/dafny/dafny'),'build','--target','py','--no-verify',str(root),'--output',str(output/'interpreter/evm')])
        run('smoke',[sys.executable,str(LIBRARY/'tools/evm_smoke.py'),'--interpreter',str(output/'interpreter/evm-py'),'--vendor',str(ROOT/'proof-tools/evm-python'),'--runtime',str(output/'runtime/runtime.hex'),'--output',str(output/'smoke.json')])
        run('public-resolve',[sys.executable,str(LIBRARY/'tools/evm_public_resolve.py'),'--interpreter',str(output/'interpreter/evm-py'),'--vendor',str(ROOT/'proof-tools/evm-python'),'--runtime',str(output/'runtime/runtime.hex'),'--output',str(output/'public-resolve.json')])
        if args.affected_source:
            run('affected-source',[sys.executable,str(LIBRARY/'tools/campaign.py'),'--migration','--output',str(output/'affected-source'),'--run'])
            campaign=json.loads((output/'affected-source/manifest.json').read_text())
            assert campaign['status']=='finished','Incomplete legacy source closures'
        assert all(digest(ROOT/p)==h and digest(output/'producer'/p)==h for p,h in producers.items()),'Producer drift'
        assert validate_python(ROOT/'proof-tools/evm-python',lock['requirementsSha256'])==python_files,'Python install drift'
        receipt.update(status='adoption-gates-passed',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat())
    except BaseException as error:
        receipt.update(status='failed-or-interrupted',error=str(error));save();raise
    receipt['evidenceSha256']={str(p.relative_to(output)):digest(p) for p in output.rglob('*') if p.is_file() and p.name!='manifest.json' and '__pycache__' not in p.parts and p.suffix!='.pyc'}
    save()
    print('PASS separate native, generation, runtime and concrete smoke gates; independent adoption review still required.')


if __name__=='__main__':main()
