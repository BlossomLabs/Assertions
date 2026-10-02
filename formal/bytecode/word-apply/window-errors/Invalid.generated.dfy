// SPDX-License-Identifier: MIT
// Generated complete physical window rejection path; native proof pins exact error bytes.
include "../windows/Inputs.dfy"
include "../../scans/Push.dfy"
include "Memory.dfy"
include "Scalar.dfy"
module BytecodeApplyWindowErrorInvalid {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import H = BytecodeApplyWindowErrorMemory
  import SC = BytecodeApplyWindowErrorScalar
  import E = BytecodeScanExecution
  predicate Admitted(prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) { W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32 && index < count && W.At(arrayOffset,index,data) > templateLength-32 && |prefix| <= 1012 }
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
                                              code[13698] == 91 &&
                                              code[13699] == 146 &&
                                              code[13700] == 145 &&
                                              code[13701] == 80 &&
                                              code[13702] == 80 &&
                                              code[13703] == 86 &&
                                              code[16419] == 91 &&
                                              code[16728] == 91 &&
                                              code[16729] == 129 &&
                                              code[16730] == 129 &&
                                              code[16731] == 16 &&
                                              code[16732] == 21 &&
                                              code[16733] == 97 &&
                                              code[16734] == 64 &&
                                              code[16735] == 35 &&
                                              code[16736] == 87 &&
                                              code[16737] == 97 &&
                                              code[16738] == 65 &&
                                              code[16739] == 107 &&
                                              code[16740] == 96 &&
                                              code[16741] == 32 &&
                                              code[16742] == 133 &&
                                              code[16743] == 97 &&
                                              code[16744] == 92 &&
                                              code[16745] == 232 &&
                                              code[16746] == 86 &&
                                              code[16747] == 91 &&
                                              code[16748] == 131 &&
                                              code[16749] == 131 &&
                                              code[16750] == 131 &&
                                              code[16751] == 129 &&
                                              code[16752] == 129 &&
                                              code[16753] == 16 &&
                                              code[16754] == 97 &&
                                              code[16755] == 65 &&
                                              code[16756] == 125 &&
                                              code[16757] == 87 &&
                                              code[16765] == 91 &&
                                              code[16766] == 144 &&
                                              code[16767] == 80 &&
                                              code[16768] == 96 &&
                                              code[16769] == 32 &&
                                              code[16770] == 2 &&
                                              code[16771] == 1 &&
                                              code[16772] == 53 &&
                                              code[16773] == 17 &&
                                              code[16774] == 21 &&
                                              code[16775] == 97 &&
                                              code[16776] == 65 &&
                                              code[16777] == 200 &&
                                              code[16778] == 87 &&
                                              code[16779] == 130 &&
                                              code[16780] == 130 &&
                                              code[16781] == 130 &&
                                              code[16782] == 129 &&
                                              code[16783] == 129 &&
                                              code[16784] == 16 &&
                                              code[16785] == 97 &&
                                              code[16786] == 65 &&
                                              code[16787] == 156 &&
                                              code[16788] == 87 &&
                                              code[16796] == 91 &&
                                              code[16797] == 96 &&
                                              code[16798] == 64 &&
                                              code[16799] == 81 &&
                                              code[16800] == 99 &&
                                              code[16801] == 13 &&
                                              code[16802] == 6 &&
                                              code[16803] == 193 &&
                                              code[16804] == 239 &&
                                              code[16805] == 96 &&
                                              code[16806] == 225 &&
                                              code[16807] == 27 &&
                                              code[16808] == 129 &&
                                              code[16809] == 82 &&
                                              code[16810] == 96 &&
                                              code[16811] == 32 &&
                                              code[16812] == 144 &&
                                              code[16813] == 145 &&
                                              code[16814] == 2 &&
                                              code[16815] == 146 &&
                                              code[16816] == 144 &&
                                              code[16817] == 146 &&
                                              code[16818] == 1 &&
                                              code[16819] == 53 &&
                                              code[16820] == 96 &&
                                              code[16821] == 4 &&
                                              code[16822] == 131 &&
                                              code[16823] == 1 &&
                                              code[16824] == 82 &&
                                              code[16825] == 80 &&
                                              code[16826] == 96 &&
                                              code[16827] == 36 &&
                                              code[16828] == 129 &&
                                              code[16829] == 1 &&
                                              code[16830] == 133 &&
                                              code[16831] == 144 &&
                                              code[16832] == 82 &&
                                              code[16833] == 96 &&
                                              code[16834] == 68 &&
                                              code[16835] == 1 &&
                                              code[16836] == 97 &&
                                              code[16837] == 4 &&
                                              code[16838] == 90 &&
                                              code[16839] == 86 &&
                                              code[16840] == 91 &&
                                              code[23784] == 91 &&
                                              code[23785] == 129 &&
                                              code[23786] == 129 &&
                                              code[23787] == 3 &&
                                              code[23788] == 129 &&
                                              code[23789] == 129 &&
                                              code[23790] == 17 &&
                                              code[23791] == 21 &&
                                              code[23792] == 97 &&
                                              code[23793] == 53 &&
                                              code[23794] == 130 &&
                                              code[23795] == 87
  }
  function Destinations(): set<nat> { {1114,13698,16419,16747,16765,16796,16840,23784} }
  opaque predicate Good(id: nat,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) { Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && (
                                                                                                                                                                                                           if id == 0 then state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 1 then state == Running(16729,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 2 then state == Running(16730,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 3 then state == Running(16731,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 4 then state == Running(16732,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],Store([],64,128))
                                                                                                                                                                                                           else if id == 5 then state == Running(16733,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],Store([],64,128))
                                                                                                                                                                                                           else if id == 6 then state == Running(16736,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0,16419],Store([],64,128))
                                                                                                                                                                                                           else if id == 7 then state == Running(16737,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 8 then state == Running(16740,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747],Store([],64,128))
                                                                                                                                                                                                           else if id == 9 then state == Running(16742,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32],Store([],64,128))
                                                                                                                                                                                                           else if id == 10 then state == Running(16743,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],Store([],64,128))
                                                                                                                                                                                                           else if id == 11 then state == Running(16746,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,23784],Store([],64,128))
                                                                                                                                                                                                           else if id == 12 then state == Running(23784,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],Store([],64,128))
                                                                                                                                                                                                           else if id == 13 then state == Running(23785,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],Store([],64,128))
                                                                                                                                                                                                           else if id == 14 then state == Running(23786,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32],Store([],64,128))
                                                                                                                                                                                                           else if id == 15 then state == Running(23787,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32,templateLength],Store([],64,128))
                                                                                                                                                                                                           else if id == 16 then state == Running(23788,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],Store([],64,128))
                                                                                                                                                                                                           else if id == 17 then state == Running(23789,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength],Store([],64,128))
                                                                                                                                                                                                           else if id == 18 then state == Running(23790,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength,templateLength-32],Store([],64,128))
                                                                                                                                                                                                           else if id == 19 then state == Running(23791,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,0],Store([],64,128))
                                                                                                                                                                                                           else if id == 20 then state == Running(23792,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1],Store([],64,128))
                                                                                                                                                                                                           else if id == 21 then state == Running(23795,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1,13698],Store([],64,128))
                                                                                                                                                                                                           else if id == 22 then state == Running(13698,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],Store([],64,128))
                                                                                                                                                                                                           else if id == 23 then state == Running(13699,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],Store([],64,128))
                                                                                                                                                                                                           else if id == 24 then state == Running(13700,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,32,templateLength,16747],Store([],64,128))
                                                                                                                                                                                                           else if id == 25 then state == Running(13701,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength,32],Store([],64,128))
                                                                                                                                                                                                           else if id == 26 then state == Running(13702,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength],Store([],64,128))
                                                                                                                                                                                                           else if id == 27 then state == Running(13703,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747],Store([],64,128))
                                                                                                                                                                                                           else if id == 28 then state == Running(16747,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],Store([],64,128))
                                                                                                                                                                                                           else if id == 29 then state == Running(16748,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],Store([],64,128))
                                                                                                                                                                                                           else if id == 30 then state == Running(16749,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset],Store([],64,128))
                                                                                                                                                                                                           else if id == 31 then state == Running(16750,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 32 then state == Running(16751,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 33 then state == Running(16752,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 34 then state == Running(16753,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 35 then state == Running(16754,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1],Store([],64,128))
                                                                                                                                                                                                           else if id == 36 then state == Running(16757,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1,16765],Store([],64,128))
                                                                                                                                                                                                           else if id == 37 then state == Running(16765,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 38 then state == Running(16766,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 39 then state == Running(16767,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 40 then state == Running(16768,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 41 then state == Running(16770,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,32],Store([],64,128))
                                                                                                                                                                                                           else if id == 42 then state == Running(16771,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index*32],Store([],64,128))
                                                                                                                                                                                                           else if id == 43 then state == Running(16772,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,((arrayOffset as nat)+index*32)%G.Modulus()],Store([],64,128))
                                                                                                                                                                                                           else if id == 44 then state == Running(16773,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,W.At(arrayOffset,index,data)],Store([],64,128))
                                                                                                                                                                                                           else if id == 45 then state == Running(16774,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],Store([],64,128))
                                                                                                                                                                                                           else if id == 46 then state == Running(16775,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],Store([],64,128))
                                                                                                                                                                                                           else if id == 47 then state == Running(16778,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0,16840],Store([],64,128))
                                                                                                                                                                                                           else if id == 48 then state == Running(16779,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 49 then state == Running(16780,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset],Store([],64,128))
                                                                                                                                                                                                           else if id == 50 then state == Running(16781,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 51 then state == Running(16782,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 52 then state == Running(16783,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,count],Store([],64,128))
                                                                                                                                                                                                           else if id == 53 then state == Running(16784,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 54 then state == Running(16785,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,1],Store([],64,128))
                                                                                                                                                                                                           else if id == 55 then state == Running(16788,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,1,16796],Store([],64,128))
                                                                                                                                                                                                           else if id == 56 then state == Running(16796,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 57 then state == Running(16797,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index],Store([],64,128))
                                                                                                                                                                                                           else if id == 58 then state == Running(16799,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,64],Store([],64,128))
                                                                                                                                                                                                           else if id == 59 then state == Running(16800,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128],Store([],64,128))
                                                                                                                                                                                                           else if id == 60 then state == Running(16805,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,218546671],Store([],64,128))
                                                                                                                                                                                                           else if id == 61 then state == Running(16807,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,218546671,225],Store([],64,128))
                                                                                                                                                                                                           else if id == 62 then state == Running(16808,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,11784013188886634765289199401549831190745770750984918956358808852095274319872],Store([],64,128))
                                                                                                                                                                                                           else if id == 63 then state == Running(16809,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,11784013188886634765289199401549831190745770750984918956358808852095274319872,128],Store([],64,128))
                                                                                                                                                                                                           else if id == 64 then state == Running(16810,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 65 then state == Running(16812,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,32],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 66 then state == Running(16813,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,32,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 67 then state == Running(16814,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,128,32,index],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 68 then state == Running(16815,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,128,index*32],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 69 then state == Running(16816,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,index*32,count,128,arrayOffset],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 70 then state == Running(16817,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,index*32,count,arrayOffset,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 71 then state == Running(16818,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,arrayOffset,index*32],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 72 then state == Running(16819,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,((arrayOffset as nat)+index*32)%G.Modulus()],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 73 then state == Running(16820,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data)],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 74 then state == Running(16822,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data),4],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 75 then state == Running(16823,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data),4,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 76 then state == Running(16824,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data),132],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872))
                                                                                                                                                                                                           else if id == 77 then state == Running(16825,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)))
                                                                                                                                                                                                           else if id == 78 then state == Running(16826,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)))
                                                                                                                                                                                                           else if id == 79 then state == Running(16828,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,36],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)))
                                                                                                                                                                                                           else if id == 80 then state == Running(16829,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,36,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)))
                                                                                                                                                                                                           else if id == 81 then state == Running(16830,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)))
                                                                                                                                                                                                           else if id == 82 then state == Running(16831,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,164,templateLength],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)))
                                                                                                                                                                                                           else if id == 83 then state == Running(16832,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,templateLength,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)))
                                                                                                                                                                                                           else if id == 84 then state == Running(16833,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 85 then state == Running(16835,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 86 then state == Running(16836,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 87 then state == Running(16839,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,1114],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 88 then state == Running(1114,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 89 then state == Running(1115,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 90 then state == Running(1117,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,64],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 91 then state == Running(1118,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 92 then state == Running(1119,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,128,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 93 then state == Running(1120,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,128,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 94 then state == Running(1121,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else if id == 95 then state == Running(1122,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,68,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength))
                                                                                                                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(0,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16728) == Op(91,16729,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(1,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16729,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16729) == Op(129,16730,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(2,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16730,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count],Store([],64,128));
    assert Fetch(code,16730) == Op(129,16731,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(3,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16731,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count,index],Store([],64,128));
    assert Fetch(code,16731) == Op(16,16732,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(4,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16732,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],Store([],64,128));
    assert Fetch(code,16732) == Op(21,16733,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(5,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16733,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],Store([],64,128));
    F.Push2(code,16733);
    assert Fetch(code,16733) == Op(97,16736,16419);
  }
  lemma Advance6(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(6,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16736,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0,16419],Store([],64,128));
    assert Fetch(code,16736) == Op(87,16737,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(7,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16737,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128));
    F.Push2(code,16737);
    assert Fetch(code,16737) == Op(97,16740,16747);
  }
  lemma Advance8(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(8,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16740,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747],Store([],64,128));
    F.Push1(code,16740);
    assert Fetch(code,16740) == Op(96,16742,32);
  }
  lemma Advance9(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(9,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16742,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32],Store([],64,128));
    assert Fetch(code,16742) == Op(133,16743,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(10,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16743,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],Store([],64,128));
    F.Push2(code,16743);
    assert Fetch(code,16743) == Op(97,16746,23784);
  }
  lemma Advance11(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(11,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16746,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,23784],Store([],64,128));
    assert Fetch(code,16746) == Op(86,16747,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(12,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23784,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],Store([],64,128));
    assert Fetch(code,23784) == Op(91,23785,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(13,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23785,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],Store([],64,128));
    assert Fetch(code,23785) == Op(129,23786,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(14,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23786,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32],Store([],64,128));
    assert Fetch(code,23786) == Op(129,23787,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(15,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23787,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32,templateLength],Store([],64,128));
    assert Fetch(code,23787) == Op(3,23788,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(16,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23788,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],Store([],64,128));
    assert Fetch(code,23788) == Op(129,23789,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(17,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23789,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength],Store([],64,128));
    assert Fetch(code,23789) == Op(129,23790,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(18,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23790,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength,templateLength-32],Store([],64,128));
    assert Fetch(code,23790) == Op(17,23791,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(19,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23791,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,0],Store([],64,128));
    assert Fetch(code,23791) == Op(21,23792,0);
  }
  lemma Advance20(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(20,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23792,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1],Store([],64,128));
    F.Push2(code,23792);
    assert Fetch(code,23792) == Op(97,23795,13698);
  }
  lemma Advance21(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(21,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(23795,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1,13698],Store([],64,128));
    assert Fetch(code,23795) == Op(87,23796,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(22,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(13698,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],Store([],64,128));
    assert Fetch(code,13698) == Op(91,13699,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(23,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(13699,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],Store([],64,128));
    assert Fetch(code,13699) == Op(146,13700,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(24,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(13700,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,32,templateLength,16747],Store([],64,128));
    assert Fetch(code,13700) == Op(145,13701,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(25,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(13701,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength,32],Store([],64,128));
    assert Fetch(code,13701) == Op(80,13702,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(26,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(13702,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength],Store([],64,128));
    assert Fetch(code,13702) == Op(80,13703,0);
  }
  lemma Advance27(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(27,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(13703,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747],Store([],64,128));
    assert Fetch(code,13703) == Op(86,13704,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(28,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16747,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],Store([],64,128));
    assert Fetch(code,16747) == Op(91,16748,0);
  }
  lemma Advance29(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(29,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16748,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],Store([],64,128));
    assert Fetch(code,16748) == Op(131,16749,0);
  }
  lemma Advance30(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(30,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16749,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset],Store([],64,128));
    assert Fetch(code,16749) == Op(131,16750,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(31,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16750,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count],Store([],64,128));
    assert Fetch(code,16750) == Op(131,16751,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(32,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16751,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16751) == Op(129,16752,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(33,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16752,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count],Store([],64,128));
    assert Fetch(code,16752) == Op(129,16753,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(34,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16753,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count,index],Store([],64,128));
    assert Fetch(code,16753) == Op(16,16754,0);
  }
  lemma Advance35(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(35,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16754,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1],Store([],64,128));
    F.Push2(code,16754);
    assert Fetch(code,16754) == Op(97,16757,16765);
  }
  lemma Advance36(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(36,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16757,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1,16765],Store([],64,128));
    assert Fetch(code,16757) == Op(87,16758,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(37,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16765,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16765) == Op(91,16766,0);
  }
  lemma Advance38(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(38,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16766,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16766) == Op(144,16767,0);
  }
  lemma Advance39(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(39,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16767,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,count],Store([],64,128));
    assert Fetch(code,16767) == Op(80,16768,0);
  }
  lemma Advance40(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(40,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16768,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index],Store([],64,128));
    F.Push1(code,16768);
    assert Fetch(code,16768) == Op(96,16770,32);
  }
  lemma Advance41(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(41,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16770,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,32],Store([],64,128));
    assert Fetch(code,16770) == Op(2,16771,0);
  }
  lemma Advance42(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(42,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16771,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index*32],Store([],64,128));
    assert Fetch(code,16771) == Op(1,16772,0);
  }
  lemma Advance43(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(43,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16772,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,((arrayOffset as nat)+index*32)%G.Modulus()],Store([],64,128));
    assert Fetch(code,16772) == Op(53,16773,0);
  }
  lemma Advance44(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(44,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16773,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,W.At(arrayOffset,index,data)],Store([],64,128));
    assert Fetch(code,16773) == Op(17,16774,0);
  }
  lemma Advance45(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(45,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16774,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],Store([],64,128));
    assert Fetch(code,16774) == Op(21,16775,0);
  }
  lemma Advance46(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(46,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16775,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],Store([],64,128));
    F.Push2(code,16775);
    assert Fetch(code,16775) == Op(97,16778,16840);
  }
  lemma Advance47(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(47,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16778,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0,16840],Store([],64,128));
    assert Fetch(code,16778) == Op(87,16779,0);
  }
  lemma Advance48(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(48,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16779,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16779) == Op(130,16780,0);
  }
  lemma Advance49(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(49,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16780,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset],Store([],64,128));
    assert Fetch(code,16780) == Op(130,16781,0);
  }
  lemma Advance50(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(50,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16781,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count],Store([],64,128));
    assert Fetch(code,16781) == Op(130,16782,0);
  }
  lemma Advance51(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(51,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16782,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16782) == Op(129,16783,0);
  }
  lemma Advance52(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(52,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16783,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,count],Store([],64,128));
    assert Fetch(code,16783) == Op(129,16784,0);
  }
  lemma Advance53(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(53,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16784,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,count,index],Store([],64,128));
    assert Fetch(code,16784) == Op(16,16785,0);
  }
  lemma Advance54(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(54,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(55,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16785,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,1],Store([],64,128));
    F.Push2(code,16785);
    assert Fetch(code,16785) == Op(97,16788,16796);
  }
  lemma Advance55(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(55,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(56,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16788,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,1,16796],Store([],64,128));
    assert Fetch(code,16788) == Op(87,16789,0);
  }
  lemma Advance56(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(56,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(57,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16796,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index],Store([],64,128));
    assert Fetch(code,16796) == Op(91,16797,0);
  }
  lemma Advance57(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(57,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(58,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16797,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index],Store([],64,128));
    F.Push1(code,16797);
    assert Fetch(code,16797) == Op(96,16799,64);
  }
  lemma Advance58(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(58,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(59,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16799,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,64],Store([],64,128));
    assert Fetch(code,16799) == Op(81,16800,0);
  }
  lemma Advance59(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(59,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(60,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16800,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128],Store([],64,128));
    P.Push4(code,16800);
    assert Fetch(code,16800) == Op(99,16805,218546671);
  }
  lemma Advance60(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(60,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(61,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16805,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,218546671],Store([],64,128));
    F.Push1(code,16805);
    assert Fetch(code,16805) == Op(96,16807,225);
  }
  lemma Advance61(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(61,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(62,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);
    SC.Selector();

    assert state == Running(16807,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,218546671,225],Store([],64,128));
    assert Fetch(code,16807) == Op(27,16808,0);
  }
  lemma Advance62(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(62,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(63,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16808,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,11784013188886634765289199401549831190745770750984918956358808852095274319872],Store([],64,128));
    assert Fetch(code,16808) == Op(129,16809,0);
  }
  lemma Advance63(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(63,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(64,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16809,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,11784013188886634765289199401549831190745770750984918956358808852095274319872,128],Store([],64,128));
    assert Fetch(code,16809) == Op(82,16810,0);
  }
  lemma Advance64(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(64,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(65,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16810,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    F.Push1(code,16810);
    assert Fetch(code,16810) == Op(96,16812,32);
  }
  lemma Advance65(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(65,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(66,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16812,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,128,32],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16812) == Op(144,16813,0);
  }
  lemma Advance66(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(66,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(67,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16813,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,index,32,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16813) == Op(145,16814,0);
  }
  lemma Advance67(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(67,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(68,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16814,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,128,32,index],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16814) == Op(2,16815,0);
  }
  lemma Advance68(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(68,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(69,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16815,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,arrayOffset,count,128,index*32],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16815) == Op(146,16816,0);
  }
  lemma Advance69(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(69,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(70,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16816,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,index*32,count,128,arrayOffset],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16816) == Op(144,16817,0);
  }
  lemma Advance70(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(70,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(71,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16817,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,index*32,count,arrayOffset,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16817) == Op(146,16818,0);
  }
  lemma Advance71(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(71,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(72,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16818,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,arrayOffset,index*32],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16818) == Op(1,16819,0);
  }
  lemma Advance72(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(72,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(73,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16819,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,((arrayOffset as nat)+index*32)%G.Modulus()],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16819) == Op(53,16820,0);
  }
  lemma Advance73(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(73,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(74,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16820,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data)],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    F.Push1(code,16820);
    assert Fetch(code,16820) == Op(96,16822,4);
  }
  lemma Advance74(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(74,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(75,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16822,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data),4],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16822) == Op(131,16823,0);
  }
  lemma Advance75(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(75,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(76,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16823,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data),4,128],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16823) == Op(1,16824,0);
  }
  lemma Advance76(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(76,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(77,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16824,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count,W.At(arrayOffset,index,data),132],Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872));
    assert Fetch(code,16824) == Op(82,16825,0);
  }
  lemma Advance77(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(77,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(78,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16825,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,count],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)));
    assert Fetch(code,16825) == Op(80,16826,0);
  }
  lemma Advance78(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(78,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(79,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16826,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)));
    F.Push1(code,16826);
    assert Fetch(code,16826) == Op(96,16828,36);
  }
  lemma Advance79(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(79,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(80,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16828,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,36],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)));
    assert Fetch(code,16828) == Op(129,16829,0);
  }
  lemma Advance80(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(80,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(81,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16829,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,36,128],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)));
    assert Fetch(code,16829) == Op(1,16830,0);
  }
  lemma Advance81(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(81,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(82,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16830,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)));
    assert Fetch(code,16830) == Op(133,16831,0);
  }
  lemma Advance82(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(82,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(83,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16831,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,164,templateLength],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)));
    assert Fetch(code,16831) == Op(144,16832,0);
  }
  lemma Advance83(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(83,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(84,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16832,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,templateLength,164],Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)));
    assert Fetch(code,16832) == Op(82,16833,0);
  }
  lemma Advance84(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(84,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(85,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16833,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    F.Push1(code,16833);
    assert Fetch(code,16833) == Op(96,16835,68);
  }
  lemma Advance85(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(85,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(86,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16835,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,16835) == Op(1,16836,0);
  }
  lemma Advance86(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(86,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(87,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16836,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    F.Push2(code,16836);
    assert Fetch(code,16836) == Op(97,16839,1114);
  }
  lemma Advance87(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(87,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(88,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(16839,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,1114],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,16839) == Op(86,16840,0);
  }
  lemma Advance88(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(88,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(89,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(1114,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,1114) == Op(91,1115,0);
  }
  lemma Advance89(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(89,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(90,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(1115,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
  }
  lemma Advance90(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(90,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(91,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(1117,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,64],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,1117) == Op(81,1118,0);
  }
  lemma Advance91(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(91,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(92,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(1118,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,1118) == Op(128,1119,0);
  }
  lemma Advance92(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(92,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(93,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(1119,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,196,128,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,1119) == Op(145,1120,0);
  }
  lemma Advance93(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(93,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(94,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(1120,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,128,196],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,1120) == Op(3,1121,0);
  }
  lemma Advance94(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(94,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(95,next,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);


    assert state == Running(1121,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,128,68],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
    assert Fetch(code,1121) == Op(144,1122,0);
  }
  lemma Advance95(code: seq<Byte>,state: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(95,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(W.At(arrayOffset,index,data),32)+G.Encode(templateLength,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout(W.At(arrayOffset,index,data),templateLength);
    W.Index(templateLength,arrayOffset,count,data,index);

    H.Error(Store([],64,128),W.At(arrayOffset,index,data),templateLength);
    assert state == Running(1122,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,68,128],Store(Store(Store(Store([],64,128),128,11784013188886634765289199401549831190745770750984918956358808852095274319872),132,W.At(arrayOffset,index,data)),164,templateLength));
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
    ensures Good(40,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
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
    Advance37(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37); trace := trace+[next37]; state := next37;
    Advance38(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38); trace := trace+[next38]; state := next38;
    Advance39(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39); trace := trace+[next39]; state := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(40,initial,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures Good(60,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance40(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40); trace := trace+[next40]; state := next40;
    Advance41(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41); trace := trace+[next41]; state := next41;
    Advance42(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42); trace := trace+[next42]; state := next42;
    Advance43(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43); trace := trace+[next43]; state := next43;
    Advance44(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44); trace := trace+[next44]; state := next44;
    Advance45(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45); trace := trace+[next45]; state := next45;
    Advance46(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46); trace := trace+[next46]; state := next46;
    Advance47(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47); trace := trace+[next47]; state := next47;
    Advance48(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48); trace := trace+[next48]; state := next48;
    Advance49(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49); trace := trace+[next49]; state := next49;
    Advance50(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50); trace := trace+[next50]; state := next50;
    Advance51(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51); trace := trace+[next51]; state := next51;
    Advance52(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52); trace := trace+[next52]; state := next52;
    Advance53(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next53 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53); trace := trace+[next53]; state := next53;
    Advance54(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next54 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54); trace := trace+[next54]; state := next54;
    Advance55(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next55 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55); trace := trace+[next55]; state := next55;
    Advance56(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next56 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56); trace := trace+[next56]; state := next56;
    Advance57(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next57 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57); trace := trace+[next57]; state := next57;
    Advance58(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next58 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58); trace := trace+[next58]; state := next58;
    Advance59(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next59 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59); trace := trace+[next59]; state := next59;
  }
  ghost method Block3(code: seq<Byte>,initial: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(60,initial,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures Good(80,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance60(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next60 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next60); trace := trace+[next60]; state := next60;
    Advance61(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next61 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next61); trace := trace+[next61]; state := next61;
    Advance62(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next62 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next62); trace := trace+[next62]; state := next62;
    Advance63(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next63 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next63); trace := trace+[next63]; state := next63;
    Advance64(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next64 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next64); trace := trace+[next64]; state := next64;
    Advance65(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next65 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next65); trace := trace+[next65]; state := next65;
    Advance66(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next66 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next66); trace := trace+[next66]; state := next66;
    Advance67(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next67 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next67); trace := trace+[next67]; state := next67;
    Advance68(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next68 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next68); trace := trace+[next68]; state := next68;
    Advance69(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next69 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next69); trace := trace+[next69]; state := next69;
    Advance70(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next70 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next70); trace := trace+[next70]; state := next70;
    Advance71(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next71 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next71); trace := trace+[next71]; state := next71;
    Advance72(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next72 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next72); trace := trace+[next72]; state := next72;
    Advance73(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next73 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next73); trace := trace+[next73]; state := next73;
    Advance74(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next74 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next74); trace := trace+[next74]; state := next74;
    Advance75(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next75 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next75); trace := trace+[next75]; state := next75;
    Advance76(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next76 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next76); trace := trace+[next76]; state := next76;
    Advance77(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next77 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next77); trace := trace+[next77]; state := next77;
    Advance78(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next78 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next78); trace := trace+[next78]; state := next78;
    Advance79(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next79 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next79); trace := trace+[next79]; state := next79;
  }
  ghost method Block4(code: seq<Byte>,initial: State,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data) && Good(80,initial,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(W.At(arrayOffset,index,data),32)+G.Encode(templateLength,32)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 17 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance80(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next80 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next80); trace := trace+[next80]; state := next80;
    Advance81(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next81 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next81); trace := trace+[next81]; state := next81;
    Advance82(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next82 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next82); trace := trace+[next82]; state := next82;
    Advance83(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next83 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next83); trace := trace+[next83]; state := next83;
    Advance84(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next84 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next84); trace := trace+[next84]; state := next84;
    Advance85(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next85 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next85); trace := trace+[next85]; state := next85;
    Advance86(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next86 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next86); trace := trace+[next86]; state := next86;
    Advance87(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next87 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next87); trace := trace+[next87]; state := next87;
    Advance88(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next88 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next88); trace := trace+[next88]; state := next88;
    Advance89(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next89 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next89); trace := trace+[next89]; state := next89;
    Advance90(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next90 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next90); trace := trace+[next90]; state := next90;
    Advance91(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next91 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next91); trace := trace+[next91]; state := next91;
    Advance92(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next92 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next92); trace := trace+[next92]; state := next92;
    Advance93(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next93 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next93); trace := trace+[next93]; state := next93;
    Advance94(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next94 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next94); trace := trace+[next94]; state := next94;
    Advance95(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    var next95 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next95); trace := trace+[next95]; state := next95;
  }
  ghost method Run(code: seq<Byte>,prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data)
    ensures state == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(W.At(arrayOffset,index,data),32)+G.Encode(templateLength,32)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 97 && trace[0] == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128)) && trace[|trace|-1] == state
  { state := Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128)); trace := [state]; reveal Good();
    var part: seq<State>;
    state,part := Block0(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block2(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block3(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block4(code,state,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
