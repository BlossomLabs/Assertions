// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUniqueSegmentOrderedEmpty {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeUniqueLoopScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { ((index as nat)*32+32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function Target(kept: Word): Word { (160+(kept as nat)*32)%G.Modulus() }
  predicate MemoryAdmitted(mem: seq<Byte>, j: Word, last: Word) { true }
  predicate Admitted(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && ordered <= 1 && kept <= index <= length/32 && j <= kept && seen <= 1 && index < length/32 && ordered == 1 && kept == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6801] == 91 &&
                                              code[6802] == 144 &&
                                              code[6803] == 80 &&
                                              code[6804] == 95 &&
                                              code[6805] == 133 &&
                                              code[6806] == 21 &&
                                              code[6807] == 97 &&
                                              code[6808] == 26 &&
                                              code[6809] == 189 &&
                                              code[6810] == 87 &&
                                              code[6811] == 131 &&
                                              code[6812] == 21 &&
                                              code[6813] == 128 &&
                                              code[6814] == 21 &&
                                              code[6815] == 144 &&
                                              code[6816] == 97 &&
                                              code[6817] == 26 &&
                                              code[6818] == 182 &&
                                              code[6819] == 87 &&
                                              code[6838] == 91 &&
                                              code[6839] == 144 &&
                                              code[6840] == 80 &&
                                              code[6841] == 97 &&
                                              code[6842] == 26 &&
                                              code[6843] == 234 &&
                                              code[6844] == 86 &&
                                              code[6845] == 91 &&
                                              code[6890] == 91
  }
  function Destinations(): set<nat> { {6838,6845,6890} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>) { Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && (
                                                                                                                                                                                    if id == 0 then state == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem)
                                                                                                                                                                                    else if id == 1 then state == Running(6802,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem)
                                                                                                                                                                                    else if id == 2 then state == Running(6803,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem)
                                                                                                                                                                                    else if id == 3 then state == Running(6804,[3045624246,518,offset,length,ordered,128,kept,index,word],mem)
                                                                                                                                                                                    else if id == 4 then state == Running(6805,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem)
                                                                                                                                                                                    else if id == 5 then state == Running(6806,[3045624246,518,offset,length,ordered,128,kept,index,word,0,ordered],mem)
                                                                                                                                                                                    else if id == 6 then state == Running(6807,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem)
                                                                                                                                                                                    else if id == 7 then state == Running(6810,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0,6845],mem)
                                                                                                                                                                                    else if id == 8 then state == Running(6811,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem)
                                                                                                                                                                                    else if id == 9 then state == Running(6812,[3045624246,518,offset,length,ordered,128,kept,index,word,0,kept],mem)
                                                                                                                                                                                    else if id == 10 then state == Running(6813,[3045624246,518,offset,length,ordered,128,kept,index,word,0,1],mem)
                                                                                                                                                                                    else if id == 11 then state == Running(6814,[3045624246,518,offset,length,ordered,128,kept,index,word,0,1,1],mem)
                                                                                                                                                                                    else if id == 12 then state == Running(6815,[3045624246,518,offset,length,ordered,128,kept,index,word,0,1,0],mem)
                                                                                                                                                                                    else if id == 13 then state == Running(6816,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0,1],mem)
                                                                                                                                                                                    else if id == 14 then state == Running(6819,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0,1,6838],mem)
                                                                                                                                                                                    else if id == 15 then state == Running(6838,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem)
                                                                                                                                                                                    else if id == 16 then state == Running(6839,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem)
                                                                                                                                                                                    else if id == 17 then state == Running(6840,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem)
                                                                                                                                                                                    else if id == 18 then state == Running(6841,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem)
                                                                                                                                                                                    else if id == 19 then state == Running(6844,[3045624246,518,offset,length,ordered,128,kept,index,word,0,6890],mem)
                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(0,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    assert Fetch(code,6801) == Op(91,6802,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(1,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6802,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    assert Fetch(code,6802) == Op(144,6803,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(2,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6803,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem);
    assert Fetch(code,6803) == Op(80,6804,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(3,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6804,[3045624246,518,offset,length,ordered,128,kept,index,word],mem);
    assert Fetch(code,6804) == Op(95,6805,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(4,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6805,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem);
    assert Fetch(code,6805) == Op(133,6806,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(5,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6806,[3045624246,518,offset,length,ordered,128,kept,index,word,0,ordered],mem);
    assert Fetch(code,6806) == Op(21,6807,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(6,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6807,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem);
    F.Push2(code,6807);
    assert Fetch(code,6807) == Op(97,6810,6845);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(7,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6810,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0,6845],mem);
    assert Fetch(code,6810) == Op(87,6811,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(8,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6811,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem);
    assert Fetch(code,6811) == Op(131,6812,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(9,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6812,[3045624246,518,offset,length,ordered,128,kept,index,word,0,kept],mem);
    assert Fetch(code,6812) == Op(21,6813,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(10,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6813,[3045624246,518,offset,length,ordered,128,kept,index,word,0,1],mem);
    assert Fetch(code,6813) == Op(128,6814,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(11,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6814,[3045624246,518,offset,length,ordered,128,kept,index,word,0,1,1],mem);
    assert Fetch(code,6814) == Op(21,6815,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(12,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6815,[3045624246,518,offset,length,ordered,128,kept,index,word,0,1,0],mem);
    assert Fetch(code,6815) == Op(144,6816,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(13,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6816,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0,1],mem);
    F.Push2(code,6816);
    assert Fetch(code,6816) == Op(97,6819,6838);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(14,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6819,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0,1,6838],mem);
    assert Fetch(code,6819) == Op(87,6820,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(15,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6838,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem);
    assert Fetch(code,6838) == Op(91,6839,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(16,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6839,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem);
    assert Fetch(code,6839) == Op(144,6840,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(17,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6840,[3045624246,518,offset,length,ordered,128,kept,index,word,0,0],mem);
    assert Fetch(code,6840) == Op(80,6841,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(18,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6841,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem);
    F.Push2(code,6841);
    assert Fetch(code,6841) == Op(97,6844,6890);
  }
  lemma Advance19(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(19,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6844,[3045624246,518,offset,length,ordered,128,kept,index,word,0,6890],mem);
    assert Fetch(code,6844) == Op(86,6845,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures Good(0,Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem),offset,length,ordered,kept,index,j,word,last,seen,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures state == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,0],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,kept,index,j,word,last,seen,mem);
    state := Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next5;
    Advance6(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next6;
    Advance7(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next7;
    Advance8(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next8;
    Advance9(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next9;
    Advance10(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next10;
    Advance11(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next11;
    Advance12(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next12;
    Advance13(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next13;
    Advance14(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next14;
    Advance15(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next15;
    Advance16(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next16;
    Advance17(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next17;
    Advance18(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next18;
    Advance19(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(6801,[3045624246,518,offset,length,ordered,128,kept,index,0,word],mem);
    state := next19;
  }
}
