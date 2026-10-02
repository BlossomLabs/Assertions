import hashlib,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3];pkg=root/'formal/source/operations/concat/v1'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
rows=[]
for filename in ['Model.dfy','Connection.dfy']:
 old=root/'formal/operations/concat'/filename;new=pkg/filename
 def interfaces(p):
  s=p.read_text();out={}
  for m in re.finditer(r'(?m)^  (?:ghost )?(?:lemma|method|function|predicate)\s+(\w+)',s):
   start=m.start(); end=s.index('{',m.end());out[m[1]]=s[start:end].strip()
  return out
 oi,ni=interfaces(old),interfaces(new)
 for name,interface in oi.items():
  rows.append({'oldFile':str(old.relative_to(root)),'oldSha256':sha(old),'oldSymbol':name,'newFile':str(new.relative_to(root)),'newSha256':sha(new),'newSymbol':name,'logicalInterface':interface,'logicalInterfaceSha256':hashlib.sha256(interface.encode()).hexdigest(),'unchangedInterface':interface==ni.get(name),'status':'pending-native-closure'})
 assert oi==ni
(root/'formal/source/theorem-mapping.json').write_text(json.dumps({'scope':'Concat representative only; no proof credit until complete evidence review. All original declaration interfaces byte-identical; original CopyProjection input domain and conclusions retained. New independent total-memory lemmas are additional proved implementation arguments.','rows':rows,'generation':{'generator':'formal/operations/concat/generate.py','generatorSha256':sha(root/'formal/operations/concat/generate.py'),'mapping':'formal/source/operations/concat/v1/mapping.json','mappingSha256':sha(pkg/'mapping.json'),'sourceTemplateSha256':sha(root/'formal/operations/concat/Control.template.dfy'),'generatedSha256':sha(pkg/'Control.generated.dfy')}},indent=2)+'\n')
print(len(rows),'unchanged declaration interfaces')
