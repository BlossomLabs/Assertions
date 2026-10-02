import hashlib,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3];inventory=json.loads((root/'formal/source/active-inventory.json').read_text());rows=[]
for file in inventory['files']:
 if file['classification']!='live-source':continue
 p=root/file['path'];text=p.read_text();module=re.search(r'(?m)^module (\w+)',text)
 for match in re.finditer(r'(?m)^\s*(?:(?:ghost|opaque)\s+)*(lemma|method|function|predicate)\s+(?:\{:[^}]+\}\s*)*(\w+)',text):
  end=text.find('{',match.end()); interface=text[match.start():end].strip() if end>=0 else None
  rows.append({'oldFile':file['path'],'oldFileSha256':file['sha256'],'oldModule':module[1] if module else None,'oldSymbol':match[2],'kind':match[1],'originalInterface':interface,'originalInterfaceSha256':hashlib.sha256(interface.encode()).hexdigest() if interface else None,'plannedNewFile':file['path'].replace('formal/','formal/source/migration-v1/',1),'status':'pending-semantic-preserving-migration','equivalenceObligation':'Retain complete original input domain, assumptions and conclusions; verify full native import/declaration closure and reviewed source execution correspondence','coverageCredit':False})
result={'scope':'All candidate conventional active source declarations across four contracts and shared dependencies. This is a migration plan; interfaces use a lexical candidate extractor and require reviewed reconciliation, never assumed proof equivalence. Historical evidence and generated execution adapters separately catalogued in active-inventory.json.','rows':rows,'completedRepresentativeMappings':['formal/source/theorem-mapping.json','formal/source/replace-suite-theorem-mapping.json','formal/source/word-memory-theorem-mapping.json']}
(root/'formal/source/migration-plan.json').write_text(json.dumps(result,indent=2)+'\n');print(len(rows),'pending/representative declaration migration targets')
