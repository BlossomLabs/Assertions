#!/usr/bin/env python3
"""Require semantic proof failures and EVM regressions for recursive ABI body faults."""
import argparse
import concurrent.futures
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('shape_verify',HERE/'verify.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
run,sha=base.run,base.sha
MUTATIONS=[
 ('body-extent','return x.base - p + x.tail;','return x.base - p + x.tail + 1;','AbiDynamicSource.BodyExtent',2,'all'),
 ('tuple-second-cursor','x.j = next + 1;','x.j = next + 0;','AbiDynamicSource.SecondNext',2,'last'),
 ('tuple-word-stride','x.base += w * 32;','x.base += w * 31;','AbiDynamicSource.TupleAdvance',1,'all'),
]



def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--dafny',required=True);p.add_argument('--solc',required=True)
 p.add_argument('--baseline',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
 a=p.parse_args();binary,solver,compiler,pin,versions,hashes=base.common.tools(a.dafny,a.solc)
 baseline=json.loads(a.baseline.read_text())
 assert baseline['status']=='passed'
 assert all(sha(ROOT/n)==h for n,h in baseline['sourceSha256'].items())
 assert all(sha(a.baseline.parent/n)==h for n,h in baseline['evidenceSha256'].items())
 out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 shutil.copy2(a.baseline,out/'baseline.json')
 report={'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'baselineSha256':sha(a.baseline),'versions':versions,'executableSha256':hashes,'results':[]}
 def save(): (out/'mutations.json').write_text(json.dumps(report,indent=2)+'\n')
 save()
 source=(ROOT/'contracts/lib/AbiCodec.sol').read_text()
 def check(case):
  name,old,new,target,occurrences,which=case;dest=out/name;dest.mkdir()
  snap=dest/'source-snapshot';shutil.copytree(a.baseline.parent/'source-snapshot',snap)
  assert source.count(old)==occurrences
  altered=source.replace(old,new) if which=='all' else new.join(source.rsplit(old,1))
  sol=snap/'contracts/lib/AbiCodec.sol';sol.write_text(altered)
  result={'name':name,'before':old,'after':new,'target':target,'alteredSourceSha256':sha(sol),'status':'incomplete'}
  gen=run([sys.executable,'-B',snap/'formal/abi/dynamic/generate.py','--solc',compiler,'--source',sol,'--output',dest/'generated'],dest/'generate.log')
  result['generation']=gen
  if gen['exitCode']!=0: return result
  shutil.copy2(dest/'generated/Body.generated.dfy',snap/'formal/abi/dynamic/Body.generated.dfy')
  command=base.common.proof_command(binary,solver,pin,snap/'formal/abi/dynamic/Body.generated.dfy',dest/'verification.csv',target)
  proof=run(command,dest/'verify.log',900)
  result['assertionIsolation']=False
  result['proof']=proof;native=base.common.native_results(dest/'verification.csv');result['nativeResults']=native
  text=(dest/'verify.log').read_text()
  # Timeouts/unsupported translation never count as a detected mutation.
  semantic=bool(re.search(r'(postcondition could not be proved|assertion might not hold|invariant could not be proved|precondition could not be proved)',text))
  rows=[r for r in native if r['TestResult.DisplayName'].split(' (')[0]==target]
  detected=proof['exitCode'] is not None and semantic and any(r['TestResult.Outcome']=='Failed' for r in rows) and not re.search(r'time.?out|inconclusive|resource limit',text,re.I)
  concrete=base.evm(sol,snap/'formal/abi/dynamic/DynamicOracle.t.sol',compiler,dest);result['concrete']=concrete
  accounted=sorted(concrete['expectedTests'])==sorted(concrete['passedTests']+concrete['failedTests'])
  result['status']='detected' if detected and concrete['failedTests'] and accounted else 'incomplete'
  return result
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
  for result in pool.map(check,MUTATIONS):
   report['results'].append(result);save();print(result['name'],result['status'],flush=True)
 report['sourceDrift']=any(sha(ROOT/n)!=h for n,h in baseline['sourceSha256'].items())
 report['status']='passed' if len(report['results'])==len(MUTATIONS) and all(r['status']=='detected' for r in report['results']) and not report['sourceDrift'] else 'incomplete'
 report['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
 report['evidenceSha256']={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='mutations.json'}
 save();print(report['status'])
 return 0 if report['status']=='passed' else 1


if __name__=='__main__': sys.exit(main())
