// SPDX-License-Identifier: MIT
// Generated complete physical window rejection path; native proof pins exact error bytes.
include "../windows/Inputs.dfy"
include "../../scans/Push.dfy"
include "Memory.dfy"
include "Scalar.dfy"
module BytecodeApplyWindowErrorShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import H = BytecodeApplyWindowErrorMemory
  import SC = BytecodeApplyWindowErrorScalar
  import E = BytecodeScanExecution
  predicate Admitted(prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) { templateLength < 32 && |prefix| <= 1015 }
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
                                              code[16683] == 91 &&
                                              code[16684] == 96 &&
                                              code[16685] == 32 &&
                                              code[16686] == 131 &&
                                              code[16687] == 16 &&
                                              code[16688] == 21 &&
                                              code[16689] == 97 &&
                                              code[16690] == 65 &&
                                              code[16691] == 86 &&
                                              code[16692] == 87 &&
                                              code[16693] == 96 &&
                                              code[16694] == 64 &&
                                              code[16695] == 81 &&
                                              code[16696] == 99 &&
                                              code[16697] == 13 &&
                                              code[16698] == 6 &&
                                              code[16699] == 193 &&
                                              code[16700] == 239 &&
                                              code[16701] == 96 &&
                                              code[16702] == 225 &&
                                              code[16703] == 27 &&
                                              code[16704] == 129 &&
                                              code[16705] == 82 &&
                                              code[16706] == 95 &&
                                              code[16707] == 96 &&
                                              code[16708] == 4 &&
                                              code[16709] == 130 &&
                                              code[16710] == 1 &&
                                              code[16711] == 82 &&
                                              code[16712] == 96 &&
                                              code[16713] == 36 &&
                                              code[16714] == 129 &&
                                              code[16715] == 1 &&
                                              code[16716] == 132 &&
                                              code[16717] == 144 &&
                                              code[16718] == 82 &&
                                              code[16719] == 96 &&
                                              code[16720] == 68 &&
                                              code[16721] == 1 &&
                                              code[16722] == 97 &&
                                              code[16723] == 4 &&
                                              code[16724] == 90 &&
                                              code[16725] == 86 &&
                                              code[16726] == 91
  }
  function Destinations(): set<nat> { {1114,16726} }
  opaque predicate Good(id: nat,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) { Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && (
                                                                                                                                                                                                           if id == 0 then state == Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 1 then state == Running(16684,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 2 then state == Running(16686,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32],Store([],64,128))
                                                                                                                                                                                                           else if id == 3 then state == Running(16687,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32,templateLength],Store([],64,128))
                                                                                                                                                                                                           else if id == 4 then state == Running(16688,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,1],Store([],64,128))
                                                                                                                                                                                                           else if id == 5 then state == Running(16689,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0],Store([],64,128))
                                                                                                                                                                                                           else if id == 6 then state == Running(16692,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0,16726],Store([],64,128))
                                                                                                                                                                                                           else if id == 7 then state == Running(16693,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 8 then state == Running(16695,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,64],Store([],64,128))
                                                                                                                                                                                                           else if id == 9 then state == Running(16696,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store([],64,128))
                                                                                                                                                                                                           else if id == 10 then state == Running(16701,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,218546671],Store([],64,128))
                                                                                                                                                                                                           else if id == 11 then state == Running(16703,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,218546671,225],Store([],64,128))
                                                                                                                                                                                                           else if id == 12 then state == Running(16704,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,11784013188886634765289199401549831190745770750984918956358808852095274319872],Store([],64,128))
                                                                                                                                                                                                           else if id == 13 then state == Running(16705,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,11784013188886634765289199401549831190745770750984918956358808852095274319872,128],Store([],64,128))
                                                                                                                                                                                                           else if id == 14 then state == Running(16706,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 15 then state == Running(16707,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 16 then state == Running(16709,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0,4],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 17 then state == Running(16710,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0,4,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 18 then state == Running(16711,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0,132],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 19 then state == Running(16712,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0))
                                                                                                                                                                                                           else if id == 20 then state == Running(16714,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,36],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0))
                                                                                                                                                                                                           else if id == 21 then state == Running(16715,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,36,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0))
                                                                                                                                                                                                           else if id == 22 then state == Running(16716,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0))
                                                                                                                                                                                                           else if id == 23 then state == Running(16717,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,164,templateLength],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0))
                                                                                                                                                                                                           else if id == 24 then state == Running(16718,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,templateLength,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0))
                                                                                                                                                                                                           else if id == 25 then state == Running(16719,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 26 then state == Running(16721,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 27 then state == Running(16722,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 28 then state == Running(16725,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,1114],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 29 then state == Running(1114,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 30 then state == Running(1115,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 31 then state == Running(1117,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,64],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 32 then state == Running(1118,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 33 then state == Running(1119,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,128,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 34 then state == Running(1120,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,128,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 35 then state == Running(1121,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else if id == 36 then state == Running(1122,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,68,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength))
                                                                                                                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(0,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128));
    assert Fetch(code,16683) == Op(91,16684,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(1,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16684,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128));
    F.Push1(code,16684);
    assert Fetch(code,16684) == Op(96,16686,32);
  }
  lemma Advance2(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(2,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16686,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32],Store([],64,128));
    assert Fetch(code,16686) == Op(131,16687,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(3,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16687,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32,templateLength],Store([],64,128));
    assert Fetch(code,16687) == Op(16,16688,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(4,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16688,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,1],Store([],64,128));
    assert Fetch(code,16688) == Op(21,16689,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(5,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16689,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0],Store([],64,128));
    F.Push2(code,16689);
    assert Fetch(code,16689) == Op(97,16692,16726);
  }
  lemma Advance6(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(6,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16692,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0,16726],Store([],64,128));
    assert Fetch(code,16692) == Op(87,16693,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(7,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16693,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128));
    F.Push1(code,16693);
    assert Fetch(code,16693) == Op(96,16695,64);
  }
  lemma Advance8(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(8,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16695,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,64],Store([],64,128));
    assert Fetch(code,16695) == Op(81,16696,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(9,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16696,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store([],64,128));
    P.Push4(code,16696);
    assert Fetch(code,16696) == Op(99,16701,218546671);
  }
  lemma Advance10(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(10,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16701,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,218546671],Store([],64,128));
    F.Push1(code,16701);
    assert Fetch(code,16701) == Op(96,16703,225);
  }
  lemma Advance11(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(11,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);

    SC.Selector();

    assert state == Running(16703,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,218546671,225],Store([],64,128));
    assert Fetch(code,16703) == Op(27,16704,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(12,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16704,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,11784013188886634765289199401549831190745770750984918956358808852095274319872],Store([],64,128));
    assert Fetch(code,16704) == Op(129,16705,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(13,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16705,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,11784013188886634765289199401549831190745770750984918956358808852095274319872,128],Store([],64,128));
    assert Fetch(code,16705) == Op(82,16706,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(14,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16706,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16706) == Op(95,16707,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(15,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16707,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    F.Push1(code,16707);
    assert Fetch(code,16707) == Op(96,16709,4);
  }
  lemma Advance16(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(16,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16709,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0,4],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16709) == Op(130,16710,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(17,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16710,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0,4,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16710) == Op(1,16711,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(18,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16711,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,0,132],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16711) == Op(82,16712,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(19,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16712,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0));
    F.Push1(code,16712);
    assert Fetch(code,16712) == Op(96,16714,36);
  }
  lemma Advance20(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(20,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16714,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,36],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0));
    assert Fetch(code,16714) == Op(129,16715,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(21,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16715,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,36,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0));
    assert Fetch(code,16715) == Op(1,16716,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(22,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16716,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0));
    assert Fetch(code,16716) == Op(132,16717,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(23,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16717,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,164,templateLength],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0));
    assert Fetch(code,16717) == Op(144,16718,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(24,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16718,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,templateLength,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0));
    assert Fetch(code,16718) == Op(82,16719,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(25,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16719,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    F.Push1(code,16719);
    assert Fetch(code,16719) == Op(96,16721,68);
  }
  lemma Advance26(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(26,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16721,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,16721) == Op(1,16722,0);
  }
  lemma Advance27(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(27,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16722,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    F.Push2(code,16722);
    assert Fetch(code,16722) == Op(97,16725,1114);
  }
  lemma Advance28(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(28,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(16725,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,1114],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,16725) == Op(86,16726,0);
  }
  lemma Advance29(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(29,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(1114,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance30(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(30,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(1115,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance31(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(31,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(1117,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,64],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(32,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(1118,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(33,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(1119,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,196,128,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(34,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(1120,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,128,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance35(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(35,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);



    assert state == Running(1121,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(36,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(0,32)+G.Encode(templateLength,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(0,templateLength);


    H.Error(Store([],64,128),0,templateLength);
    assert state == Running(1122,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,68,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,0),164,templateLength));
    assert Fetch(code,1122) == Op(253,1123,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(0,initial,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures Good(20,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance0(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0); trace := trace+[next0]; state := next0;
    Advance1(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1); trace := trace+[next1]; state := next1;
    Advance2(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2); trace := trace+[next2]; state := next2;
    Advance3(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3); trace := trace+[next3]; state := next3;
    Advance4(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4); trace := trace+[next4]; state := next4;
    Advance5(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5); trace := trace+[next5]; state := next5;
    Advance6(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6); trace := trace+[next6]; state := next6;
    Advance7(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7); trace := trace+[next7]; state := next7;
    Advance8(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8); trace := trace+[next8]; state := next8;
    Advance9(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9); trace := trace+[next9]; state := next9;
    Advance10(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10); trace := trace+[next10]; state := next10;
    Advance11(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11); trace := trace+[next11]; state := next11;
    Advance12(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12); trace := trace+[next12]; state := next12;
    Advance13(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13); trace := trace+[next13]; state := next13;
    Advance14(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14); trace := trace+[next14]; state := next14;
    Advance15(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15); trace := trace+[next15]; state := next15;
    Advance16(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16); trace := trace+[next16]; state := next16;
    Advance17(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17); trace := trace+[next17]; state := next17;
    Advance18(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18); trace := trace+[next18]; state := next18;
    Advance19(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19); trace := trace+[next19]; state := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(20,initial,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(0,32)+G.Encode(templateLength,32)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 18 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance20(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20); trace := trace+[next20]; state := next20;
    Advance21(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21); trace := trace+[next21]; state := next21;
    Advance22(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22); trace := trace+[next22]; state := next22;
    Advance23(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23); trace := trace+[next23]; state := next23;
    Advance24(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24); trace := trace+[next24]; state := next24;
    Advance25(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25); trace := trace+[next25]; state := next25;
    Advance26(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26); trace := trace+[next26]; state := next26;
    Advance27(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27); trace := trace+[next27]; state := next27;
    Advance28(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28); trace := trace+[next28]; state := next28;
    Advance29(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29); trace := trace+[next29]; state := next29;
    Advance30(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30); trace := trace+[next30]; state := next30;
    Advance31(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31); trace := trace+[next31]; state := next31;
    Advance32(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32); trace := trace+[next32]; state := next32;
    Advance33(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33); trace := trace+[next33]; state := next33;
    Advance34(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34); trace := trace+[next34]; state := next34;
    Advance35(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35); trace := trace+[next35]; state := next35;
    Advance36(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36); trace := trace+[next36]; state := next36;
  }
  ghost method Run(code: seq<Byte>,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(0,32)+G.Encode(templateLength,32)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 38 && trace[0] == Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128)) && trace[|trace|-1] == state
  { state := Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],Store([],64,128)); trace := [state]; reveal Good();
    var part: seq<State>;
    state,part := Block0(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
