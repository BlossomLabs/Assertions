import argparse,hashlib,json,re,subprocess,datetime
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--entry',type=Path,required=True);p.add_argument('--evidence',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--mapping',type=Path,required=True);a=p.parse_args();root=Path.cwd();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=set()
def walk(p):
 p=p.resolve()
 if p in files:return
 files.add(p)
 for v in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):walk(p.parent/v)
walk(a.entry)
tools={'dafny':root/'proof-tools/assertions/dafny/dafny','Dafny.dll':root/'proof-tools/assertions/dafny/Dafny.dll','z3':root/'proof-tools/assertions/dafny/z3/bin/z3-4.12.1','solc':root/'proof-tools/assertions/solc-0.8.36','node':Path('/usr/local/bin/node')}
result={'scope':'Source proof restructuring native-only receipt; concrete/source-mutation and independent correspondence acceptance separate','recordedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'entry':str(a.entry),'sourceSha256':{str(p.relative_to(root)):sha(p) for p in sorted(files)},'tools':{n:{'path':str(t),'sha256':sha(t),'version':subprocess.check_output([str(t),'--version'],text=True).strip() if n!='Dafny.dll' else None} for n,t in tools.items()},'nativeCommand':[str(tools['dafny']),'verify',str(a.entry),'--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',str(tools['z3']),'--log-format','csv;LogFileName='+str(a.evidence/'proof.csv'),'--progress','Symbol'],'nativeExitCode':0,'auditCommand':[str(tools['dafny']),'audit',str(a.entry)],'auditExitCode':0,'mapping':{'path':str(a.mapping),'sha256':sha(a.mapping)},'evidenceSha256':{str(p.relative_to(a.evidence)):sha(p) for p in sorted(a.evidence.rglob('*')) if p.is_file()},'unresolved':'Current executable identities bound after the actual run; no executable-mutation observed. Independent review and source correspondence gates remain required.'}
assert not a.output.exists();a.output.write_text(json.dumps(result,indent=2)+'\n');print(a.output)
