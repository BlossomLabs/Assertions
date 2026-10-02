#!/usr/bin/env python3
"""Check all raw rejected frames and complete accepted descriptor-call frames independently."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);a=parser.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=ROOT/'formal/bytecode/value-array/physical-admission/development/raw-array-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);runtime=hashlib.sha256(code).hexdigest();results=[]
 def store(mem,offset,word):
  result=bytearray(mem);result.extend(bytes(max(0,(offset+63)//32*32-len(result))));result[offset:offset+32]=word.to_bytes(32,'big');return bytes(result)
 for path in sorted((original/'evm-traces').glob('*.json')):
  if path.name in {'results.json','toolchain.json'}:continue
  d=json.loads(path.read_text());assert d['runtimeSha256']==runtime
  if d['fixture']['operation']!='unpackArray':continue
  data=bytes.fromhex(d['fixture']['data'][2:]);assert data[:4]==bytes.fromhex('cb533ade')
  word=lambda offset:int.from_bytes((data[offset:offset+32]+bytes(32))[:32],'big')
  ha,hb=word(4),word(36);admitted=len(data)>=68 and ha<1<<64 and hb<1<<64 and ha+36+word(ha+4)<=len(data) and hb+36+word(hb+4)<=len(data)
  if not admitted:
   assert d['trace']['failed'] and d['trace']['returnValue'].removeprefix('0x')==''
   assert not any(x['pc']in {12814,9893}for x in d['trace']['structLogs'])
   kind='raw-rejected-empty-revert'
  else:
   offA,offB,lenA,lenB=ha+36,hb+36,word(ha+4),word(hb+4);free=128+((lenB+31)//32*32)+32
   copied=store(store(store(bytes(),64,128),64,free),128,lenB);copied=bytearray(copied);copied.extend(bytes(max(0,(160+lenB+31)//32*32-len(copied))));copied[160:160+lenB]=data[offB:offB+lenB];copied=store(copied,160+lenB,0)
   allocated=store(copied,64,free+192)
   for i in range(6):allocated=store(allocated,free+32*i,0)
   frame=next(x for x in d['trace']['structLogs']if x['pc']==9893)
   expected=[3411229406,477,offA,lenA,offB,lenB,96,5704,offA,lenA,128,96,free,12879,offA,lenA]
   assert [int(x,16)for x in frame['stack']]==expected
   assert bytes.fromhex(''.join(x.removeprefix('0x')for x in frame['memory']))==allocated
   kind='raw-accepted-full-physical-shape-frame'
  results.append(dict(name=d['fixture']['name'],kind=kind,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(results)==82 and sum(x['kind']=='raw-rejected-empty-revert'for x in results)==74
 record=dict(status='development-physical-shape-boundary-passed-not-retained',runtimeSha256=runtime,historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtures=results,rawRejects=74,physicalShapeFrames=8,scope='All 82 unpack raw development fixtures: exact empty raw decoder revert or independently constructed full lower stack/copy/padding/six zero state/free-pointer shape-call frame. Universal parser/codec/error/return and full native/retained public closure remain open.')
 (out/'results.json').write_text(json.dumps(record,indent=2)+'\n');print(record['status'],'74 raw empty reverts and 8 full physical shape frames')
if __name__=='__main__':main()
