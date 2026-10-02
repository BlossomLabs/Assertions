#!/usr/bin/env python3
"""Static whole-root resolution and audit, not native proof evidence."""
import argparse,datetime,hashlib,json,re,shutil,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);a=parser.parse_args()
 out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 scope=json.loads((HERE/'scope.json').read_text());selected=[ROOT/p for p in scope['selectedSources']]
 assert len(selected)==len(set(selected))==12
 closed=set()
 def visit(p):
  p=p.resolve();assert p.is_relative_to(ROOT) and p.is_file()
  if p in closed:return
  closed.add(p)
  for rel in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/rel)
 for p in selected:visit(p)
 paths=closed|{p for folder in ({p.parent for p in closed}|{HERE}) for p in folder.iterdir() if p.is_file()}
 hashes={str(p.relative_to(ROOT)):sha(p)for p in sorted(paths)}
 dafny=Path('/tmp/assertions-dafny-4.11.0/dafny/dafny');tools={'dafny':sha(dafny),'Dafny.dll':sha(dafny.parent/'Dafny.dll')}
 snap=out/'source-snapshot'
 for p in sorted(paths):
  d=snap/p.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
 m=dict(status='static-running-native-open-not-retained',startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),selectedSources=scope['selectedSources'],rootProofs=scope['rootProofs'],sourceSha256=hashes,executableSha256=tools,checks=[])
 def save():(out/'results.json').write_text(json.dumps(m,indent=2)+'\n')
 save()
 for name,args in [('format',['format','--check',*[str(snap/p.relative_to(ROOT))for p in selected]]),('resolve',['resolve',str(snap/scope['rootProofs'][0])]),('audit',['audit',str(snap/scope['rootProofs'][0])])]:
  command=[str(dafny),*args];start=time.monotonic()
  with (out/(name+'.log')).open('w')as log:code=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT).returncode
  passed=code==0 and (name!='audit' or 'auditor completed with 0 findings' in (out/(name+'.log')).read_text())
  m['checks'].append(dict(name=name,command=command,exitCode=code,passed=passed,seconds=round(time.monotonic()-start,3),log=name+'.log'));save()
  if not passed:break
 m['inputsUnchanged']=all(sha(ROOT/k)==digest and sha(snap/k)==digest for k,digest in hashes.items())
 m['toolsUnchanged']=tools=={'dafny':sha(dafny),'Dafny.dll':sha(dafny.parent/'Dafny.dll')}
 passed=len(m['checks'])==3 and all(j['passed']for j in m['checks']) and m['inputsUnchanged'] and m['toolsUnchanged']
 m.update(status='static-passed-native-open-not-retained' if passed else 'static-failed-preserved',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),nativeObligations=0,publicCoverageDelta=0)
 m['evidenceSha256']={str(p.relative_to(out)):sha(p)for p in out.rglob('*')if p.is_file()and p.name!='results.json'};save();print(m['status'],flush=True);raise SystemExit(0 if passed else 1)
if __name__=='__main__':main()
