import csv,hashlib,json,re,argparse
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--entry',type=Path,required=True);p.add_argument('--evidence',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
seen=set()
def walk(path):
 path=path.resolve()
 if path in seen:return
 seen.add(path)
 for s in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):walk(path.parent/s)
walk(a.entry);decls=[]
for path in sorted(seen):
 text=path.read_text(); module=re.search(r'^module (\w+)',text,re.M)[1]
 for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|const|type|datatype)(?: \{:[^}]+\})* (\w+)',text,re.M):decls.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
rows=list(csv.DictReader((a.evidence/'proof.csv').open()));names={r['TestResult.DisplayName'].split(' (')[0] for r in rows}
for d in decls:
 d['batches']=sum(r['TestResult.DisplayName'].split(' (')[0]==d['name'] for r in rows)
 if d['kind'] in ['lemma','method']:assert d['batches']>0,d
assert names<={d['name'] for d in decls}, names-{d['name'] for d in decls}
assert all(r['TestResult.Outcome']=='Passed' for r in rows)
text=(a.evidence/'proof.log').read_text();m=re.search(r'finished with (\d+) verified, (\d+) errors',text);assert m and int(m[1])==len(rows) and int(m[2])==0
assert not re.search(r'Error:|timed out|inconclusive',text,re.I)
assert 'auditor completed with 0 findings' in (a.evidence/'audit.log').read_text()
a.output.write_text(json.dumps({'status':'passed','closureFiles':len(seen),'declarations':decls,'nativeBatches':len(rows),'definitionsWithoutBatches':[d['name'] for d in decls if not d['batches']]},indent=2)+'\n');print('PASS',len(decls),'declarations',len(rows),'batches')
