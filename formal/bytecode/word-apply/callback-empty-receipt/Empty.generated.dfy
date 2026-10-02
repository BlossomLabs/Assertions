// SPDX-License-Identifier: MIT
// Generated complete empty receipt branch before callback success/failure dispatch, with unchanged physical heap.
include "Memory.dfy"
include "../../scans/Fetch.dfy"
module BytecodeApplyEmptyCallbackReceipt {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  import H = BytecodeApplyEmptyReceiptMemory
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) { H.Fits(mem,free) && |returned| == 0 && X.Context(self) && |prefix| <= 1011 }
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
                                              code[16992] == 91 &&
                                              code[16993] == 96 &&
                                              code[16994] == 96 &&
                                              code[16995] == 145 &&
                                              code[16996] == 80 &&
                                              code[16997] == 91 &&
                                              code[16998] == 80 &&
                                              code[16999] == 145 &&
                                              code[17000] == 80 &&
                                              code[17001] == 145 &&
                                              code[17002] == 80
  }
  function Destinations(): set<nat> { {12484,16992} }
  opaque predicate Good(id: nat,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) { Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && (
                                                                                                                                                                                                                                                                                   if id == 0 then frame == X.Frame(Running(16948,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,end,(if success then 1 else 0)],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 1 then frame == X.Frame(Running(16949,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),end,target],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 2 then frame == X.Frame(Running(16950,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),end],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 3 then frame == X.Frame(Running(16951,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0)],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 4 then frame == X.Frame(Running(16952,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 5 then frame == X.Frame(Running(16953,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 6 then frame == X.Frame(Running(16954,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 7 then frame == X.Frame(Running(16955,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,0,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 8 then frame == X.Frame(Running(16956,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,1],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 9 then frame == X.Frame(Running(16959,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,1,16992],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 10 then frame == X.Frame(Running(16992,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 11 then frame == X.Frame(Running(16993,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 12 then frame == X.Frame(Running(16995,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,96],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 13 then frame == X.Frame(Running(16996,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96,0,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 14 then frame == X.Frame(Running(16997,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 15 then frame == X.Frame(Running(16998,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 16 then frame == X.Frame(Running(16999,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 17 then frame == X.Frame(Running(17000,prefix+[12484,target,ptr,index,0,gasBefore,0,96,(if success then 1 else 0),0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 18 then frame == X.Frame(Running(17001,prefix+[12484,target,ptr,index,0,gasBefore,0,96,(if success then 1 else 0)],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else if id == 19 then frame == X.Frame(Running(17002,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),96,0],mem),returned,cursor)
                                                                                                                                                                                                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(0,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(1,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
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
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
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
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
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
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16951,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0)],mem),returned,cursor);
    assert Fetch(code,16951) == Op(61,16952,0);
    X.ReturnSizeStep(code,16951,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0)],mem,self,returned,cursor,observations,value,data);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);

  }
  lemma Advance4(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(4,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(5,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16952,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0],mem),returned,cursor);
    assert Fetch(code,16952) == Op(128,16953,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance5(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(5,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(6,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16953,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0],mem),returned,cursor);
    assert Fetch(code,16953) == Op(95,16954,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance6(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(6,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(7,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16954,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,0],mem),returned,cursor);
    assert Fetch(code,16954) == Op(129,16955,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance7(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(7,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(8,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16955,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,0,0],mem),returned,cursor);
    assert Fetch(code,16955) == Op(20,16956,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance8(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(8,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(9,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16956,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,1],mem),returned,cursor);
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
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16959,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,1,16992],mem),returned,cursor);
    assert Fetch(code,16959) == Op(87,16960,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance10(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(10,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(11,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16992,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0],mem),returned,cursor);
    assert Fetch(code,16992) == Op(91,16993,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance11(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(11,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(12,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16993,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0],mem),returned,cursor);
    F.Push1(code,16993);
    assert Fetch(code,16993) == Op(96,16995,96);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance12(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(12,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(13,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16995,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),0,0,96],mem),returned,cursor);
    assert Fetch(code,16995) == Op(145,16996,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance13(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(13,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(14,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16996,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96,0,0],mem),returned,cursor);
    assert Fetch(code,16996) == Op(80,16997,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance14(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(14,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(15,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16997,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96,0],mem),returned,cursor);
    assert Fetch(code,16997) == Op(91,16998,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance15(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(15,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(16,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16998,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96,0],mem),returned,cursor);
    assert Fetch(code,16998) == Op(80,16999,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance16(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(16,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(17,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(16999,prefix+[12484,target,ptr,index,0,gasBefore,0,0,(if success then 1 else 0),96],mem),returned,cursor);
    assert Fetch(code,16999) == Op(145,17000,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance17(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(17,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(18,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(17000,prefix+[12484,target,ptr,index,0,gasBefore,0,96,(if success then 1 else 0),0],mem),returned,cursor);
    assert Fetch(code,17000) == Op(80,17001,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance18(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(18,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(19,next,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(17001,prefix+[12484,target,ptr,index,0,gasBefore,0,96,(if success then 1 else 0)],mem),returned,cursor);
    assert Fetch(code,17001) == Op(145,17002,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance19(code: seq<Byte>,frame: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(19,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); next == X.Frame(Running(17003,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),96],mem),returned,cursor)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Header(mem,free);
    assert frame == X.Frame(Running(17002,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),96,0],mem),returned,cursor);
    assert Fetch(code,17002) == Op(80,17003,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  ghost method Block0(code: seq<Byte>,initial: X.Frame,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success) && Good(0,initial,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures frame == X.Frame(Running(17003,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),96],mem),returned,cursor) && E.Trace(code,Destinations(),self,value,data,observations,trace)
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
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word,success: bool) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success)
    ensures frame == X.Frame(Running(17003,prefix+[12484,target,ptr,index,0,gasBefore,(if success then 1 else 0),96],mem),returned,cursor) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 21 && trace[0] == X.Frame(Running(16948,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,end,(if success then 1 else 0)],mem),returned,cursor) && trace[|trace|-1] == frame
  { frame := X.Frame(Running(16948,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,end,(if success then 1 else 0)],mem),returned,cursor);trace := [frame];reveal Good();var part: seq<X.Frame>;
    frame,part := Block0(code,frame,data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value,success);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
  }
}
