import hashlib,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3]
roots=['constraints','composition','arguments','signed-mod','navigation','control','resolution','core','operations','collections','expressions','abi']
files=[]
for name in roots:
 for p in sorted((root/'formal'/name).rglob('*')):
  if not p.is_file() or p.suffix not in ['.dfy','.py','.json','.md']: continue
  if any(x in p.parts for x in ['bytecode','evidence','source-snapshot','__pycache__']):continue
  data=p.read_bytes(); text=data.decode(errors='replace')
  decls=[{'kind':m[1],'name':m[2],'offset':m.start()} for m in re.finditer(r'(?m)^\s*(?:ghost\s+)?(lemma|method|function|predicate)\s+(?:\{:[^}]+\}\s*)*(\w+)',text)] if p.suffix=='.dfy' else []
  files.append({'path':str(p.relative_to(root)),'sha256':hashlib.sha256(data).hexdigest(),'declarations':decls,'classification':'template' if '.template.' in p.name else 'source-model-or-correspondence' if p.suffix=='.dfy' else 'support'})
(root/'formal/source/inventory.json').write_text(json.dumps({'scope':'Source proof inputs only; declaration inventory is not verification or acceptance. Generated adapters absent from live tree must be freshly generated from original AST gates.','roots':roots,'files':files},indent=2)+'\n')
print(len(files),'files',sum(len(x['declarations']) for x in files),'declarations')
