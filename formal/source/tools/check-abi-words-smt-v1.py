import json,hashlib,subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
r=Path.cwd();g=r/'formal/source/evidence/abi-words-generation-v1/generated';o=r/'formal/source/evidence/abi-words-smt-v1';o.mkdir(exist_ok=False);z=r/'proof-tools/assertions/dafny/z3/bin/z3-4.12.1';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();files=[z,*sorted(g.glob('*.smt2')),g/'queries.json'];before={str(p):sha(p) for p in files}
def run(q):
 p=g/(q['name']+'.smt2');cmd=[str(z),str(p)];s=subprocess.run(cmd,capture_output=True,text=True,timeout=40);(o/(q['name']+'.log')).write_text(s.stdout+s.stderr);return {'name':q['name'],'command':cmd,'exitCode':s.returncode,'result':s.stdout.strip(),'passed':s.returncode==0 and s.stdout.strip()=='unsat'}
with ThreadPoolExecutor(max_workers=2) as pool:rows=list(pool.map(run,json.loads((g/'queries.json').read_text())))
after={str(p):sha(p) for p in files};receipt={'results':rows,'before':before,'after':after,'passed':before==after and all(x['passed'] for x in rows)};(o/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({'queries':len(rows),'passed':receipt['passed']}))
