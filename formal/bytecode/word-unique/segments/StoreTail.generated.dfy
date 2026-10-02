// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUniqueSegmentStoreTail {
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
  predicate Admitted(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && ordered <= 1 && kept <= index <= length/32 && j <= kept && seen <= 1 && index < length/32 && seen == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6724] == 91 &&
                                              code[6909] == 91 &&
                                              code[6910] == 150 &&
                                              code[6911] == 80 &&
                                              code[6912] == 132 &&
                                              code[6913] == 96 &&
                                              code[6914] == 32 &&
                                              code[6915] == 145 &&
                                              code[6916] == 130 &&
                                              code[6917] == 2 &&
                                              code[6918] == 146 &&
                                              code[6919] == 144 &&
                                              code[6920] == 146 &&
                                              code[6921] == 1 &&
                                              code[6922] == 1 &&
                                              code[6923] == 82 &&
                                              code[6924] == 86 &&
                                              code[6925] == 91 &&
                                              code[6926] == 80 &&
                                              code[6927] == 80 &&
                                              code[6928] == 96 &&
                                              code[6929] == 1 &&
                                              code[6930] == 1 &&
                                              code[6931] == 97 &&
                                              code[6932] == 26 &&
                                              code[6933] == 68 &&
                                              code[6934] == 86
  }
  function Destinations(): set<nat> { {6724,6925} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>) { Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && (
                                                                                                                                                                                    if id == 0 then state == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem)
                                                                                                                                                                                    else if id == 1 then state == Running(6910,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem)
                                                                                                                                                                                    else if id == 2 then state == Running(6911,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept,kept],mem)
                                                                                                                                                                                    else if id == 3 then state == Running(6912,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept],mem)
                                                                                                                                                                                    else if id == 4 then state == Running(6913,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept,word],mem)
                                                                                                                                                                                    else if id == 5 then state == Running(6915,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept,word,32],mem)
                                                                                                                                                                                    else if id == 6 then state == Running(6916,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,32,word,kept],mem)
                                                                                                                                                                                    else if id == 7 then state == Running(6917,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,32,word,kept,32],mem)
                                                                                                                                                                                    else if id == 8 then state == Running(6918,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,32,word,((32 as nat)*(kept as nat))%G.Modulus()],mem)
                                                                                                                                                                                    else if id == 9 then state == Running(6919,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,((32 as nat)*(kept as nat))%G.Modulus(),32,word,128],mem)
                                                                                                                                                                                    else if id == 10 then state == Running(6920,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,((32 as nat)*(kept as nat))%G.Modulus(),32,128,word],mem)
                                                                                                                                                                                    else if id == 11 then state == Running(6921,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,word,32,128,((32 as nat)*(kept as nat))%G.Modulus()],mem)
                                                                                                                                                                                    else if id == 12 then state == Running(6922,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,word,32,((((32 as nat)*(kept as nat))%G.Modulus() as nat)+(128 as nat))%G.Modulus()],mem)
                                                                                                                                                                                    else if id == 13 then state == Running(6923,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,word,((((((32 as nat)*(kept as nat))%G.Modulus() as nat)+(128 as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                                                                                                                    else if id == 14 then state == Running(6924,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925],Store(mem,Target(kept),word))
                                                                                                                                                                                    else if id == 15 then state == Running(6925,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen],Store(mem,Target(kept),word))
                                                                                                                                                                                    else if id == 16 then state == Running(6926,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen],Store(mem,Target(kept),word))
                                                                                                                                                                                    else if id == 17 then state == Running(6927,[3045624246,518,offset,length,ordered,128,kept+1,index,word],Store(mem,Target(kept),word))
                                                                                                                                                                                    else if id == 18 then state == Running(6928,[3045624246,518,offset,length,ordered,128,kept+1,index],Store(mem,Target(kept),word))
                                                                                                                                                                                    else if id == 19 then state == Running(6930,[3045624246,518,offset,length,ordered,128,kept+1,index,1],Store(mem,Target(kept),word))
                                                                                                                                                                                    else if id == 20 then state == Running(6931,[3045624246,518,offset,length,ordered,128,kept+1,((1 as nat)+(index as nat))%G.Modulus()],Store(mem,Target(kept),word))
                                                                                                                                                                                    else if id == 21 then state == Running(6934,[3045624246,518,offset,length,ordered,128,kept+1,((1 as nat)+(index as nat))%G.Modulus(),6724],Store(mem,Target(kept),word))
                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(0,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    assert Fetch(code,6909) == Op(91,6910,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(1,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6910,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    assert Fetch(code,6910) == Op(150,6911,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(2,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6911,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept,kept],mem);
    assert Fetch(code,6911) == Op(80,6912,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(3,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6912,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept],mem);
    assert Fetch(code,6912) == Op(132,6913,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(4,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6913,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept,word],mem);
    F.Push1(code,6913);
    assert Fetch(code,6913) == Op(96,6915,32);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(5,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6915,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,kept,word,32],mem);
    assert Fetch(code,6915) == Op(145,6916,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(6,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6916,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,32,word,kept],mem);
    assert Fetch(code,6916) == Op(130,6917,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(7,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6917,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,32,word,kept,32],mem);
    assert Fetch(code,6917) == Op(2,6918,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(8,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6918,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,128,32,word,((32 as nat)*(kept as nat))%G.Modulus()],mem);
    assert Fetch(code,6918) == Op(146,6919,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(9,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6919,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,((32 as nat)*(kept as nat))%G.Modulus(),32,word,128],mem);
    assert Fetch(code,6919) == Op(144,6920,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(10,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6920,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,((32 as nat)*(kept as nat))%G.Modulus(),32,128,word],mem);
    assert Fetch(code,6920) == Op(146,6921,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(11,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6921,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,word,32,128,((32 as nat)*(kept as nat))%G.Modulus()],mem);
    assert Fetch(code,6921) == Op(1,6922,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(12,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6922,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,word,32,((((32 as nat)*(kept as nat))%G.Modulus() as nat)+(128 as nat))%G.Modulus()],mem);
    assert Fetch(code,6922) == Op(1,6923,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(13,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6923,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925,word,((((((32 as nat)*(kept as nat))%G.Modulus() as nat)+(128 as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,6923) == Op(82,6924,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(14,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6924,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen,6925],Store(mem,Target(kept),word));
    assert Fetch(code,6924) == Op(86,6925,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(15,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6925,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen],Store(mem,Target(kept),word));
    assert Fetch(code,6925) == Op(91,6926,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(16,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6926,[3045624246,518,offset,length,ordered,128,kept+1,index,word,seen],Store(mem,Target(kept),word));
    assert Fetch(code,6926) == Op(80,6927,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(17,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6927,[3045624246,518,offset,length,ordered,128,kept+1,index,word],Store(mem,Target(kept),word));
    assert Fetch(code,6927) == Op(80,6928,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(18,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6928,[3045624246,518,offset,length,ordered,128,kept+1,index],Store(mem,Target(kept),word));
    F.Push1(code,6928);
    assert Fetch(code,6928) == Op(96,6930,1);
  }
  lemma Advance19(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(19,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6930,[3045624246,518,offset,length,ordered,128,kept+1,index,1],Store(mem,Target(kept),word));
    assert Fetch(code,6930) == Op(1,6931,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(20,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6931,[3045624246,518,offset,length,ordered,128,kept+1,((1 as nat)+(index as nat))%G.Modulus()],Store(mem,Target(kept),word));
    F.Push2(code,6931);
    assert Fetch(code,6931) == Op(97,6934,6724);
  }
  lemma Advance21(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(21,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6724,[3045624246,518,offset,length,ordered,128,kept+1,index+1],Store(mem,Target(kept),word))
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6934,[3045624246,518,offset,length,ordered,128,kept+1,((1 as nat)+(index as nat))%G.Modulus(),6724],Store(mem,Target(kept),word));
    assert Fetch(code,6934) == Op(86,6935,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures Good(0,Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem),offset,length,ordered,kept,index,j,word,last,seen,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures state == Running(6724,[3045624246,518,offset,length,ordered,128,kept+1,index+1],Store(mem,Target(kept),word))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 23 && trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,kept,index,j,word,last,seen,mem);
    state := Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next5;
    Advance6(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next6;
    Advance7(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next7;
    Advance8(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next8;
    Advance9(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next9;
    Advance10(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next10;
    Advance11(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next11;
    Advance12(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next12;
    Advance13(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next13;
    Advance14(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next14;
    Advance15(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next15;
    Advance16(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next16;
    Advance17(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next17;
    Advance18(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next18;
    Advance19(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next19;
    Advance20(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next20;
    Advance21(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(6909,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,kept+1],mem);
    state := next21;
  }
}
