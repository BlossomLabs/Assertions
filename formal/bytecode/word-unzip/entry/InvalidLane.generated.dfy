// SPDX-License-Identifier: MIT
// Generated reached exact error instructions; native proof pins error bytes.
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
include "../../scans/ErrorBytes.dfy"
include "../../scans/Scalar.dfy"
include "ErrorScalar.dfy"
module BytecodeUnzipErrorInvalidLane {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  import CS = BytecodeUnzipErrorScalar
  import E = BytecodeScanExecution
  predicate Admitted(offset: Word, length: Word, lane: Word) { length%32 == 0 && lane > 1 }
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
                                              code[5982] == 91 &&
                                              code[5983] == 96 &&
                                              code[5984] == 1 &&
                                              code[5985] == 130 &&
                                              code[5986] == 17 &&
                                              code[5987] == 21 &&
                                              code[5988] == 97 &&
                                              code[5989] == 23 &&
                                              code[5990] == 131 &&
                                              code[5991] == 87 &&
                                              code[5992] == 96 &&
                                              code[5993] == 64 &&
                                              code[5994] == 81 &&
                                              code[5995] == 99 &&
                                              code[5996] == 28 &&
                                              code[5997] == 19 &&
                                              code[5998] == 56 &&
                                              code[5999] == 3 &&
                                              code[6000] == 96 &&
                                              code[6001] == 224 &&
                                              code[6002] == 27 &&
                                              code[6003] == 129 &&
                                              code[6004] == 82 &&
                                              code[6005] == 96 &&
                                              code[6006] == 4 &&
                                              code[6007] == 129 &&
                                              code[6008] == 1 &&
                                              code[6009] == 131 &&
                                              code[6010] == 144 &&
                                              code[6011] == 82 &&
                                              code[6012] == 96 &&
                                              code[6013] == 36 &&
                                              code[6014] == 1 &&
                                              code[6015] == 97 &&
                                              code[6016] == 4 &&
                                              code[6017] == 90 &&
                                              code[6018] == 86 &&
                                              code[6019] == 91
  }
  function Destinations(): set<nat> { {1114,6019} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word) { Admitted(offset,length,lane) && (
                                                                                           if id == 0 then state == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128))
                                                                                           else if id == 1 then state == Running(5983,[2989505972,518,offset,length,lane,96],Store([],64,128))
                                                                                           else if id == 2 then state == Running(5985,[2989505972,518,offset,length,lane,96,1],Store([],64,128))
                                                                                           else if id == 3 then state == Running(5986,[2989505972,518,offset,length,lane,96,1,lane],Store([],64,128))
                                                                                           else if id == 4 then state == Running(5987,[2989505972,518,offset,length,lane,96,1],Store([],64,128))
                                                                                           else if id == 5 then state == Running(5988,[2989505972,518,offset,length,lane,96,0],Store([],64,128))
                                                                                           else if id == 6 then state == Running(5991,[2989505972,518,offset,length,lane,96,0,6019],Store([],64,128))
                                                                                           else if id == 7 then state == Running(5992,[2989505972,518,offset,length,lane,96],Store([],64,128))
                                                                                           else if id == 8 then state == Running(5994,[2989505972,518,offset,length,lane,96,64],Store([],64,128))
                                                                                           else if id == 9 then state == Running(5995,[2989505972,518,offset,length,lane,96,128],Store([],64,128))
                                                                                           else if id == 10 then state == Running(6000,[2989505972,518,offset,length,lane,96,128,471021571],Store([],64,128))
                                                                                           else if id == 11 then state == Running(6002,[2989505972,518,offset,length,lane,96,128,471021571,224],Store([],64,128))
                                                                                           else if id == 12 then state == Running(6003,[2989505972,518,offset,length,lane,96,128,12698716433237508449739174868168688147736356049858948261288790313357421838336],Store([],64,128))
                                                                                           else if id == 13 then state == Running(6004,[2989505972,518,offset,length,lane,96,128,12698716433237508449739174868168688147736356049858948261288790313357421838336,128],Store([],64,128))
                                                                                           else if id == 14 then state == Running(6005,[2989505972,518,offset,length,lane,96,128],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336))
                                                                                           else if id == 15 then state == Running(6007,[2989505972,518,offset,length,lane,96,128,4],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336))
                                                                                           else if id == 16 then state == Running(6008,[2989505972,518,offset,length,lane,96,128,4,128],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336))
                                                                                           else if id == 17 then state == Running(6009,[2989505972,518,offset,length,lane,96,128,132],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336))
                                                                                           else if id == 18 then state == Running(6010,[2989505972,518,offset,length,lane,96,128,132,lane],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336))
                                                                                           else if id == 19 then state == Running(6011,[2989505972,518,offset,length,lane,96,128,lane,132],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336))
                                                                                           else if id == 20 then state == Running(6012,[2989505972,518,offset,length,lane,96,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 21 then state == Running(6014,[2989505972,518,offset,length,lane,96,128,36],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 22 then state == Running(6015,[2989505972,518,offset,length,lane,96,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 23 then state == Running(6018,[2989505972,518,offset,length,lane,96,164,1114],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 24 then state == Running(1114,[2989505972,518,offset,length,lane,96,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 25 then state == Running(1115,[2989505972,518,offset,length,lane,96,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 26 then state == Running(1117,[2989505972,518,offset,length,lane,96,164,64],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 27 then state == Running(1118,[2989505972,518,offset,length,lane,96,164,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 28 then state == Running(1119,[2989505972,518,offset,length,lane,96,164,128,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 29 then state == Running(1120,[2989505972,518,offset,length,lane,96,128,128,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 30 then state == Running(1121,[2989505972,518,offset,length,lane,96,128,36],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else if id == 31 then state == Running(1122,[2989505972,518,offset,length,lane,96,36,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane))
                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    assert Fetch(code,5982) == Op(91,5983,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5983,[2989505972,518,offset,length,lane,96],Store([],64,128));
    F.Push1(code,5983);
    assert Fetch(code,5983) == Op(96,5985,1);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5985,[2989505972,518,offset,length,lane,96,1],Store([],64,128));
    assert Fetch(code,5985) == Op(130,5986,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(3,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5986,[2989505972,518,offset,length,lane,96,1,lane],Store([],64,128));
    assert Fetch(code,5986) == Op(17,5987,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(4,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5987,[2989505972,518,offset,length,lane,96,1],Store([],64,128));
    assert Fetch(code,5987) == Op(21,5988,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(5,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5988,[2989505972,518,offset,length,lane,96,0],Store([],64,128));
    F.Push2(code,5988);
    assert Fetch(code,5988) == Op(97,5991,6019);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(6,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5991,[2989505972,518,offset,length,lane,96,0,6019],Store([],64,128));
    assert Fetch(code,5991) == Op(87,5992,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(7,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5992,[2989505972,518,offset,length,lane,96],Store([],64,128));
    F.Push1(code,5992);
    assert Fetch(code,5992) == Op(96,5994,64);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(8,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5994,[2989505972,518,offset,length,lane,96,64],Store([],64,128));
    assert Fetch(code,5994) == Op(81,5995,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(9,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(5995,[2989505972,518,offset,length,lane,96,128],Store([],64,128));
    P.Push4(code,5995);
    assert Fetch(code,5995) == Op(99,6000,471021571);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(10,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(6000,[2989505972,518,offset,length,lane,96,128,471021571],Store([],64,128));
    F.Push1(code,6000);
    assert Fetch(code,6000) == Op(96,6002,224);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(11,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    CS.InvalidLaneSelector();
    assert state == Running(6002,[2989505972,518,offset,length,lane,96,128,471021571,224],Store([],64,128));
    assert Fetch(code,6002) == Op(27,6003,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(12,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(6003,[2989505972,518,offset,length,lane,96,128,12698716433237508449739174868168688147736356049858948261288790313357421838336],Store([],64,128));
    assert Fetch(code,6003) == Op(129,6004,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(13,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    assert state == Running(6004,[2989505972,518,offset,length,lane,96,128,12698716433237508449739174868168688147736356049858948261288790313357421838336,128],Store([],64,128));
    assert Fetch(code,6004) == Op(82,6005,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(14,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    assert state == Running(6005,[2989505972,518,offset,length,lane,96,128],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336));
    F.Push1(code,6005);
    assert Fetch(code,6005) == Op(96,6007,4);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(15,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    assert state == Running(6007,[2989505972,518,offset,length,lane,96,128,4],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336));
    assert Fetch(code,6007) == Op(129,6008,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(16,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    assert state == Running(6008,[2989505972,518,offset,length,lane,96,128,4,128],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336));
    assert Fetch(code,6008) == Op(1,6009,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(17,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    assert state == Running(6009,[2989505972,518,offset,length,lane,96,128,132],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336));
    assert Fetch(code,6009) == Op(131,6010,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(18,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    assert state == Running(6010,[2989505972,518,offset,length,lane,96,128,132,lane],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336));
    assert Fetch(code,6010) == Op(144,6011,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(19,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(6011,[2989505972,518,offset,length,lane,96,128,lane,132],Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336));
    assert Fetch(code,6011) == Op(82,6012,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(20,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(6012,[2989505972,518,offset,length,lane,96,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    F.Push1(code,6012);
    assert Fetch(code,6012) == Op(96,6014,36);
  }
  lemma Advance21(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(21,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(6014,[2989505972,518,offset,length,lane,96,128,36],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,6014) == Op(1,6015,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(22,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(6015,[2989505972,518,offset,length,lane,96,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    F.Push2(code,6015);
    assert Fetch(code,6015) == Op(97,6018,1114);
  }
  lemma Advance23(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(23,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(6018,[2989505972,518,offset,length,lane,96,164,1114],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,6018) == Op(86,6019,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(24,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(1114,[2989505972,518,offset,length,lane,96,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(25,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(1115,[2989505972,518,offset,length,lane,96,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance26(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(26,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    R.StoredFrame(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336,64);
    R.StoredFrame(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane,64);
    assert state == Running(1117,[2989505972,518,offset,length,lane,96,164,64],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(27,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(1118,[2989505972,518,offset,length,lane,96,164,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(28,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(1119,[2989505972,518,offset,length,lane,96,164,128,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(29,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(1120,[2989505972,518,offset,length,lane,96,128,128,164],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(30,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,offset,length,lane)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    assert state == Running(1121,[2989505972,518,offset,length,lane,96,128,36],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(31,state,offset,length,lane)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(471021571,4)+G.Encode(lane,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336);
    R.StoredWord(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane);
    ER.PhysicalError(Store([],64,128),128,471021571,12698716433237508449739174868168688147736356049858948261288790313357421838336,lane);
    assert state == Running(1122,[2989505972,518,offset,length,lane,96,36,128],Store(Store(Store([],64,128),128,12698716433237508449739174868168688147736356049858948261288790313357421838336),132,lane));
    assert Fetch(code,1122) == Op(253,1123,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128)),offset,length,lane)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Reverted(G.Encode(471021571,4)+G.Encode(lane,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 33 && trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(offset,length,lane);
    state := Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    trace := [state];
    Advance0(code,state,offset,length,lane,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next0;
    Advance1(code,state,offset,length,lane,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next1;
    Advance2(code,state,offset,length,lane,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next2;
    Advance3(code,state,offset,length,lane,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next3;
    Advance4(code,state,offset,length,lane,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next4;
    Advance5(code,state,offset,length,lane,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next5;
    Advance6(code,state,offset,length,lane,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next6;
    Advance7(code,state,offset,length,lane,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next7;
    Advance8(code,state,offset,length,lane,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next8;
    Advance9(code,state,offset,length,lane,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next9;
    Advance10(code,state,offset,length,lane,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next10;
    Advance11(code,state,offset,length,lane,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next11;
    Advance12(code,state,offset,length,lane,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next12;
    Advance13(code,state,offset,length,lane,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next13;
    Advance14(code,state,offset,length,lane,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next14;
    Advance15(code,state,offset,length,lane,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next15;
    Advance16(code,state,offset,length,lane,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next16;
    Advance17(code,state,offset,length,lane,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next17;
    Advance18(code,state,offset,length,lane,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next18;
    Advance19(code,state,offset,length,lane,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next19;
    Advance20(code,state,offset,length,lane,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next20;
    Advance21(code,state,offset,length,lane,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next21;
    Advance22(code,state,offset,length,lane,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next22;
    Advance23(code,state,offset,length,lane,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next23;
    Advance24(code,state,offset,length,lane,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next24;
    Advance25(code,state,offset,length,lane,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next25;
    Advance26(code,state,offset,length,lane,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next26;
    Advance27(code,state,offset,length,lane,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next27;
    Advance28(code,state,offset,length,lane,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next28;
    Advance29(code,state,offset,length,lane,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next29;
    Advance30(code,state,offset,length,lane,value,data);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next30;
    Advance31(code,state,offset,length,lane,value,data);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31];
    assert trace[0] == Running(5982,[2989505972,518,offset,length,lane,96],Store([],64,128));
    state := next31;
  }
}
