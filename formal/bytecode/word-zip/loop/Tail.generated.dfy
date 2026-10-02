// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentTail {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { ((index as nat)*32+32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function TargetA(index: Word): Word { (160+(index as nat)*64)%G.Modulus() }
  function TargetB(index: Word): Word { (192+(index as nat)*64)%G.Modulus() }
  predicate Admitted(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word) { length < 0x8000000000000000 && (a as nat)+(length as nat) < G.Modulus() && (b as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2094] == 91 &&
                                              code[2222] == 91 &&
                                              code[2223] == 96 &&
                                              code[2224] == 64 &&
                                              code[2225] == 132 &&
                                              code[2226] == 2 &&
                                              code[2227] == 134 &&
                                              code[2228] == 1 &&
                                              code[2229] == 96 &&
                                              code[2230] == 32 &&
                                              code[2231] == 144 &&
                                              code[2232] == 129 &&
                                              code[2233] == 1 &&
                                              code[2234] == 147 &&
                                              code[2235] == 144 &&
                                              code[2236] == 147 &&
                                              code[2237] == 82 &&
                                              code[2238] == 96 &&
                                              code[2239] == 1 &&
                                              code[2240] == 96 &&
                                              code[2241] == 2 &&
                                              code[2242] == 133 &&
                                              code[2243] == 2 &&
                                              code[2244] == 129 &&
                                              code[2245] == 1 &&
                                              code[2246] == 132 &&
                                              code[2247] == 2 &&
                                              code[2248] == 135 &&
                                              code[2249] == 1 &&
                                              code[2250] == 144 &&
                                              code[2251] == 147 &&
                                              code[2252] == 1 &&
                                              code[2253] == 82 &&
                                              code[2254] == 80 &&
                                              code[2255] == 1 &&
                                              code[2256] == 97 &&
                                              code[2257] == 8 &&
                                              code[2258] == 46 &&
                                              code[2259] == 86
  }
  function Destinations(): set<nat> { {2094} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem)
                                                                                                                                          else if id == 1 then state == Running(2223,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem)
                                                                                                                                          else if id == 2 then state == Running(2225,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,64],mem)
                                                                                                                                          else if id == 3 then state == Running(2226,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,64,index],mem)
                                                                                                                                          else if id == 4 then state == Running(2227,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((index as nat)*(64 as nat))%G.Modulus()],mem)
                                                                                                                                          else if id == 5 then state == Running(2228,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((index as nat)*(64 as nat))%G.Modulus(),128],mem)
                                                                                                                                          else if id == 6 then state == Running(2229,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                          else if id == 7 then state == Running(2231,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus(),32],mem)
                                                                                                                                          else if id == 8 then state == Running(2232,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,32,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                          else if id == 9 then state == Running(2233,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,32,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus(),32],mem)
                                                                                                                                          else if id == 10 then state == Running(2234,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,32,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                          else if id == 11 then state == Running(2235,[269019481,518,a,length,b,length,128,length/32,index,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),0,wordB,32,wordA],mem)
                                                                                                                                          else if id == 12 then state == Running(2236,[269019481,518,a,length,b,length,128,length/32,index,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),0,wordB,wordA,32],mem)
                                                                                                                                          else if id == 13 then state == Running(2237,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,wordA,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                          else if id == 14 then state == Running(2238,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 15 then state == Running(2240,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 16 then state == Running(2242,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,2],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 17 then state == Running(2243,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,2,index],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 18 then state == Running(2244,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((index as nat)*(2 as nat))%G.Modulus()],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 19 then state == Running(2245,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((index as nat)*(2 as nat))%G.Modulus(),1],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 20 then state == Running(2246,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 21 then state == Running(2247,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus(),32],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 22 then state == Running(2248,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 23 then state == Running(2249,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),128],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 24 then state == Running(2250,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 25 then state == Running(2251,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),1],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 26 then state == Running(2252,[269019481,518,a,length,b,length,128,length/32,index,1,0,wordB,((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),32],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 27 then state == Running(2253,[269019481,518,a,length,b,length,128,length/32,index,1,0,wordB,((32 as nat)+(((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA))
                                                                                                                                          else if id == 28 then state == Running(2254,[269019481,518,a,length,b,length,128,length/32,index,1,0],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB))
                                                                                                                                          else if id == 29 then state == Running(2255,[269019481,518,a,length,b,length,128,length/32,index,1],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB))
                                                                                                                                          else if id == 30 then state == Running(2256,[269019481,518,a,length,b,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus()],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB))
                                                                                                                                          else if id == 31 then state == Running(2259,[269019481,518,a,length,b,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus(),2094],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB))
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    assert Fetch(code,2222) == Op(91,2223,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2223,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    F.Push1(code,2223);
    assert Fetch(code,2223) == Op(96,2225,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2225,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,64],mem);
    assert Fetch(code,2225) == Op(132,2226,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2226,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,64,index],mem);
    assert Fetch(code,2226) == Op(2,2227,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2227,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((index as nat)*(64 as nat))%G.Modulus()],mem);
    assert Fetch(code,2227) == Op(134,2228,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(5,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2228,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((index as nat)*(64 as nat))%G.Modulus(),128],mem);
    assert Fetch(code,2228) == Op(1,2229,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(6,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2229,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    F.Push1(code,2229);
    assert Fetch(code,2229) == Op(96,2231,32);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(7,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2231,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus(),32],mem);
    assert Fetch(code,2231) == Op(144,2232,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(8,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2232,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,32,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,2232) == Op(129,2233,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(9,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2233,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,32,((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus(),32],mem);
    assert Fetch(code,2233) == Op(1,2234,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(10,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2234,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB,32,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,2234) == Op(147,2235,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(11,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2235,[269019481,518,a,length,b,length,128,length/32,index,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),0,wordB,32,wordA],mem);
    assert Fetch(code,2235) == Op(144,2236,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(12,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2236,[269019481,518,a,length,b,length,128,length/32,index,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),0,wordB,wordA,32],mem);
    assert Fetch(code,2236) == Op(147,2237,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(13,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2237,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,wordA,((32 as nat)+(((128 as nat)+(((index as nat)*(64 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,2237) == Op(82,2238,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(14,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2238,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB],Store(mem,TargetA(index),wordA));
    F.Push1(code,2238);
    assert Fetch(code,2238) == Op(96,2240,1);
  }
  lemma Advance15(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(15,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2240,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1],Store(mem,TargetA(index),wordA));
    F.Push1(code,2240);
    assert Fetch(code,2240) == Op(96,2242,2);
  }
  lemma Advance16(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(16,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2242,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,2],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2242) == Op(133,2243,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(17,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2243,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,2,index],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2243) == Op(2,2244,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(18,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2244,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((index as nat)*(2 as nat))%G.Modulus()],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2244) == Op(129,2245,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(19,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2245,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((index as nat)*(2 as nat))%G.Modulus(),1],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2245) == Op(1,2246,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(20,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2246,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2246) == Op(132,2247,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(21,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2247,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus(),32],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2247) == Op(2,2248,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(22,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2248,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2248) == Op(135,2249,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(23,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2249,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),128],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2249) == Op(1,2250,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(24,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2250,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,1,((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2250) == Op(144,2251,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(25,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2251,[269019481,518,a,length,b,length,128,length/32,index,32,0,wordB,((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),1],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2251) == Op(147,2252,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(26,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2252,[269019481,518,a,length,b,length,128,length/32,index,1,0,wordB,((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus(),32],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2252) == Op(1,2253,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(27,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2253,[269019481,518,a,length,b,length,128,length/32,index,1,0,wordB,((32 as nat)+(((128 as nat)+(((32 as nat)*(((1 as nat)+(((index as nat)*(2 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],Store(mem,TargetA(index),wordA));
    assert Fetch(code,2253) == Op(82,2254,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(28,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2254,[269019481,518,a,length,b,length,128,length/32,index,1,0],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB));
    assert Fetch(code,2254) == Op(80,2255,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(29,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2255,[269019481,518,a,length,b,length,128,length/32,index,1],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB));
    assert Fetch(code,2255) == Op(1,2256,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(30,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2256,[269019481,518,a,length,b,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus()],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB));
    F.Push2(code,2256);
    assert Fetch(code,2256) == Op(97,2259,2094);
  }
  lemma Advance31(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(31,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(2094,[269019481,518,a,length,b,length,128,length/32,index+1],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB))
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2259,[269019481,518,a,length,b,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus(),2094],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB));
    assert Fetch(code,2259) == Op(86,2260,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(2094,[269019481,518,a,length,b,length,128,length/32,index+1],Store(Store(mem,TargetA(index),wordA),TargetB(index),wordB))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 33 && trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next4;
    Advance5(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next5;
    Advance6(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next6;
    Advance7(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next7;
    Advance8(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next8;
    Advance9(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next9;
    Advance10(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next10;
    Advance11(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next11;
    Advance12(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next12;
    Advance13(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next13;
    Advance14(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next14;
    Advance15(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next15;
    Advance16(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next16;
    Advance17(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next17;
    Advance18(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next18;
    Advance19(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next19;
    Advance20(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next20;
    Advance21(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next21;
    Advance22(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next22;
    Advance23(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next23;
    Advance24(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next24;
    Advance25(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next25;
    Advance26(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next26;
    Advance27(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next27;
    Advance28(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next28;
    Advance29(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next29;
    Advance30(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next30;
    Advance31(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31];
    assert trace[0] == Running(2222,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,wordB],mem);
    state := next31;
  }
}
