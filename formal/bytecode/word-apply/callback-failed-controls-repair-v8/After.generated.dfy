// SPDX-License-Identifier: MIT
// Generated complete physical CallbackFailed After segment.
include "Scalar.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackFailedAfter {
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
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[1114] == 91 &&
                                              code[1115] == 96 &&
                                              code[1116] == 64 &&
                                              code[1117] == 81 &&
                                              code[1118] == 128 &&
                                              code[1119] == 145 &&
                                              code[1120] == 3 &&
                                              code[1121] == 144 &&
                                              code[1122] == 253 &&
                                              code[24370] == 91 &&
                                              code[24371] == 153 &&
                                              code[24372] == 152 &&
                                              code[24373] == 80 &&
                                              code[24374] == 80 &&
                                              code[24375] == 80 &&
                                              code[24376] == 80 &&
                                              code[24377] == 80 &&
                                              code[24378] == 80 &&
                                              code[24379] == 80 &&
                                              code[24380] == 80 &&
                                              code[24381] == 80 &&
                                              code[24382] == 86 }
  function Destinations(): set<nat> { {1114} }
  opaque predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    ensures Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) ==> free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && |prefix| <= 1005
  { free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1005 }
  lemma Admission(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1005
  { hide DataWord();hide ShiftRight();reveal Admitted(); }
  lemma Admit(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1005
    ensures Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide DataWord();hide ShiftRight();reveal Admitted(); }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) { free+|payload|+|reason|+512 < 0x400000000000000000 && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && (
                                                                                                                                                                                                                                             var heap9 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
                                                                                                                                                                                                                                             if id == 0 then state == Running(24370,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.End(free,payload,reason)],heap9)
                                                                                                                                                                                                                                             else if id == 1 then state == Running(24371,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.End(free,payload,reason)],heap9)
                                                                                                                                                                                                                                             else if id == 2 then state == Running(24372,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),1114],heap9)
                                                                                                                                                                                                                                             else if id == 3 then state == Running(24373,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),CL.Operation(filter)],heap9)
                                                                                                                                                                                                                                             else if id == 4 then state == Running(24374,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],heap9)
                                                                                                                                                                                                                                             else if id == 5 then state == Running(24375,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4,0],heap9)
                                                                                                                                                                                                                                             else if id == 6 then state == Running(24376,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4],heap9)
                                                                                                                                                                                                                                             else if id == 7 then state == Running(24377,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt],heap9)
                                                                                                                                                                                                                                             else if id == 8 then state == Running(24378,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr],heap9)
                                                                                                                                                                                                                                             else if id == 9 then state == Running(24379,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target],heap9)
                                                                                                                                                                                                                                             else if id == 10 then state == Running(24380,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0],heap9)
                                                                                                                                                                                                                                             else if id == 11 then state == Running(24381,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index],heap9)
                                                                                                                                                                                                                                             else if id == 12 then state == Running(24382,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114],heap9)
                                                                                                                                                                                                                                             else if id == 13 then state == Running(1114,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason)],heap9)
                                                                                                                                                                                                                                             else if id == 14 then state == Running(1115,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason)],heap9)
                                                                                                                                                                                                                                             else if id == 15 then state == Running(1117,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),64],heap9)
                                                                                                                                                                                                                                             else if id == 16 then state == Running(1118,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),free],heap9)
                                                                                                                                                                                                                                             else if id == 17 then state == Running(1119,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),free,free],heap9)
                                                                                                                                                                                                                                             else if id == 18 then state == Running(1120,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,free,free,H.End(free,payload,reason)],heap9)
                                                                                                                                                                                                                                             else if id == 19 then state == Running(1121,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,free,S.Round32(|payload|)+S.Round32(|reason|)+260],heap9)
                                                                                                                                                                                                                                             else if id == 20 then state == Running(1122,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,S.Round32(|payload|)+S.Round32(|reason|)+260,free],heap9)
                                                                                                                                                                                                                                             else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(0,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24370,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.End(free,payload,reason)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24370) == Op(91,24371,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(1,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24371,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.End(free,payload,reason)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24371) == Op(153,24372,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(2,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24372,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),1114],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24372) == Op(152,24373,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(3,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24373,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),CL.Operation(filter)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24373) == Op(80,24374,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(4,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24374,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24374) == Op(80,24375,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(5,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24375,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4,0],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24375) == Op(80,24376,0);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(6,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24376,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24376) == Op(80,24377,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(7,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24377,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr,receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24377) == Op(80,24378,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(8,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24378,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target,ptr],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24378) == Op(80,24379,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(9,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24379,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0,target],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24379) == Op(80,24380,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(10,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24380,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index,0],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24380) == Op(80,24381,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(11,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24381,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114,index],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24381) == Op(80,24382,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(12,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(24382,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),1114],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,24382) == Op(86,24383,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(13,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1114,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(14,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1115,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(15,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1117,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),64],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(16,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1118,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),free],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(17,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1119,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,H.End(free,payload,reason),free,free],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(18,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1120,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,free,free,H.End(free,payload,reason)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(19,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1121,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,free,S.Round32(|payload|)+S.Round32(|reason|)+260],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(20,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(H.Packet(CL.Operation(filter),index,target,payload,reason))
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    H.FinalBytes(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason);
    M.HeapProjection(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert G.Grow(M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9),H.End(free,payload,reason)) == M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9);
    assert state == Running(1122,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,S.Round32(|payload|)+S.Round32(|reason|)+260,free],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));
    assert Fetch(code,1122) == Op(253,1123,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(0,initial,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Good(20,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
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
    Advance13(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next13 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);trace := trace+[next13];frame := next13;
    Advance14(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next14 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);trace := trace+[next14];frame := next14;
    Advance15(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next15 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);trace := trace+[next15];frame := next15;
    Advance16(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next16 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);trace := trace+[next16];frame := next16;
    Advance17(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next17 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);trace := trace+[next17];frame := next17;
    Advance18(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next18 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);trace := trace+[next18];frame := next18;
    Advance19(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next19 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);trace := trace+[next19];frame := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(20,initial,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures frame == Reverted(H.Packet(CL.Operation(filter),index,target,payload,reason)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 2 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    Advance20(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next20 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);trace := trace+[next20];frame := next20;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures frame == Reverted(H.Packet(CL.Operation(filter),index,target,payload,reason)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 22 && trace[0] == Running(24370,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.End(free,payload,reason)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9)) && trace[|trace|-1] == frame
  { hide E.Trace();hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);frame := Running(24370,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.End(free,payload,reason)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,9));trace := [frame];reveal Good();var part: seq<State>;
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    frame,part := Block0(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    frame,part := Block1(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
