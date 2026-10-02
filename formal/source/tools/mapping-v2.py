"""Conservative source migration mapping. Body helper is not a certified Dafny parser."""
import argparse,hashlib,importlib.util,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3];helper=root/'scripts/dafny_declaration_body.py';spec=importlib.util.spec_from_file_location('body',helper);body=importlib.util.module_from_spec(spec);spec.loader.exec_module(body)
sha=lambda s:hashlib.sha256(s.encode()).hexdigest()
def declarations(path):
 text=path.read_text();masked=body.mask_literals_and_comments(text);pattern=r'(?m)^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|const|datatype|type)(?: \{:[^}]+\})* (\w+)';matches=list(re.finditer(pattern,masked));out={}
 for i,m in enumerate(matches):
  segment=text[m.start():matches[i+1].start() if i+1<len(matches) else len(text)].strip()
  if i+1==len(matches):
   maskedsegment=body.mask_literals_and_comments(segment);last=maskedsegment.rstrip().rfind('}');assert last>=0 and not maskedsegment[last+1:].strip();segment=(segment[:last]+segment[last+1:]).rstrip()
  if m[1] in ['lemma','method','function','predicate']:interface,proofbody=body.split_body(segment)
  else:interface=segment;proofbody=None
  assert m[2] not in out,'Multiple declarations named '+m[2]
  out[m[2]]={'kind':m[1],'interface':interface,'full':segment,'body':proofbody}
 return out
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--mapping',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();old=json.loads(a.mapping.read_text());pairs=sorted({(r['oldFile'],r['newFile']) for r in old['rows']});rows=[]
 for oldrel,newrel in pairs:
  op=root/oldrel;np=root/newrel;od,nd=declarations(op),declarations(np);assert set(od)<=set(nd),(oldrel,set(od)-set(nd))
  for name,d in od.items():
   n=nd[name];assert d['kind']==n['kind'];assert d['interface']==n['interface'],('Logical domain/conclusion changed',oldrel,name,d['interface'],n['interface'])
   rows.append({'oldFile':oldrel,'oldFileSha256':hashlib.sha256(op.read_bytes()).hexdigest(),'newFile':newrel,'newFileSha256':hashlib.sha256(np.read_bytes()).hexdigest(),'symbol':name,'kind':d['kind'],'originalLogicalInterface':d['interface'],'logicalInterfaceSha256':sha(d['interface']),'unchangedLogicalInterface':True,'oldDeclarationSha256':sha(d['full']),'newDeclarationSha256':sha(n['full']),'unchangedFullDeclaration':d['full']==n['full'],'oldBodySha256':sha(d['body']) if d['body'] else None,'newBodySha256':sha(n['body']) if n['body'] else None})
 result={'scope':'Source-only refactor; complete original interfaces extracted conservatively including attributes/set-literal contracts. Exact definitions and bodies hashed; changed proof bodies require independent semantic diff/native review. No bytecode credit.','helper':{'path':str(helper.relative_to(root)),'sha256':hashlib.sha256(helper.read_bytes()).hexdigest()},'previousMapping':{'path':str(a.mapping),'sha256':hashlib.sha256(a.mapping.read_bytes()).hexdigest()},'rows':rows};assert not a.output.exists();a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS',len(rows),'complete logical interfaces')
