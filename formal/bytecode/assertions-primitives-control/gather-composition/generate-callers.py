#!/usr/bin/env python3
"""Regenerate caller-compatible helpers, preserving every certified physical instruction."""
import argparse,re,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=HERE);out=p.parse_args().output;out.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);ins={};pc=0
while pc<len(code):
 op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=op;pc+=1+width
dests=sorted(pc for pc,op in ins.items() if op==91)
oldline=next(l for l in (HERE/'ElementSpec.dfy').read_text().splitlines() if 'function RuntimeDestinations' in l);assert list(map(int,re.findall(r'\d+',oldline)))==dests
chunks=['  opaque function Chunk'+str(i//32)+'(): set<nat> { {'+','.join(map(str,dests[i:i+32]))+'} }' for i in range(0,len(dests),32)]
s='''// SPDX-License-Identifier: MIT
// Scanned destinations are split so caller constants have small native witnesses.
include "ElementSpec.dfy"
module AssertionsGatherCallerSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import D = AssertionsGatherElementSpec
'''+ '\n'.join(chunks)+'\n  opaque function RuntimeDestinations(): set<nat> { '+'+'.join('Chunk'+str(i)+'()' for i in range(len(chunks)))+' }\n'+'''  function Bound(data: seq<S.Byte>, base: G.Word): G.Word { D.Bound(data,base) }
  predicate Accepts(data: seq<S.Byte>, slot: G.Word, base: G.Word) { D.Accepts(data,slot,base) }
  function Pointer(data: seq<S.Byte>, slot: G.Word, base: G.Word): G.Word { D.Pointer(data,slot,base) }
  lemma Budget(data: seq<S.Byte>, base: G.Word)
    requires |data| < G.Modulus()
    ensures ((S.BitNot(126) as nat)+((|data|+G.Modulus()-base)%G.Modulus()))%G.Modulus() == Bound(data,base)
  { D.Budget(data,base); }
}
''';(out/'CallerElementSpec.dfy').write_text(s)
s=(HERE/'ElementSuccess.generated.dfy').read_text().replace('include "ElementSpec.dfy"','include "CallerElementSpec.dfy"').replace('module AssertionsGatherElementSuccess','module AssertionsGatherCallerSuccess').replace('import D = AssertionsGatherElementSpec','import D = AssertionsGatherCallerSpec');(out/'CallerElementSuccess.generated.dfy').write_text(s)
s=(HERE.parent/'GatherDoneExit.generated.dfy').read_text().replace('include "../scans/Execution.dfy"','include "../../scans/Execution.dfy"\ninclude "CallerElementSpec.dfy"').replace('include "../scans/Push.dfy"','include "../../scans/Push.dfy"').replace('include "../assertions-primitives/Scalar.dfy"','include "../../assertions-primitives/Scalar.dfy"').replace('module AssertionsControlGatherDoneExit','module AssertionsGatherCallerDone').replace('  import Q = AssertionsPrimitiveScalar','  import Q = AssertionsPrimitiveScalar\n  import D = AssertionsGatherCallerSpec');s=re.sub(r'  function RuntimeDestinations\(\): set<nat> \{ .* \}\n','  function RuntimeDestinations(): set<nat> { D.RuntimeDestinations() }\n',s);(out/'CallerGatherDone.generated.dfy').write_text(s)
(out/'caller-provenance.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'runtimeDestinations':dests,'coreSourceSha256':{str(f.relative_to(ROOT)):hashlib.sha256(f.read_bytes()).hexdigest() for f in [HERE/'ElementSpec.dfy',HERE/'ElementSuccess.generated.dfy',HERE.parent/'GatherDoneExit.generated.dfy']},'changes':'Imported module aliases and opaque, 32-entry scanned destination chunks only; instruction lemmas, exact byte gates, path states and trace assembly are unchanged.'},indent=2)+'\n')
