// SPDX-License-Identifier: MIT
// Generated complete nonempty receipt allocation and full return byte copy before callback success/failure dispatch.
include "../callback-receipt/Memory.dfy"
include "Scalar.dfy"
module BytecodeApplyNonemptyCallbackReceipt {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  import H = BytecodeApplyCallbackReceiptMemory
  import SC = BytecodeApplyCallbackReceiptScalar
  import CS = BytecodeApplyCallbackSuccessScalar
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) { H.Fits(mem,free,returned) && X.Context(self) && |prefix| <= 1009 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12484] == 91 &&
                                              code[16948] == 145 &&
                                              code[16949] == 80 &&
                                              code[16950] == 80 &&
                                              code[16951] == 61 &&
                                              code[16952] == 128 &&
                                              code[16953] == 95 &&
                                              code[16954] == 129 &&
                                              code[16955] == 20 &&
                                              code[16956] == 97 &&
                                              code[16957] == 66 &&
                                              code[16958] == 96 &&
                                              code[16959] == 87 &&
                                              code[16960] == 96 &&
                                              code[16961] == 64 &&
                                              code[16962] == 81 &&
                                              code[16963] == 145 &&
                                              code[16964] == 80 &&
                                              code[16965] == 96 &&
                                              code[16966] == 31 &&
                                              code[16967] == 25 &&
                                              code[16968] == 96 &&
                                              code[16969] == 63 &&
                                              code[16970] == 61 &&
                                              code[16971] == 1 &&
                                              code[16972] == 22 &&
                                              code[16973] == 130 &&
                                              code[16974] == 1 &&
                                              code[16975] == 96 &&
                                              code[16976] == 64 &&
                                              code[16977] == 82 &&
                                              code[16978] == 61 &&
                                              code[16979] == 130 &&
                                              code[16980] == 82 &&
                                              code[16981] == 61 &&
                                              code[16982] == 95 &&
                                              code[16983] == 96 &&
                                              code[16984] == 32 &&
                                              code[16985] == 132 &&
                                              code[16986] == 1 &&
                                              code[16987] == 62 &&
                                              code[16988] == 97 &&
                                              code[16989] == 66 &&
                                              code[16990] == 101 &&
                                              code[16991] == 86 &&
                                              code[16992] == 91 &&
                                              code[16997] == 91 &&
                                              code[16998] == 80 &&
                                              code[16999] == 145 &&
                                              code[17000] == 80 &&
                                              code[17001] == 145 &&
                                              code[17002] == 80
  }
  function Destinations(): set<nat> { {12484,16992,16997} }
  opaque predicate Good(id: nat,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) { Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && (
                                                                                                                                                                                                                                                                                   if id == 0 then frame == X.Frame(Running(16948,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,end,(if success then 1 else 0)],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 1 then frame == X.Frame(Running(16949,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),end,target],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 2 then frame == X.Frame(Running(16950,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),end],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 3 then frame == X.Frame(Running(16951,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0)],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 4 then frame == X.Frame(Running(16952,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 5 then frame == X.Frame(Running(16953,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 6 then frame == X.Frame(Running(16954,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 7 then frame == X.Frame(Running(16955,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0,|returned|],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 8 then frame == X.Frame(Running(16956,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 9 then frame == X.Frame(Running(16959,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0,16992],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 10 then frame == X.Frame(Running(16960,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 11 then frame == X.Frame(Running(16962,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,64],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 12 then frame == X.Frame(Running(16963,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,free],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 13 then frame == X.Frame(Running(16964,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 14 then frame == X.Frame(Running(16965,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 15 then frame == X.Frame(Running(16967,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,31],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 16 then frame == X.Frame(Running(16968,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 17 then frame == X.Frame(Running(16970,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904,63],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 18 then frame == X.Frame(Running(16971,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904,63,|returned|],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 19 then frame == X.Frame(Running(16972,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904,|returned|+63],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 20 then frame == X.Frame(Running(16973,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,SC.Extent(returned)],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 21 then frame == X.Frame(Running(16974,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,SC.Extent(returned),free],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 22 then frame == X.Frame(Running(16975,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,H.End(free,returned)],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 23 then frame == X.Frame(Running(16977,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,H.End(free,returned),64],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 24 then frame == X.Frame(Running(16978,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Pointer(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 25 then frame == X.Frame(Running(16979,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|],H.Pointer(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 26 then frame == X.Frame(Running(16980,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,free],H.Pointer(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 27 then frame == X.Frame(Running(16981,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Head(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 28 then frame == X.Frame(Running(16982,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|],H.Head(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 29 then frame == X.Frame(Running(16983,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0],H.Head(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 30 then frame == X.Frame(Running(16985,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0,32],H.Head(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 31 then frame == X.Frame(Running(16986,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0,32,free],H.Head(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 32 then frame == X.Frame(Running(16987,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0,free+32],H.Head(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 33 then frame == X.Frame(Running(16988,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 34 then frame == X.Frame(Running(16991,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,16997],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 35 then frame == X.Frame(Running(16997,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 36 then frame == X.Frame(Running(16998,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 37 then frame == X.Frame(Running(16999,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 38 then frame == X.Frame(Running(17000,prefix+[12484,target,ptr,index,0,gasBefore,0,free,(if success then 1 else 0),0],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 39 then frame == X.Frame(Running(17001,prefix+[12484,target,ptr,index,0,gasBefore,0,free,(if success then 1 else 0)],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 40 then frame == X.Frame(Running(17002,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),free,0],H.Complete(mem,free,returned)),returned,cursor)
                                                                                                                                                                                                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(0,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(1,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16948,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,end,(if success then 1 else 0)],mem),returned,cursor);
    assert Fetch(code,16948) == Op(145,16949,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance1(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(1,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(2,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16949,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),end,target],mem),returned,cursor);
    assert Fetch(code,16949) == Op(80,16950,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance2(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(2,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(3,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16950,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),end],mem),returned,cursor);
    assert Fetch(code,16950) == Op(80,16951,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance3(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(3,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(4,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16951,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0)],mem),returned,cursor);
    assert Fetch(code,16951) == Op(61,16952,0);
    X.ReturnSizeStep(code,16951,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0)],mem,self,returned,cursor,observations,value,data);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);

  }
  lemma Advance4(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(4,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(5,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16952,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|],mem),returned,cursor);
    assert Fetch(code,16952) == Op(128,16953,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance5(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(5,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(6,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16953,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|],mem),returned,cursor);
    assert Fetch(code,16953) == Op(95,16954,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance6(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(6,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(7,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16954,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0],mem),returned,cursor);
    assert Fetch(code,16954) == Op(129,16955,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance7(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(7,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(8,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16955,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0,|returned|],mem),returned,cursor);
    assert Fetch(code,16955) == Op(20,16956,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance8(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(8,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(9,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16956,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0],mem),returned,cursor);
    F.Push2(code,16956);
    assert Fetch(code,16956) == Op(97,16959,16992);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance9(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(9,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(10,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16959,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,0,16992],mem),returned,cursor);
    assert Fetch(code,16959) == Op(87,16960,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance10(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(10,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(11,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16960,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|],mem),returned,cursor);
    F.Push1(code,16960);
    assert Fetch(code,16960) == Op(96,16962,64);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance11(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(11,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(12,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16962,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,64],mem),returned,cursor);
    assert Fetch(code,16962) == Op(81,16963,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance12(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(12,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(13,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16963,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),|returned|,|returned|,free],mem),returned,cursor);
    assert Fetch(code,16963) == Op(145,16964,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance13(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(13,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(14,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16964,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|],mem),returned,cursor);
    assert Fetch(code,16964) == Op(80,16965,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance14(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(14,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(15,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16965,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],mem),returned,cursor);
    F.Push1(code,16965);
    assert Fetch(code,16965) == Op(96,16967,31);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance15(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(15,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(16,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16967,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,31],mem),returned,cursor);
    assert Fetch(code,16967) == Op(25,16968,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
    CS.Not31();

  }
  lemma Advance16(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(16,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(17,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16968,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904],mem),returned,cursor);
    F.Push1(code,16968);
    assert Fetch(code,16968) == Op(96,16970,63);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance17(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(17,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(18,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16970,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904,63],mem),returned,cursor);
    assert Fetch(code,16970) == Op(61,16971,0);
    X.ReturnSizeStep(code,16970,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904,63],mem,self,returned,cursor,observations,value,data);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);

  }
  lemma Advance18(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(18,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(19,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16971,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904,63,|returned|],mem),returned,cursor);
    assert Fetch(code,16971) == Op(1,16972,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance19(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(19,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(20,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16972,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,115792089237316195423570985008687907853269984665640564039457584007913129639904,|returned|+63],mem),returned,cursor);
    assert Fetch(code,16972) == Op(22,16973,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    assert frame.state == Running(16972,(prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|])+[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,|returned|+63],mem);
    SC.At(code,Destinations(),prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],mem,value,data,returned);

  }
  lemma Advance20(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(20,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(21,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16973,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,SC.Extent(returned)],mem),returned,cursor);
    assert Fetch(code,16973) == Op(130,16974,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance21(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(21,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(22,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16974,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,SC.Extent(returned),free],mem),returned,cursor);
    assert Fetch(code,16974) == Op(1,16975,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance22(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(22,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(23,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16975,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,H.End(free,returned)],mem),returned,cursor);
    F.Push1(code,16975);
    assert Fetch(code,16975) == Op(96,16977,64);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance23(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(23,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(24,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16977,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,H.End(free,returned),64],mem),returned,cursor);
    assert Fetch(code,16977) == Op(82,16978,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance24(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(24,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(25,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16978,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Pointer(mem,free,returned)),returned,cursor);
    assert Fetch(code,16978) == Op(61,16979,0);
    X.ReturnSizeStep(code,16978,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Pointer(mem,free,returned),self,returned,cursor,observations,value,data);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);

  }
  lemma Advance25(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(25,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(26,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16979,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|],H.Pointer(mem,free,returned)),returned,cursor);
    assert Fetch(code,16979) == Op(130,16980,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance26(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(26,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(27,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16980,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,free],H.Pointer(mem,free,returned)),returned,cursor);
    assert Fetch(code,16980) == Op(82,16981,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance27(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(27,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(28,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16981,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Head(mem,free,returned)),returned,cursor);
    assert Fetch(code,16981) == Op(61,16982,0);
    X.ReturnSizeStep(code,16981,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Head(mem,free,returned),self,returned,cursor,observations,value,data);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);

  }
  lemma Advance28(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(28,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(29,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16982,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|],H.Head(mem,free,returned)),returned,cursor);
    assert Fetch(code,16982) == Op(95,16983,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance29(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(29,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(30,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16983,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0],H.Head(mem,free,returned)),returned,cursor);
    F.Push1(code,16983);
    assert Fetch(code,16983) == Op(96,16985,32);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance30(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(30,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(31,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16985,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0,32],H.Head(mem,free,returned)),returned,cursor);
    assert Fetch(code,16985) == Op(132,16986,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance31(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(31,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(32,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16986,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0,32,free],H.Head(mem,free,returned)),returned,cursor);
    assert Fetch(code,16986) == Op(1,16987,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance32(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(32,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(33,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16987,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0,free+32],H.Head(mem,free,returned)),returned,cursor);
    assert Fetch(code,16987) == Op(62,16988,0);
    CS.Fourteen(prefix,12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,|returned|,0,free+32);
    assert frame == X.Frame(Running(16987,(prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|])+[|returned|,0,free+32],H.Head(mem,free,returned)),returned,cursor);
    X.ReturnCopyStep(code,16987,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Head(mem,free,returned),self,free+32,0,|returned|,returned,cursor,observations,value,data);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);

  }
  lemma Advance33(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(33,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(34,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16988,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Complete(mem,free,returned)),returned,cursor);
    F.Push2(code,16988);
    assert Fetch(code,16988) == Op(97,16991,16997);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance34(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(34,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(35,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16991,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|,16997],H.Complete(mem,free,returned)),returned,cursor);
    assert Fetch(code,16991) == Op(86,16992,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance35(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(35,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(36,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16997,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Complete(mem,free,returned)),returned,cursor);
    assert Fetch(code,16997) == Op(91,16998,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance36(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(36,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(37,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16998,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free,|returned|],H.Complete(mem,free,returned)),returned,cursor);
    assert Fetch(code,16998) == Op(80,16999,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance37(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(37,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(38,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(16999,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),free],H.Complete(mem,free,returned)),returned,cursor);
    assert Fetch(code,16999) == Op(145,17000,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance38(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(38,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(39,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(17000,prefix+[12484,target,ptr,index,0,gasBefore,0,free,(if success then 1 else 0),0],H.Complete(mem,free,returned)),returned,cursor);
    assert Fetch(code,17000) == Op(80,17001,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance39(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(39,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(40,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(17001,prefix+[12484,target,ptr,index,0,gasBefore,0,free,(if success then 1 else 0)],H.Complete(mem,free,returned)),returned,cursor);
    assert Fetch(code,17001) == Op(145,17002,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance40(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(40,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); next == X.Frame(Running(17003,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),free],H.Complete(mem,free,returned)),returned,cursor)
  { hide G.BitAnd(); hide BitNot(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == X.Frame(Running(17002,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),free,0],H.Complete(mem,free,returned)),returned,cursor);
    assert Fetch(code,17002) == Op(80,17003,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  ghost method Block0(code: seq<Byte>,initial: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(0,initial,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures Good(20,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { frame := initial;trace := [frame];
    Advance0(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next0 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next0);trace := trace+[next0];frame := next0;
    Advance1(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next1 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next1);trace := trace+[next1];frame := next1;
    Advance2(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next2 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next2);trace := trace+[next2];frame := next2;
    Advance3(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next3 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next3);trace := trace+[next3];frame := next3;
    Advance4(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next4 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next4);trace := trace+[next4];frame := next4;
    Advance5(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next5 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next5);trace := trace+[next5];frame := next5;
    Advance6(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next6 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next6);trace := trace+[next6];frame := next6;
    Advance7(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next7 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next7);trace := trace+[next7];frame := next7;
    Advance8(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next8 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next8);trace := trace+[next8];frame := next8;
    Advance9(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next9 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next9);trace := trace+[next9];frame := next9;
    Advance10(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next10 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next10);trace := trace+[next10];frame := next10;
    Advance11(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next11 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next11);trace := trace+[next11];frame := next11;
    Advance12(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next12 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next12);trace := trace+[next12];frame := next12;
    Advance13(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next13 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next13);trace := trace+[next13];frame := next13;
    Advance14(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next14 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next14);trace := trace+[next14];frame := next14;
    Advance15(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next15 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next15);trace := trace+[next15];frame := next15;
    Advance16(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next16 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next16);trace := trace+[next16];frame := next16;
    Advance17(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next17 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next17);trace := trace+[next17];frame := next17;
    Advance18(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next18 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next18);trace := trace+[next18];frame := next18;
    Advance19(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next19 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next19);trace := trace+[next19];frame := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(20,initial,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures Good(40,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { frame := initial;trace := [frame];
    Advance20(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next20 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next20);trace := trace+[next20];frame := next20;
    Advance21(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next21 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next21);trace := trace+[next21];frame := next21;
    Advance22(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next22 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next22);trace := trace+[next22];frame := next22;
    Advance23(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next23 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next23);trace := trace+[next23];frame := next23;
    Advance24(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next24 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next24);trace := trace+[next24];frame := next24;
    Advance25(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next25 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next25);trace := trace+[next25];frame := next25;
    Advance26(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next26 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next26);trace := trace+[next26];frame := next26;
    Advance27(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next27 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next27);trace := trace+[next27];frame := next27;
    Advance28(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next28 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next28);trace := trace+[next28];frame := next28;
    Advance29(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next29 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next29);trace := trace+[next29];frame := next29;
    Advance30(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next30 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next30);trace := trace+[next30];frame := next30;
    Advance31(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next31 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next31);trace := trace+[next31];frame := next31;
    Advance32(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next32 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next32);trace := trace+[next32];frame := next32;
    Advance33(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next33 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next33);trace := trace+[next33];frame := next33;
    Advance34(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next34 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next34);trace := trace+[next34];frame := next34;
    Advance35(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next35 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next35);trace := trace+[next35];frame := next35;
    Advance36(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next36 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next36);trace := trace+[next36];frame := next36;
    Advance37(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next37 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next37);trace := trace+[next37];frame := next37;
    Advance38(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next38 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next38);trace := trace+[next38];frame := next38;
    Advance39(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next39 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next39);trace := trace+[next39];frame := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(40,initial,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures frame == X.Frame(Running(17003,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),free],H.Complete(mem,free,returned)),returned,cursor) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 2 && trace[0] == initial && trace[|trace|-1] == frame
  { frame := initial;trace := [frame];
    Advance40(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    var next40 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next40);trace := trace+[next40];frame := next40;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures frame == X.Frame(Running(17003,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),free],H.Complete(mem,free,returned)),returned,cursor) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 42 && trace[0] == X.Frame(Running(16948,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,end,(if success then 1 else 0)],mem),returned,cursor) && trace[|trace|-1] == frame
  { frame := X.Frame(Running(16948,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,end,(if success then 1 else 0)],mem),returned,cursor);trace := [frame];reveal Good();var part: seq<X.Frame>;
    frame,part := Block0(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    frame,part := Block1(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    frame,part := Block2(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
  }
}
