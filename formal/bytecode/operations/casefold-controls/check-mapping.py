#!/usr/bin/env python3
"""Independently match all generated words and expanded bytes at every loop PC."""
import argparse,ast,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;MOD=1<<256
def store(mem,at,value):
 expanded=mem+b'\0'*max(0,((at+32+31)//32*32)-len(mem));return expanded[:at]+value.to_bytes(32,'big')+expanded[at+32:]
def copy(mem,at,src,count,data):
 if count==0:return mem
 expanded=mem+b'\0'*max(0,((at+count+31)//32*32)-len(mem));return expanded[:at]+data[src:src+count].ljust(count,b'\0')+expanded[at+count:]
def require(ok,msg):
 if not ok:raise RuntimeError(msg)
def expression(text,values):
 tree=ast.parse(text,mode='eval')
 def go(n):
  if isinstance(n,ast.Expression):return go(n.body)
  if isinstance(n,ast.Constant) and isinstance(n.value,(int,bool)):return n.value
  if isinstance(n,ast.Name):require(n.id in values,('Unknown symbol',n.id));return values[n.id]
  if isinstance(n,ast.Subscript):return go(n.value)[go(n.slice)]
  if isinstance(n,ast.BinOp):
   a,b=go(n.left),go(n.right)
   if isinstance(n.op,ast.Add):return a+b
   if isinstance(n.op,ast.Sub):return a-b
   if isinstance(n.op,ast.Mod):return a%b
   if isinstance(n.op,ast.Mult):return a*b
   if isinstance(n.op,(ast.Div,ast.FloorDiv)):return a//b
   raise RuntimeError('Unsupported arithmetic')
  if isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute) and isinstance(n.func.value,ast.Name):
   args=[go(a) for a in n.args];f=n.func.value.id+'.'+n.func.attr
   if f=='I.Selector':return 0xc1459c04 if args[0] else 0xfeec0cff
   if f=='I.Low':return 65 if args[0] else 97
   if f=='I.High':return 90 if args[0] else 122
   if f=='I.Fold':return args[1]^32 if (65 if args[0] else 97)<=args[1]<=(90 if args[0] else 122) else args[1]
   if f=='B.Cell':return args[0]<<248
   if f=='B.Mask':return 255<<248
   if f=='S.Load':return int.from_bytes(args[0][args[1]:args[1]+32].ljust(32,b'\0'),'big')
   if f=='S.Store':return store(*args)
   if f=='S.Round32':return (args[0]+31)//32*32
   if f=='C.Calldata':return copy(*args)
   if f=='K.Base':return store(b'',64,128)
   if f=='K.Free':return 160+(args[0]+31)//32*32
   if f=='K.Allocated':return store(store(b'',64,128),64,160+(args[0]+31)//32*32)
   if f=='K.Initial':
    data,off,n=args;allocated=store(store(b'',64,128),64,160+(n+31)//32*32);return store(copy(store(allocated,128,n),160,off,n,data),160+n,0)
   if f in ['Q.Head','Q.Length','Q.Payload','Q.Final']:
    mem,data,off,n,lower=args;free=160+(n+31)//32*32;head=store(mem,free,32)
    if f=='Q.Head':return head
    sized=store(head,free+32,n)
    if f=='Q.Length':return sized
    moved=copy(sized,free+64,160,n,sized)
    return moved if f=='Q.Payload' else store(moved,free+64+n,0)
   if f=='G.Modulus':return MOD
   raise RuntimeError(('Unsupported symbolic function',f))
  raise RuntimeError(('Unsupported generated expression',ast.dump(n)))
 return go(tree)
def memory(step):return bytes.fromhex(''.join(v.removeprefix('0x') for v in step['memory']))
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--mapping',type=Path,default=HERE/'controls.mapping.json');p.add_argument('--initialization',action='store_true');p.add_argument('--return-stages',action='store_true');a=p.parse_args();require(not (a.initialization and a.return_stages),'Choose one geometry');mapping=json.loads(a.mapping.read_text());paths={v['name']:v for v in mapping['paths']};rows=json.loads((a.directory/'results.json').read_text());seen=set();states=iterations=fixtures=0
 for row in rows:
  if row['reason']!='Success':continue
  receipt=json.loads((a.directory/row['trace']).read_text());require(receipt['runtimeSha256']==mapping['runtimeSha256'],'Runtime mismatch');steps=receipt['trace']['structLogs'];data=bytes.fromhex(receipt['data'][2:]);off=int(receipt['model']['offset'])+36;n=int(receipt['model']['length']);lower=row['mode']=='lower';low,high=(65,90) if lower else (97,122);at=next(i for i,s in enumerate(steps) if s['pc']==(12150 if a.initialization else 10129 if a.return_stages else 12208))
  if a.return_stages:
   path=paths['Return'];seen.add('Return');values=dict(data=data,offset=off,length=n,index=n,lower=lower,mem=memory(steps[at]))
   require(len(steps)-at==len(path['nodes']),'Missing physical RETURN')
   for i,node in enumerate(path['nodes']):
    step=steps[at+i];require(step['pc']==node['pc'],'Return PC mismatch');require([int(v,16) for v in step['stack']]==[expression(e,values) for e in node['stack']],(row['name'],i,'Return full stack mismatch'));require(memory(step)==expression(node['memory'],values),(row['name'],i,'Return full memory mismatch'));states+=1
   final=memory(steps[-1]);size,start=map(lambda v:int(v,16),steps[-1]['stack'][-2:]);body=bytes(v^32 if low<=v<=high else v for v in data[off:off+n]);canonical=(32).to_bytes(32,'big')+n.to_bytes(32,'big')+body+b'\0'*((n+31)//32*32-n);require(final[start:start+size]==canonical,'Complete final RETURN packet mismatch');fixtures+=1;continue
  if a.initialization:
   path=paths['Start'];seen.add('Start');values=dict(data=data,offset=off,length=n,index=0,lower=lower,mem=store(b'',64,128))
   for i,node in enumerate(path['nodes']):
    step=steps[at+i];require(step['pc']==node['pc'],'Initialization PC mismatch');require([int(v,16) for v in step['stack']]==[expression(e,values) for e in node['stack']],(row['name'],i,'Initialization full stack mismatch'));require(memory(step)==expression(node['memory'],values),(row['name'],i,'Initialization full memory mismatch'));states+=1
   require(steps[at+len(path['nodes'])]['pc']==12208,'Initialization endpoint mismatch');require(memory(steps[at+len(path['nodes'])])==expression('K.Initial(data,offset,length)',values),'Initialization full successor memory mismatch');fixtures+=1;continue
  for index in range(n+1):
   original=data[off+index] if index<n else 0;name='Done' if index==n else 'Below' if original<low else 'Above' if original>high else 'Fold';path=paths[name];seen.add(name);mem=memory(steps[at]);values=dict(data=data,offset=off,length=n,index=index,lower=lower,mem=mem)
   after=bytearray(mem)
   if name=='Fold':after[160+index]=original^32
   for i,node in enumerate(path['nodes']):
    step=steps[at+i];require(step['pc']==node['pc'],(row['name'],name,index,i,'PC mismatch'));require([int(v,16) for v in step['stack']]==[expression(e,values) for e in node['stack']],(row['name'],name,index,i,'Full symbolic word mismatch'))
    expected=mem
    if node['memory']!='mem':require(name=='Fold' and node['memory']=='F.Store8(mem,160+index,I.Fold(lower,data[offset+index]))','Unknown symbolic memory');expected=bytes(after)
    require(memory(step)==expected,(row['name'],name,index,i,'Full expanded memory mismatch'));states+=1
   at+=len(path['nodes']);successor=steps[at];require(successor['pc']==(10129 if name=='Done' else 12208),'Successor PC mismatch');require(memory(successor)==bytes(after),'Full successor memory mismatch')
   stack=[0xc1459c04 if lower else 0xfeec0cff,1362,off,n,96,3085,off,n,low<<248,high<<248,128,index if name=='Done' else index+1];require([int(v,16) for v in successor['stack']]==stack,'Full successor stack mismatch')
   if name!='Done':iterations+=1
  fixtures+=1
 require(seen==set(paths),'Missing exact branch');report=dict(status='prepared-no-native-credit',fixtures=fixtures,states=states,iterations=iterations,paths=sorted(seen));(a.directory/('generated-initialization-mapping.json' if a.initialization else 'generated-return-mapping.json' if a.return_stages else 'generated-body-mapping.json')).write_text(json.dumps(report,indent=2)+'\n');print('PASS case-fold complete generated stack/memory states:',states,'states,',iterations,'iterations,',fixtures,'accepted receipts; native pending')
if __name__=='__main__':main()
