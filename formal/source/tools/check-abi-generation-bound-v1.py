import hashlib,json,subprocess,sys
from pathlib import Path
r=Path.cwd();o=r/'formal/source/evidence/abi-generation-bound-v1';o.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();solc=r/'proof-tools/assertions/solc-0.8.36';wrapper=r/'proof-tools/source-smt-z3-4.12.6/bin/python';files=[Path(sys.executable).resolve(),Path('/usr/bin/python3').resolve(),solc,r/'contracts/lib/AbiCodec.sol',*sorted((r/'formal/abi').rglob('*.py')),*sorted(p for p in wrapper.parents[1].rglob('*') if p.is_file())];files=list(dict.fromkeys(files));before={str(p):sha(p) for p in files};results=[]
for package in ['aggregate','connection','descriptor','dynamic','layout','parser','shape','source','tuples','words']:
 original=r/'formal/abi'/package;output=o/package;cmd=[str(wrapper) if package=='words' else sys.executable,'-B',str(original/'generate.py'),'--source',str(r/'contracts/lib/AbiCodec.sol'),'--solc',str(solc),'--output',str(output)];proc=subprocess.run(cmd,capture_output=True,text=True);(o/(package+'.log')).write_text(proc.stdout+proc.stderr);row={'package':package,'command':cmd,'exitCode':proc.returncode,'comparisons':[]}
 if proc.returncode==0:
  for generated in sorted(output.glob('*.generated.dfy')):
   staged=r/'formal/source/migration-v4/abi'/package/generated.name
   if staged.exists():row['comparisons'].append({'generated':str(generated.relative_to(r)),'staged':str(staged.relative_to(r)),'freshSha256':sha(generated),'stagedSha256':sha(staged),'equal':generated.read_bytes()==staged.read_bytes()})
 row['passed']=proc.returncode==0 and bool(row['comparisons']) and all(x['equal'] for x in row['comparisons']);results.append(row)
after={str(p):sha(p) for p in files};receipt={'scope':'Fresh original ABI source AST adapters only, not compiler correctness or bytecode coverage','toolsAndSourcesBefore':before,'toolsAndSourcesAfter':after,'results':results,'passed':before==after and all(x['passed'] for x in results)};(o/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({'packages':len(results),'adapters':sum(len(x['comparisons']) for x in results),'passed':receipt['passed']}));sys.exit(0 if receipt['passed'] else 1)
