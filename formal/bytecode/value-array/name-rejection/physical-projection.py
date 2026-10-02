#!/usr/bin/env python3
"""Check complete invalid-name parser paths against independent first-byte rules."""
import argparse, hashlib, json, re
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MOD = 1 << 256
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def graph(paths):
 closed = set()
 def visit(path):
  path = path.resolve(); assert path.is_relative_to(ROOT) and path.is_file()
  if path in closed: return
  closed.add(path)
  for inc in re.findall(r'^include "([^"]+)"', path.read_text(), re.M): visit(path.parent/inc)
 for path in paths: visit(path)
 return closed
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);args=ap.parse_args();out=args.output.resolve();assert not out.exists()
 scope=json.loads((HERE/'scope.json').read_text());closed=graph([ROOT/p for p in scope['selectedSources']]);folders={p.parent for p in closed}|{HERE};paths=closed|{p for folder in folders for p in folder.iterdir()if p.is_file()};hashes={str(p.relative_to(ROOT)):sha(p)for p in sorted(paths)}
 receipt=HERE.parent/'physical-descriptor-errors/development/receipts-v2';m=json.loads((receipt/'manifest.json').read_text());assert m['completedAt']and m['status']=='development-physical-passed-not-retained'and m['concreteFixtures']==60
 assert m['inputsUnchanged']and m['concreteToolsUnchanged']and all(c['passed']and c['exitCode']==0 for c in m['checks'])
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(receipt/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(receipt/p)==h
 tools=m['concreteToolchain']
 for key in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[key]))==tools[key+'Sha256']
 assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256']and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
 pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==pin
 names={'invocation':'type-name-invocation/Invocation.mapping.json','cleanup':'named-type/Cleanup.mapping.json','error':'descriptor-error-foundation/NameEmpty.mapping.json',**{mode:'name-scanner-v2/'+mode+'.mapping.json'for mode in ['OtherLow','OtherMid','OtherHigh']}}
 maps={name:json.loads((HERE.parent/p).read_text())for name,p in names.items()}
 for mapping in maps.values():assert mapping['runtimeSha256']==pin and all(code[int(pc)]==v for pc,v in mapping['requiredBytes'].items())
 assert code[19245]==91 and code[19246]==129
 memory=lambda row:bytes.fromhex(''.join(w.removeprefix('0x')for w in row['memory']));stack=lambda row:[int(v,16)for v in row['stack']]
 def store(data,offset,value):
  n=max(len(data),((offset+32+31)//32)*32);result=bytearray(data+b'\0'*(n-len(data)));result[offset:offset+32]=value.to_bytes(32,'big');return bytes(result)
 fixtures=[];calls=steps=0;operations=set();byBranch={mode:0 for mode in ['OtherLow','OtherMid','OtherHigh']}
 for file in sorted((receipt/'evm-traces').glob('*.json')):
  doc=json.loads(file.read_text())
  if 'trace'not in doc:continue
  f=doc['fixture'];trace=doc['trace'];logs=trace['structLogs'];data=bytes.fromhex(f['data'][2:]);assert doc['runtimeSha256']==pin and logs[0]['pc']==0 and trace['failed']and trace['returnValue'].removeprefix('0x')==f['expected'];rows=[]
  for i,row in enumerate(logs):
   if row['pc']!=13839:continue
   s=stack(row);prefix=s[:-5];ret,offset,length,p,limit=s[-5:];assert offset<2**64 and limit<=length<2**64
   if p>=limit:continue
   b=data[offset+p]if offset+p<len(data)else 0
   if b==40 or 48<=b<58 or 97<=b<123:continue
   assert len(prefix)<=1004;initial=memory(row);assert len(initial)%32==0 and len(initial)>=96;fp=int.from_bytes(initial[64:96],'big');assert fp>=96 and fp+64<MOD
   fields=dict(returnPc=ret,descriptorOffset=offset,descriptorLength=length,p=p,limit=limit,q=p,b=b,fp=fp)
   def evaluate(expr,values):
    if expr.isdecimal():return int(expr)
    if expr in values:return values[expr]
    if expr in ['descriptorOffset+p','descriptorOffset+q']:return offset+p
    if expr in ['DataWord(data,descriptorOffset+p)','DataWord(data,descriptorOffset+q)']:return int.from_bytes((data[offset+p:offset+p+32]+b'\0'*32)[:32],'big')
    if expr=='G.Modulus()-40':return MOD-40
    if expr=='((G.Modulus()-40+b)%G.Modulus())':return (MOD-40+b)%MOD
    if expr=='fp+4':return fp+4
    if expr=='fp+36':return fp+36
    raise AssertionError(('unknown exact expression',expr))
   def compare(j,mapping,base,values):
    for k,state in enumerate(mapping['states']):
     y=logs[j+k];assert y['depth']==1 and y['pc']==state['pc'],(f['name'],j+k,'PC');assert stack(y)==base+[evaluate(v,values)for v in state['stack']],(f['name'],j+k,'full stack');assert memory(y)==initial,(f['name'],j+k,'full memory')
    return j+len(mapping['states'])
   j=compare(i,maps['invocation'],prefix,fields);scannerPrefix=prefix+[ret,offset,length,p,limit,0,0,0,0];scanfields=fields|{'returnPc':14157}
   for pc,extra in [(19245,[]),(19246,[])]:
    y=logs[j];assert y['pc']==pc and stack(y)==scannerPrefix+[14157,offset,length,p,limit]and memory(y)==initial;j+=1
   mode='OtherLow'if b<48 else'OtherMid'if b<97 else'OtherHigh';j=compare(j,maps[mode],scannerPrefix,scanfields);j=compare(j,maps['cleanup'],scannerPrefix,scanfields)
   mapping=maps['error'];header=int(mapping['errorSelector'],16)<<224;first=store(initial,fp,header);complete=store(first,fp+4,p)
   for k,state in enumerate(mapping['states']):
    y=logs[j+k];assert y['depth']==1 and y['pc']==state['pc'],(f['name'],j+k,'error PC');assert stack(y)==prefix+[evaluate(v,fields)for v in state['stack']],(f['name'],j+k,'error full stack');expected=initial if state['memory']=='mem'else first if state['memory']=='H.First(mem,fp)'else complete if state['memory']=='H.Complete(mem,fp,p)'else None;assert expected is not None and memory(y)==expected,(f['name'],j+k,'error full memory')
   j+=len(mapping['states']);assert j==len(logs)and logs[-1]['op']=='REVERT';packet=bytes.fromhex(mapping['errorSelector'])+p.to_bytes(32,'big');assert complete[fp:fp+36]==packet and trace['returnValue'].removeprefix('0x')==packet.hex()==f['expected']and f['position']==p
   rows.append(dict(startIndex=i,endIndex=j,completeInstructions=j-i,prefixWords=len(prefix),position=p,invalidFirstByte=b,scannerBranch=mode));calls+=1;steps+=j-i;operations.add(f['operation']);byBranch[mode]+=1
  fixtures.append(dict(name=f['name'],trace=str(file.relative_to(ROOT)),traceSha256=sha(file),calls=rows))
 assert len(fixtures)==60 and calls==20 and operations=={'packArray','unpackArray'}and byBranch['OtherLow']and byBranch['OtherMid']
 assert all(sha(ROOT/p)==h for p,h in hashes.items());out.mkdir(parents=True);result=dict(status='development-physical-complete-invalid-name-rejections-passed-not-retained',historicalManifest=str((receipt/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(receipt/'manifest.json'),runtimeSha256=pin,sourceSha256=hashes,inputsUnchanged=True,fixtureCount=len(fixtures),checkedCompleteRejections=calls,checkedSpanInstructions=steps,byScannerBranch=byBranch,fixtures=fixtures,scope='Every independently invalid non-tuple first-byte parser call among 60 complete PC-zero receipts, exact complete invocation, zero-iteration scanner branch, cleanup, and full error packet REVERT, all lower stack and physical memory. OtherHigh is admitted by the universal owner but not exercised by these ASCII fixtures; other rejecting recursive parser branches/raw codecs/native closure/retention remain open. No public credit.');(out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],calls,steps,byBranch)
if __name__=='__main__':main()
