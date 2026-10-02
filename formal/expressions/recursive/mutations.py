#!/usr/bin/env python3
"""Actual-source faults must fail a semantic obligation and an exact EVM test."""
import argparse
import datetime
import json
from pathlib import Path
import re
import shutil
import sys
import verify

FAULTS=[
 ('select-direction','AbiCodec.word(condition, 0) != 0 ? 1 : 2','AbiCodec.word(condition, 0) != 0 ? 2 : 1','ExpressionRecursiveSource.Choose','testSelectDirectionAndLaziness'),
 ('skip-validation','        AbiCodec.validate(bytes(node.valueType), result, cache.dynamic[index], cache.words[index]);\n','','ExpressionRecursiveSource.Run','testValidationCannotBeSkipped'),
 ('call-reference','cache, node.refs[i + 1]','cache, node.refs[i + 0]','ExpressionRecursiveSource.Run','testCallArgumentsRemainOrdered'),
]



def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 manifest={'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'faults':[],
   'sourceSha256':{str(p.relative_to(verify.ROOT)):verify.sha(p) for p in verify.inputs()},
   'executableSha256':{n:verify.sha(binary) for n,binary in [('dafny',a.dafny),('Dafny.dll',a.dafny.parent/'Dafny.dll'),('solc',a.solc),('z3',a.dafny.parent/'z3/bin/z3-4.12.1')]}}
 def save(): (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 save()
 for name,before,after,theorem,test in FAULTS:
  directory=out/name;scratch=directory/'source-snapshot'
  for path in verify.inputs():
   dest=scratch/path.relative_to(verify.ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
  source=scratch/'formal/expressions/recursive';solidity=scratch/'contracts/Expressions.sol';text=solidity.read_text()
  if text.count(before)!=1: raise ValueError('Ambiguous mutation '+name)
  solidity.write_text(text.replace(before,after))
  gate=verify.run([sys.executable,'-B',source/'generate.py','--solc',a.solc,'--root',scratch,'--output',directory/'generated'],directory/'gate.log')
  result={'name':name,'before':before,'after':after,'expectedTheorem':theorem,'expectedTest':test,'sourceGate':gate,'passed':False}
  if gate['exitCode']==0:
   for generated in ['Source.generated.dfy']:
    shutil.copy2(directory/'generated'/generated,source/generated)
   command=verify.common.proof_command(a.dafny,source/'Source.generated.dfy',directory/'proof.csv')+['--filter-symbol',theorem]
   proof=verify.run(command,directory/'proof.log',240);log=(directory/'proof.log').read_text()
   proof['killed']=bool(proof['exitCode']==4 and re.search(r'with \d+ verified, [1-9]\d* errors?',log)
       and re.search(r'postcondition could not be proved|invariant could not be proved|assertion might not hold|index out of range|upper bound|subset constraints',log)
       and not re.search(r'time.?out|inconclusive|resolution/type errors|parse errors',log,re.I))
   result['proof']=proof
   (scratch/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/expressions/recursive"\nsolc='+json.dumps(str(a.solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n')
   evm=verify.run(['forge','test','--root',scratch,'--match-contract','RecursiveOracleTest','-vv'],directory/'concrete.log',180);text=(directory/'concrete.log').read_text()
   expected=re.findall(r'function (test\w+)\(', (source/'RecursiveOracle.t.sol').read_text());observed=re.findall(r'^\[(?:PASS|FAIL:.*)\] (test\w+)\(',text,re.M);failed=re.findall(r'^\[FAIL:.*\] (test\w+)\(',text,re.M)
   evm.update(expectedTests=expected,observedTests=sorted(set(observed)),failedTests=sorted(set(failed)))
   evm['killed']=evm['exitCode']==1 and set(observed)==set(expected) and test in failed
   result['concrete']=evm;result['passed']=proof['killed'] and evm['killed']
   shutil.rmtree(scratch/'out',ignore_errors=True);shutil.rmtree(scratch/'cache',ignore_errors=True)
  manifest['faults'].append(result);save()
 manifest['inputsUnchanged']=manifest['sourceSha256']=={str(p.relative_to(verify.ROOT)):verify.sha(p) for p in verify.inputs()}
 manifest['status']='passed' if manifest['inputsUnchanged'] and all(f['passed'] for f in manifest['faults']) else 'incomplete'
 manifest['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
 manifest['evidenceSha256']={str(p.relative_to(out)):verify.sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}
 save();print(manifest['status']);raise SystemExit(0 if manifest['status']=='passed' else 1)


if __name__=='__main__': main()
