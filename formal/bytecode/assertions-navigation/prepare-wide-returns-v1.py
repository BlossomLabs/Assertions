#!/usr/bin/env python3
"""Fresh physical terminal return adapters with arbitrary incoming word footprint."""
from pathlib import Path
import hashlib,json
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
rows=[]
for kind in ['limit','byte']:
 source=HERE/f'development/base-{kind}-return-v1/Character.dfy';dest=HERE/f'development/base-{kind}-return-wide-v1/Character.dfy';dest.parent.mkdir(exist_ok=False)
 old='AssertionsNavigationBase'+kind.title()+'Return';new=old+'Wide';text=source.read_text();assert text.count('module '+old+' {')==1
 text=text.replace('module '+old+' {','module '+new+' {')
 changes=[('dyn: Word,prefix:','dyn: Word,words: Word,prefix:'),(',dyn,prefix',',dyn,words,prefix'),('limit,q,dyn,1','limit,q,dyn,words'),('ret,offset,1,p','ret,offset,words,p'),('ret,dyn,1,p','ret,dyn,words,p'),('q,dyn,1','q,dyn,words')]
 counts=[]
 for a,b in changes:
  counts.append({'from':a,'to':b,'occurrences':text.count(a)});text=text.replace(a,b)
 assert ',dyn,prefix' not in text and 'dyn: Word,prefix:' not in text
 dest.write_text(text);rows.append({'source':str(source.relative_to(HERE)),'sourceSha256':sha(source),'output':str(dest.relative_to(HERE)),'outputSha256':sha(dest),'module':[old,new],'replacements':counts,'scope':'Only name-specialized incoming stack footprint1 generalized to supplied Word; actual EVM constants, branch predicates, byte guards and instruction sequence preserved.'})
out=HERE/'development/wide-return-preparation-v1';out.mkdir(exist_ok=False);(out/'generation.json').write_text(json.dumps(rows,indent=2)+'\n');print('Prepared private byte and limit return adapters')
