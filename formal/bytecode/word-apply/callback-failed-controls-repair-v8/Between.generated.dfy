// SPDX-License-Identifier: MIT
// Generated complete physical CallbackFailed Between segment.
include "Scalar.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackFailedBetween {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import M = BytecodeApplyCallbackFailedControlMemory
  import H = BytecodeApplyCallbackFailedMemory
  import CL = BytecodeApplyCallbackLengthScalar
  import WC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  import L = BytecodeApplyCallbackFailedControlScalar
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[20951] == 91 &&
                                              code[24352] == 91 &&
                                              code[24353] == 130 &&
                                              code[24354] == 129 &&
                                              code[24355] == 3 &&
                                              code[24356] == 96 &&
                                              code[24357] == 160 &&
                                              code[24358] == 132 &&
                                              code[24359] == 1 &&
                                              code[24360] == 82 &&
                                              code[24361] == 97 &&
                                              code[24362] == 95 &&
                                              code[24363] == 50 &&
                                              code[24364] == 129 &&
                                              code[24365] == 133 &&
                                              code[24366] == 97 &&
                                              code[24367] == 81 &&
                                              code[24368] == 215 &&
                                              code[24369] == 86 }
  function Destinations(): set<nat> { {20951} }
  opaque predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    ensures Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) ==> free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && |prefix| <= 1002
  { free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1002 }
  lemma Admission(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1002
  { hide DataWord();hide ShiftRight();reveal Admitted(); }
  lemma Admit(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1002
    ensures Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide DataWord();hide ShiftRight();reveal Admitted(); }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) { free+|payload|+|reason|+512 < 0x400000000000000000 && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && (
                                                                                                                                                                                                                                             var heap7 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
                                                                                                                                                                                                                                             var heap8 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8);
                                                                                                                                                                                                                                             if id == 0 then state == Running(24352,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],heap7)
                                                                                                                                                                                                                                             else if id == 1 then state == Running(24353,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],heap7)
                                                                                                                                                                                                                                             else if id == 2 then state == Running(24354,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),free+4],heap7)
                                                                                                                                                                                                                                             else if id == 3 then state == Running(24355,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),free+4,H.ReasonDst(free,payload)],heap7)
                                                                                                                                                                                                                                             else if id == 4 then state == Running(24356,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload)],heap7)
                                                                                                                                                                                                                                             else if id == 5 then state == Running(24358,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload),160],heap7)
                                                                                                                                                                                                                                             else if id == 6 then state == Running(24359,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload),160,free+4],heap7)
                                                                                                                                                                                                                                             else if id == 7 then state == Running(24360,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload),free+164],heap7)
                                                                                                                                                                                                                                             else if id == 8 then state == Running(24361,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],heap8)
                                                                                                                                                                                                                                             else if id == 9 then state == Running(24364,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370],heap8)
                                                                                                                                                                                                                                             else if id == 10 then state == Running(24365,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload)],heap8)
                                                                                                                                                                                                                                             else if id == 11 then state == Running(24366,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload),receipt],heap8)
                                                                                                                                                                                                                                             else if id == 12 then state == Running(24369,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload),receipt,20951],heap8)
                                                                                                                                                                                                                                             else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(0,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24352,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    assert Fetch(code,24352) == Op(91,24353,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(1,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24353,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    assert Fetch(code,24353) == Op(130,24354,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(2,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24354,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    assert Fetch(code,24354) == Op(129,24355,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(3,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24355,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),free+4,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    assert Fetch(code,24355) == Op(3,24356,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(4,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24356,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    F.Push1(code,24356);
    assert Fetch(code,24356) == Op(96,24358,160);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(5,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24358,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload),160],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    assert Fetch(code,24358) == Op(132,24359,0);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(6,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24359,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload),160,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    assert Fetch(code,24359) == Op(1,24360,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(7,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    M.NextStore(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7);
    assert state == Running(24360,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.ReasonOffset(payload),free+164],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));
    assert Fetch(code,24360) == Op(82,24361,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(8,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8);
    assert state == Running(24361,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8));
    F.Push2(code,24361);
    assert Fetch(code,24361) == Op(97,24364,24370);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(9,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8);
    assert state == Running(24364,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8));
    assert Fetch(code,24364) == Op(129,24365,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(10,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8);
    assert state == Running(24365,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8));
    assert Fetch(code,24365) == Op(133,24366,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(11,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8);
    assert state == Running(24366,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload),receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8));
    F.Push2(code,24366);
    assert Fetch(code,24366) == Op(97,24369,20951);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(12,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(20951,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload),receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8))
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8);
    assert state == Running(24369,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload),receipt,20951],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8));
    assert Fetch(code,24369) == Op(86,24370,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(0,initial,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures frame == Running(20951,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload),receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    Advance0(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next0 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);trace := trace+[next0];frame := next0;
    Advance1(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next1 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);trace := trace+[next1];frame := next1;
    Advance2(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next2 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);trace := trace+[next2];frame := next2;
    Advance3(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next3 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);trace := trace+[next3];frame := next3;
    Advance4(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next4 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);trace := trace+[next4];frame := next4;
    Advance5(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next5 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);trace := trace+[next5];frame := next5;
    Advance6(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next6 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);trace := trace+[next6];frame := next6;
    Advance7(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next7 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);trace := trace+[next7];frame := next7;
    Advance8(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next8 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);trace := trace+[next8];frame := next8;
    Advance9(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next9 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);trace := trace+[next9];frame := next9;
    Advance10(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next10 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);trace := trace+[next10];frame := next10;
    Advance11(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next11 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);trace := trace+[next11];frame := next11;
    Advance12(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next12 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);trace := trace+[next12];frame := next12;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures frame == Running(20951,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),24370,H.ReasonDst(free,payload),receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,8)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == Running(24352,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7)) && trace[|trace|-1] == frame
  { hide E.Trace();hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);frame := Running(24352,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,7));trace := [frame];reveal Good();var part: seq<State>;
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    frame,part := Block0(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
