// SPDX-License-Identifier: MIT
// Generated pinned reverseWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeReverseSegmentTail {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeReverseLoopScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function Target(length: Word, index: Word): Word { (if index < length/32 then 160+(length/32-1-index)*32 else 160)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5846] == 91 &&
                                              code[5913] == 91 &&
                                              code[5914] == 96 &&
                                              code[5915] == 32 &&
                                              code[5916] == 95 &&
                                              code[5917] == 25 &&
                                              code[5918] == 132 &&
                                              code[5919] == 134 &&
                                              code[5920] == 3 &&
                                              code[5921] == 1 &&
                                              code[5922] == 129 &&
                                              code[5923] == 2 &&
                                              code[5924] == 134 &&
                                              code[5925] == 1 &&
                                              code[5926] == 1 &&
                                              code[5927] == 82 &&
                                              code[5928] == 80 &&
                                              code[5929] == 96 &&
                                              code[5930] == 1 &&
                                              code[5931] == 1 &&
                                              code[5932] == 97 &&
                                              code[5933] == 22 &&
                                              code[5934] == 214 &&
                                              code[5935] == 86
  }
  function Destinations(): set<nat> { {5846} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,index,word) && (
                                                                                                                        if id == 0 then state == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem)
                                                                                                                        else if id == 1 then state == Running(5914,[2874738232,518,offset,length,128,length/32,index,0,word],mem)
                                                                                                                        else if id == 2 then state == Running(5916,[2874738232,518,offset,length,128,length/32,index,0,word,32],mem)
                                                                                                                        else if id == 3 then state == Running(5917,[2874738232,518,offset,length,128,length/32,index,0,word,32,0],mem)
                                                                                                                        else if id == 4 then state == Running(5918,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935],mem)
                                                                                                                        else if id == 5 then state == Running(5919,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935,index],mem)
                                                                                                                        else if id == 6 then state == Running(5920,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935,index,length/32],mem)
                                                                                                                        else if id == 7 then state == Running(5921,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935,((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus()],mem)
                                                                                                                        else if id == 8 then state == Running(5922,[2874738232,518,offset,length,128,length/32,index,0,word,32,((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus()],mem)
                                                                                                                        else if id == 9 then state == Running(5923,[2874738232,518,offset,length,128,length/32,index,0,word,32,((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus(),32],mem)
                                                                                                                        else if id == 10 then state == Running(5924,[2874738232,518,offset,length,128,length/32,index,0,word,32,((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                        else if id == 11 then state == Running(5925,[2874738232,518,offset,length,128,length/32,index,0,word,32,((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus(),128],mem)
                                                                                                                        else if id == 12 then state == Running(5926,[2874738232,518,offset,length,128,length/32,index,0,word,32,((128 as nat)+(((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                        else if id == 13 then state == Running(5927,[2874738232,518,offset,length,128,length/32,index,0,word,((((128 as nat)+(((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                                                        else if id == 14 then state == Running(5928,[2874738232,518,offset,length,128,length/32,index,0],Store(mem,Target(length,index),word))
                                                                                                                        else if id == 15 then state == Running(5929,[2874738232,518,offset,length,128,length/32,index],Store(mem,Target(length,index),word))
                                                                                                                        else if id == 16 then state == Running(5931,[2874738232,518,offset,length,128,length/32,index,1],Store(mem,Target(length,index),word))
                                                                                                                        else if id == 17 then state == Running(5932,[2874738232,518,offset,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus()],Store(mem,Target(length,index),word))
                                                                                                                        else if id == 18 then state == Running(5935,[2874738232,518,offset,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus(),5846],Store(mem,Target(length,index),word))
                                                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(0,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    assert Fetch(code,5913) == Op(91,5914,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(1,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5914,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    F.Push1(code,5914);
    assert Fetch(code,5914) == Op(96,5916,32);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(2,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5916,[2874738232,518,offset,length,128,length/32,index,0,word,32],mem);
    assert Fetch(code,5916) == Op(95,5917,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(3,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5917,[2874738232,518,offset,length,128,length/32,index,0,word,32,0],mem);
    SC.Not0();
    assert Fetch(code,5917) == Op(25,5918,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(4,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5918,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935],mem);
    assert Fetch(code,5918) == Op(132,5919,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(5,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5919,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935,index],mem);
    assert Fetch(code,5919) == Op(134,5920,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(6,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5920,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935,index,length/32],mem);
    assert Fetch(code,5920) == Op(3,5921,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(7,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5921,[2874738232,518,offset,length,128,length/32,index,0,word,32,115792089237316195423570985008687907853269984665640564039457584007913129639935,((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus()],mem);
    assert Fetch(code,5921) == Op(1,5922,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(8,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5922,[2874738232,518,offset,length,128,length/32,index,0,word,32,((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus()],mem);
    assert Fetch(code,5922) == Op(129,5923,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(9,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5923,[2874738232,518,offset,length,128,length/32,index,0,word,32,((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus(),32],mem);
    assert Fetch(code,5923) == Op(2,5924,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(10,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5924,[2874738232,518,offset,length,128,length/32,index,0,word,32,((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,5924) == Op(134,5925,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(11,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5925,[2874738232,518,offset,length,128,length/32,index,0,word,32,((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus(),128],mem);
    assert Fetch(code,5925) == Op(1,5926,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(12,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5926,[2874738232,518,offset,length,128,length/32,index,0,word,32,((128 as nat)+(((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,5926) == Op(1,5927,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(13,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5927,[2874738232,518,offset,length,128,length/32,index,0,word,((((128 as nat)+(((32 as nat)*(((((length/32 as nat)+G.Modulus()-(index as nat))%G.Modulus() as nat)+(115792089237316195423570985008687907853269984665640564039457584007913129639935 as nat))%G.Modulus() as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,5927) == Op(82,5928,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(14,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5928,[2874738232,518,offset,length,128,length/32,index,0],Store(mem,Target(length,index),word));
    assert Fetch(code,5928) == Op(80,5929,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(15,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5929,[2874738232,518,offset,length,128,length/32,index],Store(mem,Target(length,index),word));
    F.Push1(code,5929);
    assert Fetch(code,5929) == Op(96,5931,1);
  }
  lemma Advance16(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(16,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5931,[2874738232,518,offset,length,128,length/32,index,1],Store(mem,Target(length,index),word));
    assert Fetch(code,5931) == Op(1,5932,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(17,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5932,[2874738232,518,offset,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus()],Store(mem,Target(length,index),word));
    F.Push2(code,5932);
    assert Fetch(code,5932) == Op(97,5935,5846);
  }
  lemma Advance18(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(18,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5846,[2874738232,518,offset,length,128,length/32,index+1],Store(mem,Target(length,index),word))
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5935,[2874738232,518,offset,length,128,length/32,((1 as nat)+(index as nat))%G.Modulus(),5846],Store(mem,Target(length,index),word));
    assert Fetch(code,5935) == Op(86,5936,0);
  }
  lemma Start(offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,index,word)
    ensures Good(0,Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem),offset,length,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,index,word)
    ensures state == Running(5846,[2874738232,518,offset,length,128,length/32,index+1],Store(mem,Target(length,index),word))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 20 && trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,index,word,mem);
    state := Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    trace := [state];
    Advance0(code,state,offset,length,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next0;
    Advance1(code,state,offset,length,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next1;
    Advance2(code,state,offset,length,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next2;
    Advance3(code,state,offset,length,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next3;
    Advance4(code,state,offset,length,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next4;
    Advance5(code,state,offset,length,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next5;
    Advance6(code,state,offset,length,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next6;
    Advance7(code,state,offset,length,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next7;
    Advance8(code,state,offset,length,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next8;
    Advance9(code,state,offset,length,index,word,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next9;
    Advance10(code,state,offset,length,index,word,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next10;
    Advance11(code,state,offset,length,index,word,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next11;
    Advance12(code,state,offset,length,index,word,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next12;
    Advance13(code,state,offset,length,index,word,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next13;
    Advance14(code,state,offset,length,index,word,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next14;
    Advance15(code,state,offset,length,index,word,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next15;
    Advance16(code,state,offset,length,index,word,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next16;
    Advance17(code,state,offset,length,index,word,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next17;
    Advance18(code,state,offset,length,index,word,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(5913,[2874738232,518,offset,length,128,length/32,index,0,word],mem);
    state := next18;
  }
}
