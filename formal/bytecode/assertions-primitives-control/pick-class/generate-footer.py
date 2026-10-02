#!/usr/bin/env python3
"""Actual word-return code PCs371..389, symbolic original memory/free/word."""
from pathlib import Path
import json,hashlib
H=Path(__file__).resolve().parent;R=H.parents[3];code=bytes.fromhex(json.loads((R/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest=='84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903'
pcs=[371,372,374,375,376,377,378,380,381,382,384,385,386,387,388,389];stacks=[['word'],['word'],['word','64'],['word','free'],['free','word'],['free','word','free'],['free'],['free','32'],['free+32'],['free+32'],['free+32','64'],['free+32','free'],['free+32','free','free'],['free','free','free+32'],['free','32'],['32','free']];rows=[];facts={}
for i,pc in enumerate(pcs):
 op=code[pc];w=op-95 if 96<=op<=127 else 0;nxt=pc+1+w;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});rows.append(dict(id=i,pc=pc,op=op,next=nxt,immediate=imm,stack=stacks[i],memory='mem' if i<6 else 'Image(mem,free,word)'))
params='free: Word,word: Word,prefix: seq<Word>,mem: seq<Byte>,value: Word,data: seq<Byte>';args='free,word,prefix,mem,value,data';state=lambda r:f'S.Running({r["pc"]},prefix+[{",".join(r["stack"])}],{r["memory"]})';good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == {state(r)}' for i,r in enumerate(rows))+'\n    else false'
s=f'''// SPDX-License-Identifier: MIT
// Exact complete compiler word RETURN, independently specified Encode(word,32).
include "Spec.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module AssertionsPickFooter {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  type Word = S.Word
  type Byte = S.Byte
  function Image(mem: seq<Byte>,free: Word,word: Word): seq<Byte> {{ S.Store(mem,free,word) }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == 20049 && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Destinations(): set<nat> {{ {{}} }}
  predicate Admitted({params}) {{ |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && 128 <= free && free+64 < 0x10000000000000000 && S.Load(mem,64) == free && |prefix| <= 960 }}
  opaque predicate Good(id: nat,state: S.State,{params}) {{ Admitted({args}) && (\n{good}) }}
  lemma Built(mem: seq<Byte>,free: Word,word: Word)
    requires |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && 128 <= free && free+64 < G.Modulus()
    ensures S.Load(Image(mem,free,word),64) == S.Load(mem,64)
    ensures S.Expand(Image(mem,free,word),96) == Image(mem,free,word)
    ensures G.Grow(Image(mem,free,word),free+32)[free..free+32] == G.Encode(word,32)
  {{ R.StoredWord(mem,free,word); R.StoredFrame(mem,free,word,64); assert G.Grow(Image(mem,free,word),free+32) == Image(mem,free,word); }}
'''
for i,r in enumerate(rows):
 post=state(rows[i+1]) if i<15 else 'S.Returned(G.Encode(word,32))';push=f'    F.Push1(code,{r["pc"]});\n' if r['op']==96 else '';extra='    Built(mem,free,word);\n' if i in [10,15] else ''
 s+=f'''  lemma Advance{i}(code: seq<Byte>,state: S.State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures S.Step(code,Destinations(),state,value,data) == {post}
  {{ reveal Matches(); reveal Good(); reveal S.Step(); hide S.Load(); hide G.Decode(); hide S.Store();
{extra}{push}    assert S.Fetch(code,{r['pc']}) == S.Op({r['op']},{r['next']},{r['immediate']});
  }}
'''
s+=f'''  lemma Advance(id: nat,code: seq<Byte>,state: S.State,{params})
    requires Matches(code) && Admitted({args}) && Good(id,state,{args}) && id < 16
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures S.Step(code,Destinations(),state,value,data) != S.Bad
    ensures id+1 < 16 ==> Good(id+1,S.Step(code,Destinations(),state,value,data),{args})
    ensures id+1 == 16 ==> S.Step(code,Destinations(),state,value,data) == S.Returned(G.Encode(word,32))
  {{ reveal Good();
'''
for i in range(16):s+=f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args}); }}\n'
s+=f'''  }}
  ghost method Run(code: seq<Byte>,{params}) returns (state: S.State,trace: seq<S.State>)
    requires Matches(code) && Admitted({args})
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(371,prefix+[word],mem) && trace[|trace|-1] == state && state == S.Returned(G.Encode(word,32))
    ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
  {{ reveal Good();state := S.Running(371,prefix+[word],mem);trace := [state];var id: nat := 0;
    while id < 16
      invariant id <= 16 && |trace| == id+1
      invariant E.Trace(code,Destinations(),value,data,trace)
      invariant trace[0] == S.Running(371,prefix+[word],mem) && trace[|trace|-1] == state
      invariant forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
      invariant id < 16 ==> Good(id,state,{args})
      invariant id == 16 ==> state == S.Returned(G.Encode(word,32))
      decreases 16-id
    {{ Advance(id,code,state,{args});var next := S.Step(code,Destinations(),state,value,data); E.Extend(code,Destinations(),value,data,trace,next);trace := trace+[next];state := next;id := id+1; }}
  }}
}}
'''
(H/'Footer.generated.dfy').write_text(s);(H/'Footer.mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':rows,'requiredBytes':facts},indent=2)+'\n')
