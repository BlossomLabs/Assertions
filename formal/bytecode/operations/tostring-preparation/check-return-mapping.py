#!/usr/bin/env python3
"""Independently compare every generic serializer state full symbolic stack to physical receipts."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256

def check(directory):
 mapping=json.loads((HERE.parent/'tostring-return/return.mapping.json').read_text());rows=json.loads((directory/'results.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
 paths={p['name']:p for p in mapping['paths']};states=0;macros=0
 def ev(expr,env):
  if expr.startswith('(if '):
   m=re.fullmatch(r'\(if \((.*)\)==0 then 1 else 0\)',expr);assert m,expr;return int(ev(m.group(1),env)==0)
  s=expr.replace('|data|','size').replace('|body|','length').replace('G.Modulus()',str(M)).replace('B.Mask()',str(255*(1<<248))).replace('A.Free','Free').replace('S.Round32','Round32').replace('B.Cell','Cell').replace('I.Digit','Digit').replace('D.Steps','Steps').replace('/','//');assert re.fullmatch(r'[a-zA-Z0-9_, +*()%/\-]+',s),s
  return eval(s,{'__builtins__':{}},env|dict(Cell=lambda x:x*(1<<248),Digit=lambda x:48+x%10,Steps=lambda x:len(str(x)) if x else 0,Free=lambda b,n:b+32+((n+31)//32)*32,Round32=lambda n:((n+31)//32)*32))
 for row in rows:
  if row['reason']!='Success':continue
  t=json.loads((directory/row['trace']).read_text());logs=t['trace']['structLogs'];v=t['model']['input'];mag=abs(int(t['model']['number']))
  for i,log in enumerate(logs):
   if log['pc']!=1362:continue
   stack=[int(x,16) for x in log['stack']];assert len(stack)==2;selector,base=stack;name='Return';p=paths[name]
   memory=bytes.fromhex(''.join(x.removeprefix('0x') for x in log['memory']));free=int.from_bytes(memory[64:96],'big');length=int.from_bytes(memory[base:base+32],'big');body=memory[base+32:base+32+length];assert body==t['model']['text'].encode();env=dict(selector=selector,base=base,free=free,length=length);macros+=1
   def store(mem,at,value):
    result=bytearray(mem);result.extend(b'\0'*max(0,((at+63)//32)*32-len(result)));result[at:at+32]=value.to_bytes(32,'big');return bytes(result)
   head=store(memory,free,32);lendata=store(head,free+32,length);payload=bytearray(lendata)
   if length:payload.extend(b'\0'*max(0,((free+64+length+31)//32)*32-len(payload)));payload[free+64:free+64+length]=body
   final=store(payload,free+64+length,0)
   def wantedmem(expr):
    if expr=='mem':return memory
    if expr.startswith('Q.Head'):return head
    if expr.startswith('Q.Length'):return lendata
    if expr.startswith('Q.Payload'):return payload
    if expr.startswith('Q.Final'):return final
    raise RuntimeError(expr)
   for j,node in enumerate(p['nodes']):
    actual=logs[i+j];expected=[ev(e,env) for e in node['stack']];assert actual['pc']==node['pc'] and [int(x,16) for x in actual['stack']]==expected and bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))==wantedmem(node['memory']),(row['name'],name,j,node['pc']);states+=1
   assert i+len(p['nodes'])==len(logs) and logs[-1]['op']=='RETURN' and final[free:free+64+((length+31)//32)*32]==bytes.fromhex(row['expected'])

 print(f'PASS{states} full symbolic serializer states/{macros} macros across complete unsigned/signed receipts; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);check(p.parse_args().directory)
