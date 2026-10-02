import hashlib,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3];base=root/'formal/source/migration-v1';rows=[]
sha=lambda s:hashlib.sha256(s.encode()).hexdigest()
def declarations(path):
 s=path.read_text();matches=list(re.finditer(r'(?m)^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|const|datatype)\s+(\w+)',s)); result={}
 for i,m in enumerate(matches):
  whole=s[m.start():matches[i+1].start() if i+1<len(matches) else len(s)].strip()
  if i+1==len(matches):whole=whole.rstrip().removesuffix('}').rstrip()
  if m[1] in ['lemma','method','function','predicate']:interface=whole[:whole.index('{')].strip()
  else:interface=whole
  result[m[2]]={'kind':m[1],'interface':interface,'declaration':whole}
 return result
for pkg in ['collections/word-memory']:
 for new in sorted((base/pkg).glob('*.dfy')):
  if '.template.' in new.name:continue
  old=root/'formal'/pkg/new.name
  if not old.exists():continue
  oi,ni=declarations(old),declarations(new)
  assert set(oi)==set(ni),(old,set(oi)^set(ni))
  for name,o in oi.items():
   n=ni[name];assert o['interface']==n['interface'],(old,name)
   rows.append({'oldFile':str(old.relative_to(root)),'oldFileSha256':sha(old.read_text()),'newFile':str(new.relative_to(root)),'newFileSha256':sha(new.read_text()),'symbol':name,'kind':o['kind'],'unchangedLogicalInterface':True,'logicalInterface':o['interface'],'interfaceSha256':sha(o['interface']),'oldDeclarationSha256':sha(o['declaration']),'newDeclarationSha256':sha(n['declaration']),'unchangedDefinitionOrProof':o['declaration']==n['declaration'],'equivalenceObligation':'Original Slice/Outside requires and ensures freshly proved by generic sequence lemmas with exact original Store representation' if o['declaration']!=n['declaration'] else 'Identity; entire original declaration text retained'})
(root/'formal/source/word-memory-theorem-mapping.json').write_text(json.dumps({'status':'complete native mapping; source correspondence gates pending','rows':rows},indent=2)+'\n');print(len(rows),'mapped declarations')
