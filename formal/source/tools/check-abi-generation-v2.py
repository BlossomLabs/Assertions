import argparse,json,subprocess,sys,hashlib,re
from pathlib import Path
root=Path.cwd();p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();solc=root/'proof-tools/assertions/solc-0.8.36';results=[]
for package in ['aggregate','connection','descriptor','dynamic','layout','parser','shape','source','tuples']:
 original=root/'formal/abi'/package;output=a.output/package;cmd=[sys.executable,str(original/'generate.py'),'--source',str(root/'contracts/lib/AbiCodec.sol'),'--solc',str(solc),'--output',str(output)];proc=subprocess.run(cmd,capture_output=True,text=True);(a.output/(package+'.log')).write_text(proc.stdout+proc.stderr)
 row={'package':package,'command':cmd,'exitCode':proc.returncode,'generatorSha256':sha(original/'generate.py'),'comparisons':[]}
 if proc.returncode==0:
  for generated in sorted(output.glob('*.generated.dfy')):
   staged=root/'formal/source/migration-v1/abi'/package/generated.name
   if not staged.exists():continue
   row['comparisons'].append({'generated':str(generated.relative_to(root)),'staged':str(staged.relative_to(root)),'freshSha256':sha(generated),'stagedSha256':sha(staged),'equal':generated.read_bytes()==staged.read_bytes()})
 row['passed']=proc.returncode==0 and bool(row['comparisons']) and all(r['equal'] for r in row['comparisons']);results.append(row);(a.output/'results.json').write_text(json.dumps({'status':'running','results':results},indent=2)+'\n')
(a.output/'results.json').write_text(json.dumps({'status':'passed' if all(r['passed'] for r in results) else 'failed','compilerSha256':sha(solc),'results':results},indent=2)+'\n');print('PASS' if all(r['passed'] for r in results) else 'FAIL');sys.exit(0 if all(r['passed'] for r in results) else 1)
