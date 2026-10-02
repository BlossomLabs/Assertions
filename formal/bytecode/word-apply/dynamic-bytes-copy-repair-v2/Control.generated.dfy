// SPDX-License-Identifier: MIT
// Generated complete physical shared bytes ABI copy; arbitrary fitting payload length.
include "Memory.dfy"
include "../callback-success/Scalar.dfy"
include "../../scans/Fetch.dfy"
module BytecodeApplyDynamicBytesCopyControl {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import M = BytecodeCopyMachine
  import B = BytecodeCopyMemory
  import E = BytecodeCopyExecution
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import H = BytecodeApplyDynamicBytesCopyMemory
  import CS = BytecodeApplyCallbackSuccessScalar
  opaque predicate Matches(code: seq<Byte>,returnPc: Word) { |code| == 24560 && returnPc < |code| && code[returnPc] == 0x5b && code[20951] == 91 &&
                                                             code[20952] == 95 &&
                                                             code[20953] == 129 &&
                                                             code[20954] == 81 &&
                                                             code[20955] == 128 &&
                                                             code[20956] == 132 &&
                                                             code[20957] == 82 &&
                                                             code[20958] == 128 &&
                                                             code[20959] == 96 &&
                                                             code[20960] == 32 &&
                                                             code[20961] == 132 &&
                                                             code[20962] == 1 &&
                                                             code[20963] == 96 &&
                                                             code[20964] == 32 &&
                                                             code[20965] == 134 &&
                                                             code[20966] == 1 &&
                                                             code[20967] == 94 &&
                                                             code[20968] == 95 &&
                                                             code[20969] == 96 &&
                                                             code[20970] == 32 &&
                                                             code[20971] == 130 &&
                                                             code[20972] == 134 &&
                                                             code[20973] == 1 &&
                                                             code[20974] == 1 &&
                                                             code[20975] == 82 &&
                                                             code[20976] == 96 &&
                                                             code[20977] == 32 &&
                                                             code[20978] == 96 &&
                                                             code[20979] == 31 &&
                                                             code[20980] == 25 &&
                                                             code[20981] == 96 &&
                                                             code[20982] == 31 &&
                                                             code[20983] == 131 &&
                                                             code[20984] == 1 &&
                                                             code[20985] == 22 &&
                                                             code[20986] == 133 &&
                                                             code[20987] == 1 &&
                                                             code[20988] == 1 &&
                                                             code[20989] == 145 &&
                                                             code[20990] == 80 &&
                                                             code[20991] == 80 &&
                                                             code[20992] == 146 &&
                                                             code[20993] == 145 &&
                                                             code[20994] == 80 &&
                                                             code[20995] == 80 &&
                                                             code[20996] == 86 }
  function Destinations(returnPc: Word): set<nat> { {returnPc} }
  predicate Admitted(mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>) { H.Fits(mem,src,dst,length,payload) && |prefix| <= 1015 }
  opaque predicate Good(id: nat,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>) { Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && (
                                                                                                                                                                                  if id == 0 then state == Running(20951,prefix+[returnPc,dst,src],H.Stage(mem,src,dst,length,payload,0))
                                                                                                                                                                                  else if id == 1 then state == Running(20952,prefix+[returnPc,dst,src],H.Stage(mem,src,dst,length,payload,0))
                                                                                                                                                                                  else if id == 2 then state == Running(20953,prefix+[returnPc,dst,src,0],H.Stage(mem,src,dst,length,payload,0))
                                                                                                                                                                                  else if id == 3 then state == Running(20954,prefix+[returnPc,dst,src,0,src],H.Stage(mem,src,dst,length,payload,0))
                                                                                                                                                                                  else if id == 4 then state == Running(20955,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,0))
                                                                                                                                                                                  else if id == 5 then state == Running(20956,prefix+[returnPc,dst,src,0,length,length],H.Stage(mem,src,dst,length,payload,0))
                                                                                                                                                                                  else if id == 6 then state == Running(20957,prefix+[returnPc,dst,src,0,length,length,dst],H.Stage(mem,src,dst,length,payload,0))
                                                                                                                                                                                  else if id == 7 then state == Running(20958,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 8 then state == Running(20959,prefix+[returnPc,dst,src,0,length,length],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 9 then state == Running(20961,prefix+[returnPc,dst,src,0,length,length,32],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 10 then state == Running(20962,prefix+[returnPc,dst,src,0,length,length,32,src],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 11 then state == Running(20963,prefix+[returnPc,dst,src,0,length,length,src+32],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 12 then state == Running(20965,prefix+[returnPc,dst,src,0,length,length,src+32,32],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 13 then state == Running(20966,prefix+[returnPc,dst,src,0,length,length,src+32,32,dst],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 14 then state == Running(20967,prefix+[returnPc,dst,src,0,length,length,src+32,dst+32],H.Stage(mem,src,dst,length,payload,1))
                                                                                                                                                                                  else if id == 15 then state == Running(20968,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,2))
                                                                                                                                                                                  else if id == 16 then state == Running(20969,prefix+[returnPc,dst,src,0,length,0],H.Stage(mem,src,dst,length,payload,2))
                                                                                                                                                                                  else if id == 17 then state == Running(20971,prefix+[returnPc,dst,src,0,length,0,32],H.Stage(mem,src,dst,length,payload,2))
                                                                                                                                                                                  else if id == 18 then state == Running(20972,prefix+[returnPc,dst,src,0,length,0,32,length],H.Stage(mem,src,dst,length,payload,2))
                                                                                                                                                                                  else if id == 19 then state == Running(20973,prefix+[returnPc,dst,src,0,length,0,32,length,dst],H.Stage(mem,src,dst,length,payload,2))
                                                                                                                                                                                  else if id == 20 then state == Running(20974,prefix+[returnPc,dst,src,0,length,0,32,dst+length],H.Stage(mem,src,dst,length,payload,2))
                                                                                                                                                                                  else if id == 21 then state == Running(20975,prefix+[returnPc,dst,src,0,length,0,dst+32+length],H.Stage(mem,src,dst,length,payload,2))
                                                                                                                                                                                  else if id == 22 then state == Running(20976,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 23 then state == Running(20978,prefix+[returnPc,dst,src,0,length,32],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 24 then state == Running(20980,prefix+[returnPc,dst,src,0,length,32,31],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 25 then state == Running(20981,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 26 then state == Running(20983,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 27 then state == Running(20984,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31,length],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 28 then state == Running(20985,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,length+31],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 29 then state == Running(20986,prefix+[returnPc,dst,src,0,length,32,S.Round32(length)],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 30 then state == Running(20987,prefix+[returnPc,dst,src,0,length,32,S.Round32(length),dst],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 31 then state == Running(20988,prefix+[returnPc,dst,src,0,length,32,dst+S.Round32(length)],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 32 then state == Running(20989,prefix+[returnPc,dst,src,0,length,H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 33 then state == Running(20990,prefix+[returnPc,dst,src,H.End(dst,length),length,0],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 34 then state == Running(20991,prefix+[returnPc,dst,src,H.End(dst,length),length],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 35 then state == Running(20992,prefix+[returnPc,dst,src,H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 36 then state == Running(20993,prefix+[H.End(dst,length),dst,src,returnPc],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 37 then state == Running(20994,prefix+[H.End(dst,length),returnPc,src,dst],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 38 then state == Running(20995,prefix+[H.End(dst,length),returnPc,src],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else if id == 39 then state == Running(20996,prefix+[H.End(dst,length),returnPc],H.Stage(mem,src,dst,length,payload,3))
                                                                                                                                                                                  else false) }
  lemma Advance0(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(0,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(1,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,0);H.Headers(mem,src,dst,length,payload,0);
    assert state == Running(20951,prefix+[returnPc,dst,src],H.Stage(mem,src,dst,length,payload,0));
    assert Fetch(code,20951) == Op(91,20952,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance1(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(1,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(2,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,0);H.Headers(mem,src,dst,length,payload,0);
    assert state == Running(20952,prefix+[returnPc,dst,src],H.Stage(mem,src,dst,length,payload,0));
    assert Fetch(code,20952) == Op(95,20953,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance2(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(2,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(3,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,0);H.Headers(mem,src,dst,length,payload,0);
    assert state == Running(20953,prefix+[returnPc,dst,src,0],H.Stage(mem,src,dst,length,payload,0));
    assert Fetch(code,20953) == Op(129,20954,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance3(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(3,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(4,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,0);H.Headers(mem,src,dst,length,payload,0);
    assert state == Running(20954,prefix+[returnPc,dst,src,0,src],H.Stage(mem,src,dst,length,payload,0));
    assert Fetch(code,20954) == Op(81,20955,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance4(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(4,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(5,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,0);H.Headers(mem,src,dst,length,payload,0);
    assert state == Running(20955,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,0));
    assert Fetch(code,20955) == Op(128,20956,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance5(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(5,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(6,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,0);H.Headers(mem,src,dst,length,payload,0);
    assert state == Running(20956,prefix+[returnPc,dst,src,0,length,length],H.Stage(mem,src,dst,length,payload,0));
    assert Fetch(code,20956) == Op(132,20957,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance6(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(6,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(7,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,0);H.Headers(mem,src,dst,length,payload,0);
    assert state == Running(20957,prefix+[returnPc,dst,src,0,length,length,dst],H.Stage(mem,src,dst,length,payload,0));
    assert Fetch(code,20957) == Op(82,20958,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
    reveal H.Stage();
  }
  lemma Advance7(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(7,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(8,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20958,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,1));
    assert Fetch(code,20958) == Op(128,20959,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance8(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(8,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(9,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20959,prefix+[returnPc,dst,src,0,length,length],H.Stage(mem,src,dst,length,payload,1));
    F.Push1(code,20959);
    assert Fetch(code,20959) == Op(96,20961,32);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance9(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(9,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(10,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20961,prefix+[returnPc,dst,src,0,length,length,32],H.Stage(mem,src,dst,length,payload,1));
    assert Fetch(code,20961) == Op(132,20962,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance10(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(10,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(11,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20962,prefix+[returnPc,dst,src,0,length,length,32,src],H.Stage(mem,src,dst,length,payload,1));
    assert Fetch(code,20962) == Op(1,20963,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance11(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(11,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(12,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20963,prefix+[returnPc,dst,src,0,length,length,src+32],H.Stage(mem,src,dst,length,payload,1));
    F.Push1(code,20963);
    assert Fetch(code,20963) == Op(96,20965,32);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance12(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(12,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(13,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20965,prefix+[returnPc,dst,src,0,length,length,src+32,32],H.Stage(mem,src,dst,length,payload,1));
    assert Fetch(code,20965) == Op(134,20966,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance13(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(13,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(14,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20966,prefix+[returnPc,dst,src,0,length,length,src+32,32,dst],H.Stage(mem,src,dst,length,payload,1));
    assert Fetch(code,20966) == Op(1,20967,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance14(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(14,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(15,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,1);H.Headers(mem,src,dst,length,payload,1);
    assert state == Running(20967,prefix+[returnPc,dst,src,0,length,length,src+32,dst+32],H.Stage(mem,src,dst,length,payload,1));
    assert Fetch(code,20967) == Op(94,20968,0);
    CS.Append(prefix,[returnPc,dst,src,0,length],[length,src+32,dst+32]);
    var base := prefix+[returnPc,dst,src,0,length];
    assert prefix+[returnPc,dst,src,0,length,length,src+32,dst+32] == base+[length,src+32,dst+32];
    assert state == Running(20967,base+[length,src+32,dst+32],H.Stage(mem,src,dst,length,payload,1));
    M.MemoryStep(code,20967,base,H.Stage(mem,src,dst,length,payload,1),dst+32,src+32,length,value,data);
    assert M.Step(code,{},state,value,data) == Running(20968,base,B.Memory(H.Stage(mem,src,dst,length,payload,1),dst+32,src+32,length));
    assert M.Step(code,{},state,value,data) != Bad;
    E.WidenStep(code,{},Destinations(returnPc),state,value,data);
    reveal H.Stage();
  }
  lemma Advance15(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(15,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(16,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,2);H.Headers(mem,src,dst,length,payload,2);
    assert state == Running(20968,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,2));
    assert Fetch(code,20968) == Op(95,20969,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance16(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(16,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(17,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,2);H.Headers(mem,src,dst,length,payload,2);
    assert state == Running(20969,prefix+[returnPc,dst,src,0,length,0],H.Stage(mem,src,dst,length,payload,2));
    F.Push1(code,20969);
    assert Fetch(code,20969) == Op(96,20971,32);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance17(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(17,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(18,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,2);H.Headers(mem,src,dst,length,payload,2);
    assert state == Running(20971,prefix+[returnPc,dst,src,0,length,0,32],H.Stage(mem,src,dst,length,payload,2));
    assert Fetch(code,20971) == Op(130,20972,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance18(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(18,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(19,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,2);H.Headers(mem,src,dst,length,payload,2);
    assert state == Running(20972,prefix+[returnPc,dst,src,0,length,0,32,length],H.Stage(mem,src,dst,length,payload,2));
    assert Fetch(code,20972) == Op(134,20973,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance19(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(19,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(20,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,2);H.Headers(mem,src,dst,length,payload,2);
    assert state == Running(20973,prefix+[returnPc,dst,src,0,length,0,32,length,dst],H.Stage(mem,src,dst,length,payload,2));
    assert Fetch(code,20973) == Op(1,20974,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance20(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(20,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(21,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,2);H.Headers(mem,src,dst,length,payload,2);
    assert state == Running(20974,prefix+[returnPc,dst,src,0,length,0,32,dst+length],H.Stage(mem,src,dst,length,payload,2));
    assert Fetch(code,20974) == Op(1,20975,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance21(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(21,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(22,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,2);H.Headers(mem,src,dst,length,payload,2);
    assert state == Running(20975,prefix+[returnPc,dst,src,0,length,0,dst+32+length],H.Stage(mem,src,dst,length,payload,2));
    assert Fetch(code,20975) == Op(82,20976,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
    reveal H.Stage();
  }
  lemma Advance22(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(22,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(23,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20976,prefix+[returnPc,dst,src,0,length],H.Stage(mem,src,dst,length,payload,3));
    F.Push1(code,20976);
    assert Fetch(code,20976) == Op(96,20978,32);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance23(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(23,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(24,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20978,prefix+[returnPc,dst,src,0,length,32],H.Stage(mem,src,dst,length,payload,3));
    F.Push1(code,20978);
    assert Fetch(code,20978) == Op(96,20980,31);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance24(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(24,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(25,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    CS.Not31();
    assert state == Running(20980,prefix+[returnPc,dst,src,0,length,32,31],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20980) == Op(25,20981,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance25(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(25,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(26,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20981,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904],H.Stage(mem,src,dst,length,payload,3));
    F.Push1(code,20981);
    assert Fetch(code,20981) == Op(96,20983,31);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance26(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(26,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(27,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20983,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20983) == Op(131,20984,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance27(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(27,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(28,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20984,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31,length],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20984) == Op(1,20985,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance28(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(28,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(29,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    CS.Not31();H.Round(length);
    assert state == Running(20985,prefix+[returnPc,dst,src,0,length,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,length+31],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20985) == Op(22,20986,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance29(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(29,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(30,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20986,prefix+[returnPc,dst,src,0,length,32,S.Round32(length)],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20986) == Op(133,20987,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance30(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(30,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(31,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20987,prefix+[returnPc,dst,src,0,length,32,S.Round32(length),dst],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20987) == Op(1,20988,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance31(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(31,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(32,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20988,prefix+[returnPc,dst,src,0,length,32,dst+S.Round32(length)],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20988) == Op(1,20989,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance32(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(32,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(33,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20989,prefix+[returnPc,dst,src,0,length,H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20989) == Op(145,20990,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance33(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(33,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(34,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20990,prefix+[returnPc,dst,src,H.End(dst,length),length,0],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20990) == Op(80,20991,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance34(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(34,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(35,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20991,prefix+[returnPc,dst,src,H.End(dst,length),length],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20991) == Op(80,20992,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance35(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(35,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(36,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20992,prefix+[returnPc,dst,src,H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20992) == Op(146,20993,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance36(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(36,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(37,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20993,prefix+[H.End(dst,length),dst,src,returnPc],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20993) == Op(145,20994,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance37(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(37,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(38,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20994,prefix+[H.End(dst,length),returnPc,src,dst],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20994) == Op(80,20995,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance38(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(38,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); Good(39,next,mem,prefix,src,dst,length,payload,returnPc,value,data)
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20995,prefix+[H.End(dst,length),returnPc,src],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20995) == Op(80,20996,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  lemma Advance39(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(39,state,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); next == Running(returnPc,prefix+[H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3))
  { hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,3);H.Headers(mem,src,dst,length,payload,3);
    assert state == Running(20996,prefix+[H.End(dst,length),returnPc],H.Stage(mem,src,dst,length,payload,3));
    assert Fetch(code,20996) == Op(86,20997,0);
    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();
  }
  ghost method Block0(code: seq<Byte>,initial: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>) returns (frame: State,trace: seq<State>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(0,initial,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures Good(20,frame,mem,prefix,src,dst,length,payload,returnPc,value,data) && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(returnPc),value,data,trace) by { reveal E.Trace(); }
    Advance0(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next0 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next0);trace := trace+[next0];frame := next0;
    Advance1(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next1 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next1);trace := trace+[next1];frame := next1;
    Advance2(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next2 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next2);trace := trace+[next2];frame := next2;
    Advance3(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next3 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next3);trace := trace+[next3];frame := next3;
    Advance4(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next4 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next4);trace := trace+[next4];frame := next4;
    Advance5(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next5 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next5);trace := trace+[next5];frame := next5;
    Advance6(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next6 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next6);trace := trace+[next6];frame := next6;
    Advance7(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next7 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next7);trace := trace+[next7];frame := next7;
    Advance8(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next8 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next8);trace := trace+[next8];frame := next8;
    Advance9(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next9 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next9);trace := trace+[next9];frame := next9;
    Advance10(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next10 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next10);trace := trace+[next10];frame := next10;
    Advance11(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next11 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next11);trace := trace+[next11];frame := next11;
    Advance12(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next12 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next12);trace := trace+[next12];frame := next12;
    Advance13(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next13 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next13);trace := trace+[next13];frame := next13;
    Advance14(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next14 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next14);trace := trace+[next14];frame := next14;
    Advance15(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next15 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next15);trace := trace+[next15];frame := next15;
    Advance16(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next16 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next16);trace := trace+[next16];frame := next16;
    Advance17(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next17 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next17);trace := trace+[next17];frame := next17;
    Advance18(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next18 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next18);trace := trace+[next18];frame := next18;
    Advance19(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next19 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next19);trace := trace+[next19];frame := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>) returns (frame: State,trace: seq<State>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data) && Good(20,initial,mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures frame == Running(returnPc,prefix+[H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3)) && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(returnPc),value,data,trace) by { reveal E.Trace(); }
    Advance20(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next20 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next20);trace := trace+[next20];frame := next20;
    Advance21(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next21 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next21);trace := trace+[next21];frame := next21;
    Advance22(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next22 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next22);trace := trace+[next22];frame := next22;
    Advance23(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next23 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next23);trace := trace+[next23];frame := next23;
    Advance24(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next24 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next24);trace := trace+[next24];frame := next24;
    Advance25(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next25 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next25);trace := trace+[next25];frame := next25;
    Advance26(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next26 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next26);trace := trace+[next26];frame := next26;
    Advance27(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next27 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next27);trace := trace+[next27];frame := next27;
    Advance28(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next28 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next28);trace := trace+[next28];frame := next28;
    Advance29(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next29 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next29);trace := trace+[next29];frame := next29;
    Advance30(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next30 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next30);trace := trace+[next30];frame := next30;
    Advance31(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next31 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next31);trace := trace+[next31];frame := next31;
    Advance32(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next32 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next32);trace := trace+[next32];frame := next32;
    Advance33(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next33 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next33);trace := trace+[next33];frame := next33;
    Advance34(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next34 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next34);trace := trace+[next34];frame := next34;
    Advance35(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next35 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next35);trace := trace+[next35];frame := next35;
    Advance36(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next36 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next36);trace := trace+[next36];frame := next36;
    Advance37(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next37 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next37);trace := trace+[next37];frame := next37;
    Advance38(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next38 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next38);trace := trace+[next38];frame := next38;
    Advance39(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    var next39 := M.Step(code,Destinations(returnPc),frame,value,data);
    E.Extend(code,Destinations(returnPc),value,data,trace,next39);trace := trace+[next39];frame := next39;
  }
  ghost method Run(code: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>) returns (frame: State,trace: seq<State>)
    requires Matches(code,returnPc) && Admitted(mem,prefix,src,dst,length,payload,returnPc,value,data)
    ensures frame == Running(returnPc,prefix+[H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3)) && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == 41 && trace[0] == Running(20951,prefix+[returnPc,dst,src],H.Stage(mem,src,dst,length,payload,0)) && trace[|trace|-1] == frame
  { hide E.Trace();frame := Running(20951,prefix+[returnPc,dst,src],H.Stage(mem,src,dst,length,payload,0));trace := [frame];reveal Good();
    var part: seq<State>;
    assert E.Trace(code,Destinations(returnPc),value,data,trace) by { reveal E.Trace(); }
    frame,part := Block0(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    E.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    frame,part := Block1(code,frame,mem,prefix,src,dst,length,payload,returnPc,value,data);
    E.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
