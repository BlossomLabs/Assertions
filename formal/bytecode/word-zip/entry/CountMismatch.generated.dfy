// SPDX-License-Identifier: MIT
// Generated reached exact error instructions; native proof pins error bytes.
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
include "../../scans/ErrorBytes.dfy"
include "../../scans/Scalar.dfy"
include "ErrorScalar.dfy"
include "ErrorMemory.dfy"
module BytecodeZipErrorCountMismatch {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  import E = BytecodeScanExecution
  import CS = BytecodeZipErrorScalar
  import EM = BytecodeZipErrorMemory
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { lengthA%32 == 0 && lengthB%32 == 0 && lengthA != lengthB }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[1114] == 91 &&
                                              code[1115] == 96 &&
                                              code[1116] == 64 &&
                                              code[1117] == 81 &&
                                              code[1118] == 128 &&
                                              code[1119] == 145 &&
                                              code[1120] == 3 &&
                                              code[1121] == 144 &&
                                              code[1122] == 253 &&
                                              code[1965] == 91 &&
                                              code[1966] == 96 &&
                                              code[1967] == 64 &&
                                              code[1968] == 81 &&
                                              code[1969] == 99 &&
                                              code[1970] == 13 &&
                                              code[1971] == 136 &&
                                              code[1972] == 49 &&
                                              code[1973] == 181 &&
                                              code[1974] == 96 &&
                                              code[1975] == 225 &&
                                              code[1976] == 27 &&
                                              code[1977] == 129 &&
                                              code[1978] == 82 &&
                                              code[1979] == 96 &&
                                              code[1980] == 4 &&
                                              code[1981] == 129 &&
                                              code[1982] == 1 &&
                                              code[1983] == 146 &&
                                              code[1984] == 144 &&
                                              code[1985] == 146 &&
                                              code[1986] == 82 &&
                                              code[1987] == 96 &&
                                              code[1988] == 36 &&
                                              code[1989] == 130 &&
                                              code[1990] == 1 &&
                                              code[1991] == 82 &&
                                              code[1992] == 96 &&
                                              code[1993] == 68 &&
                                              code[1994] == 1 &&
                                              code[1995] == 97 &&
                                              code[1996] == 4 &&
                                              code[1997] == 90 &&
                                              code[1998] == 86
  }
  function Destinations(): set<nat> { {1114} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                   if id == 0 then state == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128))
                                                                                                   else if id == 1 then state == Running(1966,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128))
                                                                                                   else if id == 2 then state == Running(1968,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,64],Store([],64,128))
                                                                                                   else if id == 3 then state == Running(1969,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128],Store([],64,128))
                                                                                                   else if id == 4 then state == Running(1974,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,227029429],Store([],64,128))
                                                                                                   else if id == 5 then state == Running(1976,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,227029429,225],Store([],64,128))
                                                                                                   else if id == 6 then state == Running(1977,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,12241402595427325619135859360680904127253452502879841799436131849436112355328],Store([],64,128))
                                                                                                   else if id == 7 then state == Running(1978,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,12241402595427325619135859360680904127253452502879841799436131849436112355328,128],Store([],64,128))
                                                                                                   else if id == 8 then state == Running(1979,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328))
                                                                                                   else if id == 9 then state == Running(1981,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,4],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328))
                                                                                                   else if id == 10 then state == Running(1982,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,4,128],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328))
                                                                                                   else if id == 11 then state == Running(1983,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,132],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328))
                                                                                                   else if id == 12 then state == Running(1984,[269019481,518,a,lengthA,b,lengthB,96,132,lengthB/32,128,lengthA/32],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328))
                                                                                                   else if id == 13 then state == Running(1985,[269019481,518,a,lengthA,b,lengthB,96,132,lengthB/32,lengthA/32,128],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328))
                                                                                                   else if id == 14 then state == Running(1986,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,lengthA/32,132],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328))
                                                                                                   else if id == 15 then state == Running(1987,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32))
                                                                                                   else if id == 16 then state == Running(1989,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,36],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32))
                                                                                                   else if id == 17 then state == Running(1990,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,36,128],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32))
                                                                                                   else if id == 18 then state == Running(1991,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,164],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32))
                                                                                                   else if id == 19 then state == Running(1992,[269019481,518,a,lengthA,b,lengthB,96,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 20 then state == Running(1994,[269019481,518,a,lengthA,b,lengthB,96,128,68],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 21 then state == Running(1995,[269019481,518,a,lengthA,b,lengthB,96,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 22 then state == Running(1998,[269019481,518,a,lengthA,b,lengthB,96,196,1114],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 23 then state == Running(1114,[269019481,518,a,lengthA,b,lengthB,96,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 24 then state == Running(1115,[269019481,518,a,lengthA,b,lengthB,96,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 25 then state == Running(1117,[269019481,518,a,lengthA,b,lengthB,96,196,64],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 26 then state == Running(1118,[269019481,518,a,lengthA,b,lengthB,96,196,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 27 then state == Running(1119,[269019481,518,a,lengthA,b,lengthB,96,196,128,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 28 then state == Running(1120,[269019481,518,a,lengthA,b,lengthB,96,128,128,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 29 then state == Running(1121,[269019481,518,a,lengthA,b,lengthB,96,128,68],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else if id == 30 then state == Running(1122,[269019481,518,a,lengthA,b,lengthB,96,68,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32))
                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(0,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    assert Fetch(code,1965) == Op(91,1966,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(1,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(1966,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    F.Push1(code,1966);
    assert Fetch(code,1966) == Op(96,1968,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(2,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(1968,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,64],Store([],64,128));
    assert Fetch(code,1968) == Op(81,1969,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(3,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(1969,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128],Store([],64,128));
    P.Push4(code,1969);
    assert Fetch(code,1969) == Op(99,1974,227029429);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(4,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(1974,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,227029429],Store([],64,128));
    F.Push1(code,1974);
    assert Fetch(code,1974) == Op(96,1976,225);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(5,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    CS.WordCountMismatchHalfSelector();
    assert state == Running(1976,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,227029429,225],Store([],64,128));
    assert Fetch(code,1976) == Op(27,1977,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(6,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(1977,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,12241402595427325619135859360680904127253452502879841799436131849436112355328],Store([],64,128));
    assert Fetch(code,1977) == Op(129,1978,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(7,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1978,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,12241402595427325619135859360680904127253452502879841799436131849436112355328,128],Store([],64,128));
    assert Fetch(code,1978) == Op(82,1979,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(8,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    assert state == Running(1979,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328));
    F.Push1(code,1979);
    assert Fetch(code,1979) == Op(96,1981,4);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(9,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    assert state == Running(1981,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,4],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328));
    assert Fetch(code,1981) == Op(129,1982,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(10,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    assert state == Running(1982,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,4,128],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328));
    assert Fetch(code,1982) == Op(1,1983,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(11,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    assert state == Running(1983,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32,128,132],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328));
    assert Fetch(code,1983) == Op(146,1984,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(12,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    assert state == Running(1984,[269019481,518,a,lengthA,b,lengthB,96,132,lengthB/32,128,lengthA/32],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328));
    assert Fetch(code,1984) == Op(144,1985,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(13,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    assert state == Running(1985,[269019481,518,a,lengthA,b,lengthB,96,132,lengthB/32,lengthA/32,128],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328));
    assert Fetch(code,1985) == Op(146,1986,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(14,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1986,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,lengthA/32,132],Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328));
    assert Fetch(code,1986) == Op(82,1987,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(15,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    assert state == Running(1987,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32));
    F.Push1(code,1987);
    assert Fetch(code,1987) == Op(96,1989,36);
  }
  lemma Advance16(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(16,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    assert state == Running(1989,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,36],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32));
    assert Fetch(code,1989) == Op(130,1990,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(17,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    assert state == Running(1990,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,36,128],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32));
    assert Fetch(code,1990) == Op(1,1991,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(18,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1991,[269019481,518,a,lengthA,b,lengthB,96,128,lengthB/32,164],Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32));
    assert Fetch(code,1991) == Op(82,1992,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(19,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1992,[269019481,518,a,lengthA,b,lengthB,96,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    F.Push1(code,1992);
    assert Fetch(code,1992) == Op(96,1994,68);
  }
  lemma Advance20(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(20,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1994,[269019481,518,a,lengthA,b,lengthB,96,128,68],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1994) == Op(1,1995,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(21,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1995,[269019481,518,a,lengthA,b,lengthB,96,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    F.Push2(code,1995);
    assert Fetch(code,1995) == Op(97,1998,1114);
  }
  lemma Advance22(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(22,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1998,[269019481,518,a,lengthA,b,lengthB,96,196,1114],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1998) == Op(86,1999,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(23,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1114,[269019481,518,a,lengthA,b,lengthB,96,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(24,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1115,[269019481,518,a,lengthA,b,lengthB,96,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance25(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(25,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    R.StoredFrame(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328,64);
    R.StoredFrame(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32,64);
    R.StoredFrame(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32,64);
    assert state == Running(1117,[269019481,518,a,lengthA,b,lengthB,96,196,64],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(26,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1118,[269019481,518,a,lengthA,b,lengthB,96,196,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(27,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1119,[269019481,518,a,lengthA,b,lengthB,96,196,128,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(28,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1120,[269019481,518,a,lengthA,b,lengthB,96,128,128,196],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(29,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    assert state == Running(1121,[269019481,518,a,lengthA,b,lengthB,96,128,68],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(30,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(454058858,4)+G.Encode(lengthA/32,32)+G.Encode(lengthB/32,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328);
    R.StoredWord(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32);
    R.StoredWord(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32);
    EM.Mismatch(Store([],64,128),lengthA/32,lengthB/32);
    assert state == Running(1122,[269019481,518,a,lengthA,b,lengthB,96,68,128],Store(Store(Store(Store([],64,128),128,12241402595427325619135859360680904127253452502879841799436131849436112355328),132,lengthA/32),164,lengthB/32));
    assert Fetch(code,1122) == Op(253,1123,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128)),a,lengthA,b,lengthB)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Reverted(G.Encode(454058858,4)+G.Encode(lengthA/32,32)+G.Encode(lengthB/32,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 32 && trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(a,lengthA,b,lengthB);
    state := Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    trace := [state];
    Advance0(code,state,a,lengthA,b,lengthB,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next0;
    Advance1(code,state,a,lengthA,b,lengthB,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next1;
    Advance2(code,state,a,lengthA,b,lengthB,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next2;
    Advance3(code,state,a,lengthA,b,lengthB,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next3;
    Advance4(code,state,a,lengthA,b,lengthB,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next4;
    Advance5(code,state,a,lengthA,b,lengthB,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next5;
    Advance6(code,state,a,lengthA,b,lengthB,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next6;
    Advance7(code,state,a,lengthA,b,lengthB,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next7;
    Advance8(code,state,a,lengthA,b,lengthB,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next8;
    Advance9(code,state,a,lengthA,b,lengthB,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next9;
    Advance10(code,state,a,lengthA,b,lengthB,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next10;
    Advance11(code,state,a,lengthA,b,lengthB,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next11;
    Advance12(code,state,a,lengthA,b,lengthB,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next12;
    Advance13(code,state,a,lengthA,b,lengthB,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next13;
    Advance14(code,state,a,lengthA,b,lengthB,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next14;
    Advance15(code,state,a,lengthA,b,lengthB,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next15;
    Advance16(code,state,a,lengthA,b,lengthB,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next16;
    Advance17(code,state,a,lengthA,b,lengthB,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next17;
    Advance18(code,state,a,lengthA,b,lengthB,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next18;
    Advance19(code,state,a,lengthA,b,lengthB,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next19;
    Advance20(code,state,a,lengthA,b,lengthB,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next20;
    Advance21(code,state,a,lengthA,b,lengthB,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next21;
    Advance22(code,state,a,lengthA,b,lengthB,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next22;
    Advance23(code,state,a,lengthA,b,lengthB,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next23;
    Advance24(code,state,a,lengthA,b,lengthB,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next24;
    Advance25(code,state,a,lengthA,b,lengthB,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next25;
    Advance26(code,state,a,lengthA,b,lengthB,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next26;
    Advance27(code,state,a,lengthA,b,lengthB,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next27;
    Advance28(code,state,a,lengthA,b,lengthB,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next28;
    Advance29(code,state,a,lengthA,b,lengthB,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next29;
    Advance30(code,state,a,lengthA,b,lengthB,value,data);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    assert trace[0] == Running(1965,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthB/32],Store([],64,128));
    state := next30;
  }
}
