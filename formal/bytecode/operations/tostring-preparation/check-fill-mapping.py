#!/usr/bin/env python3
"""Independently compare every fill macro full symbolic stack to physical receipts."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256

def check(directory):
 mapping=json.loads((HERE.parent/'tostring-controls/fill.mapping.json').read_text());rows=json.loads((directory/'results.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
 paths={p['name']:p for p in mapping['paths']};states=0;macros=0
 def ev(expr,env):
  if expr.startswith('(if '):
   m=re.fullmatch(r'\(if \((.*)\)==0 then 1 else 0\)',expr);assert m,expr;return int(ev(m.group(1),env)==0)
  s=expr.replace('G.Modulus()',str(M)).replace('B.Mask()',str(255*(1<<248))).replace('B.Cell','Cell').replace('I.Digit','Digit').replace('D.Steps','Steps').replace('/','//');assert re.fullmatch(r'[a-zA-Z0-9_, +*()%/\-]+',s),s
  return eval(s,{'__builtins__':{}},env|dict(Cell=lambda x:x*(1<<248),Digit=lambda x:48+x%10,Steps=lambda x:len(str(x)) if x else 0))
 for row in rows:
  if row['reason']!='Success':continue
  t=json.loads((directory/row['trace']).read_text());logs=t['trace']['structLogs'];v=t['model']['input'];mag=abs(int(t['model']['number']))
  for i,log in enumerate(logs):
   if log['pc']!=5649:continue
   stack=[int(x,16) for x in log['stack']];original,reserved,left,base,current=stack[-5:];assert reserved==96 and original==mag;env=dict(original=original,left=left,base=base,current=current);prefix=stack[:-5];name='FillTake' if current else 'FillDone'
   p=paths[name];memory=bytes.fromhex(''.join(x.removeprefix('0x') for x in log['memory']));macros+=1
   changed=bytearray(memory)
   if current:changed[base+31+left]=48+current%10
   for j,node in enumerate(p['nodes']):
    actual=logs[i+j];expected=prefix+[ev(e,env) for e in node['stack']];assert actual['pc']==node['pc'] and [int(x,16) for x in actual['stack']]==expected and bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))==(memory if node['memory']=='mem' else changed),(row['name'],name,j,node['pc']);states+=1
   terminal=logs[i+len(p['nodes'])];assert terminal['pc']==p['terminalPc'] and [int(x,16) for x in terminal['stack']]==prefix+[ev(e,env) for e in p['terminalStack']] and bytes.fromhex(''.join(x.removeprefix('0x') for x in terminal['memory']))==(memory if p['terminalMemory']=='mem' else changed)
 print(f'PASS{states} full symbolic fill states/{macros} macros across complete unsigned/signed receipts; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);check(p.parse_args().directory)
