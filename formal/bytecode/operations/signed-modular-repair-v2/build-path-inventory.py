#!/usr/bin/env python3
"""Build reviewed planning paths from independently replayed concrete receipts.

This is not a symbolic execution certificate or a universal native proof.
"""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256;H=M//2
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def classify(name,a,b,m):
 if name=='MulModS':return 0 if m==0 else (1 if m>0 else 5)+(1 if a<0 else 0)+(2 if b<0 else 0)
 if a>=0 and b>=0:return 0 if m==0 else 1 if m>0 else 2
 if a<0 and b<0:return 15 if m==0 else 16 if m>0 else 17
 if a>=0:
  return (5 if m==0 else 6 if m>0 else 8) if abs(a)>=abs(b) else (3 if m==0 else 4 if m>0 else 7)
 return (11 if m==0 else 12 if m>0 else 14) if abs(a)>=abs(b) else (9 if m==0 else 10 if m>0 else 13)
def main():
 p=argparse.ArgumentParser();p.add_argument('--physical',type=Path,required=True);p.add_argument('--output',type=Path,required=True);args=p.parse_args();physical=args.physical.resolve();out=args.output.resolve();assert not out.exists(),'Preserve previous path inventory'
 code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1].ljust(width,b'\0'),'big'));pc+=width+1
 rows=read(physical/'results.json');assert len(rows)==1476 and all(r['passed'] for r in rows);paths={};samples={}
 for row in rows:
  body=row['name'] in ['AddModS','MulModS'];index=classify(row['name'],*[int(row[k]) for k in ['a','b','modulus']]) if body else None;name=row['name']+('Case'+str(index) if body else '')
  t=read(physical/row['trace']);assert t['runtimeSha256']==digest and not t['candidate'];logs=t['trace']['structLogs'];path=tuple(s['pc'] for s in logs);assert path[0]==0 and ins[path[-1]][0] in [0xf3,0xfd] and all(s['depth']==1 for s in logs)
  if name in paths:assert paths[name]==path,'Concrete path is not uniform in its proposed guard class'
  else:paths[name]=path;samples[name]=(row,t,index)
 assert sum(n.startswith('AddModSCase') for n in paths)==18 and sum(n.startswith('MulModSCase') for n in paths)==9 and len(paths)==33
 result=[]
 for name,path in sorted(paths.items()):
  row,t,index=samples[name];required={};states=[];dests=set()
  for s in t['trace']['structLogs']:
   pc=s['pc'];op,nextpc,imm=ins[pc];assert nextpc<=len(code)
   for at in range(pc,nextpc):required[at]=code[at]
   if op in [0x56,0x57]:
    dest=int(s['stack'][-1],16);assert ins.get(dest,(None,))[0]==0x5b;dests.add(dest);required[dest]=0x5b
   states.append(dict(pc=pc,opcode=op,next=nextpc,immediate=imm))
  result.append(dict(name=name,classIndex=index,sourceFamily=row['name'],nativePredicate=('AddCase' if name.startswith('Add') else 'MulCase') if index is not None else None,sample=row['trace'],sampleSha256=sha(physical/row['trace']),sampleArguments=[row[k] for k in ['a','b','modulus']] if index is not None else [],physicalFailed=t['trace']['failed'],states=states,destinations=sorted(dests),reachedByteRequirements={str(k):v for k,v in sorted(required.items())}))
 data=dict(status='planning-only-no-native-public-credit',scope='33 observed complete compiler-bound planning paths. Every fixture maps to one proposed mathematical class; universal class/path connection, raw Frame bridge, opcode mathematics, physical serialization, all native proof declarations and retained semantic mutation remain open.',runtimeSha256=digest,runtimeBytes=len(code),inputSha256={str(p.relative_to(ROOT)):sha(p) for p in sorted(HERE.iterdir()) if p.is_file()},physicalManifest=str(physical.parent/'manifest.json'),physicalManifestSha256=sha(physical.parent/'manifest.json'),cases=result)
 out.write_text(json.dumps(data,indent=2)+'\n');print('PASS planning only:33 observed full paths bound to runtime bytes; no native/public proof credit')
if __name__=='__main__':main()
