// SPDX-License-Identifier: MIT
// Generated complete actual noncanonical filter predicate branch through exact132-byte REVERT.
include "../callback-result-error/Scalar.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyPredicateError {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import H = BytecodeApplyWrongCallbackMemory
  import SC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  opaque predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) { H.Fits(mem,free) && result > 1 && target < A.Bound() && ShiftRight(DataWord(data,0),224) == 2005396296 && |prefix| <= 999 }
  lemma Admission(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000
    ensures result > 1 && target < A.Bound() && ShiftRight(DataWord(data,0),224) == 2005396296 && |prefix| <= 999
  { hide DataWord(); hide ShiftRight(); reveal Admitted(); }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[1114] == 91 &&
                                              code[1115] == 96 &&
                                              code[1116] == 64 &&
                                              code[1117] == 81 &&
                                              code[1118] == 128 &&
                                              code[1119] == 145 &&
                                              code[1120] == 3 &&
                                              code[1121] == 144 &&
                                              code[1122] == 253 &&
                                              code[12484] == 91 &&
                                              code[12485] == 144 &&
                                              code[12486] == 80 &&
                                              code[12487] == 135 &&
                                              code[12488] == 21 &&
                                              code[12489] == 97 &&
                                              code[12490] == 49 &&
                                              code[12491] == 37 &&
                                              code[12492] == 87 &&
                                              code[12493] == 96 &&
                                              code[12494] == 1 &&
                                              code[12495] == 129 &&
                                              code[12496] == 17 &&
                                              code[12497] == 21 &&
                                              code[12498] == 97 &&
                                              code[12499] == 49 &&
                                              code[12500] == 1 &&
                                              code[12501] == 87 &&
                                              code[12502] == 95 &&
                                              code[12503] == 53 &&
                                              code[12504] == 96 &&
                                              code[12505] == 1 &&
                                              code[12506] == 96 &&
                                              code[12507] == 1 &&
                                              code[12508] == 96 &&
                                              code[12509] == 224 &&
                                              code[12510] == 27 &&
                                              code[12511] == 3 &&
                                              code[12512] == 25 &&
                                              code[12513] == 22 &&
                                              code[12514] == 131 &&
                                              code[12515] == 95 &&
                                              code[12516] == 143 &&
                                              code[12517] == 96 &&
                                              code[12518] == 64 &&
                                              code[12519] == 81 &&
                                              code[12520] == 99 &&
                                              code[12521] == 36 &&
                                              code[12522] == 68 &&
                                              code[12523] == 138 &&
                                              code[12524] == 17 &&
                                              code[12525] == 96 &&
                                              code[12526] == 224 &&
                                              code[12527] == 27 &&
                                              code[12528] == 129 &&
                                              code[12529] == 82 &&
                                              code[12530] == 96 &&
                                              code[12531] == 4 &&
                                              code[12532] == 1 &&
                                              code[12533] == 97 &&
                                              code[12534] == 4 &&
                                              code[12535] == 90 &&
                                              code[12536] == 148 &&
                                              code[12537] == 147 &&
                                              code[12538] == 146 &&
                                              code[12539] == 145 &&
                                              code[12540] == 144 &&
                                              code[12541] == 97 &&
                                              code[12542] == 94 &&
                                              code[12543] == 38 &&
                                              code[12544] == 86 &&
                                              code[12545] == 91 &&
                                              code[12581] == 91 &&
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
  function Destinations(): set<nat> { {1114,12545,12581,24102} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) { Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000 && (
                                                                                                                                                                                                                                                                                                                                               if id == 0 then state == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 1 then state == Running(12485,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 2 then state == Running(12486,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 3 then state == Running(12487,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 4 then state == Running(12488,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 5 then state == Running(12489,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 6 then state == Running(12492,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12581],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 7 then state == Running(12493,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 8 then state == Running(12495,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 9 then state == Running(12496,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,result],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 10 then state == Running(12497,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 11 then state == Running(12498,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 12 then state == Running(12501,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12545],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 13 then state == Running(12502,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 14 then state == Running(12503,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 15 then state == Running(12504,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0)],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 16 then state == Running(12506,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 17 then state == Running(12508,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1,1],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 18 then state == Running(12510,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1,1,224],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 19 then state == Running(12511,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 20 then state == Running(12512,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 21 then state == Running(12513,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 22 then state == Running(12514,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 23 then state == Running(12515,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 24 then state == Running(12516,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 25 then state == Running(12517,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 26 then state == Running(12519,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,64],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 27 then state == Running(12520,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 28 then state == Running(12525,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,608471569],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 29 then state == Running(12527,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,608471569,224],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 30 then state == Running(12528,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 31 then state == Running(12529,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904,free],H.Stage(mem,free,SC.Operation(),index,target,0))
                                                                                                                                                                                                                                                                                                                                               else if id == 32 then state == Running(12530,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 33 then state == Running(12532,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,4],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 34 then state == Running(12533,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 35 then state == Running(12536,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free+4,1114],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 36 then state == Running(12537,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,index,0,target,free+4,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 37 then state == Running(12538,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),0,target,free+4,index],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 38 then state == Running(12539,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,target,free+4,0],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 39 then state == Running(12540,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,free+4,target],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 40 then state == Running(12541,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 41 then state == Running(12544,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,24102],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 42 then state == Running(24102,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 43 then state == Running(24103,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 44 then state == Running(24105,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 45 then state == Running(24107,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1,1],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 46 then state == Running(24109,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1,1,224],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 47 then state == Running(24110,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 48 then state == Running(24111,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 49 then state == Running(24112,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 50 then state == Running(24113,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,free+4,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 51 then state == Running(24114,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,SC.Operation(),free+4],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 52 then state == Running(24115,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,SC.Operation(),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 53 then state == Running(24116,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 54 then state == Running(24117,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,SC.Operation(),free+4],H.Stage(mem,free,SC.Operation(),index,target,1))
                                                                                                                                                                                                                                                                                                                                               else if id == 55 then state == Running(24118,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target],H.Stage(mem,free,SC.Operation(),index,target,2))
                                                                                                                                                                                                                                                                                                                                               else if id == 56 then state == Running(24120,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,32],H.Stage(mem,free,SC.Operation(),index,target,2))
                                                                                                                                                                                                                                                                                                                                               else if id == 57 then state == Running(24121,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,32,free+4],H.Stage(mem,free,SC.Operation(),index,target,2))
                                                                                                                                                                                                                                                                                                                                               else if id == 58 then state == Running(24122,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,free+36],H.Stage(mem,free,SC.Operation(),index,target,2))
                                                                                                                                                                                                                                                                                                                                               else if id == 59 then state == Running(24123,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,free+36,0,target,index],H.Stage(mem,free,SC.Operation(),index,target,2))
                                                                                                                                                                                                                                                                                                                                               else if id == 60 then state == Running(24124,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,free+36,0,index,target],H.Stage(mem,free,SC.Operation(),index,target,2))
                                                                                                                                                                                                                                                                                                                                               else if id == 61 then state == Running(24125,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,index,free+36],H.Stage(mem,free,SC.Operation(),index,target,2))
                                                                                                                                                                                                                                                                                                                                               else if id == 62 then state == Running(24126,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0],H.Stage(mem,free,SC.Operation(),index,target,3))
                                                                                                                                                                                                                                                                                                                                               else if id == 63 then state == Running(24128,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,64],H.Stage(mem,free,SC.Operation(),index,target,3))
                                                                                                                                                                                                                                                                                                                                               else if id == 64 then state == Running(24129,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,64,free+4],H.Stage(mem,free,SC.Operation(),index,target,3))
                                                                                                                                                                                                                                                                                                                                               else if id == 65 then state == Running(24130,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,free+68],H.Stage(mem,free,SC.Operation(),index,target,3))
                                                                                                                                                                                                                                                                                                                                               else if id == 66 then state == Running(24131,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 67 then state == Running(24133,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 68 then state == Running(24135,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1,1],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 69 then state == Running(24137,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1,1,160],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 70 then state == Running(24138,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1,1461501637330902918203684832716283019655932542976],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 71 then state == Running(24139,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1461501637330902918203684832716283019655932542975],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 72 then state == Running(24140,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 73 then state == Running(24142,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,96],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 74 then state == Running(24143,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,96,free+4],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 75 then state == Running(24144,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,free+100],H.Stage(mem,free,SC.Operation(),index,target,4))
                                                                                                                                                                                                                                                                                                                                               else if id == 76 then state == Running(24145,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 77 then state == Running(24147,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,128],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 78 then state == Running(24148,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+132],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 79 then state == Running(24149,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,1114],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 80 then state == Running(1114,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 81 then state == Running(1115,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 82 then state == Running(1117,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,64],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 83 then state == Running(1118,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,free],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 84 then state == Running(1119,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,free,free],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 85 then state == Running(1120,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free,free,free+132],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 86 then state == Running(1121,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free,132],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else if id == 87 then state == Running(1122,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,132,free],H.Stage(mem,free,SC.Operation(),index,target,5))
                                                                                                                                                                                                                                                                                                                                               else false) }
  lemma StageNext(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word,k: nat)
    requires H.Fits(mem,free) && k < 5
    ensures H.Stage(mem,free,SC.Operation(),index,target,k+1) == Store(H.Stage(mem,free,SC.Operation(),index,target,k),if k == 0 then free else free+4+32*(k-1),if k == 0 then H.Header() else if k == 1 then SC.Operation() else if k == 2 then index else if k == 3 then 0 else target)
  { reveal H.Stage(); }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12484) == Op(91,12485,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12485,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12485) == Op(144,12486,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12486,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12486) == Op(80,12487,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12487,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12487) == Op(135,12488,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12488,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12488) == Op(21,12489,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12489,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push2(code,12489);
    assert Fetch(code,12489) == Op(97,12492,12581);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12492,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12581],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12492) == Op(87,12493,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12493,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push1(code,12493);
    assert Fetch(code,12493) == Op(96,12495,1);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12495,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12495) == Op(129,12496,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12496,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,result],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12496) == Op(17,12497,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12497,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12497) == Op(21,12498,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(11,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12498,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push2(code,12498);
    assert Fetch(code,12498) == Op(97,12501,12545);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(12,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12501,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12545],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12501) == Op(87,12502,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(13,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12502,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12502) == Op(95,12503,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(14,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12503,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12503) == Op(53,12504,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(15,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12504,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0)],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push1(code,12504);
    assert Fetch(code,12504) == Op(96,12506,1);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(16,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12506,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push1(code,12506);
    assert Fetch(code,12506) == Op(96,12508,1);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(17,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12508,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1,1],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push1(code,12508);
    assert Fetch(code,12508) == Op(96,12510,224);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(18,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.Literals();
    assert state == Running(12510,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1,1,224],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12510) == Op(27,12511,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(19,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12511,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12511) == Op(3,12512,0);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.NotLiteral();
    assert state == Running(12512,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12512) == Op(25,12513,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(21,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.OperationMask(data); A.Canonical(target);
    assert state == Running(12513,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,DataWord(data,0),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12513) == Op(22,12514,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(22,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12514,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12514) == Op(131,12515,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(23,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12515,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12515) == Op(95,12516,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(24,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12516,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12516) == Op(143,12517,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(25,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12517,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push1(code,12517);
    assert Fetch(code,12517) == Op(96,12519,64);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(26,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12519,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,64],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12519) == Op(81,12520,0);
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(27,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12520,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free],H.Stage(mem,free,SC.Operation(),index,target,0));
    P.Push4(code,12520);
    assert Fetch(code,12520) == Op(99,12525,608471569);
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(28,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12525,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,608471569],H.Stage(mem,free,SC.Operation(),index,target,0));
    F.Push1(code,12525);
    assert Fetch(code,12525) == Op(96,12527,224);
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(29,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.Literals();
    assert state == Running(12527,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,608471569,224],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12527) == Op(27,12528,0);
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(30,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12528,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12528) == Op(129,12529,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(31,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,0);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    StageNext(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value,0);
    assert state == Running(12529,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,16404361048717470555214876502545506209788520203462861103735336579904940539904,free],H.Stage(mem,free,SC.Operation(),index,target,0));
    assert Fetch(code,12529) == Op(82,12530,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(32,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12530,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free],H.Stage(mem,free,SC.Operation(),index,target,1));
    F.Push1(code,12530);
    assert Fetch(code,12530) == Op(96,12532,4);
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(33,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12532,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free,4],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,12532) == Op(1,12533,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(34,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12533,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1));
    F.Push2(code,12533);
    assert Fetch(code,12533) == Op(97,12536,1114);
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(35,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12536,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,SC.Operation(),index,0,target,free+4,1114],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,12536) == Op(148,12537,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(36,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12537,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,index,0,target,free+4,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,12537) == Op(147,12538,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(37,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12538,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),0,target,free+4,index],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,12538) == Op(146,12539,0);
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(38,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12539,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,target,free+4,0],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,12539) == Op(145,12540,0);
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(39,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12540,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,free+4,target],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,12540) == Op(144,12541,0);
  }
  lemma Advance40(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(40,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12541,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1));
    F.Push2(code,12541);
    assert Fetch(code,12541) == Op(97,12544,24102);
  }
  lemma Advance41(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(41,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(12544,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,24102],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,12544) == Op(86,12545,0);
  }
  lemma Advance42(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(42,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24102,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24102) == Op(91,24103,0);
  }
  lemma Advance43(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(43,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24103,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4],H.Stage(mem,free,SC.Operation(),index,target,1));
    F.Push1(code,24103);
    assert Fetch(code,24103) == Op(96,24105,1);
  }
  lemma Advance44(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(44,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24105,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1],H.Stage(mem,free,SC.Operation(),index,target,1));
    F.Push1(code,24105);
    assert Fetch(code,24105) == Op(96,24107,1);
  }
  lemma Advance45(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(45,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24107,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1,1],H.Stage(mem,free,SC.Operation(),index,target,1));
    F.Push1(code,24107);
    assert Fetch(code,24107) == Op(96,24109,224);
  }
  lemma Advance46(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(46,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.Literals();
    assert state == Running(24109,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1,1,224],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24109) == Op(27,24110,0);
  }
  lemma Advance47(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(47,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24110,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,1,26959946667150639794667015087019630673637144422540572481103610249216],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24110) == Op(3,24111,0);
  }
  lemma Advance48(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(48,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.NotLiteral();
    assert state == Running(24111,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,26959946667150639794667015087019630673637144422540572481103610249215],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24111) == Op(25,24112,0);
  }
  lemma Advance49(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(49,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24112,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,SC.Operation(),index,0,target,free+4,115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24112) == Op(148,24113,0);
  }
  lemma Advance50(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(50,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24113,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,free+4,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24113) == Op(144,24114,0);
  }
  lemma Advance51(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(51,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24114,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,115792089210356248756420345214020892766250353992003419616917011526809519390720,index,0,target,SC.Operation(),free+4],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24114) == Op(148,24115,0);
  }
  lemma Advance52(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(52,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.OperationMask(data); A.Canonical(target);
    assert state == Running(24115,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,SC.Operation(),115792089210356248756420345214020892766250353992003419616917011526809519390720],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24115) == Op(22,24116,0);
  }
  lemma Advance53(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(53,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24116,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,SC.Operation()],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24116) == Op(132,24117,0);
  }
  lemma Advance54(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(54,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(55,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,1);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    StageNext(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value,1);
    assert state == Running(24117,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,SC.Operation(),free+4],H.Stage(mem,free,SC.Operation(),index,target,1));
    assert Fetch(code,24117) == Op(82,24118,0);
  }
  lemma Advance55(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(55,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(56,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,2);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24118,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target],H.Stage(mem,free,SC.Operation(),index,target,2));
    F.Push1(code,24118);
    assert Fetch(code,24118) == Op(96,24120,32);
  }
  lemma Advance56(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(56,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(57,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,2);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24120,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,32],H.Stage(mem,free,SC.Operation(),index,target,2));
    assert Fetch(code,24120) == Op(132,24121,0);
  }
  lemma Advance57(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(57,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(58,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,2);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24121,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,32,free+4],H.Stage(mem,free,SC.Operation(),index,target,2));
    assert Fetch(code,24121) == Op(1,24122,0);
  }
  lemma Advance58(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(58,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(59,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,2);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24122,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,index,0,target,free+36],H.Stage(mem,free,SC.Operation(),index,target,2));
    assert Fetch(code,24122) == Op(146,24123,0);
  }
  lemma Advance59(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(59,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(60,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,2);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24123,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,free+36,0,target,index],H.Stage(mem,free,SC.Operation(),index,target,2));
    assert Fetch(code,24123) == Op(144,24124,0);
  }
  lemma Advance60(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(60,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(61,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,2);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24124,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,free+36,0,index,target],H.Stage(mem,free,SC.Operation(),index,target,2));
    assert Fetch(code,24124) == Op(146,24125,0);
  }
  lemma Advance61(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(61,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(62,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,2);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    StageNext(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value,2);
    assert state == Running(24125,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,index,free+36],H.Stage(mem,free,SC.Operation(),index,target,2));
    assert Fetch(code,24125) == Op(82,24126,0);
  }
  lemma Advance62(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(62,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(63,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,3);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24126,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0],H.Stage(mem,free,SC.Operation(),index,target,3));
    F.Push1(code,24126);
    assert Fetch(code,24126) == Op(96,24128,64);
  }
  lemma Advance63(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(63,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(64,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,3);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24128,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,64],H.Stage(mem,free,SC.Operation(),index,target,3));
    assert Fetch(code,24128) == Op(131,24129,0);
  }
  lemma Advance64(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(64,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(65,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,3);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24129,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,64,free+4],H.Stage(mem,free,SC.Operation(),index,target,3));
    assert Fetch(code,24129) == Op(1,24130,0);
  }
  lemma Advance65(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(65,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(66,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,3);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    StageNext(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value,3);
    assert state == Running(24130,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,0,free+68],H.Stage(mem,free,SC.Operation(),index,target,3));
    assert Fetch(code,24130) == Op(82,24131,0);
  }
  lemma Advance66(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(66,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(67,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24131,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target],H.Stage(mem,free,SC.Operation(),index,target,4));
    F.Push1(code,24131);
    assert Fetch(code,24131) == Op(96,24133,1);
  }
  lemma Advance67(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(67,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(68,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24133,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1],H.Stage(mem,free,SC.Operation(),index,target,4));
    F.Push1(code,24133);
    assert Fetch(code,24133) == Op(96,24135,1);
  }
  lemma Advance68(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(68,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(69,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24135,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1,1],H.Stage(mem,free,SC.Operation(),index,target,4));
    F.Push1(code,24135);
    assert Fetch(code,24135) == Op(96,24137,160);
  }
  lemma Advance69(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(69,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(70,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.Literals();
    assert state == Running(24137,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1,1,160],H.Stage(mem,free,SC.Operation(),index,target,4));
    assert Fetch(code,24137) == Op(27,24138,0);
  }
  lemma Advance70(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(70,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(71,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24138,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1,1461501637330902918203684832716283019655932542976],H.Stage(mem,free,SC.Operation(),index,target,4));
    assert Fetch(code,24138) == Op(3,24139,0);
  }
  lemma Advance71(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(71,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(72,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    SC.OperationMask(data); A.Canonical(target);
    assert state == Running(24139,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,1461501637330902918203684832716283019655932542975],H.Stage(mem,free,SC.Operation(),index,target,4));
    assert Fetch(code,24139) == Op(22,24140,0);
  }
  lemma Advance72(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(72,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(73,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24140,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target],H.Stage(mem,free,SC.Operation(),index,target,4));
    F.Push1(code,24140);
    assert Fetch(code,24140) == Op(96,24142,96);
  }
  lemma Advance73(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(73,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(74,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24142,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,96],H.Stage(mem,free,SC.Operation(),index,target,4));
    assert Fetch(code,24142) == Op(130,24143,0);
  }
  lemma Advance74(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(74,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(75,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24143,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,96,free+4],H.Stage(mem,free,SC.Operation(),index,target,4));
    assert Fetch(code,24143) == Op(1,24144,0);
  }
  lemma Advance75(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(75,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(76,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,4);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    StageNext(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value,4);
    assert state == Running(24144,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,target,free+100],H.Stage(mem,free,SC.Operation(),index,target,4));
    assert Fetch(code,24144) == Op(82,24145,0);
  }
  lemma Advance76(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(76,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(77,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24145,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4],H.Stage(mem,free,SC.Operation(),index,target,5));
    F.Push1(code,24145);
    assert Fetch(code,24145) == Op(96,24147,128);
  }
  lemma Advance77(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(77,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(78,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24147,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+4,128],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,24147) == Op(1,24148,0);
  }
  lemma Advance78(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(78,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(79,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24148,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1114,free+132],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,24148) == Op(144,24149,0);
  }
  lemma Advance79(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(79,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(80,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(24149,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,1114],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,24149) == Op(86,24150,0);
  }
  lemma Advance80(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(80,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(81,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(1114,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance81(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(81,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(82,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(1115,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132],H.Stage(mem,free,SC.Operation(),index,target,5));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance82(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(82,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(83,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(1117,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,64],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance83(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(83,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(84,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(1118,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,free],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance84(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(84,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(85,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(1119,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free+132,free,free],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance85(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(85,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(86,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(1120,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free,free,free+132],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance86(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(86,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(87,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    assert state == Running(1121,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,free,132],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance87(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(87,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(H.Packet(SC.Operation(),index,target))
  { hide G.BitAnd(); hide BitNot(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,5);
    Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    H.Bytes(mem,free,SC.Operation(),index,target);
    assert G.Grow(H.Stage(mem,free,SC.Operation(),index,target,5),free+132) == H.Stage(mem,free,SC.Operation(),index,target,5);
    assert state == Running(1122,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,132,free],H.Stage(mem,free,SC.Operation(),index,target,5));
    assert Fetch(code,1122) == Op(253,1123,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { hide E.Trace(); state := initial;trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);trace := trace+[next0];state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);trace := trace+[next1];state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);trace := trace+[next2];state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);trace := trace+[next3];state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);trace := trace+[next4];state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);trace := trace+[next5];state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);trace := trace+[next6];state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);trace := trace+[next7];state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);trace := trace+[next8];state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);trace := trace+[next9];state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);trace := trace+[next10];state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);trace := trace+[next11];state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);trace := trace+[next12];state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);trace := trace+[next13];state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);trace := trace+[next14];state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);trace := trace+[next15];state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);trace := trace+[next16];state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);trace := trace+[next17];state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);trace := trace+[next18];state := next18;
    Advance19(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);trace := trace+[next19];state := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(20,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Good(40,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { hide E.Trace(); state := initial;trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);trace := trace+[next20];state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);trace := trace+[next21];state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);trace := trace+[next22];state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);trace := trace+[next23];state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);trace := trace+[next24];state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);trace := trace+[next25];state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);trace := trace+[next26];state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);trace := trace+[next27];state := next27;
    Advance28(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);trace := trace+[next28];state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);trace := trace+[next29];state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);trace := trace+[next30];state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);trace := trace+[next31];state := next31;
    Advance32(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);trace := trace+[next32];state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);trace := trace+[next33];state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);trace := trace+[next34];state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);trace := trace+[next35];state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);trace := trace+[next36];state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);trace := trace+[next37];state := next37;
    Advance38(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);trace := trace+[next38];state := next38;
    Advance39(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);trace := trace+[next39];state := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(40,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Good(60,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { hide E.Trace(); state := initial;trace := [state];
    Advance40(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);trace := trace+[next40];state := next40;
    Advance41(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);trace := trace+[next41];state := next41;
    Advance42(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);trace := trace+[next42];state := next42;
    Advance43(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);trace := trace+[next43];state := next43;
    Advance44(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);trace := trace+[next44];state := next44;
    Advance45(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);trace := trace+[next45];state := next45;
    Advance46(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);trace := trace+[next46];state := next46;
    Advance47(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);trace := trace+[next47];state := next47;
    Advance48(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);trace := trace+[next48];state := next48;
    Advance49(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);trace := trace+[next49];state := next49;
    Advance50(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);trace := trace+[next50];state := next50;
    Advance51(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);trace := trace+[next51];state := next51;
    Advance52(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);trace := trace+[next52];state := next52;
    Advance53(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next53 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);trace := trace+[next53];state := next53;
    Advance54(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next54 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);trace := trace+[next54];state := next54;
    Advance55(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next55 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55);trace := trace+[next55];state := next55;
    Advance56(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next56 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56);trace := trace+[next56];state := next56;
    Advance57(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next57 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57);trace := trace+[next57];state := next57;
    Advance58(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next58 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58);trace := trace+[next58];state := next58;
    Advance59(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next59 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59);trace := trace+[next59];state := next59;
  }
  ghost method Block3(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(60,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures Good(80,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { hide E.Trace(); state := initial;trace := [state];
    Advance60(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next60 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next60);trace := trace+[next60];state := next60;
    Advance61(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next61 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next61);trace := trace+[next61];state := next61;
    Advance62(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next62 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next62);trace := trace+[next62];state := next62;
    Advance63(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next63 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next63);trace := trace+[next63];state := next63;
    Advance64(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next64 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next64);trace := trace+[next64];state := next64;
    Advance65(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next65 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next65);trace := trace+[next65];state := next65;
    Advance66(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next66 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next66);trace := trace+[next66];state := next66;
    Advance67(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next67 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next67);trace := trace+[next67];state := next67;
    Advance68(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next68 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next68);trace := trace+[next68];state := next68;
    Advance69(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next69 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next69);trace := trace+[next69];state := next69;
    Advance70(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next70 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next70);trace := trace+[next70];state := next70;
    Advance71(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next71 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next71);trace := trace+[next71];state := next71;
    Advance72(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next72 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next72);trace := trace+[next72];state := next72;
    Advance73(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next73 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next73);trace := trace+[next73];state := next73;
    Advance74(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next74 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next74);trace := trace+[next74];state := next74;
    Advance75(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next75 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next75);trace := trace+[next75];state := next75;
    Advance76(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next76 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next76);trace := trace+[next76];state := next76;
    Advance77(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next77 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next77);trace := trace+[next77];state := next77;
    Advance78(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next78 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next78);trace := trace+[next78];state := next78;
    Advance79(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next79 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next79);trace := trace+[next79];state := next79;
  }
  ghost method Block4(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && Good(80,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value)
    ensures state == Reverted(H.Packet(SC.Operation(),index,target)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == initial && trace[|trace|-1] == state
  { hide E.Trace(); state := initial;trace := [state];
    Advance80(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next80 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next80);trace := trace+[next80];state := next80;
    Advance81(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next81 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next81);trace := trace+[next81];state := next81;
    Advance82(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next82 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next82);trace := trace+[next82];state := next82;
    Advance83(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next83 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next83);trace := trace+[next83];state := next83;
    Advance84(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next84 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next84);trace := trace+[next84];state := next84;
    Advance85(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next85 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next85);trace := trace+[next85];state := next85;
    Advance86(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next86 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next86);trace := trace+[next86];state := next86;
    Advance87(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    var next87 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next87);trace := trace+[next87];state := next87;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value) && H.Fits(mem,free)
    ensures state == Reverted(H.Packet(SC.Operation(),index,target)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 89 && trace[0] == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],H.Stage(mem,free,SC.Operation(),index,target,0)) && trace[|trace|-1] == state
  { hide E.Trace(); Admission(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value); state := Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],H.Stage(mem,free,SC.Operation(),index,target,0));trace := [state];reveal Good();var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block3(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block4(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
