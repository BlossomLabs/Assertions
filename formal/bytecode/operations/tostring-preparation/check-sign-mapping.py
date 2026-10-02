#!/usr/bin/env python3
"""Independently compare every signed-prefix state full symbolic stack to physical receipts."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256

def check(directory):
 mapping=json.loads((HERE.parent/'tostring-controls/sign.mapping.json').read_text());rows=json.loads((directory/'results.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
 paths={p['name']:p for p in mapping['paths']};states=0;macros=0
 def ev(expr,env):
  if expr.startswith('(if '):
   m=re.fullmatch(r'\(if \((.*)\)==0 then 1 else 0\)',expr);assert m,expr;return int(ev(m.group(1),env)==0)
  s=expr.replace('|data|','size').replace('|body|','length').replace('G.Modulus()',str(M)).replace('B.Mask()',str(255*(1<<248))).replace('A.Free','Free').replace('S.Round32','Round32').replace('I.Selector','Selector').replace('I.Magnitude','Magnitude').replace('B.Cell','Cell').replace('I.Digit','Digit').replace('D.Steps','Steps').replace('true','True').replace('/','//');assert re.fullmatch(r'[a-zA-Z0-9_, +*()%/\-]+',s),s
  return eval(s,{'__builtins__':{}},env|dict(Cell=lambda x:x*(1<<248),Digit=lambda x:48+x%10,Steps=lambda x:len(str(x)) if x else 0,Free=lambda b,n:b+32+((n+31)//32)*32,Round32=lambda n:((n+31)//32)*32,Selector=lambda signed:0xa322c40e if signed else 0x6900a3ae,Magnitude=lambda w,signed:M-w if signed and w>=M//2 else w))
 for row in rows:
  if row['reason']!='Success' or row['mode']!='signed':continue
  t=json.loads((directory/row['trace']).read_text());logs=t['trace']['structLogs'];v=t['model']['input'];mag=abs(int(t['model']['number']))
  for i,log in enumerate(logs):
   if log['pc']!=2412:continue
   word=int(t['model']['input']);negative=word>=M//2;name='SignNegative' if negative else 'SignPositive';p=paths[name];env=dict(word=word);macros+=1
   memory=b'\0'*64+(128).to_bytes(32,'big')
   def store(mem,at,value):
    result=bytearray(mem);result.extend(b'\0'*max(0,((at+63)//32)*32-len(result)));result[at:at+32]=value.to_bytes(32,'big');return bytes(result)
   free=192 if negative else 160;allocated=store(memory,64,free);header=store(allocated,128,int(negative));initial=store(header,160,45*(1<<248)) if negative else header
   def wantedmem(expr):
    if expr=='K.Base()':return memory
    if expr.startswith('Q.Allocated'):return allocated
    if expr.startswith('Q.Header'):return header
    if expr.startswith('Q.Initial'):return initial
    raise RuntimeError(expr)
   for j,node in enumerate(p['nodes']):
    actual=logs[i+j];expected=[ev(e,env) for e in node['stack']];assert actual['pc']==node['pc'] and [int(x,16) for x in actual['stack']]==expected and bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))==wantedmem(node['memory']),(row['name'],name,j,node['pc']);states+=1
   terminal=logs[i+len(p['nodes'])];assert terminal['pc']==p['terminalPc'] and [int(x,16) for x in terminal['stack']]==[ev(e,env) for e in p['terminalStack']] and bytes.fromhex(''.join(x.removeprefix('0x') for x in terminal['memory']))==wantedmem(p['terminalMemory'])

 print(f'PASS{states} full symbolic sign/magnitude states/{macros} macros across complete unsigned/signed receipts; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);check(p.parse_args().directory)
