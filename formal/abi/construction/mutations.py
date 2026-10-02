#!/usr/bin/env python3
"""Check actual layout/construction source faults against proofs and the EVM."""
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
spec=importlib.util.spec_from_file_location('construction_verify',HERE/'verify.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
run,sha=base.run,base.sha
# Every replacement has the same width, preserving unrelated solc source-location
# annotations. Unsupported translation or a timeout never counts as detection.
CASES=[
 ('layout-depth','tupleLayout','depth := add(depth, 1)','depth := add(depth, 2)',1,'layout','Count','AbiLayoutCountSource.Open'),
 ('layout-comma','tupleLayout','count := add(count, 1)','count := add(count, 2)',1,'layout','Count','AbiLayoutCountSource.Comma'),
 ('layout-head','tupleLayout','plan.headSize += words * 32;','plan.headSize += words * 31;',1,'layout','Layout','AbiLayoutSource.Head'),
 ('context-index','requireValue','InvalidComponentValue(context.index, offset)','InvalidComponentValue(context.other, offset)',1,'construction','Context','AbiConstructionContext.RequireValue'),
 # Two arithmetic expressions and their adjacent explanatory comment.
 ('component-width','validateComponent','words * 32','words * 31',3,'construction','Component','AbiConstructionComponent.Component'),
 ('assembly-size','assemble','size += values[i].length - 32;','size += values[i].length - 31;',1,'construction','Assembly','AbiConstructionAssembly.Assemble'),
 ('assembly-head','assemble','head += 32;','head += 31;',1,'construction','Assembly','AbiConstructionAssembly.Assemble'),
 ('assembly-tail','assemble','tail += v.length - 32;','tail += v.length - 31;',1,'construction','Assembly','AbiConstructionAssembly.Assemble'),
 ('unpack-width','unpack','slice(encoded, p, x.words * 32)','slice(encoded, p, x.words * 31)',1,'construction','Unpack','AbiConstructionUnpack.StaticSliceWidth'),
]


def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--dafny',required=True);p.add_argument('--solc',required=True)
 p.add_argument('--baseline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 binary,solver,compiler,pin,versions,hashes=base.common.tools(a.dafny,a.solc)
 baseline=json.loads(a.baseline.read_text());assert baseline['status']=='passed'
 assert all(sha(ROOT/n)==h for n,h in baseline['sourceSha256'].items())
 assert all(sha(a.baseline.parent/n)==h for n,h in baseline['evidenceSha256'].items())
 out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);shutil.copy2(a.baseline,out/'baseline.json')
 report={'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'baselineSha256':sha(a.baseline),'versions':versions,'executableSha256':hashes,'results':[]}
 def save():(out/'mutations.json').write_text(json.dumps(report,indent=2)+'\n')
 save();source=(ROOT/'contracts/lib/AbiCodec.sol').read_text()
 def check(case):
  name,function,old,new,count,folder,module,target=case;dest=out/name;dest.mkdir()
  snap=dest/'source-snapshot';shutil.copytree(a.baseline.parent/'source-snapshot',snap)
  start=source.index('    function '+function+'(');end=source.find('\n    function ',start+1)
  if end<0:end=len(source)
  region=source[start:end];assert region.count(old)==count
  changed=source[:start]+region.replace(old,new)+source[end:]
  sol=snap/'contracts/lib/AbiCodec.sol';sol.write_text(changed)
  result={'name':name,'before':old,'after':new,'function':function,'target':target,'alteredSourceSha256':sha(sol),'status':'incomplete'}
  generated=dest/'generated'
  generation_command=[sys.executable,'-B',snap/'formal/abi'/folder/'generate.py','--solc',compiler,'--source',sol,'--output',generated]
  if name=='context-index':generation_command.append('--context-only')
  generation=run(generation_command,dest/'generate.log')
  result['generation']=generation
  if generation['exitCode']!=0:return result
  for path in generated.glob('*.dfy'):shutil.copy2(path,snap/'formal/abi'/folder/path.name)
  command=base.common.proof_command(binary,solver,pin,snap/'formal/abi'/folder/(module+'.generated.dfy'),dest/'verification.csv',target)
  command.remove('--verify-included-files')
  proof=run(command,dest/'verify.log',900);result['proof']=proof
  native=base.common.native_results(dest/'verification.csv');result['nativeResults']=native
  text=(dest/'verify.log').read_text()
  semantic=bool(re.search(r'(postcondition could not be proved|assertion might not hold|invariant could not be proved|precondition could not be proved)',text))
  rows=[row for row in native if row['TestResult.DisplayName'].split(' (')[0]==target]
  detected=proof['exitCode'] is not None and semantic and any(row['TestResult.Outcome']=='Failed' for row in rows) and not re.search(r'time.?out|inconclusive|resource limit',text,re.I)
  concrete=base.evm(sol,[snap/'formal/abi/construction/ConstructionOracle.t.sol'],compiler,dest);result['concrete']=concrete
  accounted=len(concrete['expectedTests'])==24 and sorted(concrete['expectedTests'])==sorted(concrete['passedTests']+concrete['failedTests'])
  result['status']='detected' if detected and concrete['failedTests'] and accounted else 'incomplete'
  return result
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
  for result in pool.map(check,CASES):report['results'].append(result);save();print(result['name'],result['status'],flush=True)
 report['sourceDrift']=any(sha(ROOT/n)!=h for n,h in baseline['sourceSha256'].items())
 report['status']='passed' if len(report['results'])==len(CASES) and all(r['status']=='detected' for r in report['results']) and not report['sourceDrift'] else 'incomplete'
 report['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
 report['evidenceSha256']={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='mutations.json'}
 save();print(report['status']);return 0 if report['status']=='passed' else 1

if __name__=='__main__':sys.exit(main())
