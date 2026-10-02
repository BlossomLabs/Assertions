// SPDX-License-Identifier: MIT
// Generated compiler-bound sortWords segment; each actual reached opcode is checked.
include "../../scans/Execution.dfy"
include "../../copy/Memory.dfy"
include "Scalar.dfy"
module BytecodeSortSegmentDecisionRight {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import SC = BytecodeSortMergeScalar
  predicate Admitted(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { n < 0x800000000000000 && offset < 0x10000000000000000 && out < 0x20000000000000000 && scratch < 0x20000000000000000 && 0 < width <= 2*n+1 && start <= 3*n && start <= a <= middle <= b <= end <= n && dest <= end && take <= 1 && dest < end && a < middle && b < end && lword > rword }
  predicate MemoryAdmitted(mem: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && out+32+b*32+32 <= |mem| && Load(mem,out+32+b*32) == rword && out+32+a*32+32 <= |mem| && Load(mem,out+32+a*32) == lword && |mem| < G.Modulus() && Round32(|mem|) == |mem| }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[3735] == 129 &&
                                              code[3736] == 132 &&
                                              code[3737] == 20 &&
                                              code[3738] == 133 &&
                                              code[3739] == 132 &&
                                              code[3740] == 16 &&
                                              code[3741] == 128 &&
                                              code[3742] == 21 &&
                                              code[3743] == 97 &&
                                              code[3744] == 14 &&
                                              code[3745] == 167 &&
                                              code[3746] == 87 &&
                                              code[3747] == 80 &&
                                              code[3748] == 132 &&
                                              code[3749] == 131 &&
                                              code[3750] == 16 &&
                                              code[3751] == 91 &&
                                              code[3752] == 21 &&
                                              code[3753] == 97 &&
                                              code[3754] == 14 &&
                                              code[3755] == 195 &&
                                              code[3756] == 87 &&
                                              code[3757] == 96 &&
                                              code[3758] == 32 &&
                                              code[3759] == 128 &&
                                              code[3760] == 132 &&
                                              code[3761] == 2 &&
                                              code[3762] == 140 &&
                                              code[3763] == 1 &&
                                              code[3764] == 1 &&
                                              code[3765] == 81 &&
                                              code[3766] == 96 &&
                                              code[3767] == 32 &&
                                              code[3768] == 128 &&
                                              code[3769] == 134 &&
                                              code[3770] == 2 &&
                                              code[3771] == 141 &&
                                              code[3772] == 1 &&
                                              code[3773] == 1 &&
                                              code[3774] == 81 &&
                                              code[3775] == 17 &&
                                              code[3776] == 21 &&
                                              code[3777] == 144 &&
                                              code[3778] == 80 &&
                                              code[3779] == 91 &&
                                              code[3780] == 133 &&
                                              code[3781] == 132 &&
                                              code[3782] == 3 &&
                                              code[3783] == 97 &&
                                              code[3784] == 14 &&
                                              code[3785] == 205 &&
                                              code[3786] == 87 &&
                                              code[3789] == 91 }
  function Destinations(): set<nat> { {3751,3779,3789} }
  opaque predicate Good(id: nat, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && (
                                                                                                                                                                                                                                           if id == 0 then state == Running(3735,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest],mem)
                                                                                                                                                                                                                                           else if id == 1 then state == Running(3736,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,b],mem)
                                                                                                                                                                                                                                           else if id == 2 then state == Running(3737,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,b,end],mem)
                                                                                                                                                                                                                                           else if id == 3 then state == Running(3738,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem)
                                                                                                                                                                                                                                           else if id == 4 then state == Running(3739,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle],mem)
                                                                                                                                                                                                                                           else if id == 5 then state == Running(3740,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle,a],mem)
                                                                                                                                                                                                                                           else if id == 6 then state == Running(3741,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem)
                                                                                                                                                                                                                                           else if id == 7 then state == Running(3742,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1,1],mem)
                                                                                                                                                                                                                                           else if id == 8 then state == Running(3743,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1,0],mem)
                                                                                                                                                                                                                                           else if id == 9 then state == Running(3746,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1,0,3751],mem)
                                                                                                                                                                                                                                           else if id == 10 then state == Running(3747,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem)
                                                                                                                                                                                                                                           else if id == 11 then state == Running(3748,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem)
                                                                                                                                                                                                                                           else if id == 12 then state == Running(3749,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,end],mem)
                                                                                                                                                                                                                                           else if id == 13 then state == Running(3750,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,end,b],mem)
                                                                                                                                                                                                                                           else if id == 14 then state == Running(3751,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem)
                                                                                                                                                                                                                                           else if id == 15 then state == Running(3752,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem)
                                                                                                                                                                                                                                           else if id == 16 then state == Running(3753,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0],mem)
                                                                                                                                                                                                                                           else if id == 17 then state == Running(3756,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0,3779],mem)
                                                                                                                                                                                                                                           else if id == 18 then state == Running(3757,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem)
                                                                                                                                                                                                                                           else if id == 19 then state == Running(3759,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32],mem)
                                                                                                                                                                                                                                           else if id == 20 then state == Running(3760,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,32],mem)
                                                                                                                                                                                                                                           else if id == 21 then state == Running(3761,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,32,b],mem)
                                                                                                                                                                                                                                           else if id == 22 then state == Running(3762,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,((b as nat)*(32 as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                                           else if id == 23 then state == Running(3763,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,((b as nat)*(32 as nat))%G.Modulus(),out],mem)
                                                                                                                                                                                                                                           else if id == 24 then state == Running(3764,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,((out as nat)+(((b as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                                           else if id == 25 then state == Running(3765,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,((((out as nat)+(((b as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                                           else if id == 26 then state == Running(3766,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword],mem)
                                                                                                                                                                                                                                           else if id == 27 then state == Running(3768,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32],mem)
                                                                                                                                                                                                                                           else if id == 28 then state == Running(3769,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,32],mem)
                                                                                                                                                                                                                                           else if id == 29 then state == Running(3770,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,32,a],mem)
                                                                                                                                                                                                                                           else if id == 30 then state == Running(3771,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,((a as nat)*(32 as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                                           else if id == 31 then state == Running(3772,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,((a as nat)*(32 as nat))%G.Modulus(),out],mem)
                                                                                                                                                                                                                                           else if id == 32 then state == Running(3773,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,((out as nat)+(((a as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                                           else if id == 33 then state == Running(3774,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,((((out as nat)+(((a as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                                           else if id == 34 then state == Running(3775,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,lword],mem)
                                                                                                                                                                                                                                           else if id == 35 then state == Running(3776,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem)
                                                                                                                                                                                                                                           else if id == 36 then state == Running(3777,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0],mem)
                                                                                                                                                                                                                                           else if id == 37 then state == Running(3778,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0],mem)
                                                                                                                                                                                                                                           else if id == 38 then state == Running(3779,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem)
                                                                                                                                                                                                                                           else if id == 39 then state == Running(3780,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem)
                                                                                                                                                                                                                                           else if id == 40 then state == Running(3781,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle],mem)
                                                                                                                                                                                                                                           else if id == 41 then state == Running(3782,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle,a],mem)
                                                                                                                                                                                                                                           else if id == 42 then state == Running(3783,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,((a as nat)+G.Modulus()-(middle as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                                           else if id == 43 then state == Running(3786,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,((a as nat)+G.Modulus()-(middle as nat))%G.Modulus(),3789],mem)
                                                                                                                                                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(0,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3735,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest],mem);
    assert Fetch(code,3735) == Op(129,3736,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(1,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3736,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,b],mem);
    assert Fetch(code,3736) == Op(132,3737,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(2,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3737,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,b,end],mem);
    assert Fetch(code,3737) == Op(20,3738,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(3,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3738,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem);
    assert Fetch(code,3738) == Op(133,3739,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(4,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3739,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle],mem);
    assert Fetch(code,3739) == Op(132,3740,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(5,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3740,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle,a],mem);
    assert Fetch(code,3740) == Op(16,3741,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(6,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3741,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem);
    assert Fetch(code,3741) == Op(128,3742,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(7,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3742,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1,1],mem);
    assert Fetch(code,3742) == Op(21,3743,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(8,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3743,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1,0],mem);
    F.Push2(code,3743);
    assert Fetch(code,3743) == Op(97,3746,3751);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(9,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3746,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1,0,3751],mem);
    assert Fetch(code,3746) == Op(87,3747,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(10,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3747,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem);
    assert Fetch(code,3747) == Op(80,3748,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(11,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3748,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem);
    assert Fetch(code,3748) == Op(132,3749,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(12,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3749,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,end],mem);
    assert Fetch(code,3749) == Op(131,3750,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(13,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3750,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,end,b],mem);
    assert Fetch(code,3750) == Op(16,3751,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(14,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3751,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem);
    assert Fetch(code,3751) == Op(91,3752,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(15,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3752,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem);
    assert Fetch(code,3752) == Op(21,3753,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(16,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3753,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0],mem);
    F.Push2(code,3753);
    assert Fetch(code,3753) == Op(97,3756,3779);
  }
  lemma Advance17(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(17,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3756,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0,3779],mem);
    assert Fetch(code,3756) == Op(87,3757,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(18,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3757,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem);
    F.Push1(code,3757);
    assert Fetch(code,3757) == Op(96,3759,32);
  }
  lemma Advance19(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(19,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3759,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32],mem);
    assert Fetch(code,3759) == Op(128,3760,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(20,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3760,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,32],mem);
    assert Fetch(code,3760) == Op(132,3761,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(21,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3761,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,32,b],mem);
    assert Fetch(code,3761) == Op(2,3762,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(22,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3762,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,((b as nat)*(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,3762) == Op(140,3763,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(23,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3763,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,((b as nat)*(32 as nat))%G.Modulus(),out],mem);
    assert Fetch(code,3763) == Op(1,3764,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(24,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3764,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,32,((out as nat)+(((b as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,3764) == Op(1,3765,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(25,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3765,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,((((out as nat)+(((b as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    SC.Address(out,b);
    C.RoundedMonotone(out+32+b*32+32,|mem|);
    assert Expand(mem,out+32+b*32+32) == mem;
    assert Fetch(code,3765) == Op(81,3766,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(26,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3766,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword],mem);
    F.Push1(code,3766);
    assert Fetch(code,3766) == Op(96,3768,32);
  }
  lemma Advance27(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(27,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3768,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32],mem);
    assert Fetch(code,3768) == Op(128,3769,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(28,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3769,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,32],mem);
    assert Fetch(code,3769) == Op(134,3770,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(29,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3770,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,32,a],mem);
    assert Fetch(code,3770) == Op(2,3771,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(30,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3771,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,((a as nat)*(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,3771) == Op(141,3772,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(31,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3772,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,((a as nat)*(32 as nat))%G.Modulus(),out],mem);
    assert Fetch(code,3772) == Op(1,3773,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(32,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3773,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,32,((out as nat)+(((a as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,3773) == Op(1,3774,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(33,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3774,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,((((out as nat)+(((a as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    SC.Address(out,a);
    C.RoundedMonotone(out+32+a*32+32,|mem|);
    assert Expand(mem,out+32+a*32+32) == mem;
    assert Fetch(code,3774) == Op(81,3775,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(34,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3775,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,rword,lword],mem);
    assert Fetch(code,3775) == Op(17,3776,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(35,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3776,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,1],mem);
    assert Fetch(code,3776) == Op(21,3777,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(36,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3777,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0],mem);
    assert Fetch(code,3777) == Op(144,3778,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(37,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3778,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,0],mem);
    assert Fetch(code,3778) == Op(80,3779,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(38,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3779,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem);
    assert Fetch(code,3779) == Op(91,3780,0);
  }
  lemma Advance39(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(39,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3780,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem);
    assert Fetch(code,3780) == Op(133,3781,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(40,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3781,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle],mem);
    assert Fetch(code,3781) == Op(132,3782,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(41,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3782,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,middle,a],mem);
    SC.Difference(a,middle);
    assert Fetch(code,3782) == Op(3,3783,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(42,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3783,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,((a as nat)+G.Modulus()-(middle as nat))%G.Modulus()],mem);
    F.Push2(code,3783);
    assert Fetch(code,3783) == Op(97,3786,3789);
  }
  lemma Advance43(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(43,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3789,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3786,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0,((a as nat)+G.Modulus()-(middle as nat))%G.Modulus(),3789],mem);
    assert Fetch(code,3786) == Op(87,3787,0);
  }
  lemma Start(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>)
    requires Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures Good(0,Running(3735,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest],mem),offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures state == Running(3789,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,0],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 45 && trace[0] == Running(3735,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest],mem) && trace[|trace|-1] == state
  {
    Start(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem);state := Running(3735,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest],mem);trace := [state];
    Advance0(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
    Advance20(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    state := next20;
    Advance21(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    state := next21;
    Advance22(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    state := next22;
    Advance23(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    state := next23;
    Advance24(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    state := next24;
    Advance25(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    state := next25;
    Advance26(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    state := next26;
    Advance27(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    state := next27;
    Advance28(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    state := next28;
    Advance29(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    state := next29;
    Advance30(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    state := next30;
    Advance31(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31];
    state := next31;
    Advance32(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32];
    state := next32;
    Advance33(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33];
    state := next33;
    Advance34(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34];
    state := next34;
    Advance35(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35];
    state := next35;
    Advance36(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36];
    state := next36;
    Advance37(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37];
    state := next37;
    Advance38(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);
    trace := trace+[next38];
    state := next38;
    Advance39(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);
    trace := trace+[next39];
    state := next39;
    Advance40(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);
    trace := trace+[next40];
    state := next40;
    Advance41(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);
    trace := trace+[next41];
    state := next41;
    Advance42(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);
    trace := trace+[next42];
    state := next42;
    Advance43(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);
    trace := trace+[next43];
    state := next43;
  }
}
