// SPDX-License-Identifier: MIT
// Generated reached exact error instructions; native proof pins error bytes.
include "../scans/Execution.dfy"
include "../scans/Push.dfy"
include "../scans/ErrorBytes.dfy"
include "../scans/Scalar.dfy"
module BytecodeIndexUnaligned {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  import E = BytecodeScanExecution
  predicate Admitted(offset: Word, length: Word, needle: Word) { length%32 != 0 }
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
                                              code[8247] == 91 &&
                                              code[8248] == 21 &&
                                              code[8249] == 97 &&
                                              code[8250] == 32 &&
                                              code[8251] == 88 &&
                                              code[8252] == 87 &&
                                              code[8253] == 96 &&
                                              code[8254] == 64 &&
                                              code[8255] == 81 &&
                                              code[8256] == 99 &&
                                              code[8257] == 169 &&
                                              code[8258] == 73 &&
                                              code[8259] == 210 &&
                                              code[8260] == 133 &&
                                              code[8261] == 96 &&
                                              code[8262] == 224 &&
                                              code[8263] == 27 &&
                                              code[8264] == 129 &&
                                              code[8265] == 82 &&
                                              code[8266] == 96 &&
                                              code[8267] == 4 &&
                                              code[8268] == 129 &&
                                              code[8269] == 1 &&
                                              code[8270] == 132 &&
                                              code[8271] == 144 &&
                                              code[8272] == 82 &&
                                              code[8273] == 96 &&
                                              code[8274] == 36 &&
                                              code[8275] == 1 &&
                                              code[8276] == 97 &&
                                              code[8277] == 4 &&
                                              code[8278] == 90 &&
                                              code[8279] == 86 &&
                                              code[8280] == 91
  }
  function Destinations(): set<nat> { {1114,8280} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, needle: Word) { Admitted(offset,length,needle) && (
                                                                                             if id == 0 then state == Running(8247,[3904669827,604,offset,length,needle,0,length%32],Store([],64,128))
                                                                                             else if id == 1 then state == Running(8248,[3904669827,604,offset,length,needle,0,length%32],Store([],64,128))
                                                                                             else if id == 2 then state == Running(8249,[3904669827,604,offset,length,needle,0,0],Store([],64,128))
                                                                                             else if id == 3 then state == Running(8252,[3904669827,604,offset,length,needle,0,0,8280],Store([],64,128))
                                                                                             else if id == 4 then state == Running(8253,[3904669827,604,offset,length,needle,0],Store([],64,128))
                                                                                             else if id == 5 then state == Running(8255,[3904669827,604,offset,length,needle,0,64],Store([],64,128))
                                                                                             else if id == 6 then state == Running(8256,[3904669827,604,offset,length,needle,0,128],Store([],64,128))
                                                                                             else if id == 7 then state == Running(8261,[3904669827,604,offset,length,needle,0,128,2840187525],Store([],64,128))
                                                                                             else if id == 8 then state == Running(8263,[3904669827,604,offset,length,needle,0,128,2840187525,224],Store([],64,128))
                                                                                             else if id == 9 then state == Running(8264,[3904669827,604,offset,length,needle,0,128,76571304198706574440581817779139944469371563965523062767188772062285424230400],Store([],64,128))
                                                                                             else if id == 10 then state == Running(8265,[3904669827,604,offset,length,needle,0,128,76571304198706574440581817779139944469371563965523062767188772062285424230400,128],Store([],64,128))
                                                                                             else if id == 11 then state == Running(8266,[3904669827,604,offset,length,needle,0,128],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400))
                                                                                             else if id == 12 then state == Running(8268,[3904669827,604,offset,length,needle,0,128,4],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400))
                                                                                             else if id == 13 then state == Running(8269,[3904669827,604,offset,length,needle,0,128,4,128],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400))
                                                                                             else if id == 14 then state == Running(8270,[3904669827,604,offset,length,needle,0,128,132],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400))
                                                                                             else if id == 15 then state == Running(8271,[3904669827,604,offset,length,needle,0,128,132,length],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400))
                                                                                             else if id == 16 then state == Running(8272,[3904669827,604,offset,length,needle,0,128,length,132],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400))
                                                                                             else if id == 17 then state == Running(8273,[3904669827,604,offset,length,needle,0,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 18 then state == Running(8275,[3904669827,604,offset,length,needle,0,128,36],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 19 then state == Running(8276,[3904669827,604,offset,length,needle,0,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 20 then state == Running(8279,[3904669827,604,offset,length,needle,0,164,1114],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 21 then state == Running(1114,[3904669827,604,offset,length,needle,0,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 22 then state == Running(1115,[3904669827,604,offset,length,needle,0,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 23 then state == Running(1117,[3904669827,604,offset,length,needle,0,164,64],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 24 then state == Running(1118,[3904669827,604,offset,length,needle,0,164,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 25 then state == Running(1119,[3904669827,604,offset,length,needle,0,164,128,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 26 then state == Running(1120,[3904669827,604,offset,length,needle,0,128,128,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 27 then state == Running(1121,[3904669827,604,offset,length,needle,0,128,36],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else if id == 28 then state == Running(1122,[3904669827,604,offset,length,needle,0,36,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length))
                                                                                             else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(0,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8247,[3904669827,604,offset,length,needle,0,length%32],Store([],64,128));
    assert Fetch(code,8247) == Op(91,8248,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(1,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8248,[3904669827,604,offset,length,needle,0,length%32],Store([],64,128));
    assert Fetch(code,8248) == Op(21,8249,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(2,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8249,[3904669827,604,offset,length,needle,0,0],Store([],64,128));
    F.Push2(code,8249);
    assert Fetch(code,8249) == Op(97,8252,8280);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(3,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8252,[3904669827,604,offset,length,needle,0,0,8280],Store([],64,128));
    assert Fetch(code,8252) == Op(87,8253,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(4,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8253,[3904669827,604,offset,length,needle,0],Store([],64,128));
    F.Push1(code,8253);
    assert Fetch(code,8253) == Op(96,8255,64);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(5,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8255,[3904669827,604,offset,length,needle,0,64],Store([],64,128));
    assert Fetch(code,8255) == Op(81,8256,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(6,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8256,[3904669827,604,offset,length,needle,0,128],Store([],64,128));
    P.Push4(code,8256);
    assert Fetch(code,8256) == Op(99,8261,2840187525);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(7,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8261,[3904669827,604,offset,length,needle,0,128,2840187525],Store([],64,128));
    F.Push1(code,8261);
    assert Fetch(code,8261) == Op(96,8263,224);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(8,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    SC.ErrorSelectors();
    assert state == Running(8263,[3904669827,604,offset,length,needle,0,128,2840187525,224],Store([],64,128));
    assert Fetch(code,8263) == Op(27,8264,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(9,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(8264,[3904669827,604,offset,length,needle,0,128,76571304198706574440581817779139944469371563965523062767188772062285424230400],Store([],64,128));
    assert Fetch(code,8264) == Op(129,8265,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(10,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    assert state == Running(8265,[3904669827,604,offset,length,needle,0,128,76571304198706574440581817779139944469371563965523062767188772062285424230400,128],Store([],64,128));
    assert Fetch(code,8265) == Op(82,8266,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(11,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    assert state == Running(8266,[3904669827,604,offset,length,needle,0,128],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400));
    F.Push1(code,8266);
    assert Fetch(code,8266) == Op(96,8268,4);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(12,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    assert state == Running(8268,[3904669827,604,offset,length,needle,0,128,4],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400));
    assert Fetch(code,8268) == Op(129,8269,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(13,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    assert state == Running(8269,[3904669827,604,offset,length,needle,0,128,4,128],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400));
    assert Fetch(code,8269) == Op(1,8270,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(14,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    assert state == Running(8270,[3904669827,604,offset,length,needle,0,128,132],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400));
    assert Fetch(code,8270) == Op(132,8271,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(15,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    assert state == Running(8271,[3904669827,604,offset,length,needle,0,128,132,length],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400));
    assert Fetch(code,8271) == Op(144,8272,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(16,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(8272,[3904669827,604,offset,length,needle,0,128,length,132],Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400));
    assert Fetch(code,8272) == Op(82,8273,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(17,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(8273,[3904669827,604,offset,length,needle,0,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    F.Push1(code,8273);
    assert Fetch(code,8273) == Op(96,8275,36);
  }
  lemma Advance18(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(18,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(8275,[3904669827,604,offset,length,needle,0,128,36],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,8275) == Op(1,8276,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(19,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(8276,[3904669827,604,offset,length,needle,0,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    F.Push2(code,8276);
    assert Fetch(code,8276) == Op(97,8279,1114);
  }
  lemma Advance20(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(20,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(8279,[3904669827,604,offset,length,needle,0,164,1114],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,8279) == Op(86,8280,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(21,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(1114,[3904669827,604,offset,length,needle,0,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(22,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(1115,[3904669827,604,offset,length,needle,0,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance23(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(23,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    R.StoredFrame(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400,64);
    R.StoredFrame(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length,64);
    assert state == Running(1117,[3904669827,604,offset,length,needle,0,164,64],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(24,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(1118,[3904669827,604,offset,length,needle,0,164,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(25,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(1119,[3904669827,604,offset,length,needle,0,164,128,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(26,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(1120,[3904669827,604,offset,length,needle,0,128,128,164],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(27,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,offset,length,needle)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    assert state == Running(1121,[3904669827,604,offset,length,needle,0,128,36],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle) && Good(28,state,offset,length,needle)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(2840187525,4)+G.Encode(length,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400);
    R.StoredWord(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length);
    ER.PhysicalError(Store([],64,128),128,2840187525,76571304198706574440581817779139944469371563965523062767188772062285424230400,length);
    assert state == Running(1122,[3904669827,604,offset,length,needle,0,36,128],Store(Store(Store([],64,128),128,76571304198706574440581817779139944469371563965523062767188772062285424230400),132,length));
    assert Fetch(code,1122) == Op(253,1123,0);
  }
  lemma Start(offset: Word, length: Word, needle: Word)
    requires Admitted(offset,length,needle)
    ensures Good(0,Running(8247,[3904669827,604,offset,length,needle,0,length%32],Store([],64,128)),offset,length,needle)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, needle: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,needle)
    ensures state == Reverted(G.Encode(2840187525,4)+G.Encode(length,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 30 && trace[0] == Running(8247,[3904669827,604,offset,length,needle,0,length%32],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(offset,length,needle);
    state := Running(8247,[3904669827,604,offset,length,needle,0,length%32],Store([],64,128));
    trace := [state];
    Advance0(code,state,offset,length,needle,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,offset,length,needle,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,offset,length,needle,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,offset,length,needle,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,offset,length,needle,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,offset,length,needle,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,offset,length,needle,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,offset,length,needle,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,offset,length,needle,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,offset,length,needle,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,offset,length,needle,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,offset,length,needle,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,offset,length,needle,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,offset,length,needle,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,offset,length,needle,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,offset,length,needle,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,offset,length,needle,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,offset,length,needle,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,offset,length,needle,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,offset,length,needle,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
    Advance20(code,state,offset,length,needle,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    state := next20;
    Advance21(code,state,offset,length,needle,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    state := next21;
    Advance22(code,state,offset,length,needle,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    state := next22;
    Advance23(code,state,offset,length,needle,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    state := next23;
    Advance24(code,state,offset,length,needle,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    state := next24;
    Advance25(code,state,offset,length,needle,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    state := next25;
    Advance26(code,state,offset,length,needle,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    state := next26;
    Advance27(code,state,offset,length,needle,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    state := next27;
    Advance28(code,state,offset,length,needle,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    state := next28;
  }
}
