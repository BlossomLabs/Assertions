#!/usr/bin/env python3
"""Independently match every signed concatenation stack and complete byte memory."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256

def digits(n):
 out=[]
 if n==0:return bytes([48])
 while n:out.append(48+n%10);n//=10
 return bytes(reversed(out))
def store(mem,at,value):
 out=bytearray(mem);out.extend(bytes(max(0,((at+63)//32)*32-len(out))));out[at:at+32]=value.to_bytes(32,'big');return bytes(out)
def copy(mem,dst,src,count):
 if count==0:return mem
 out=bytearray(mem);out.extend(bytes(max(0,((max(dst,src)+count+31)//32)*32-len(out))));snap=bytes(out[src:src+count]);out[dst:dst+count]=snap;return bytes(out)
def check(directory):
 mapping=json.loads((HERE.parent/'tostring-controls/concat.mapping.json').read_text());rows=json.loads((directory/'results.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest();p=mapping['paths'][0];assert len(p['nodes'])==94;states=0;macros=0
 def ev(expr,env):
  s=expr.replace('I.Selector(true)','2736964622').replace('N.Free','Base').replace('Q.Free','Free').replace('Q.Minus','Minus').replace('Q.Length','Length').replace('Q.End','End').replace('G.Modulus()',str(M));assert re.fullmatch(r'[a-zA-Z0-9_, +*()%/\-]+',s),s
  return eval(s,{'__builtins__':{}},env)
 for row in rows:
  if row['reason']!='Success' or row['mode']!='signed':continue
  t=json.loads((directory/row['trace']).read_text());logs=t['trace']['structLogs'];i=next(i for i,x in enumerate(logs) if x['pc']==7455);stack=[int(x,16) for x in logs[i]['stack']];assert stack[-6:-4]==[2736964622,1362] and stack[-3:-1]==[96,128];prefix=stack[:-6];word=stack[-4];negative=word>=M//2;mag=M-word if negative else word;body=digits(mag);minus=int(negative);base=192 if negative else 160;free=base+32+((len(body)+31)//32)*32;end=free+32+minus+len(body);assert stack[-1]==base
  mem=bytes.fromhex(''.join(x.removeprefix('0x') for x in logs[i]['memory']));assert len(mem)==free and int.from_bytes(mem[64:96],'big')==free and int.from_bytes(mem[128:160],'big')==minus and mem[160:160+minus]==(bytes([45]) if negative else b'') and int.from_bytes(mem[base:base+32],'big')==len(body) and mem[base+32:base+32+len(body)]==body
  first=copy(mem,free+32,160,minus);zero1=store(first,free+32+minus,0);second=copy(zero1,free+32+minus,base+32,len(body));zero2=store(second,end,0);header=store(zero2,free,minus+len(body));final=store(header,64,end)
  memories={'mem':mem,'Q.FirstCopy(mem,word)':first,'Q.FirstZero(mem,word)':zero1,'Q.SecondCopy(mem,word)':second,'Q.SecondZero(mem,word)':zero2,'Q.Header(mem,word)':header,'Q.Final(mem,word)':final}
  env=dict(word=word,Base=lambda w:base,Free=lambda w:free,Minus=lambda w:minus,Length=lambda w:len(body),End=lambda w:end);macros+=1
  for j,node in enumerate(p['nodes']):
   actual=logs[i+j];assert actual['pc']==node['pc'];assert code[actual['pc']]==node['opcode'];expected=prefix+[ev(e,env) for e in node['stack']];assert [int(x,16) for x in actual['stack']]==expected and bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))==memories[node['memory']],(row['name'],j,node['pc']);states+=1
  terminal=logs[i+len(p['nodes'])];assert terminal['pc']==1362 and [int(x,16) for x in terminal['stack']]==prefix+[2736964622,free] and bytes.fromhex(''.join(x.removeprefix('0x') for x in terminal['memory']))==final
  assert int.from_bytes(final[free:free+32],'big')==minus+len(body) and final[free+32:end]==(bytes([45]) if negative else b'')+body and int.from_bytes(final[64:96],'big')==end
 print(f'PASS {states} full symbolic concatenation states/{macros} complete signed fixtures; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);check(p.parse_args().directory)
