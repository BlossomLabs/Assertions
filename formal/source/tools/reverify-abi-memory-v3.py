import argparse,csv,datetime,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
root=Path.cwd();p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
tools={'dafny':root/'proof-tools/assertions/dafny/dafny','Dafny.dll':root/'proof-tools/assertions/dafny/Dafny.dll','z3':root/'proof-tools/assertions/dafny/z3/bin/z3-4.12.1','solc':root/'proof-tools/assertions/solc-0.8.36','node':Path('/usr/local/bin/node')}
entries=[('abi-memory','formal/source/migration-v4/abi/construction/Memory.dfy')]
manifest={'status':'running','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Source-only restructured closures; native module/declaration verification is not source or exact-bytecode entry acceptance','checks':[],'toolsBefore':{k:sha(v) for k,v in tools.items()},'versionsBefore':{k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in tools.items() if k!='Dafny.dll'}}
def save():(a.output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
save()
for name,relative in entries:
 entry=root/relative;seen=set()
 def walk(p):
  p=p.resolve()
  if p in seen:return
  seen.add(p);assert p.is_relative_to(root/'formal/source')
  for v in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):walk(p.parent/v)
 walk(entry);out=a.output/name;out.mkdir();snap=out/'snapshot';sourceBefore={str(p.relative_to(root)):sha(p) for p in sorted(seen)}
 for path in seen:
  dest=snap/path.relative_to(root);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
 actual=snap/relative;csvpath=out/'proof.csv';commands=[('proof',[tools['dafny'],'verify',actual,'--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',tools['z3'],'--log-format','csv;LogFileName='+str(csvpath),'--progress','Symbol']),('audit',[tools['dafny'],'audit',actual]),('format',[tools['dafny'],'format','--check']+[snap/p.relative_to(root) for p in sorted(seen)])]
 item={'name':name,'entry':relative,'sourceBefore':sourceBefore,'checks':[]};manifest['checks'].append(item);save()
 for label,command in commands:
  with (out/(label+'.log')).open('w') as log:proc=subprocess.run([str(x) for x in command],stdout=log,stderr=subprocess.STDOUT)
  passed=proc.returncode==0
  if label=='proof':
   rows=list(csv.DictReader(csvpath.open())) if csvpath.exists() else [];text=(out/'proof.log').read_text();m=re.search(r'finished with (\d+) verified, (\d+) errors',text);passed=passed and bool(rows) and all(r['TestResult.Outcome']=='Passed' for r in rows) and m is not None and int(m[1])==len(rows) and int(m[2])==0 and not re.search(r'Error:|timed out|inconclusive',text,re.I);item['nativeBatches']=len(rows)
  if label=='audit':passed=passed and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
  item['checks'].append({'name':label,'command':[str(x) for x in command],'exitCode':proc.returncode,'passed':passed});save()
 item['sourceAfter']={str(p.relative_to(root)):sha(p) for p in sorted(seen)};item['toolsAfter']={k:sha(v) for k,v in tools.items()};item['passed']=all(x['passed'] for x in item['checks']) and sourceBefore==item['sourceAfter'] and item['toolsAfter']==manifest['toolsBefore'];save()
 if not item['passed']:manifest['status']='failed';save();sys.exit(1)
manifest['status']='passed';manifest['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();manifest['evidenceSha256']={str(p.relative_to(a.output)):sha(p) for p in sorted(a.output.rglob('*')) if p.is_file() and p!=a.output/'manifest.json'};save();print('PASS ABI memory source-only native closure with before/after source/tool identities')
