#!/usr/bin/env python3
"""Create fresh private physical [] variants without constraining prior tuple width."""
from pathlib import Path
import hashlib,json
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
changes=[('array-init-v1','array-init-wide-v1','AssertionsNavigationArrayInit','AssertionsNavigationArrayInitWide','words <= 4294967295 && ',''),('array-close-v1','array-close-wide-v1','AssertionsNavigationArrayClose','AssertionsNavigationArrayCloseWide','words <= 4294967295 && ',''),('array-empty-finish-v1','array-empty-finish-wide-v1','AssertionsNavigationArrayEmptyFinish','AssertionsNavigationArrayEmptyFinishWide','1 <= words <= 4294967295','1 <= words')]
rows=[]
for source,out,oldmodule,newmodule,old,new in changes:
 p=HERE/'development'/source/'Character.dfy';target=HERE/'development'/out/'Character.dfy';target.parent.mkdir(exist_ok=False)
 text=p.read_text();assert text.count('module '+oldmodule+' {')==1 and text.count(old)==1
 text=text.replace('module '+oldmodule+' {','module '+newmodule+' {').replace(old,new);target.write_text(text)
 rows.append({'source':str(p.relative_to(HERE)),'sourceSha256':sha(p),'output':str(target.relative_to(HERE)),'outputSha256':sha(target),'changes':{'module':[oldmodule,newmodule],'admission':[old,new]},'scope':'Old incoming footprint is an arbitrary Word; exact [] path resets it to one before the uint32 result guard. No physical byte guard or step theorem removed.'})
out=HERE/'development/wide-empty-preparation-v1';out.mkdir(exist_ok=False);(out/'generation.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(rows,indent=2))
