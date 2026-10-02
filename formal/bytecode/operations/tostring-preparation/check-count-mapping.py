#!/usr/bin/env python3
"""Independently compare every count macro full symbolic stack to physical receipts."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256

def check(directory):
 mapping=json.loads((HERE.parent/'tostring-controls/count.mapping.json').read_text());rows=json.loads((directory/'results.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
 paths={p['name']:p for p in mapping['paths']};states=0;macros=0
 def ev(expr,env):
  if expr.startswith('(if '):
   m=re.fullmatch(r'\(if \((.*)\)==0 then 1 else 0\)',expr);assert m,expr;return int(ev(m.group(1),env)==0)
  s=expr.replace('G.Modulus()',str(M)).replace('/','//');assert re.fullmatch(r'[a-zA-Z0-9_ +*()%/\-]+',s),s
  return eval(s,{'__builtins__':{}},env)
 for row in rows:
  if row['reason']!='Success':continue
  t=json.loads((directory/row['trace']).read_text());logs=t['trace']['structLogs'];v=t['model']['input'];mag=abs(int(t['model']['number']))
  for i,log in enumerate(logs):
   if log['pc']==5497 and mag>0:
    name='CountStart';stack=[int(x,16) for x in log['stack']];env=dict(original=mag,done=0,current=mag);prefix=stack[:-1]
   elif log['pc']==5538:
    stack=[int(x,16) for x in log['stack']];original,reserved,done,current=stack[-4:];assert reserved==96 and original==mag;env=dict(original=original,done=done,current=current);prefix=stack[:-4];name='CountTake' if current else 'CountDone'
   else:continue
   p=paths[name];memory=log['memory'];macros+=1
   for j,node in enumerate(p['nodes']):
    actual=logs[i+j];expected=prefix+[ev(e,env) for e in node['stack']];assert actual['pc']==node['pc'] and [int(x,16) for x in actual['stack']]==expected and actual['memory']==memory,(row['name'],name,j,node['pc']);states+=1
   terminal=logs[i+len(p['nodes'])];assert terminal['pc']==p['terminalPc'] and [int(x,16) for x in terminal['stack']]==prefix+[ev(e,env) for e in p['terminalStack']] and terminal['memory']==memory
 print(f'PASS{states} full symbolic count states/{macros} macros across complete unsigned/signed receipts; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);check(p.parse_args().directory)
