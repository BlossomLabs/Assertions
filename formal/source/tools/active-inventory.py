import hashlib,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
roots=['constraints','composition','arguments','signed-mod','navigation','control','resolution','core','operations','collections','expressions','abi']
files=[];packages={}
for name in roots:
 base=root/'formal'/name
 for p in sorted(base.rglob('*')):
  if not p.is_file() or p.suffix not in ['.dfy','.py','.json','.md']:continue
  parts=p.relative_to(base).parts
  if any(x in parts for x in ['development','evidence','bytecode','source-snapshot','candidate','retained','__pycache__']):continue
  if any(re.search(r'(?:^|-)v\d+$',x) for x in parts[:-1]):continue
  if len(parts)>3:continue
  rel=str(p.relative_to(root));text=p.read_text();kind='template' if '.template.' in p.name else 'live-source' if p.suffix=='.dfy' else 'support'
  ds=[{'kind':m[1],'name':m[2],'status':'unmigrated'} for m in re.finditer(r'(?m)^\s*(?:ghost\s+)?(lemma|method|function|predicate)\s+(?:\{:[^}]+\}\s*)*(\w+)',text)] if kind=='live-source' else []
  key=str(p.parent.relative_to(root));packages.setdefault(key,{'files':[],'status':'unmigrated','generatedAdapters':[]})['files'].append(rel)
  files.append({'path':rel,'sha256':sha(p),'classification':kind,'declarations':ds})
ledgers=[]
for p in sorted((root/'docs/verification').glob('*.json')):
 if not re.search(r'source|connection',p.name,re.I):continue
 j=json.loads(p.read_text()); refs=re.findall(r'formal/[^"\s]+',p.read_text())
 ledgers.append({'path':str(p.relative_to(root)),'sha256':sha(p),'scope':j.get('scope'),'references':refs,'status':'retained-original-not-recertified'})
for p in packages:
 packages[p]['generatedAdapters']=[f.replace('.template.','.generated.') for f in packages[p]['files'] if '.template.' in f]
out={'scope':'Current conventional source package roots, excluded development/evidence/candidate/version histories; complete active selection still requires ledger-reference resolution, generated adapters and imported closure reconciliation. Not verification credit.','packages':packages,'files':files,'sourceCorrespondenceLedgers':ledgers,'migration':'Every old proof remains immutable; map statuses record pending work explicitly.'}
(root/'formal/source/active-inventory.json').write_text(json.dumps(out,indent=2)+'\n');print(len(packages),'packages',len(files),'files',sum(len(x['declarations']) for x in files),'live declarations',len(ledgers),'ledgers')
