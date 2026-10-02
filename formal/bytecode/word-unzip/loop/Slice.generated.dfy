// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
module BytecodeUnzipHelperSlice {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word) { |prefix| <= 1000 && start <= end <= length && (offset as nat)+(end as nat) < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6264] == 91 &&
                                              code[23623] == 91 &&
                                              code[23624] == 95 &&
                                              code[23625] == 95 &&
                                              code[23626] == 133 &&
                                              code[23627] == 133 &&
                                              code[23628] == 17 &&
                                              code[23629] == 21 &&
                                              code[23630] == 97 &&
                                              code[23631] == 92 &&
                                              code[23632] == 85 &&
                                              code[23633] == 87 &&
                                              code[23637] == 91 &&
                                              code[23638] == 131 &&
                                              code[23639] == 134 &&
                                              code[23640] == 17 &&
                                              code[23641] == 21 &&
                                              code[23642] == 97 &&
                                              code[23643] == 92 &&
                                              code[23644] == 97 &&
                                              code[23645] == 87 &&
                                              code[23649] == 91 &&
                                              code[23650] == 80 &&
                                              code[23651] == 80 &&
                                              code[23652] == 130 &&
                                              code[23653] == 1 &&
                                              code[23654] == 147 &&
                                              code[23655] == 145 &&
                                              code[23656] == 144 &&
                                              code[23657] == 146 &&
                                              code[23658] == 3 &&
                                              code[23659] == 145 &&
                                              code[23660] == 80 &&
                                              code[23661] == 86
  }
  function Destinations(): set<nat> { {6264,23637,23649} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,offset,length,start,end) && (
      if id == 0 then state == Running(23623,prefix+[6264,end,start,length,offset],mem)
      else if id == 1 then state == Running(23624,prefix+[6264,end,start,length,offset],mem)
      else if id == 2 then state == Running(23625,prefix+[6264,end,start,length,offset,0],mem)
      else if id == 3 then state == Running(23626,prefix+[6264,end,start,length,offset,0,0],mem)
      else if id == 4 then state == Running(23627,prefix+[6264,end,start,length,offset,0,0,end],mem)
      else if id == 5 then state == Running(23628,prefix+[6264,end,start,length,offset,0,0,end,start],mem)
      else if id == 6 then state == Running(23629,prefix+[6264,end,start,length,offset,0,0,0],mem)
      else if id == 7 then state == Running(23630,prefix+[6264,end,start,length,offset,0,0,1],mem)
      else if id == 8 then state == Running(23633,prefix+[6264,end,start,length,offset,0,0,1,23637],mem)
      else if id == 9 then state == Running(23637,prefix+[6264,end,start,length,offset,0,0],mem)
      else if id == 10 then state == Running(23638,prefix+[6264,end,start,length,offset,0,0],mem)
      else if id == 11 then state == Running(23639,prefix+[6264,end,start,length,offset,0,0,length],mem)
      else if id == 12 then state == Running(23640,prefix+[6264,end,start,length,offset,0,0,length,end],mem)
      else if id == 13 then state == Running(23641,prefix+[6264,end,start,length,offset,0,0,0],mem)
      else if id == 14 then state == Running(23642,prefix+[6264,end,start,length,offset,0,0,1],mem)
      else if id == 15 then state == Running(23645,prefix+[6264,end,start,length,offset,0,0,1,23649],mem)
      else if id == 16 then state == Running(23649,prefix+[6264,end,start,length,offset,0,0],mem)
      else if id == 17 then state == Running(23650,prefix+[6264,end,start,length,offset,0,0],mem)
      else if id == 18 then state == Running(23651,prefix+[6264,end,start,length,offset,0],mem)
      else if id == 19 then state == Running(23652,prefix+[6264,end,start,length,offset],mem)
      else if id == 20 then state == Running(23653,prefix+[6264,end,start,length,offset,start],mem)
      else if id == 21 then state == Running(23654,prefix+[6264,end,start,length,((start as nat)+(offset as nat))%G.Modulus()],mem)
      else if id == 22 then state == Running(23655,prefix+[((start as nat)+(offset as nat))%G.Modulus(),end,start,length,6264],mem)
      else if id == 23 then state == Running(23656,prefix+[((start as nat)+(offset as nat))%G.Modulus(),end,6264,length,start],mem)
      else if id == 24 then state == Running(23657,prefix+[((start as nat)+(offset as nat))%G.Modulus(),end,6264,start,length],mem)
      else if id == 25 then state == Running(23658,prefix+[((start as nat)+(offset as nat))%G.Modulus(),length,6264,start,end],mem)
      else if id == 26 then state == Running(23659,prefix+[((start as nat)+(offset as nat))%G.Modulus(),length,6264,((end as nat)+G.Modulus()-(start as nat))%G.Modulus()],mem)
      else if id == 27 then state == Running(23660,prefix+[((start as nat)+(offset as nat))%G.Modulus(),((end as nat)+G.Modulus()-(start as nat))%G.Modulus(),6264,length],mem)
      else if id == 28 then state == Running(23661,prefix+[((start as nat)+(offset as nat))%G.Modulus(),((end as nat)+G.Modulus()-(start as nat))%G.Modulus(),6264],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(0,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23623,prefix+[6264,end,start,length,offset],mem);
    assert Fetch(code,23623) == Op(91,23624,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(1,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23624,prefix+[6264,end,start,length,offset],mem);
    assert Fetch(code,23624) == Op(95,23625,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(2,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23625,prefix+[6264,end,start,length,offset,0],mem);
    assert Fetch(code,23625) == Op(95,23626,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(3,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23626,prefix+[6264,end,start,length,offset,0,0],mem);
    assert Fetch(code,23626) == Op(133,23627,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(4,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23627,prefix+[6264,end,start,length,offset,0,0,end],mem);
    assert Fetch(code,23627) == Op(133,23628,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(5,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23628,prefix+[6264,end,start,length,offset,0,0,end,start],mem);
    assert Fetch(code,23628) == Op(17,23629,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(6,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23629,prefix+[6264,end,start,length,offset,0,0,0],mem);
    assert Fetch(code,23629) == Op(21,23630,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(7,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23630,prefix+[6264,end,start,length,offset,0,0,1],mem);
    F.Push2(code,23630);
    assert Fetch(code,23630) == Op(97,23633,23637);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(8,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23633,prefix+[6264,end,start,length,offset,0,0,1,23637],mem);
    assert Fetch(code,23633) == Op(87,23634,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(9,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23637,prefix+[6264,end,start,length,offset,0,0],mem);
    assert Fetch(code,23637) == Op(91,23638,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(10,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23638,prefix+[6264,end,start,length,offset,0,0],mem);
    assert Fetch(code,23638) == Op(131,23639,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(11,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23639,prefix+[6264,end,start,length,offset,0,0,length],mem);
    assert Fetch(code,23639) == Op(134,23640,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(12,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23640,prefix+[6264,end,start,length,offset,0,0,length,end],mem);
    assert Fetch(code,23640) == Op(17,23641,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(13,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23641,prefix+[6264,end,start,length,offset,0,0,0],mem);
    assert Fetch(code,23641) == Op(21,23642,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(14,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23642,prefix+[6264,end,start,length,offset,0,0,1],mem);
    F.Push2(code,23642);
    assert Fetch(code,23642) == Op(97,23645,23649);
  }
  lemma Advance15(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(15,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23645,prefix+[6264,end,start,length,offset,0,0,1,23649],mem);
    assert Fetch(code,23645) == Op(87,23646,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(16,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23649,prefix+[6264,end,start,length,offset,0,0],mem);
    assert Fetch(code,23649) == Op(91,23650,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(17,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23650,prefix+[6264,end,start,length,offset,0,0],mem);
    assert Fetch(code,23650) == Op(80,23651,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(18,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23651,prefix+[6264,end,start,length,offset,0],mem);
    assert Fetch(code,23651) == Op(80,23652,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(19,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23652,prefix+[6264,end,start,length,offset],mem);
    assert Fetch(code,23652) == Op(130,23653,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(20,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23653,prefix+[6264,end,start,length,offset,start],mem);
    assert Fetch(code,23653) == Op(1,23654,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(21,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23654,prefix+[6264,end,start,length,((start as nat)+(offset as nat))%G.Modulus()],mem);
    assert Fetch(code,23654) == Op(147,23655,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(22,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23655,prefix+[((start as nat)+(offset as nat))%G.Modulus(),end,start,length,6264],mem);
    assert Fetch(code,23655) == Op(145,23656,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(23,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23656,prefix+[((start as nat)+(offset as nat))%G.Modulus(),end,6264,length,start],mem);
    assert Fetch(code,23656) == Op(144,23657,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(24,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23657,prefix+[((start as nat)+(offset as nat))%G.Modulus(),end,6264,start,length],mem);
    assert Fetch(code,23657) == Op(146,23658,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(25,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23658,prefix+[((start as nat)+(offset as nat))%G.Modulus(),length,6264,start,end],mem);
    assert Fetch(code,23658) == Op(3,23659,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(26,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23659,prefix+[((start as nat)+(offset as nat))%G.Modulus(),length,6264,((end as nat)+G.Modulus()-(start as nat))%G.Modulus()],mem);
    assert Fetch(code,23659) == Op(145,23660,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(27,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,prefix,offset,length,start,end,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23660,prefix+[((start as nat)+(offset as nat))%G.Modulus(),((end as nat)+G.Modulus()-(start as nat))%G.Modulus(),6264,length],mem);
    assert Fetch(code,23660) == Op(80,23661,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end) && Good(28,state,prefix,offset,length,start,end,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6264,prefix+[((offset as nat)+(start as nat)),((end as nat)-(start as nat))],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23661,prefix+[((start as nat)+(offset as nat))%G.Modulus(),((end as nat)+G.Modulus()-(start as nat))%G.Modulus(),6264],mem);
    assert Fetch(code,23661) == Op(86,23662,0);
  }
  lemma Start(prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,offset,length,start,end)
    ensures Good(0,Running(23623,prefix+[6264,end,start,length,offset],mem),prefix,offset,length,start,end,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, offset: Word, length: Word, start: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,offset,length,start,end)
    ensures state == Running(6264,prefix+[((offset as nat)+(start as nat)),((end as nat)-(start as nat))],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 30 && trace[0] == Running(23623,prefix+[6264,end,start,length,offset],mem) && trace[|trace|-1] == state
  {
    Start(prefix,offset,length,start,end,mem,data);
    state := Running(23623,prefix+[6264,end,start,length,offset],mem);
    trace := [state];
    Advance0(code,state,prefix,offset,length,start,end,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,offset,length,start,end,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,offset,length,start,end,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,offset,length,start,end,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,offset,length,start,end,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,offset,length,start,end,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,offset,length,start,end,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,offset,length,start,end,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,offset,length,start,end,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,offset,length,start,end,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,offset,length,start,end,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,offset,length,start,end,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,prefix,offset,length,start,end,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,prefix,offset,length,start,end,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,prefix,offset,length,start,end,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,prefix,offset,length,start,end,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,prefix,offset,length,start,end,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,prefix,offset,length,start,end,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,prefix,offset,length,start,end,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,prefix,offset,length,start,end,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
    Advance20(code,state,prefix,offset,length,start,end,mem,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    state := next20;
    Advance21(code,state,prefix,offset,length,start,end,mem,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    state := next21;
    Advance22(code,state,prefix,offset,length,start,end,mem,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    state := next22;
    Advance23(code,state,prefix,offset,length,start,end,mem,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    state := next23;
    Advance24(code,state,prefix,offset,length,start,end,mem,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    state := next24;
    Advance25(code,state,prefix,offset,length,start,end,mem,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    state := next25;
    Advance26(code,state,prefix,offset,length,start,end,mem,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    state := next26;
    Advance27(code,state,prefix,offset,length,start,end,mem,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    state := next27;
    Advance28(code,state,prefix,offset,length,start,end,mem,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    state := next28;
  }
}
