#!/usr/bin/env python3
"""Independently compare every zero/unwind state full symbolic stack to physical receipts."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256

def check(directory):
 mapping=json.loads((HERE.parent/'tostring-controls/terminal.mapping.json').read_text());rows=json.loads((directory/'results.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
 paths={p['name']:p for p in mapping['paths']};states=0;macros=0
 def ev(expr,env):
  if expr.startswith('(if '):
   m=re.fullmatch(r'\(if \((.*)\)==0 then 1 else 0\)',expr);assert m,expr;return int(ev(m.group(1),env)==0)
  s=expr.replace('|data|','size').replace('|body|','length').replace('G.Modulus()',str(M)).replace('B.Mask()',str(255*(1<<248))).replace('A.Free','Free').replace('S.Round32','Round32').replace('I.Selector','Selector').replace('I.Magnitude','Magnitude').replace('B.Cell','Cell').replace('I.Digit','Digit').replace('D.Steps','Steps').replace('true','True').replace('/','//');assert re.fullmatch(r'[a-zA-Z0-9_, +*()%/\-]+',s),s
  return eval(s,{'__builtins__':{}},env|dict(Cell=lambda x:x*(1<<248),Digit=lambda x:48+x%10,Steps=lambda x:len(str(x)) if x else 0,Free=lambda b,n:b+32+((n+31)//32)*32,Round32=lambda n:((n+31)//32)*32,Selector=lambda signed:0xa322c40e if signed else 0x6900a3ae,Magnitude=lambda w,signed:M-w if signed and w>=M//2 else w))
 for row in rows:
  if row['reason']!='Success':continue
  t=json.loads((directory/row['trace']).read_text());logs=t['trace']['structLogs'];v=t['model']['input'];mag=abs(int(t['model']['number']))
  for i,log in enumerate(logs):
   if log['pc']==5497 and mag==0:
    name='Zero';stack=[int(x,16) for x in log['stack']];assert stack[-1]==0;ret=stack[-2];prefix=stack[:-2]
   elif log['pc']==5752:
    name='Unwind';stack=[int(x,16) for x in log['stack']];ret,original,reserved,left,base,current=stack[-6:];assert original==mag and reserved==96 and left==0 and current==0;prefix=stack[:-6]
   else:continue
   p=paths[name];memory=bytes.fromhex(''.join(x.removeprefix('0x') for x in log['memory']));base=int.from_bytes(memory[64:96],'big') if name=='Zero' else base;env=dict(ret=ret,original=mag,base=base);macros+=1
   def store(mem,at,value):
    result=bytearray(mem);result.extend(b'\0'*max(0,((at+63)//32)*32-len(result)));result[at:at+32]=value.to_bytes(32,'big');return bytes(result)
   allocated=store(memory,64,base+64);header=store(allocated,base,1);initial=store(header,base+32,48*(1<<248))
   def wantedmem(expr):
    if expr=='mem':return memory
    if expr.startswith('Z.Allocated'):return allocated
    if expr.startswith('Z.Header'):return header
    if expr.startswith('Z.Initial'):return initial
    raise RuntimeError(expr)
   for j,node in enumerate(p['nodes']):
    actual=logs[i+j];expected=prefix+[ev(e,env) for e in node['stack']];assert actual['pc']==node['pc'] and [int(x,16) for x in actual['stack']]==expected and bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))==wantedmem(node['memory']),(row['name'],name,j,node['pc']);states+=1
   terminal=logs[i+len(p['nodes'])];assert terminal['pc']==ret and [int(x,16) for x in terminal['stack']]==prefix+[ev(e,env) for e in p['terminalStack']] and bytes.fromhex(''.join(x.removeprefix('0x') for x in terminal['memory']))==wantedmem(p['terminalMemory'])

 print(f'PASS{states} full symbolic zero/unwind states/{macros} macros across complete unsigned/signed receipts; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);check(p.parse_args().directory)
