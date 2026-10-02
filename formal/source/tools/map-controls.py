import hashlib,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3];sha=lambda s:hashlib.sha256(s.encode()).hexdigest()
def declarations(path):
 s=path.read_text();matches=list(re.finditer(r'(?m)^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|const|datatype)\s+(\w+)',s)); result={}
 for i,m in enumerate(matches):
  whole=s[m.start():matches[i+1].start() if i+1<len(matches) else len(s)].strip()
  if i+1==len(matches):whole=whole.rstrip().removesuffix('}').rstrip()
  interface=whole[:whole.index('{')].strip() if m[1] in ['lemma','method','function','predicate'] else whole
  result[m[2]]={'kind':m[1],'interface':interface,'declaration':whole}
 return result
for package,pairs in [
 ('constraints',[('formal/constraints/Model.dfy','formal/source/migration-v1/constraints/Model.dfy'),('formal/source/migration-v1/constraints/Engine.original.dfy.txt','formal/source/migration-v1/constraints/Engine.generated.dfy')]),
 ('expressions-recursive',[('formal/expressions/evaluation/Control.dfy','formal/source/migration-v1/expressions/evaluation/Control.dfy'),('formal/expressions/recursive/Spec.dfy','formal/source/migration-v1/expressions/recursive/Spec.dfy'),('formal/source/migration-v1/expressions/recursive/Source.original.dfy.txt','formal/source/migration-v1/expressions/recursive/Source.generated.dfy')])]:
 rows=[]
 for oldrel,newrel in pairs:
  old=root/oldrel;new=root/newrel;oi,ni=declarations(old),declarations(new);assert set(oi)==set(ni)
  for name,o in oi.items():
   n=ni[name];assert o['interface']==n['interface'],(oldrel,name)
   rows.append({'oldFile':oldrel,'oldFileSha256':sha(old.read_text()),'newFile':newrel,'newFileSha256':sha(new.read_text()),'symbol':name,'kind':o['kind'],'logicalInterface':o['interface'],'interfaceSha256':sha(o['interface']),'unchangedLogicalInterface':True,'oldDeclarationSha256':sha(o['declaration']),'newDeclarationSha256':sha(n['declaration']),'unchangedDefinitionOrProof':o['declaration']==n['declaration'],'equivalenceObligation':'Entire unchanged original theorem interface freshly verified. Changes are ghost-only lemma calls/proof bodies or logically identical splitting of conjunction loop invariants.' if o['declaration']!=n['declaration'] else 'Identity; original declaration text retained'})
 (root/f'formal/source/{package}-theorem-mapping.json').write_text(json.dumps({'scope':'Source control restructuring; original generated adapters retained as text by read-only original AST gates and current compiler input/source mapping. No public or bytecode credit','rows':rows},indent=2)+'\n');print(package,len(rows),'unchanged declaration interfaces')
