// SPDX-License-Identifier: MIT
// Generated reached exact error instructions; native proof pins error bytes.
include "Execution.dfy"
include "Push.dfy"
include "ErrorBytes.dfy"
include "Scalar.dfy"
module BytecodeSumOverflow {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  import E = BytecodeScanExecution
  predicate Admitted(prefix: seq<Word>, a: Word, b: Word) { |prefix| <= 1000 && (a as nat)+(b as nat) >= G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[13698] == 91 &&
                                              code[23542] == 91 &&
                                              code[23543] == 99 &&
                                              code[23544] == 78 &&
                                              code[23545] == 72 &&
                                              code[23546] == 123 &&
                                              code[23547] == 113 &&
                                              code[23548] == 96 &&
                                              code[23549] == 224 &&
                                              code[23550] == 27 &&
                                              code[23551] == 95 &&
                                              code[23552] == 82 &&
                                              code[23553] == 96 &&
                                              code[23554] == 17 &&
                                              code[23555] == 96 &&
                                              code[23556] == 4 &&
                                              code[23557] == 82 &&
                                              code[23558] == 96 &&
                                              code[23559] == 36 &&
                                              code[23560] == 95 &&
                                              code[23561] == 253 &&
                                              code[23604] == 91 &&
                                              code[23605] == 128 &&
                                              code[23606] == 130 &&
                                              code[23607] == 1 &&
                                              code[23608] == 128 &&
                                              code[23609] == 130 &&
                                              code[23610] == 17 &&
                                              code[23611] == 21 &&
                                              code[23612] == 97 &&
                                              code[23613] == 53 &&
                                              code[23614] == 130 &&
                                              code[23615] == 87 &&
                                              code[23616] == 97 &&
                                              code[23617] == 53 &&
                                              code[23618] == 130 &&
                                              code[23619] == 97 &&
                                              code[23620] == 91 &&
                                              code[23621] == 246 &&
                                              code[23622] == 86
  }
  function Destinations(): set<nat> { {13698,23542} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, a: Word, b: Word) { Admitted(prefix,a,b) && (
                                                                                        if id == 0 then state == Running(23604,prefix+[2904,a,b],Store([],64,128))
                                                                                        else if id == 1 then state == Running(23605,prefix+[2904,a,b],Store([],64,128))
                                                                                        else if id == 2 then state == Running(23606,prefix+[2904,a,b,b],Store([],64,128))
                                                                                        else if id == 3 then state == Running(23607,prefix+[2904,a,b,b,a],Store([],64,128))
                                                                                        else if id == 4 then state == Running(23608,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus()],Store([],64,128))
                                                                                        else if id == 5 then state == Running(23609,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus()],Store([],64,128))
                                                                                        else if id == 6 then state == Running(23610,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus(),b],Store([],64,128))
                                                                                        else if id == 7 then state == Running(23611,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),1],Store([],64,128))
                                                                                        else if id == 8 then state == Running(23612,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),0],Store([],64,128))
                                                                                        else if id == 9 then state == Running(23615,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),0,13698],Store([],64,128))
                                                                                        else if id == 10 then state == Running(23616,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus()],Store([],64,128))
                                                                                        else if id == 11 then state == Running(23619,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store([],64,128))
                                                                                        else if id == 12 then state == Running(23622,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,23542],Store([],64,128))
                                                                                        else if id == 13 then state == Running(23542,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store([],64,128))
                                                                                        else if id == 14 then state == Running(23543,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store([],64,128))
                                                                                        else if id == 15 then state == Running(23548,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,1313373041],Store([],64,128))
                                                                                        else if id == 16 then state == Running(23550,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,1313373041,224],Store([],64,128))
                                                                                        else if id == 17 then state == Running(23551,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,35408467139433450592217433187231851964531694900788300625387963629091585785856],Store([],64,128))
                                                                                        else if id == 18 then state == Running(23552,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,35408467139433450592217433187231851964531694900788300625387963629091585785856,0],Store([],64,128))
                                                                                        else if id == 19 then state == Running(23553,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                                        else if id == 20 then state == Running(23555,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,17],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                                        else if id == 21 then state == Running(23557,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,17,4],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                                        else if id == 22 then state == Running(23558,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17))
                                                                                        else if id == 23 then state == Running(23560,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,36],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17))
                                                                                        else if id == 24 then state == Running(23561,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,36,0],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17))
                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(0,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23604,prefix+[2904,a,b],Store([],64,128));
    assert Fetch(code,23604) == Op(91,23605,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(1,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23605,prefix+[2904,a,b],Store([],64,128));
    assert Fetch(code,23605) == Op(128,23606,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(2,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23606,prefix+[2904,a,b,b],Store([],64,128));
    assert Fetch(code,23606) == Op(130,23607,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(3,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23607,prefix+[2904,a,b,b,a],Store([],64,128));
    assert Fetch(code,23607) == Op(1,23608,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(4,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23608,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus()],Store([],64,128));
    assert Fetch(code,23608) == Op(128,23609,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(5,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23609,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus()],Store([],64,128));
    assert Fetch(code,23609) == Op(130,23610,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(6,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23610,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus(),b],Store([],64,128));
    assert Fetch(code,23610) == Op(17,23611,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(7,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23611,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),1],Store([],64,128));
    assert Fetch(code,23611) == Op(21,23612,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(8,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23612,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),0],Store([],64,128));
    F.Push2(code,23612);
    assert Fetch(code,23612) == Op(97,23615,13698);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(9,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23615,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),0,13698],Store([],64,128));
    assert Fetch(code,23615) == Op(87,23616,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(10,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23616,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus()],Store([],64,128));
    F.Push2(code,23616);
    assert Fetch(code,23616) == Op(97,23619,13698);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(11,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23619,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store([],64,128));
    F.Push2(code,23619);
    assert Fetch(code,23619) == Op(97,23622,23542);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(12,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23622,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,23542],Store([],64,128));
    assert Fetch(code,23622) == Op(86,23623,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(13,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23542,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store([],64,128));
    assert Fetch(code,23542) == Op(91,23543,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(14,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23543,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store([],64,128));
    P.Push4(code,23543);
    assert Fetch(code,23543) == Op(99,23548,1313373041);
  }
  lemma Advance15(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(15,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23548,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,1313373041],Store([],64,128));
    F.Push1(code,23548);
    assert Fetch(code,23548) == Op(96,23550,224);
  }
  lemma Advance16(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(16,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    SC.ErrorSelectors();
    assert state == Running(23550,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,1313373041,224],Store([],64,128));
    assert Fetch(code,23550) == Op(27,23551,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(17,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23551,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,35408467139433450592217433187231851964531694900788300625387963629091585785856],Store([],64,128));
    assert Fetch(code,23551) == Op(95,23552,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(18,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23552,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,35408467139433450592217433187231851964531694900788300625387963629091585785856,0],Store([],64,128));
    assert Fetch(code,23552) == Op(82,23553,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(19,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23553,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    F.Push1(code,23553);
    assert Fetch(code,23553) == Op(96,23555,17);
  }
  lemma Advance20(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(20,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23555,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,17],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    F.Push1(code,23555);
    assert Fetch(code,23555) == Op(96,23557,4);
  }
  lemma Advance21(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(21,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17);
    assert state == Running(23557,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,17,4],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    assert Fetch(code,23557) == Op(82,23558,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(22,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17);
    assert state == Running(23558,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17));
    F.Push1(code,23558);
    assert Fetch(code,23558) == Op(96,23560,36);
  }
  lemma Advance23(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(23,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,prefix,a,b)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17);
    assert state == Running(23560,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,36],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17));
    assert Fetch(code,23560) == Op(95,23561,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b) && Good(24,state,prefix,a,b)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(1313373041,4)+G.Encode(17,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17);
    ER.PhysicalError(Store([],64,128),0,1313373041,35408467139433450592217433187231851964531694900788300625387963629091585785856,17);
    assert state == Running(23561,prefix+[2904,a,b,((a as nat)+(b as nat))%G.Modulus(),13698,36,0],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,17));
    assert Fetch(code,23561) == Op(253,23562,0);
  }
  lemma Start(prefix: seq<Word>, a: Word, b: Word)
    requires Admitted(prefix,a,b)
    ensures Good(0,Running(23604,prefix+[2904,a,b],Store([],64,128)),prefix,a,b)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, a: Word, b: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,a,b)
    ensures state == Reverted(G.Encode(1313373041,4)+G.Encode(17,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 26 && trace[0] == Running(23604,prefix+[2904,a,b],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(prefix,a,b);
    state := Running(23604,prefix+[2904,a,b],Store([],64,128));
    trace := [state];
    Advance0(code,state,prefix,a,b,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,a,b,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,a,b,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,a,b,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,a,b,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,a,b,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,a,b,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,a,b,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,a,b,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,a,b,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,a,b,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,a,b,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,prefix,a,b,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,prefix,a,b,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,prefix,a,b,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,prefix,a,b,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,prefix,a,b,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,prefix,a,b,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,prefix,a,b,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,prefix,a,b,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
    Advance20(code,state,prefix,a,b,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    state := next20;
    Advance21(code,state,prefix,a,b,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    state := next21;
    Advance22(code,state,prefix,a,b,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    state := next22;
    Advance23(code,state,prefix,a,b,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    state := next23;
    Advance24(code,state,prefix,a,b,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    state := next24;
  }
}
