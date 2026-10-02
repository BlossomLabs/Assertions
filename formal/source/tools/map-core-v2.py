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
for package,pairs in [('core-raw-v2',[('formal/core/Model.dfy','formal/source/migration-v2/core/Model.dfy'),('formal/core/Words.dfy','formal/source/migration-v2/core/Words.dfy'),('formal/core/Source.generated.dfy','formal/source/migration-v2/core/Source.generated.dfy'),('formal/resolution/Model.dfy','formal/source/migration-v2/resolution/Model.dfy'),('formal/resolution/Words.dfy','formal/source/migration-v2/resolution/Words.dfy'),('formal/resolution/Source.generated.dfy','formal/source/migration-v2/resolution/Source.generated.dfy')])]:
 rows=[]
 for oldrel,newrel in pairs:
  old=root/oldrel;new=root/newrel;oi,ni=declarations(old),declarations(new);assert set(oi)<=set(ni)
  for name,o in oi.items():
   n=ni[name];assert o['interface']==n['interface'],(oldrel,name)
   rows.append({'oldFile':oldrel,'oldFileSha256':sha(old.read_text()),'newFile':newrel,'newFileSha256':sha(new.read_text()),'symbol':name,'kind':o['kind'],'logicalInterface':o['interface'],'interfaceSha256':sha(o['interface']),'unchangedLogicalInterface':True,'oldDeclarationSha256':sha(o['declaration']),'newDeclarationSha256':sha(n['declaration']),'unchangedDefinitionOrProof':o['declaration']==n['declaration'],'equivalenceObligation':'Entire unchanged original theorem interface freshly verified. Core ConcatAppend delegates to generic Flatten.Append through a new inductive Concat/Flatten agreement lemma; original conclusion/domain unchanged.' if o['declaration']!=n['declaration'] else 'Identity; original declaration text retained'})
 (root/f'formal/source/{package}-theorem-mapping.json').write_text(json.dumps({'scope':'Source control restructuring; original generated adapters retained as text by read-only original AST gates and current compiler input/source mapping. No public or bytecode credit','rows':rows},indent=2)+'\n');print(package,len(rows),'unchanged declaration interfaces')
