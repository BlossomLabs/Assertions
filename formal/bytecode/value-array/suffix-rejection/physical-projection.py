#!/usr/bin/env python3
"""Check all reached rejecting suffix guards through complete physical REVERT."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def graph(paths):
 closed=set()
 def visit(path):
  path=path.resolve();assert path.is_relative_to(ROOT)and path.is_file()
  if path in closed:return
  closed.add(path)
  for inc in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):visit(path.parent/inc)
 for path in paths:visit(path)
 return closed
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);args=ap.parse_args();out=args.output.resolve();assert not out.exists()
 scope=json.loads((HERE/'scope.json').read_text());closed=graph([ROOT/p for p in scope['selectedSources']]);paths=closed|{p for folder in {p.parent for p in closed}|{HERE}for p in folder.iterdir()if p.is_file()};hashes={str(p.relative_to(ROOT)):sha(p)for p in sorted(paths)}
 receipt=HERE.parent/'physical-descriptor-errors/development/receipts-v2';m=json.loads((receipt/'manifest.json').read_text());assert m['completedAt']and m['status']=='development-physical-passed-not-retained'and m['concreteFixtures']==60
 assert m['inputsUnchanged']and m['concreteToolsUnchanged']and all(c['passed']and c['exitCode']==0 for c in m['checks'])
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(receipt/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(receipt/p)==h
 tools=m['concreteToolchain']
 for key in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[key]))==tools[key+'Sha256']
 assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256']and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
 pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==pin
 modes=['AtLimit','WrongClose','Wide','Zero'];maps={mode:json.loads((HERE/(mode+'.mapping.json')).read_text())for mode in modes}
 for mapping in maps.values():assert mapping['runtimeSha256']==pin and all(code[int(pc)]==v for pc,v in mapping['requiredBytes'].items())
 memory=lambda row:bytes.fromhex(''.join(w.removeprefix('0x')for w in row['memory']));stack=lambda row:[int(v,16)for v in row['stack']]
 def store(data,offset,value):
  n=max(len(data),((offset+32+31)//32)*32);result=bytearray(data+b'\0'*(n-len(data)));result[offset:offset+32]=value.to_bytes(32,'big');return bytes(result)
 fixtures=[];counts={mode:0 for mode in modes};steps={mode:0 for mode in modes};operations={mode:set()for mode in modes}
 for file in sorted((receipt/'evm-traces').glob('*.json')):
  doc=json.loads(file.read_text())
  if 'trace'not in doc:continue
  f=doc['fixture'];trace=doc['trace'];logs=trace['structLogs'];data=bytes.fromhex(f['data'][2:]);assert doc['runtimeSha256']==pin and logs[0]['pc']==0 and trace['failed']and trace['returnValue'].removeprefix('0x')==f['expected'];rows=[]
  for i,row in enumerate(logs):
   if row['pc']!=14481:continue
   s=stack(row);prefix=s[:-10];ret,off,length,p,limit,end,dyn,words,q,k=s[-10:];assert off<2**64 and end<q<2**64 and limit<=length<2**64
   b=data[off+q]if off+q<len(data)else 0
   mode='AtLimit'if q>=limit else'WrongClose'if b!=93 else'Wide'if k>0xffffffff or words>0xffffffff else'Zero'if k==0 and q!=end+1 else None
   if mode is None:continue
   mapping=maps[mode];initial=memory(row);assert len(initial)%32==0 and len(initial)>=96;fp=int.from_bytes(initial[64:96],'big');assert fp>=96 and fp+64<2**256
   fields=dict(returnPc=ret,descriptorOffset=off,descriptorLength=length,p=p,limit=limit,end=end,dyn=dyn,words=words,q=q,k=k,b=b,fp=fp);first=store(initial,fp,int(mapping['errorSelector'],16)<<224);complete=store(first,fp+4,q)
   def evaluate(expr):
    if expr.isdecimal():return int(expr)
    if expr in fields:return fields[expr]
    if expr=='descriptorOffset+q':return off+q
    if expr=='DataWord(data,descriptorOffset+q)':return int.from_bytes((data[off+q:off+q+32]+b'\0'*32)[:32],'big')
    if expr=='G.BitOr(words,k)':return words|k
    if expr=='end+1':return end+1
    if expr=='fp+4':return fp+4
    if expr=='fp+36':return fp+36
    raise AssertionError(('unknown exact expression',expr))
   for j,state in enumerate(mapping['states']):
    y=logs[i+j];assert y['depth']==1 and y['pc']==state['pc'],(f['name'],mode,j,'PC');assert stack(y)==prefix+[evaluate(v)for v in state['stack']],(f['name'],mode,j,'full stack');expected=initial if state['memory']=='mem'else first if state['memory']=='H.First(mem,fp)'else complete if state['memory']=='H.Complete(mem,fp,q)'else None;assert expected is not None and memory(y)==expected,(f['name'],mode,j,'full memory')
   j=i+len(mapping['states']);assert j==len(logs)and logs[-1]['op']=='REVERT';packet=bytes.fromhex(mapping['errorSelector'])+q.to_bytes(32,'big');assert complete[fp:fp+36]==packet and trace['returnValue'].removeprefix('0x')==packet.hex()==f['expected']and f['position']==q
   rows.append(dict(mode=mode,startIndex=i,endIndex=j,completeInstructions=j-i,prefixWords=len(prefix),position=q,opening=end,currentWords=words,lengthNumber=k));counts[mode]+=1;steps[mode]+=j-i;operations[mode].add(f['operation'])
  fixtures.append(dict(name=f['name'],trace=str(file.relative_to(ROOT)),traceSha256=sha(file),calls=rows))
 assert len(fixtures)==60 and counts==dict(AtLimit=4,WrongClose=6,Wide=8,Zero=6)and all(v=={'packArray','unpackArray'}for v in operations.values())
 assert all(sha(ROOT/p)==h for p,h in hashes.items());out.mkdir(parents=True);result=dict(status='development-physical-complete-suffix-rejections-passed-not-retained',historicalManifest=str((receipt/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(receipt/'manifest.json'),runtimeSha256=pin,sourceSha256=hashes,inputsUnchanged=True,fixtureCount=len(fixtures),checkedCompleteRejections=sum(counts.values()),byRejection=counts,checkedSpanInstructions=steps,fixtures=fixtures,scope='All 24 reached rejecting suffix guards among 60 complete PC-zero EVM error receipts, four independently classified cursor/byte/mathematical overflow/nonempty-zero cases, exact full actual PC/lower stack/physical memory through exact complete InvalidTypeDescriptor(q). Preceding footprint calculation and recursive rejecting parser/raw codec/native/fault/retention connections remain open. No public credit.');(out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],counts,steps)
if __name__=='__main__':main()
