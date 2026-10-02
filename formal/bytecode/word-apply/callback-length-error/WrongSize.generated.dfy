// SPDX-License-Identifier: MIT
// Generated complete actual wrong receipt length branch through exact132-byte REVERT.
include "Scalar.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackLengthError {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import H = BytecodeApplyWrongCallbackMemory
  import SC = BytecodeApplyWrongCallbackScalar
  import CL = BytecodeApplyCallbackLengthScalar
  import A = BytecodeApplyAddressMask
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) { H.Fits(mem,free) && receipt+32 <= |mem| && Load(mem,receipt) == receiptLength && receiptLength != 32 && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(filter) && |prefix| <= 1008 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[1114] == 91 &&
                                              code[1115] == 96 &&
                                              code[1116] == 64 &&
                                              code[1117] == 81 &&
                                              code[1118] == 128 &&
                                              code[1119] == 145 &&
                                              code[1120] == 3 &&
                                              code[1121] == 144 &&
                                              code[1122] == 253 &&
                                              code[17065] == 91 &&
                                              code[17066] == 128 &&
                                              code[17067] == 81 &&
                                              code[17068] == 96 &&
                                              code[17069] == 32 &&
                                              code[17070] == 20 &&
                                              code[17071] == 97 &&
                                              code[17072] == 66 &&
                                              code[17073] == 222 &&
                                              code[17074] == 87 &&
                                              code[17075] == 95 &&
                                              code[17076] == 53 &&
                                              code[17077] == 96 &&
                                              code[17078] == 1 &&
                                              code[17079] == 96 &&
                                              code[17080] == 1 &&
                                              code[17081] == 96 &&
                                              code[17082] == 224 &&
                                              code[17083] == 27 &&
                                              code[17084] == 3 &&
                                              code[17085] == 25 &&
                                              code[17086] == 22 &&
                                              code[17087] == 133 &&
                                              code[17088] == 95 &&
                                              code[17089] == 137 &&
                                              code[17090] == 96 &&
                                              code[17091] == 64 &&
                                              code[17092] == 81 &&
                                              code[17093] == 99 &&
                                              code[17094] == 36 &&
                                              code[17095] == 68 &&
                                              code[17096] == 138 &&
                                              code[17097] == 17 &&
                                              code[17098] == 96 &&
                                              code[17099] == 224 &&
                                              code[17100] == 27 &&
                                              code[17101] == 129 &&
                                              code[17102] == 82 &&
                                              code[17103] == 96 &&
                                              code[17104] == 4 &&
                                              code[17105] == 1 &&
                                              code[17106] == 97 &&
                                              code[17107] == 4 &&
                                              code[17108] == 90 &&
                                              code[17109] == 148 &&
                                              code[17110] == 147 &&
                                              code[17111] == 146 &&
                                              code[17112] == 145 &&
                                              code[17113] == 144 &&
                                              code[17114] == 97 &&
                                              code[17115] == 94 &&
                                              code[17116] == 38 &&
                                              code[17117] == 86 &&
                                              code[17118] == 91 &&
                                              code[24102] == 91 &&
                                              code[24103] == 96 &&
                                              code[24104] == 1 &&
                                              code[24105] == 96 &&
                                              code[24106] == 1 &&
                                              code[24107] == 96 &&
                                              code[24108] == 224 &&
                                              code[24109] == 27 &&
                                              code[24110] == 3 &&
                                              code[24111] == 25 &&
                                              code[24112] == 148 &&
                                              code[24113] == 144 &&
                                              code[24114] == 148 &&
                                              code[24115] == 22 &&
                                              code[24116] == 132 &&
                                              code[24117] == 82 &&
                                              code[24118] == 96 &&
                                              code[24119] == 32 &&
                                              code[24120] == 132 &&
                                              code[24121] == 1 &&
                                              code[24122] == 146 &&
                                              code[24123] == 144 &&
                                              code[24124] == 146 &&
                                              code[24125] == 82 &&
                                              code[24126] == 96 &&
                                              code[24127] == 64 &&
                                              code[24128] == 131 &&
                                              code[24129] == 1 &&
                                              code[24130] == 82 &&
                                              code[24131] == 96 &&
                                              code[24132] == 1 &&
                                              code[24133] == 96 &&
                                              code[24134] == 1 &&
                                              code[24135] == 96 &&
                                              code[24136] == 160 &&
                                              code[24137] == 27 &&
                                              code[24138] == 3 &&
                                              code[24139] == 22 &&
                                              code[24140] == 96 &&
                                              code[24141] == 96 &&
                                              code[24142] == 130 &&
                                              code[24143] == 1 &&
                                              code[24144] == 82 &&
                                              code[24145] == 96 &&
                                              code[24146] == 128 &&
                                              code[24147] == 1 &&
                                              code[24148] == 144 &&
                                              code[24149] == 86 }
  function Destinations(): set<nat> { {1114,17118,24102} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) { Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && (
                                                                                                                                                                                                                      if id == 0 then state == Running(17065,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 1 then state == Running(17066,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 2 then state == Running(17067,prefix+[target,ptr,index,0,gas,1,receipt,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 3 then state == Running(17068,prefix+[target,ptr,index,0,gas,1,receipt,receiptLength],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 4 then state == Running(17070,prefix+[target,ptr,index,0,gas,1,receipt,receiptLength,32],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 5 then state == Running(17071,prefix+[target,ptr,index,0,gas,1,receipt,0],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 6 then state == Running(17074,prefix+[target,ptr,index,0,gas,1,receipt,0,17118],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 7 then state == Running(17075,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 8 then state == Running(17076,prefix+[target,ptr,index,0,gas,1,receipt,0],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 9 then state == Running(17077,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0)],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 10 then state == Running(17079,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 11 then state == Running(17081,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1,1],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 12 then state == Running(17083,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1,1,224],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 13 then state == Running(17084,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 14 then state == Running(17085,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 15 then state == Running(17086,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 16 then state == Running(17087,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 17 then state == Running(17088,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 18 then state == Running(17089,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 19 then state == Running(17090,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 20 then state == Running(17092,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,64],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 21 then state == Running(17093,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 22 then state == Running(17098,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,608471569],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 23 then state == Running(17100,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,608471569,224],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 24 then state == Running(17101,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 25 then state == Running(17102,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904,free],H.Stage(mem,free,CL.Operation(filter),index,target,0))
                                                                                                                                                                                                                      else if id == 26 then state == Running(17103,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 27 then state == Running(17105,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,4],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 28 then state == Running(17106,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 29 then state == Running(17109,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free+4,1114],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 30 then state == Running(17110,prefix+[target,ptr,index,0,gas,1,receipt,1114,index,0,target,free+4,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 31 then state == Running(17111,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),0,target,free+4,index],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 32 then state == Running(17112,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,target,free+4,0],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 33 then state == Running(17113,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,free+4,target],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 34 then state == Running(17114,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 35 then state == Running(17117,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,24102],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 36 then state == Running(24102,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 37 then state == Running(24103,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 38 then state == Running(24105,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 39 then state == Running(24107,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1,1],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 40 then state == Running(24109,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1,1,224],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 41 then state == Running(24110,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 42 then state == Running(24111,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 43 then state == Running(24112,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 44 then state == Running(24113,prefix+[target,ptr,index,0,gas,1,receipt,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,free+4,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 45 then state == Running(24114,prefix+[target,ptr,index,0,gas,1,receipt,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,CL.Operation(filter),free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 46 then state == Running(24115,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,CL.Operation(filter),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 47 then state == Running(24116,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 48 then state == Running(24117,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,CL.Operation(filter),free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1))
                                                                                                                                                                                                                      else if id == 49 then state == Running(24118,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target],H.Stage(mem,free,CL.Operation(filter),index,target,2))
                                                                                                                                                                                                                      else if id == 50 then state == Running(24120,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,32],H.Stage(mem,free,CL.Operation(filter),index,target,2))
                                                                                                                                                                                                                      else if id == 51 then state == Running(24121,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,32,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,2))
                                                                                                                                                                                                                      else if id == 52 then state == Running(24122,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,free+36],H.Stage(mem,free,CL.Operation(filter),index,target,2))
                                                                                                                                                                                                                      else if id == 53 then state == Running(24123,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,free+36,0,target,index],H.Stage(mem,free,CL.Operation(filter),index,target,2))
                                                                                                                                                                                                                      else if id == 54 then state == Running(24124,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,free+36,0,index,target],H.Stage(mem,free,CL.Operation(filter),index,target,2))
                                                                                                                                                                                                                      else if id == 55 then state == Running(24125,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,index,free+36],H.Stage(mem,free,CL.Operation(filter),index,target,2))
                                                                                                                                                                                                                      else if id == 56 then state == Running(24126,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0],H.Stage(mem,free,CL.Operation(filter),index,target,3))
                                                                                                                                                                                                                      else if id == 57 then state == Running(24128,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,64],H.Stage(mem,free,CL.Operation(filter),index,target,3))
                                                                                                                                                                                                                      else if id == 58 then state == Running(24129,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,64,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,3))
                                                                                                                                                                                                                      else if id == 59 then state == Running(24130,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,free+68],H.Stage(mem,free,CL.Operation(filter),index,target,3))
                                                                                                                                                                                                                      else if id == 60 then state == Running(24131,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 61 then state == Running(24133,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 62 then state == Running(24135,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1,1],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 63 then state == Running(24137,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1,1,160],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 64 then state == Running(24138,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1,1461501637330902918203684832716283019655932542976],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 65 then state == Running(24139,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1461501637330902918203684832716283019655932542975],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 66 then state == Running(24140,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 67 then state == Running(24142,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,96],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 68 then state == Running(24143,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,96,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 69 then state == Running(24144,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,free+100],H.Stage(mem,free,CL.Operation(filter),index,target,4))
                                                                                                                                                                                                                      else if id == 70 then state == Running(24145,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 71 then state == Running(24147,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,128],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 72 then state == Running(24148,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 73 then state == Running(24149,prefix+[target,ptr,index,0,gas,1,receipt,free+132,1114],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 74 then state == Running(1114,prefix+[target,ptr,index,0,gas,1,receipt,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 75 then state == Running(1115,prefix+[target,ptr,index,0,gas,1,receipt,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 76 then state == Running(1117,prefix+[target,ptr,index,0,gas,1,receipt,free+132,64],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 77 then state == Running(1118,prefix+[target,ptr,index,0,gas,1,receipt,free+132,free],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 78 then state == Running(1119,prefix+[target,ptr,index,0,gas,1,receipt,free+132,free,free],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 79 then state == Running(1120,prefix+[target,ptr,index,0,gas,1,receipt,free,free,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 80 then state == Running(1121,prefix+[target,ptr,index,0,gas,1,receipt,free,132],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else if id == 81 then state == Running(1122,prefix+[target,ptr,index,0,gas,1,receipt,132,free],H.Stage(mem,free,CL.Operation(filter),index,target,5))
                                                                                                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(0,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17065,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17065) == Op(91,17066,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(1,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17066,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17066) == Op(128,17067,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(2,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17067,prefix+[target,ptr,index,0,gas,1,receipt,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17067) == Op(81,17068,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(3,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17068,prefix+[target,ptr,index,0,gas,1,receipt,receiptLength],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    F.Push1(code,17068);
    assert Fetch(code,17068) == Op(96,17070,32);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(4,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17070,prefix+[target,ptr,index,0,gas,1,receipt,receiptLength,32],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17070) == Op(20,17071,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(5,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17071,prefix+[target,ptr,index,0,gas,1,receipt,0],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    F.Push2(code,17071);
    assert Fetch(code,17071) == Op(97,17074,17118);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(6,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17074,prefix+[target,ptr,index,0,gas,1,receipt,0,17118],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17074) == Op(87,17075,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(7,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17075,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17075) == Op(95,17076,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(8,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17076,prefix+[target,ptr,index,0,gas,1,receipt,0],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17076) == Op(53,17077,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(9,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17077,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0)],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    F.Push1(code,17077);
    assert Fetch(code,17077) == Op(96,17079,1);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(10,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17079,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    F.Push1(code,17079);
    assert Fetch(code,17079) == Op(96,17081,1);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(11,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17081,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1,1],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    F.Push1(code,17081);
    assert Fetch(code,17081) == Op(96,17083,224);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(12,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17083,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1,1,224],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17083) == Op(27,17084,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(13,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17084,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17084) == Op(3,17085,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(14,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17085,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17085) == Op(25,17086,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(15,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17086,prefix+[target,ptr,index,0,gas,1,receipt,DataWord(data,0),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17086) == Op(22,17087,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(16,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17087,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17087) == Op(133,17088,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(17,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17088,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17088) == Op(95,17089,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(18,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17089,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17089) == Op(137,17090,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(19,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17090,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    F.Push1(code,17090);
    assert Fetch(code,17090) == Op(96,17092,64);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(20,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17092,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,64],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17092) == Op(81,17093,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(21,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17093,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    P.Push4(code,17093);
    assert Fetch(code,17093) == Op(99,17098,608471569);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(22,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17098,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,608471569],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    F.Push1(code,17098);
    assert Fetch(code,17098) == Op(96,17100,224);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(23,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17100,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,608471569,224],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17100) == Op(27,17101,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(24,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17101,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17101) == Op(129,17102,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(25,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,0);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17102,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904,free],H.Stage(mem,free,CL.Operation(filter),index,target,0));
    assert Fetch(code,17102) == Op(82,17103,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(26,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17103,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    F.Push1(code,17103);
    assert Fetch(code,17103) == Op(96,17105,4);
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(27,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17105,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free,4],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,17105) == Op(1,17106,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(28,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17106,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    F.Push2(code,17106);
    assert Fetch(code,17106) == Op(97,17109,1114);
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(29,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17109,prefix+[target,ptr,index,0,gas,1,receipt,CL.Operation(filter),index,0,target,free+4,1114],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,17109) == Op(148,17110,0);
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(30,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17110,prefix+[target,ptr,index,0,gas,1,receipt,1114,index,0,target,free+4,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,17110) == Op(147,17111,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(31,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17111,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),0,target,free+4,index],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,17111) == Op(146,17112,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(32,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17112,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,target,free+4,0],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,17112) == Op(145,17113,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(33,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17113,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,free+4,target],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,17113) == Op(144,17114,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(34,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17114,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    F.Push2(code,17114);
    assert Fetch(code,17114) == Op(97,17117,24102);
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(35,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(17117,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,24102],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,17117) == Op(86,17118,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(36,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24102,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24102) == Op(91,24103,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(37,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24103,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    F.Push1(code,24103);
    assert Fetch(code,24103) == Op(96,24105,1);
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(38,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24105,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    F.Push1(code,24105);
    assert Fetch(code,24105) == Op(96,24107,1);
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(39,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24107,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1,1],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    F.Push1(code,24107);
    assert Fetch(code,24107) == Op(96,24109,224);
  }
  lemma Advance40(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(40,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24109,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1,1,224],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24109) == Op(27,24110,0);
  }
  lemma Advance41(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(41,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24110,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24110) == Op(3,24111,0);
  }
  lemma Advance42(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(42,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24111,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24111) == Op(25,24112,0);
  }
  lemma Advance43(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(43,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24112,prefix+[target,ptr,index,0,gas,1,receipt,1114,CL.Operation(filter),index,0,target,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24112) == Op(148,24113,0);
  }
  lemma Advance44(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(44,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24113,prefix+[target,ptr,index,0,gas,1,receipt,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,free+4,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24113) == Op(144,24114,0);
  }
  lemma Advance45(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(45,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24114,prefix+[target,ptr,index,0,gas,1,receipt,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,CL.Operation(filter),free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24114) == Op(148,24115,0);
  }
  lemma Advance46(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(46,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24115,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,CL.Operation(filter),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24115) == Op(22,24116,0);
  }
  lemma Advance47(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(47,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24116,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,CL.Operation(filter)],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24116) == Op(132,24117,0);
  }
  lemma Advance48(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(48,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,1);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24117,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,CL.Operation(filter),free+4],H.Stage(mem,free,CL.Operation(filter),index,target,1));
    assert Fetch(code,24117) == Op(82,24118,0);
  }
  lemma Advance49(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(49,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,2);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24118,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target],H.Stage(mem,free,CL.Operation(filter),index,target,2));
    F.Push1(code,24118);
    assert Fetch(code,24118) == Op(96,24120,32);
  }
  lemma Advance50(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(50,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,2);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24120,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,32],H.Stage(mem,free,CL.Operation(filter),index,target,2));
    assert Fetch(code,24120) == Op(132,24121,0);
  }
  lemma Advance51(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(51,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,2);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24121,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,32,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,2));
    assert Fetch(code,24121) == Op(1,24122,0);
  }
  lemma Advance52(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(52,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,2);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24122,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,index,0,target,free+36],H.Stage(mem,free,CL.Operation(filter),index,target,2));
    assert Fetch(code,24122) == Op(146,24123,0);
  }
  lemma Advance53(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(53,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,2);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24123,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,free+36,0,target,index],H.Stage(mem,free,CL.Operation(filter),index,target,2));
    assert Fetch(code,24123) == Op(144,24124,0);
  }
  lemma Advance54(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(54,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(55,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,2);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24124,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,free+36,0,index,target],H.Stage(mem,free,CL.Operation(filter),index,target,2));
    assert Fetch(code,24124) == Op(146,24125,0);
  }
  lemma Advance55(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(55,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(56,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,2);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24125,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,index,free+36],H.Stage(mem,free,CL.Operation(filter),index,target,2));
    assert Fetch(code,24125) == Op(82,24126,0);
  }
  lemma Advance56(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(56,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(57,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,3);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24126,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0],H.Stage(mem,free,CL.Operation(filter),index,target,3));
    F.Push1(code,24126);
    assert Fetch(code,24126) == Op(96,24128,64);
  }
  lemma Advance57(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(57,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(58,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,3);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24128,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,64],H.Stage(mem,free,CL.Operation(filter),index,target,3));
    assert Fetch(code,24128) == Op(131,24129,0);
  }
  lemma Advance58(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(58,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(59,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,3);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24129,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,64,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,3));
    assert Fetch(code,24129) == Op(1,24130,0);
  }
  lemma Advance59(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(59,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(60,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,3);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24130,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,0,free+68],H.Stage(mem,free,CL.Operation(filter),index,target,3));
    assert Fetch(code,24130) == Op(82,24131,0);
  }
  lemma Advance60(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(60,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(61,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24131,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    F.Push1(code,24131);
    assert Fetch(code,24131) == Op(96,24133,1);
  }
  lemma Advance61(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(61,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(62,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24133,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    F.Push1(code,24133);
    assert Fetch(code,24133) == Op(96,24135,1);
  }
  lemma Advance62(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(62,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(63,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24135,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1,1],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    F.Push1(code,24135);
    assert Fetch(code,24135) == Op(96,24137,160);
  }
  lemma Advance63(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(63,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(64,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24137,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1,1,160],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    assert Fetch(code,24137) == Op(27,24138,0);
  }
  lemma Advance64(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(64,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(65,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24138,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1,1461501637330902918203684832716283019655932542976],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    assert Fetch(code,24138) == Op(3,24139,0);
  }
  lemma Advance65(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(65,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(66,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24139,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,1461501637330902918203684832716283019655932542975],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    assert Fetch(code,24139) == Op(22,24140,0);
  }
  lemma Advance66(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(66,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(67,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24140,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    F.Push1(code,24140);
    assert Fetch(code,24140) == Op(96,24142,96);
  }
  lemma Advance67(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(67,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(68,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24142,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,96],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    assert Fetch(code,24142) == Op(130,24143,0);
  }
  lemma Advance68(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(68,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(69,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24143,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,96,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    assert Fetch(code,24143) == Op(1,24144,0);
  }
  lemma Advance69(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(69,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(70,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,4);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24144,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,target,free+100],H.Stage(mem,free,CL.Operation(filter),index,target,4));
    assert Fetch(code,24144) == Op(82,24145,0);
  }
  lemma Advance70(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(70,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(71,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24145,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    F.Push1(code,24145);
    assert Fetch(code,24145) == Op(96,24147,128);
  }
  lemma Advance71(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(71,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(72,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24147,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+4,128],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,24147) == Op(1,24148,0);
  }
  lemma Advance72(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(72,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(73,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24148,prefix+[target,ptr,index,0,gas,1,receipt,1114,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,24148) == Op(144,24149,0);
  }
  lemma Advance73(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(73,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(74,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(24149,prefix+[target,ptr,index,0,gas,1,receipt,free+132,1114],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,24149) == Op(86,24150,0);
  }
  lemma Advance74(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(74,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(75,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(1114,prefix+[target,ptr,index,0,gas,1,receipt,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance75(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(75,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(76,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(1115,prefix+[target,ptr,index,0,gas,1,receipt,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance76(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(76,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(77,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(1117,prefix+[target,ptr,index,0,gas,1,receipt,free+132,64],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance77(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(77,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(78,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(1118,prefix+[target,ptr,index,0,gas,1,receipt,free+132,free],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance78(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(78,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(79,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(1119,prefix+[target,ptr,index,0,gas,1,receipt,free+132,free,free],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance79(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(79,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(80,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(1120,prefix+[target,ptr,index,0,gas,1,receipt,free,free,free+132],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance80(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(80,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(81,next,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    assert state == Running(1121,prefix+[target,ptr,index,0,gas,1,receipt,free,132],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance81(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(81,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(H.Packet(CL.Operation(filter),index,target))
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,CL.Operation(filter),index,target,5);
    SC.Literals(); CL.Mask(filter,data); A.Canonical(target);
    H.Bytes(mem,free,CL.Operation(filter),index,target);
    assert G.Grow(H.Stage(mem,free,CL.Operation(filter),index,target,5),free+132) == H.Stage(mem,free,CL.Operation(filter),index,target,5);
    assert state == Running(1122,prefix+[target,ptr,index,0,gas,1,receipt,132,free],H.Stage(mem,free,CL.Operation(filter),index,target,5));
    assert Fetch(code,1122) == Op(253,1123,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(0,initial,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Good(20,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance0(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);trace := trace+[next0];state := next0;
    Advance1(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);trace := trace+[next1];state := next1;
    Advance2(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);trace := trace+[next2];state := next2;
    Advance3(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);trace := trace+[next3];state := next3;
    Advance4(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);trace := trace+[next4];state := next4;
    Advance5(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);trace := trace+[next5];state := next5;
    Advance6(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);trace := trace+[next6];state := next6;
    Advance7(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);trace := trace+[next7];state := next7;
    Advance8(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);trace := trace+[next8];state := next8;
    Advance9(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);trace := trace+[next9];state := next9;
    Advance10(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);trace := trace+[next10];state := next10;
    Advance11(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);trace := trace+[next11];state := next11;
    Advance12(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);trace := trace+[next12];state := next12;
    Advance13(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);trace := trace+[next13];state := next13;
    Advance14(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);trace := trace+[next14];state := next14;
    Advance15(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);trace := trace+[next15];state := next15;
    Advance16(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);trace := trace+[next16];state := next16;
    Advance17(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);trace := trace+[next17];state := next17;
    Advance18(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);trace := trace+[next18];state := next18;
    Advance19(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);trace := trace+[next19];state := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(20,initial,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Good(40,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance20(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);trace := trace+[next20];state := next20;
    Advance21(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);trace := trace+[next21];state := next21;
    Advance22(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);trace := trace+[next22];state := next22;
    Advance23(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);trace := trace+[next23];state := next23;
    Advance24(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);trace := trace+[next24];state := next24;
    Advance25(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);trace := trace+[next25];state := next25;
    Advance26(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);trace := trace+[next26];state := next26;
    Advance27(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);trace := trace+[next27];state := next27;
    Advance28(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);trace := trace+[next28];state := next28;
    Advance29(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);trace := trace+[next29];state := next29;
    Advance30(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);trace := trace+[next30];state := next30;
    Advance31(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);trace := trace+[next31];state := next31;
    Advance32(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);trace := trace+[next32];state := next32;
    Advance33(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);trace := trace+[next33];state := next33;
    Advance34(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);trace := trace+[next34];state := next34;
    Advance35(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);trace := trace+[next35];state := next35;
    Advance36(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);trace := trace+[next36];state := next36;
    Advance37(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);trace := trace+[next37];state := next37;
    Advance38(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);trace := trace+[next38];state := next38;
    Advance39(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);trace := trace+[next39];state := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(40,initial,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Good(60,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance40(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);trace := trace+[next40];state := next40;
    Advance41(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);trace := trace+[next41];state := next41;
    Advance42(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);trace := trace+[next42];state := next42;
    Advance43(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);trace := trace+[next43];state := next43;
    Advance44(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);trace := trace+[next44];state := next44;
    Advance45(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);trace := trace+[next45];state := next45;
    Advance46(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);trace := trace+[next46];state := next46;
    Advance47(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);trace := trace+[next47];state := next47;
    Advance48(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);trace := trace+[next48];state := next48;
    Advance49(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);trace := trace+[next49];state := next49;
    Advance50(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);trace := trace+[next50];state := next50;
    Advance51(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);trace := trace+[next51];state := next51;
    Advance52(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);trace := trace+[next52];state := next52;
    Advance53(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next53 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);trace := trace+[next53];state := next53;
    Advance54(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next54 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);trace := trace+[next54];state := next54;
    Advance55(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next55 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55);trace := trace+[next55];state := next55;
    Advance56(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next56 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56);trace := trace+[next56];state := next56;
    Advance57(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next57 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57);trace := trace+[next57];state := next57;
    Advance58(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next58 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58);trace := trace+[next58];state := next58;
    Advance59(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next59 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59);trace := trace+[next59];state := next59;
  }
  ghost method Block3(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(60,initial,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures Good(80,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance60(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next60 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next60);trace := trace+[next60];state := next60;
    Advance61(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next61 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next61);trace := trace+[next61];state := next61;
    Advance62(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next62 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next62);trace := trace+[next62];state := next62;
    Advance63(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next63 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next63);trace := trace+[next63];state := next63;
    Advance64(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next64 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next64);trace := trace+[next64];state := next64;
    Advance65(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next65 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next65);trace := trace+[next65];state := next65;
    Advance66(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next66 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next66);trace := trace+[next66];state := next66;
    Advance67(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next67 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next67);trace := trace+[next67];state := next67;
    Advance68(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next68 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next68);trace := trace+[next68];state := next68;
    Advance69(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next69 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next69);trace := trace+[next69];state := next69;
    Advance70(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next70 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next70);trace := trace+[next70];state := next70;
    Advance71(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next71 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next71);trace := trace+[next71];state := next71;
    Advance72(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next72 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next72);trace := trace+[next72];state := next72;
    Advance73(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next73 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next73);trace := trace+[next73];state := next73;
    Advance74(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next74 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next74);trace := trace+[next74];state := next74;
    Advance75(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next75 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next75);trace := trace+[next75];state := next75;
    Advance76(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next76 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next76);trace := trace+[next76];state := next76;
    Advance77(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next77 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next77);trace := trace+[next77];state := next77;
    Advance78(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next78 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next78);trace := trace+[next78];state := next78;
    Advance79(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next79 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next79);trace := trace+[next79];state := next79;
  }
  ghost method Block4(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value) && Good(80,initial,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures state == Reverted(H.Packet(CL.Operation(filter),index,target)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 3 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance80(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next80 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next80);trace := trace+[next80];state := next80;
    Advance81(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    var next81 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next81);trace := trace+[next81];state := next81;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gas: Word,receipt: Word,receiptLength: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value)
    ensures state == Reverted(H.Packet(CL.Operation(filter),index,target)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 83 && trace[0] == Running(17065,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0)) && trace[|trace|-1] == state
  { state := Running(17065,prefix+[target,ptr,index,0,gas,1,receipt],H.Stage(mem,free,CL.Operation(filter),index,target,0));trace := [state];reveal Good();var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block3(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block4(code,state,data,mem,prefix,filter,target,ptr,index,gas,receipt,receiptLength,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
