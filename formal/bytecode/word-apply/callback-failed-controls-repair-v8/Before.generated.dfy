// SPDX-License-Identifier: MIT
// Generated complete physical CallbackFailed Before segment.
include "Scalar.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackFailedBefore {
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
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[17017] == 91 &&
                                              code[17018] == 95 &&
                                              code[17019] == 53 &&
                                              code[17020] == 96 &&
                                              code[17021] == 1 &&
                                              code[17022] == 96 &&
                                              code[17023] == 1 &&
                                              code[17024] == 96 &&
                                              code[17025] == 224 &&
                                              code[17026] == 27 &&
                                              code[17027] == 3 &&
                                              code[17028] == 25 &&
                                              code[17029] == 22 &&
                                              code[17030] == 133 &&
                                              code[17031] == 95 &&
                                              code[17032] == 137 &&
                                              code[17033] == 137 &&
                                              code[17034] == 133 &&
                                              code[17035] == 96 &&
                                              code[17036] == 64 &&
                                              code[17037] == 81 &&
                                              code[17038] == 99 &&
                                              code[17039] == 8 &&
                                              code[17040] == 190 &&
                                              code[17041] == 123 &&
                                              code[17042] == 123 &&
                                              code[17043] == 96 &&
                                              code[17044] == 225 &&
                                              code[17045] == 27 &&
                                              code[17046] == 129 &&
                                              code[17047] == 82 &&
                                              code[17048] == 96 &&
                                              code[17049] == 4 &&
                                              code[17050] == 1 &&
                                              code[17051] == 97 &&
                                              code[17052] == 4 &&
                                              code[17053] == 90 &&
                                              code[17054] == 150 &&
                                              code[17055] == 149 &&
                                              code[17056] == 148 &&
                                              code[17057] == 147 &&
                                              code[17058] == 146 &&
                                              code[17059] == 145 &&
                                              code[17060] == 144 &&
                                              code[17061] == 97 &&
                                              code[17062] == 94 &&
                                              code[17063] == 223 &&
                                              code[17064] == 86 &&
                                              code[20951] == 91 &&
                                              code[24287] == 91 &&
                                              code[24288] == 96 &&
                                              code[24289] == 1 &&
                                              code[24290] == 96 &&
                                              code[24291] == 1 &&
                                              code[24292] == 96 &&
                                              code[24293] == 224 &&
                                              code[24294] == 27 &&
                                              code[24295] == 3 &&
                                              code[24296] == 25 &&
                                              code[24297] == 135 &&
                                              code[24298] == 22 &&
                                              code[24299] == 129 &&
                                              code[24300] == 82 &&
                                              code[24301] == 96 &&
                                              code[24302] == 32 &&
                                              code[24303] == 129 &&
                                              code[24304] == 1 &&
                                              code[24305] == 134 &&
                                              code[24306] == 144 &&
                                              code[24307] == 82 &&
                                              code[24308] == 96 &&
                                              code[24309] == 64 &&
                                              code[24310] == 129 &&
                                              code[24311] == 1 &&
                                              code[24312] == 133 &&
                                              code[24313] == 144 &&
                                              code[24314] == 82 &&
                                              code[24315] == 96 &&
                                              code[24316] == 1 &&
                                              code[24317] == 96 &&
                                              code[24318] == 1 &&
                                              code[24319] == 96 &&
                                              code[24320] == 160 &&
                                              code[24321] == 27 &&
                                              code[24322] == 3 &&
                                              code[24323] == 132 &&
                                              code[24324] == 22 &&
                                              code[24325] == 96 &&
                                              code[24326] == 96 &&
                                              code[24327] == 130 &&
                                              code[24328] == 1 &&
                                              code[24329] == 82 &&
                                              code[24330] == 96 &&
                                              code[24331] == 192 &&
                                              code[24332] == 96 &&
                                              code[24333] == 128 &&
                                              code[24334] == 130 &&
                                              code[24335] == 1 &&
                                              code[24336] == 129 &&
                                              code[24337] == 144 &&
                                              code[24338] == 82 &&
                                              code[24339] == 95 &&
                                              code[24340] == 144 &&
                                              code[24341] == 97 &&
                                              code[24342] == 95 &&
                                              code[24343] == 32 &&
                                              code[24344] == 144 &&
                                              code[24345] == 131 &&
                                              code[24346] == 1 &&
                                              code[24347] == 133 &&
                                              code[24348] == 97 &&
                                              code[24349] == 81 &&
                                              code[24350] == 215 &&
                                              code[24351] == 86 }
  function Destinations(): set<nat> { {20951,24287} }
  opaque predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    ensures Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) ==> free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && |prefix| <= 1003
  { free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1003 }
  lemma Admission(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1003
  { hide DataWord();hide ShiftRight();reveal Admitted(); }
  lemma Admit(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1003
    ensures Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide DataWord();hide ShiftRight();reveal Admitted(); }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) { free+|payload|+|reason|+512 < 0x400000000000000000 && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && (
                                                                                                                                                                                                                                             var heap0 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
                                                                                                                                                                                                                                             var heap1 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
                                                                                                                                                                                                                                             var heap2 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
                                                                                                                                                                                                                                             var heap3 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
                                                                                                                                                                                                                                             var heap4 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
                                                                                                                                                                                                                                             var heap5 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
                                                                                                                                                                                                                                             var heap6 := M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
                                                                                                                                                                                                                                             if id == 0 then state == Running(17017,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt],heap0)
                                                                                                                                                                                                                                             else if id == 1 then state == Running(17018,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt],heap0)
                                                                                                                                                                                                                                             else if id == 2 then state == Running(17019,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,0],heap0)
                                                                                                                                                                                                                                             else if id == 3 then state == Running(17020,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0)],heap0)
                                                                                                                                                                                                                                             else if id == 4 then state == Running(17022,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1],heap0)
                                                                                                                                                                                                                                             else if id == 5 then state == Running(17024,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1,1],heap0)
                                                                                                                                                                                                                                             else if id == 6 then state == Running(17026,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1,1,224],heap0)
                                                                                                                                                                                                                                             else if id == 7 then state == Running(17027,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1,26959946667150639794667015087019630673637144422540572481103610249216],heap0)
                                                                                                                                                                                                                                             else if id == 8 then state == Running(17028,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),26959946667150639794667015087019630673637144422540572481103610249215],heap0)
                                                                                                                                                                                                                                             else if id == 9 then state == Running(17029,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),115792089210356248756420345214020892766250353992003419616917011526809519390720],heap0)
                                                                                                                                                                                                                                             else if id == 10 then state == Running(17030,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter)],heap0)
                                                                                                                                                                                                                                             else if id == 11 then state == Running(17031,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index],heap0)
                                                                                                                                                                                                                                             else if id == 12 then state == Running(17032,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0],heap0)
                                                                                                                                                                                                                                             else if id == 13 then state == Running(17033,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target],heap0)
                                                                                                                                                                                                                                             else if id == 14 then state == Running(17034,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr],heap0)
                                                                                                                                                                                                                                             else if id == 15 then state == Running(17035,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt],heap0)
                                                                                                                                                                                                                                             else if id == 16 then state == Running(17037,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,64],heap0)
                                                                                                                                                                                                                                             else if id == 17 then state == Running(17038,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free],heap0)
                                                                                                                                                                                                                                             else if id == 18 then state == Running(17043,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,146701179],heap0)
                                                                                                                                                                                                                                             else if id == 19 then state == Running(17045,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,146701179,225],heap0)
                                                                                                                                                                                                                                             else if id == 20 then state == Running(17046,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,7910111923696238856963938051353134831934266609959952316625709689432942051328],heap0)
                                                                                                                                                                                                                                             else if id == 21 then state == Running(17047,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,7910111923696238856963938051353134831934266609959952316625709689432942051328,free],heap0)
                                                                                                                                                                                                                                             else if id == 22 then state == Running(17048,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free],heap1)
                                                                                                                                                                                                                                             else if id == 23 then state == Running(17050,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,4],heap1)
                                                                                                                                                                                                                                             else if id == 24 then state == Running(17051,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap1)
                                                                                                                                                                                                                                             else if id == 25 then state == Running(17054,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1114],heap1)
                                                                                                                                                                                                                                             else if id == 26 then state == Running(17055,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,index,0,target,ptr,receipt,free+4,CL.Operation(filter)],heap1)
                                                                                                                                                                                                                                             else if id == 27 then state == Running(17056,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),0,target,ptr,receipt,free+4,index],heap1)
                                                                                                                                                                                                                                             else if id == 28 then state == Running(17057,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,target,ptr,receipt,free+4,0],heap1)
                                                                                                                                                                                                                                             else if id == 29 then state == Running(17058,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,ptr,receipt,free+4,target],heap1)
                                                                                                                                                                                                                                             else if id == 30 then state == Running(17059,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,receipt,free+4,ptr],heap1)
                                                                                                                                                                                                                                             else if id == 31 then state == Running(17060,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,free+4,receipt],heap1)
                                                                                                                                                                                                                                             else if id == 32 then state == Running(17061,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap1)
                                                                                                                                                                                                                                             else if id == 33 then state == Running(17064,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,24287],heap1)
                                                                                                                                                                                                                                             else if id == 34 then state == Running(24287,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap1)
                                                                                                                                                                                                                                             else if id == 35 then state == Running(24288,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap1)
                                                                                                                                                                                                                                             else if id == 36 then state == Running(24290,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1],heap1)
                                                                                                                                                                                                                                             else if id == 37 then state == Running(24292,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1],heap1)
                                                                                                                                                                                                                                             else if id == 38 then state == Running(24294,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1,224],heap1)
                                                                                                                                                                                                                                             else if id == 39 then state == Running(24295,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,26959946667150639794667015087019630673637144422540572481103610249216],heap1)
                                                                                                                                                                                                                                             else if id == 40 then state == Running(24296,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,26959946667150639794667015087019630673637144422540572481103610249215],heap1)
                                                                                                                                                                                                                                             else if id == 41 then state == Running(24297,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720],heap1)
                                                                                                                                                                                                                                             else if id == 42 then state == Running(24298,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720,CL.Operation(filter)],heap1)
                                                                                                                                                                                                                                             else if id == 43 then state == Running(24299,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,CL.Operation(filter)],heap1)
                                                                                                                                                                                                                                             else if id == 44 then state == Running(24300,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,CL.Operation(filter),free+4],heap1)
                                                                                                                                                                                                                                             else if id == 45 then state == Running(24301,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap2)
                                                                                                                                                                                                                                             else if id == 46 then state == Running(24303,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,32],heap2)
                                                                                                                                                                                                                                             else if id == 47 then state == Running(24304,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,32,free+4],heap2)
                                                                                                                                                                                                                                             else if id == 48 then state == Running(24305,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+36],heap2)
                                                                                                                                                                                                                                             else if id == 49 then state == Running(24306,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+36,index],heap2)
                                                                                                                                                                                                                                             else if id == 50 then state == Running(24307,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,index,free+36],heap2)
                                                                                                                                                                                                                                             else if id == 51 then state == Running(24308,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap3)
                                                                                                                                                                                                                                             else if id == 52 then state == Running(24310,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,64],heap3)
                                                                                                                                                                                                                                             else if id == 53 then state == Running(24311,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,64,free+4],heap3)
                                                                                                                                                                                                                                             else if id == 54 then state == Running(24312,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+68],heap3)
                                                                                                                                                                                                                                             else if id == 55 then state == Running(24313,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+68,0],heap3)
                                                                                                                                                                                                                                             else if id == 56 then state == Running(24314,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,free+68],heap3)
                                                                                                                                                                                                                                             else if id == 57 then state == Running(24315,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap4)
                                                                                                                                                                                                                                             else if id == 58 then state == Running(24317,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1],heap4)
                                                                                                                                                                                                                                             else if id == 59 then state == Running(24319,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1],heap4)
                                                                                                                                                                                                                                             else if id == 60 then state == Running(24321,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1,160],heap4)
                                                                                                                                                                                                                                             else if id == 61 then state == Running(24322,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1461501637330902918203684832716283019655932542976],heap4)
                                                                                                                                                                                                                                             else if id == 62 then state == Running(24323,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1461501637330902918203684832716283019655932542975],heap4)
                                                                                                                                                                                                                                             else if id == 63 then state == Running(24324,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1461501637330902918203684832716283019655932542975,target],heap4)
                                                                                                                                                                                                                                             else if id == 64 then state == Running(24325,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target],heap4)
                                                                                                                                                                                                                                             else if id == 65 then state == Running(24327,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target,96],heap4)
                                                                                                                                                                                                                                             else if id == 66 then state == Running(24328,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target,96,free+4],heap4)
                                                                                                                                                                                                                                             else if id == 67 then state == Running(24329,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target,free+100],heap4)
                                                                                                                                                                                                                                             else if id == 68 then state == Running(24330,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],heap5)
                                                                                                                                                                                                                                             else if id == 69 then state == Running(24332,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192],heap5)
                                                                                                                                                                                                                                             else if id == 70 then state == Running(24334,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,128],heap5)
                                                                                                                                                                                                                                             else if id == 71 then state == Running(24335,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,128,free+4],heap5)
                                                                                                                                                                                                                                             else if id == 72 then state == Running(24336,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,free+132],heap5)
                                                                                                                                                                                                                                             else if id == 73 then state == Running(24337,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,free+132,192],heap5)
                                                                                                                                                                                                                                             else if id == 74 then state == Running(24338,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,192,free+132],heap5)
                                                                                                                                                                                                                                             else if id == 75 then state == Running(24339,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192],heap6)
                                                                                                                                                                                                                                             else if id == 76 then state == Running(24340,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,0],heap6)
                                                                                                                                                                                                                                             else if id == 77 then state == Running(24341,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,192],heap6)
                                                                                                                                                                                                                                             else if id == 78 then state == Running(24344,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,192,24352],heap6)
                                                                                                                                                                                                                                             else if id == 79 then state == Running(24345,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,192],heap6)
                                                                                                                                                                                                                                             else if id == 80 then state == Running(24346,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,192,free+4],heap6)
                                                                                                                                                                                                                                             else if id == 81 then state == Running(24347,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196],heap6)
                                                                                                                                                                                                                                             else if id == 82 then state == Running(24348,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196,ptr],heap6)
                                                                                                                                                                                                                                             else if id == 83 then state == Running(24351,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196,ptr,20951],heap6)
                                                                                                                                                                                                                                             else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(0,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17017,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17017) == Op(91,17018,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(1,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17018,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17018) == Op(95,17019,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(2,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17019,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,0],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17019) == Op(53,17020,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(3,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17020,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    F.Push1(code,17020);
    assert Fetch(code,17020) == Op(96,17022,1);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(4,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17022,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    F.Push1(code,17022);
    assert Fetch(code,17022) == Op(96,17024,1);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(5,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17024,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1,1],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    F.Push1(code,17024);
    assert Fetch(code,17024) == Op(96,17026,224);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(6,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    WC.UnitLiteral();A.Limit();L.HeaderLiteral();
    assert state == Running(17026,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1,1,224],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17026) == Op(27,17027,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(7,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17027,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),1,26959946667150639794667015087019630673637144422540572481103610249216],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17027) == Op(3,17028,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(8,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    WC.NotLiteral();
    assert state == Running(17028,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),26959946667150639794667015087019630673637144422540572481103610249215],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17028) == Op(25,17029,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(9,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    L.OperationMask(filter,data);A.Canonical(target);
    assert state == Running(17029,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,DataWord(data,0),115792089210356248756420345214020892766250353992003419616917011526809519390720],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17029) == Op(22,17030,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(10,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17030,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17030) == Op(133,17031,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(11,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17031,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17031) == Op(95,17032,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(12,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17032,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17032) == Op(137,17033,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(13,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17033,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17033) == Op(137,17034,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(14,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17034,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17034) == Op(133,17035,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(15,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17035,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    F.Push1(code,17035);
    assert Fetch(code,17035) == Op(96,17037,64);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(16,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17037,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,64],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17037) == Op(81,17038,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(17,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17038,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    P.Push4(code,17038);
    assert Fetch(code,17038) == Op(99,17043,146701179);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(18,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17043,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,146701179],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    F.Push1(code,17043);
    assert Fetch(code,17043) == Op(96,17045,225);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(19,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    WC.UnitLiteral();A.Limit();L.HeaderLiteral();
    assert state == Running(17045,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,146701179,225],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17045) == Op(27,17046,0);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(20,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17046,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,7910111923696238856963938051353134831934266609959952316625709689432942051328],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17046) == Op(129,17047,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(21,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    M.NextStore(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0);
    assert state == Running(17047,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,7910111923696238856963938051353134831934266609959952316625709689432942051328,free],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));
    assert Fetch(code,17047) == Op(82,17048,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(22,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17048,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    F.Push1(code,17048);
    assert Fetch(code,17048) == Op(96,17050,4);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(23,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17050,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free,4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17050) == Op(1,17051,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(24,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17051,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    F.Push2(code,17051);
    assert Fetch(code,17051) == Op(97,17054,1114);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(25,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17054,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1114],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17054) == Op(150,17055,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(26,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17055,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,index,0,target,ptr,receipt,free+4,CL.Operation(filter)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17055) == Op(149,17056,0);
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(27,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17056,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),0,target,ptr,receipt,free+4,index],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17056) == Op(148,17057,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(28,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17057,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,target,ptr,receipt,free+4,0],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17057) == Op(147,17058,0);
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(29,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17058,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,ptr,receipt,free+4,target],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17058) == Op(146,17059,0);
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(30,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17059,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,receipt,free+4,ptr],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17059) == Op(145,17060,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(31,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17060,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,free+4,receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17060) == Op(144,17061,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(32,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17061,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    F.Push2(code,17061);
    assert Fetch(code,17061) == Op(97,17064,24287);
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(33,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(17064,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,24287],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,17064) == Op(86,17065,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(34,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24287,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24287) == Op(91,24288,0);
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(35,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24288,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    F.Push1(code,24288);
    assert Fetch(code,24288) == Op(96,24290,1);
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(36,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24290,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    F.Push1(code,24290);
    assert Fetch(code,24290) == Op(96,24292,1);
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(37,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24292,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    F.Push1(code,24292);
    assert Fetch(code,24292) == Op(96,24294,224);
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(38,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    WC.UnitLiteral();A.Limit();L.HeaderLiteral();
    assert state == Running(24294,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1,224],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24294) == Op(27,24295,0);
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(39,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24295,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,26959946667150639794667015087019630673637144422540572481103610249216],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24295) == Op(3,24296,0);
  }
  lemma Advance40(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(40,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    WC.NotLiteral();
    assert state == Running(24296,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,26959946667150639794667015087019630673637144422540572481103610249215],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24296) == Op(25,24297,0);
  }
  lemma Advance41(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(41,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24297,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24297) == Op(135,24298,0);
  }
  lemma Advance42(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(42,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    L.OperationMask(filter,data);A.Canonical(target);
    assert state == Running(24298,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720,CL.Operation(filter)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24298) == Op(22,24299,0);
  }
  lemma Advance43(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(43,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24299,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,CL.Operation(filter)],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24299) == Op(129,24300,0);
  }
  lemma Advance44(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(44,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    M.NextStore(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1);
    assert state == Running(24300,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,CL.Operation(filter),free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,1));
    assert Fetch(code,24300) == Op(82,24301,0);
  }
  lemma Advance45(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(45,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
    assert state == Running(24301,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2));
    F.Push1(code,24301);
    assert Fetch(code,24301) == Op(96,24303,32);
  }
  lemma Advance46(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(46,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
    assert state == Running(24303,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,32],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2));
    assert Fetch(code,24303) == Op(129,24304,0);
  }
  lemma Advance47(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(47,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
    assert state == Running(24304,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,32,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2));
    assert Fetch(code,24304) == Op(1,24305,0);
  }
  lemma Advance48(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(48,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
    assert state == Running(24305,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+36],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2));
    assert Fetch(code,24305) == Op(134,24306,0);
  }
  lemma Advance49(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(49,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
    assert state == Running(24306,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+36,index],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2));
    assert Fetch(code,24306) == Op(144,24307,0);
  }
  lemma Advance50(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(50,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
    M.NextStore(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2);
    assert state == Running(24307,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,index,free+36],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,2));
    assert Fetch(code,24307) == Op(82,24308,0);
  }
  lemma Advance51(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(51,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
    assert state == Running(24308,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3));
    F.Push1(code,24308);
    assert Fetch(code,24308) == Op(96,24310,64);
  }
  lemma Advance52(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(52,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
    assert state == Running(24310,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,64],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3));
    assert Fetch(code,24310) == Op(129,24311,0);
  }
  lemma Advance53(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(53,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
    assert state == Running(24311,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,64,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3));
    assert Fetch(code,24311) == Op(1,24312,0);
  }
  lemma Advance54(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(54,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(55,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
    assert state == Running(24312,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+68],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3));
    assert Fetch(code,24312) == Op(133,24313,0);
  }
  lemma Advance55(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(55,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(56,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
    assert state == Running(24313,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,free+68,0],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3));
    assert Fetch(code,24313) == Op(144,24314,0);
  }
  lemma Advance56(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(56,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(57,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
    M.NextStore(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3);
    assert state == Running(24314,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,free+68],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,3));
    assert Fetch(code,24314) == Op(82,24315,0);
  }
  lemma Advance57(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(57,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(58,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24315,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    F.Push1(code,24315);
    assert Fetch(code,24315) == Op(96,24317,1);
  }
  lemma Advance58(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(58,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(59,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24317,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    F.Push1(code,24317);
    assert Fetch(code,24317) == Op(96,24319,1);
  }
  lemma Advance59(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(59,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(60,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24319,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    F.Push1(code,24319);
    assert Fetch(code,24319) == Op(96,24321,160);
  }
  lemma Advance60(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(60,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(61,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    WC.UnitLiteral();A.Limit();L.HeaderLiteral();
    assert state == Running(24321,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1,160],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    assert Fetch(code,24321) == Op(27,24322,0);
  }
  lemma Advance61(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(61,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(62,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24322,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1,1461501637330902918203684832716283019655932542976],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    assert Fetch(code,24322) == Op(3,24323,0);
  }
  lemma Advance62(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(62,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(63,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24323,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1461501637330902918203684832716283019655932542975],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    assert Fetch(code,24323) == Op(132,24324,0);
  }
  lemma Advance63(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(63,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(64,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    L.OperationMask(filter,data);A.Canonical(target);
    L.TargetMask(target);
    assert state == Running(24324,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,1461501637330902918203684832716283019655932542975,target],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    assert Fetch(code,24324) == Op(22,24325,0);
  }
  lemma Advance64(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(64,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(65,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24325,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    F.Push1(code,24325);
    assert Fetch(code,24325) == Op(96,24327,96);
  }
  lemma Advance65(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(65,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(66,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24327,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target,96],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    assert Fetch(code,24327) == Op(130,24328,0);
  }
  lemma Advance66(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(66,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(67,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24328,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target,96,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    assert Fetch(code,24328) == Op(1,24329,0);
  }
  lemma Advance67(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(67,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(68,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    M.NextStore(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4);
    assert state == Running(24329,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,target,free+100],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,4));
    assert Fetch(code,24329) == Op(82,24330,0);
  }
  lemma Advance68(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(68,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(69,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    assert state == Running(24330,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5));
    F.Push1(code,24330);
    assert Fetch(code,24330) == Op(96,24332,192);
  }
  lemma Advance69(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(69,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(70,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    assert state == Running(24332,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5));
    F.Push1(code,24332);
    assert Fetch(code,24332) == Op(96,24334,128);
  }
  lemma Advance70(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(70,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(71,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    assert state == Running(24334,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,128],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5));
    assert Fetch(code,24334) == Op(130,24335,0);
  }
  lemma Advance71(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(71,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(72,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    assert state == Running(24335,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,128,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5));
    assert Fetch(code,24335) == Op(1,24336,0);
  }
  lemma Advance72(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(72,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(73,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    assert state == Running(24336,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,free+132],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5));
    assert Fetch(code,24336) == Op(129,24337,0);
  }
  lemma Advance73(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(73,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(74,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    assert state == Running(24337,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,free+132,192],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5));
    assert Fetch(code,24337) == Op(144,24338,0);
  }
  lemma Advance74(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(74,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(75,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    M.NextStore(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5);
    assert state == Running(24338,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,192,free+132],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,5));
    assert Fetch(code,24338) == Op(82,24339,0);
  }
  lemma Advance75(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(75,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(76,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24339,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    assert Fetch(code,24339) == Op(95,24340,0);
  }
  lemma Advance76(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(76,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(77,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24340,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,192,0],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    assert Fetch(code,24340) == Op(144,24341,0);
  }
  lemma Advance77(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(77,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(78,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24341,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,192],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    F.Push2(code,24341);
    assert Fetch(code,24341) == Op(97,24344,24352);
  }
  lemma Advance78(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(78,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(79,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24344,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,192,24352],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    assert Fetch(code,24344) == Op(144,24345,0);
  }
  lemma Advance79(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(79,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(80,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24345,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,192],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    assert Fetch(code,24345) == Op(131,24346,0);
  }
  lemma Advance80(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(80,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(81,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24346,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,192,free+4],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    assert Fetch(code,24346) == Op(1,24347,0);
  }
  lemma Advance81(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(81,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(82,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24347,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    assert Fetch(code,24347) == Op(133,24348,0);
  }
  lemma Advance82(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(82,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(83,next,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24348,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196,ptr],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    F.Push2(code,24348);
    assert Fetch(code,24348) == Op(97,24351,20951);
  }
  lemma Advance83(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(83,state,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(20951,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196,ptr],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6))
  { hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    M.Info(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6);
    assert state == Running(24351,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196,ptr,20951],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6));
    assert Fetch(code,24351) == Op(86,24352,0);
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
    ensures Good(40,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    Advance20(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next20 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);trace := trace+[next20];frame := next20;
    Advance21(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next21 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);trace := trace+[next21];frame := next21;
    Advance22(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next22 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);trace := trace+[next22];frame := next22;
    Advance23(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next23 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);trace := trace+[next23];frame := next23;
    Advance24(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next24 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);trace := trace+[next24];frame := next24;
    Advance25(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next25 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);trace := trace+[next25];frame := next25;
    Advance26(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next26 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);trace := trace+[next26];frame := next26;
    Advance27(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next27 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);trace := trace+[next27];frame := next27;
    Advance28(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next28 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);trace := trace+[next28];frame := next28;
    Advance29(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next29 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);trace := trace+[next29];frame := next29;
    Advance30(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next30 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);trace := trace+[next30];frame := next30;
    Advance31(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next31 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);trace := trace+[next31];frame := next31;
    Advance32(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next32 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);trace := trace+[next32];frame := next32;
    Advance33(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next33 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);trace := trace+[next33];frame := next33;
    Advance34(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next34 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);trace := trace+[next34];frame := next34;
    Advance35(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next35 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);trace := trace+[next35];frame := next35;
    Advance36(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next36 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);trace := trace+[next36];frame := next36;
    Advance37(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next37 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);trace := trace+[next37];frame := next37;
    Advance38(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next38 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);trace := trace+[next38];frame := next38;
    Advance39(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next39 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);trace := trace+[next39];frame := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(40,initial,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Good(60,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    Advance40(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next40 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);trace := trace+[next40];frame := next40;
    Advance41(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next41 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);trace := trace+[next41];frame := next41;
    Advance42(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next42 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);trace := trace+[next42];frame := next42;
    Advance43(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next43 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);trace := trace+[next43];frame := next43;
    Advance44(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next44 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);trace := trace+[next44];frame := next44;
    Advance45(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next45 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);trace := trace+[next45];frame := next45;
    Advance46(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next46 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);trace := trace+[next46];frame := next46;
    Advance47(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next47 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);trace := trace+[next47];frame := next47;
    Advance48(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next48 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);trace := trace+[next48];frame := next48;
    Advance49(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next49 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);trace := trace+[next49];frame := next49;
    Advance50(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next50 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);trace := trace+[next50];frame := next50;
    Advance51(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next51 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);trace := trace+[next51];frame := next51;
    Advance52(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next52 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);trace := trace+[next52];frame := next52;
    Advance53(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next53 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);trace := trace+[next53];frame := next53;
    Advance54(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next54 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);trace := trace+[next54];frame := next54;
    Advance55(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next55 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55);trace := trace+[next55];frame := next55;
    Advance56(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next56 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56);trace := trace+[next56];frame := next56;
    Advance57(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next57 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57);trace := trace+[next57];frame := next57;
    Advance58(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next58 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58);trace := trace+[next58];frame := next58;
    Advance59(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next59 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59);trace := trace+[next59];frame := next59;
  }
  ghost method Block3(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(60,initial,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures Good(80,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    Advance60(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next60 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next60);trace := trace+[next60];frame := next60;
    Advance61(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next61 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next61);trace := trace+[next61];frame := next61;
    Advance62(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next62 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next62);trace := trace+[next62];frame := next62;
    Advance63(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next63 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next63);trace := trace+[next63];frame := next63;
    Advance64(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next64 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next64);trace := trace+[next64];frame := next64;
    Advance65(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next65 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next65);trace := trace+[next65];frame := next65;
    Advance66(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next66 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next66);trace := trace+[next66];frame := next66;
    Advance67(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next67 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next67);trace := trace+[next67];frame := next67;
    Advance68(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next68 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next68);trace := trace+[next68];frame := next68;
    Advance69(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next69 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next69);trace := trace+[next69];frame := next69;
    Advance70(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next70 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next70);trace := trace+[next70];frame := next70;
    Advance71(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next71 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next71);trace := trace+[next71];frame := next71;
    Advance72(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next72 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next72);trace := trace+[next72];frame := next72;
    Advance73(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next73 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next73);trace := trace+[next73];frame := next73;
    Advance74(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next74 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next74);trace := trace+[next74];frame := next74;
    Advance75(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next75 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next75);trace := trace+[next75];frame := next75;
    Advance76(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next76 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next76);trace := trace+[next76];frame := next76;
    Advance77(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next77 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next77);trace := trace+[next77];frame := next77;
    Advance78(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next78 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next78);trace := trace+[next78];frame := next78;
    Advance79(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next79 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next79);trace := trace+[next79];frame := next79;
  }
  ghost method Block4(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value) && Good(80,initial,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures frame == Running(20951,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196,ptr],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 5 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    Advance80(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next80 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next80);trace := trace+[next80];frame := next80;
    Advance81(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next81 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next81);trace := trace+[next81];frame := next81;
    Advance82(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next82 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next82);trace := trace+[next82];frame := next82;
    Advance83(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var next83 := Step(code,Destinations(),frame,value,data);
    E.Extend(code,Destinations(),value,data,trace,next83);trace := trace+[next83];frame := next83;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value)
    ensures frame == Running(20951,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,CL.Operation(filter),index,0,target,ptr,receipt,free+4,0,24352,free+196,ptr],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,6)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 85 && trace[0] == Running(17017,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0)) && trace[|trace|-1] == frame
  { hide E.Trace();hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();Admission(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);frame := Running(17017,prefix+[12484,target,ptr,index,0,gasBefore,0,receipt],M.Heap(mem,ptr,receipt,free,CL.Operation(filter),index,target,payload,reason,0));trace := [frame];reveal Good();var part: seq<State>;
    assert E.Trace(code,Destinations(),value,data,trace) by { reveal E.Trace(); }
    frame,part := Block0(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    frame,part := Block1(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    frame,part := Block2(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    frame,part := Block3(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    frame,part := Block4(code,frame,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
