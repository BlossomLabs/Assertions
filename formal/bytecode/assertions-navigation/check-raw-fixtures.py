#!/usr/bin/env python3
"""Independent public RAW-class calldata admission and physical witness checks."""
from pathlib import Path
import json,hashlib,argparse
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('traces',type=Path);a=p.parse_args();results=[];route=None
artifact=json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text());runtime=bytes.fromhex(artifact['deployedBytecode'][2:]);digest=hashlib.sha256(runtime).hexdigest()
assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
for length in [0,1,31,32,33,257]:
 fixture=a.traces/f'case-{length}.json';d=json.loads(fixture.read_text());data=bytes.fromhex(d['data'][2:]);w=lambda at:int.from_bytes(data[at:at+32].ljust(32,b'\0'),'big');size=len(data)
 assert 100<=size<2**64 and data[:4]==(531649507).to_bytes(4,'big')
 assert all(w(at)<2**64 for at in [4,36,68])
 param,th,ph=[4+w(at) for at in [4,36,68]]
 assert param+128<=size and th+32<=size and ph+32<=size
 assert w(th)<2**64 and w(ph)==0 and th+32+w(th)<=size
 br,cr=w(param+64),w(param+96)
 assert w(param+32)==0 and param+br+32+length<=size and param+cr+32<=size
 assert w(param+br)==length and w(param+cr)==0 and 160+((length+31)//32)*32+64<2**64
 payload=data[param+br+32:param+br+32+length]
 assert payload.hex()==d['payload'][2:] and not d['trace']['failed'] and d['actual']=='0x'+payload.hex() and d['runtimeSha256']==digest
 rows=d['trace']['structLogs'];pcs=[r['pc'] for r in rows]
 assert len(rows)==567 and pcs[0]==0 and pcs[-1]==1100 and rows[0]['stack']==[] and rows[0]['memory']==[]
 assert all(pcs.count(pc)==1 for pc in [344,1054,3393,1081])
 if route is None:route=pcs
 else:assert pcs==route
 last=rows[-1];stack=[int(v,16) for v in last['stack']];memory=bytes.fromhex(''.join(v.removeprefix('0x') for v in last['memory']))
 assert stack[-2]==length and memory[stack[-1]:stack[-1]+length]==payload
 results.append({'length':length,'passed':True,'traceSha256':hashlib.sha256(fixture.read_bytes()).hexdigest(),'physicalInstructions':len(rows)})
(a.traces/'admission-results.json').write_text(json.dumps({'scope':'Six concrete witnesses only; no arbitrary-input theorem or whole-entry claim. All567 reached PCs match across lengths.','runtimeSha256':digest,'cases':results},indent=2)+'\n')
print('PASS:',len(results),'structurally admitted 567-instruction public RAW witnesses')
