#!/usr/bin/env python3
"""Bind every frozen exact-byte gate and every literal destination to canonical runtime."""
import sys,json,re,hashlib
from pathlib import Path
root=Path(sys.argv[1]).resolve();manifest=json.loads(Path(sys.argv[2]).read_text());artifact=json.loads((root/'artifacts/contracts/Assertions.sol/Assertions.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);assert len(code)==20049 and hashlib.sha256(code).hexdigest()=='84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903';destinations=set();boundaries=set();pc=0
while pc<len(code):
 boundaries.add(pc);op=code[pc]
 if op==91:destinations.add(pc)
 pc+=1+(op-95 if 96<=op<=127 else 0)
assert len(destinations)==1049
bindings=[]
for rel in manifest['includeClosure']:
 text=(root/rel).read_text();facts=[(int(a),int(b,0) if b.startswith('0x') else int(b)) for a,b in re.findall(r'code\[(\d+)\] == (0x[0-9a-fA-F]+|\d+)',text)]
 for pc,value in facts:assert pc<len(code) and code[pc]==value,(rel,pc,value,code[pc])
 if facts:bindings.append({'file':rel,'literalByteGateCount':len(facts),'passed':True})
 literalLabels=[]
 for body in re.findall(r'(?:opaque )?function (?:Runtime)?Destinations\([^\n]*?\): set<nat> \{ \{([^}]+)\}',text):
  literalLabels.extend(int(v) for v in re.findall(r'\b\d+\b',body))
 for label in literalLabels:assert label in destinations,(rel,label)
 if literalLabels:bindings.append({'file':rel,'literalScannedDestinationCount':len(literalLabels),'passed':True})
print(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'runtimeBytes':len(code),'instructionBoundaryDestinations':len(destinations),'bindings':bindings,'passed':True},indent=2))
