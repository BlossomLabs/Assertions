#!/usr/bin/env python3
"""Match exact loop entries/successors and original-byte prefix memory independently."""
import argparse,json
from pathlib import Path
def require(ok,msg):
 if not ok:raise RuntimeError(msg)
def memory(step):return bytes.fromhex(''.join(v.removeprefix('0x') for v in step['memory']))
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);a=p.parse_args();rows=json.loads((a.directory/'results.json').read_text());seen={};iterations=entries=fixtures=0
 for row in rows:
  if row['reason']!='Success':continue
  d=json.loads((a.directory/row['trace']).read_text());steps=d['trace']['structLogs'];data=bytes.fromhex(d['data'][2:]);off=int(d['model']['offset'])+36;length=int(d['model']['length']);lower=row['mode']=='lower';low,high=(65,90) if lower else (97,122);selector=0xc1459c04 if lower else 0xfeec0cff;original=data[off:off+length];payload=bytearray(original);roundn=(length+31)//32*32;size=192+roundn;free=160+roundn
  starts=[i for i,s in enumerate(steps) if s['pc']==12208];require(len(starts)==length+1,'Missing finite loop iterations')
  def wantmem():return b'\0'*64+free.to_bytes(32,'big')+b'\0'*32+length.to_bytes(32,'big')+bytes(payload)+b'\0'*(size-160-length)
  for index,at in enumerate(starts):
   step=steps[at];prefix=[selector,1362,off,length,96,3085,off,length,low<<248,high<<248,128,index];require([int(v,16) for v in step['stack']]==prefix and memory(step)==wantmem(),(row['name'],index,'Complete physical loop invariant mismatch'));entries+=1
   stop=starts[index+1] if index<length else next(i for i in range(at,len(steps)) if steps[i]['pc']==10129)
   name='Done' if index==length else 'Below' if original[index]<low else 'Above' if original[index]>high else 'Fold';path=tuple(s['pc'] for s in steps[at:stop]);require(name not in seen or seen[name]==path,'More than four claimed exact loop geometries');seen[name]=path
   if name=='Fold':payload[index]^=32
   successor=steps[stop];require(memory(successor)==wantmem(),(row['name'],name,index,'Complete successor memory mismatch'))
   if index<length:require([int(v,16) for v in successor['stack']]==prefix[:-1]+[index+1],'Physical loop successor stack mismatch');iterations+=1
   else:require([int(v,16) for v in successor['stack']]==prefix,'Physical exit stack mismatch')
  fixtures+=1
 require(set(seen)=={'Done','Below','Above','Fold'},'Missing loop branch geometry');report=dict(status='physical-preparation-only-no-native-credit',fixtures=fixtures,loopEntries=entries,iterations=iterations,paths={name:list(path) for name,path in sorted(seen.items())});(a.directory/'loop-mapping.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS4 complete case-fold loop geometries:',fixtures,'accepted fixtures,',iterations,'physical iterations,',entries,'whole stack/memory invariant entries;', {name:len(path) for name,path in seen.items()},'; native proof pending')
if __name__=='__main__':main()
