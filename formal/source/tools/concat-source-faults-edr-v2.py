import argparse,json,re,shutil,subprocess,sys,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);workspace=Path.cwd();results=[]
for name,signature,old,new,symbol in [('shifted-copy-destination','function _copy(bytes memory dst','add(dst, 32)','add(dst, 33)','Copy'),('leading-delimiter','function concat(bytes[] calldata parts','if (i != 0)','if (i == 0)','Concat')]:
 root=a.output/name;shutil.copytree(a.snapshot,root);source=root/'contracts/Operations.sol';text=source.read_text();start=text.index(signature);end=text.index('\n    }',start)+6;body=text[start:end];assert body.count(old)==1;source.write_text(text[:start]+body.replace(old,new,1)+text[end:]);here=root/'formal/source/operations/concat/v1'
 commands=[('source-gate',[sys.executable,'-B',here/'generate.py','--root',root,'--solc',a.solc,'--output',root/'generated']),('proof',[a.dafny,'verify',here/'Connection.dfy','--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',a.dafny.parent/'z3/bin/z3-4.12.1','--filter-symbol','OperationsConcatSource.'+symbol,'--progress','Symbol']),('compile',[sys.executable,workspace/'formal/source/tools/compile-concat-oracle.py','--snapshot',root,'--output',root/'compiled']),('concrete',[workspace/'proof-tools/bin/node',workspace/'formal/source/tools/concat-edr-v2.mjs','--snapshot',root,'--compiled',root/'compiled/solc-output.json','--output',root/'concrete-edr'])]
 result={'name':name,'mutation':{'signature':signature,'old':old,'new':new},'checks':[]}
 for label,command in commands:
  proc=subprocess.run([str(x) for x in command],capture_output=True,text=True,timeout=240);output=proc.stdout+proc.stderr;(root/(label+'.log')).write_text(output)
  if label in ['source-gate','compile']:passed=proc.returncode==0
  elif label=='proof':passed=proc.returncode==4 and bool(re.search(r'might not hold|postcondition could not be proved|invariant could not be proved',output)) and not re.search(r'timed out|inconclusive|resource limit|parse errors|resolution/type errors',output,re.I)
  else:
   rs=json.loads((root/'concrete-edr/results.json').read_text());passed=proc.returncode==1 and len(rs['tests'])==2 and any(not t['passed'] for t in rs['tests'])
  result['checks'].append({'name':label,'command':[str(x) for x in command],'exitCode':proc.returncode,'passed':passed})
  (a.output/'progress.json').write_text(json.dumps(results+[result],indent=2)+'\n')
  assert passed,(name,label,output)
  if label=='source-gate':shutil.copy2(root/'generated/Control.generated.dfy',here/'Control.generated.dfy')
 results.append(result)
(a.output/'results.json').write_text(json.dumps({'status':'passed','engine':'Hardhat/EDR, same retained Solidity oracle','results':results},indent=2)+'\n');print('PASS two source faults translate and fail native semantics and retained EVM oracle')
