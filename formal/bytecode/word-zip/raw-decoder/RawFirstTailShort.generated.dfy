// SPDX-License-Identifier: MIT
// Generated actual raw bytes decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipRawFirstTailShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function HeadA(data: seq<Byte>): Word { DataWord(data,4) }
  function HeadB(data: seq<Byte>): Word { DataWord(data,36) }
  function HeadPositionA(data: seq<Byte>): Word { ((HeadA(data) as nat)+4)%G.Modulus() }
  function HeadPositionB(data: seq<Byte>): Word { ((HeadB(data) as nat)+4)%G.Modulus() }
  function LengthA(data: seq<Byte>): Word { DataWord(data,HeadPositionA(data)) }
  function LengthB(data: seq<Byte>): Word { DataWord(data,HeadPositionB(data)) }
  function OffsetA(data: seq<Byte>): Word { ((HeadA(data) as nat)+36)%G.Modulus() }
  function OffsetB(data: seq<Byte>): Word { ((HeadB(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && 68 <= |data| && HeadA(data) < 0x10000000000000000 && (HeadA(data) as nat)+36 <= |data| && LengthA(data) < 0x10000000000000000 && (HeadA(data) as nat)+36+(LengthA(data) as nat) > |data| }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[499] == 91 &&
                                              code[500] == 97 &&
                                              code[501] == 2 &&
                                              code[502] == 6 &&
                                              code[503] == 97 &&
                                              code[504] == 2 &&
                                              code[505] == 1 &&
                                              code[506] == 54 &&
                                              code[507] == 96 &&
                                              code[508] == 4 &&
                                              code[509] == 97 &&
                                              code[510] == 82 &&
                                              code[511] == 113 &&
                                              code[512] == 86 &&
                                              code[20617] == 91 &&
                                              code[20618] == 95 &&
                                              code[20619] == 95 &&
                                              code[20620] == 131 &&
                                              code[20621] == 96 &&
                                              code[20622] == 31 &&
                                              code[20623] == 132 &&
                                              code[20624] == 1 &&
                                              code[20625] == 18 &&
                                              code[20626] == 97 &&
                                              code[20627] == 80 &&
                                              code[20628] == 153 &&
                                              code[20629] == 87 &&
                                              code[20633] == 91 &&
                                              code[20634] == 80 &&
                                              code[20635] == 129 &&
                                              code[20636] == 53 &&
                                              code[20637] == 96 &&
                                              code[20638] == 1 &&
                                              code[20639] == 96 &&
                                              code[20640] == 1 &&
                                              code[20641] == 96 &&
                                              code[20642] == 64 &&
                                              code[20643] == 27 &&
                                              code[20644] == 3 &&
                                              code[20645] == 129 &&
                                              code[20646] == 17 &&
                                              code[20647] == 21 &&
                                              code[20648] == 97 &&
                                              code[20649] == 80 &&
                                              code[20650] == 175 &&
                                              code[20651] == 87 &&
                                              code[20655] == 91 &&
                                              code[20656] == 96 &&
                                              code[20657] == 32 &&
                                              code[20658] == 131 &&
                                              code[20659] == 1 &&
                                              code[20660] == 145 &&
                                              code[20661] == 80 &&
                                              code[20662] == 131 &&
                                              code[20663] == 96 &&
                                              code[20664] == 32 &&
                                              code[20665] == 130 &&
                                              code[20666] == 133 &&
                                              code[20667] == 1 &&
                                              code[20668] == 1 &&
                                              code[20669] == 17 &&
                                              code[20670] == 21 &&
                                              code[20671] == 97 &&
                                              code[20672] == 80 &&
                                              code[20673] == 198 &&
                                              code[20674] == 87 &&
                                              code[20675] == 95 &&
                                              code[20676] == 95 &&
                                              code[20677] == 253 &&
                                              code[20678] == 91 &&
                                              code[21105] == 91 &&
                                              code[21106] == 95 &&
                                              code[21107] == 95 &&
                                              code[21108] == 95 &&
                                              code[21109] == 95 &&
                                              code[21110] == 96 &&
                                              code[21111] == 64 &&
                                              code[21112] == 133 &&
                                              code[21113] == 135 &&
                                              code[21114] == 3 &&
                                              code[21115] == 18 &&
                                              code[21116] == 21 &&
                                              code[21117] == 97 &&
                                              code[21118] == 82 &&
                                              code[21119] == 132 &&
                                              code[21120] == 87 &&
                                              code[21124] == 91 &&
                                              code[21125] == 132 &&
                                              code[21126] == 53 &&
                                              code[21127] == 96 &&
                                              code[21128] == 1 &&
                                              code[21129] == 96 &&
                                              code[21130] == 1 &&
                                              code[21131] == 96 &&
                                              code[21132] == 64 &&
                                              code[21133] == 27 &&
                                              code[21134] == 3 &&
                                              code[21135] == 129 &&
                                              code[21136] == 17 &&
                                              code[21137] == 21 &&
                                              code[21138] == 97 &&
                                              code[21139] == 82 &&
                                              code[21140] == 153 &&
                                              code[21141] == 87 &&
                                              code[21145] == 91 &&
                                              code[21146] == 97 &&
                                              code[21147] == 82 &&
                                              code[21148] == 165 &&
                                              code[21149] == 135 &&
                                              code[21150] == 130 &&
                                              code[21151] == 136 &&
                                              code[21152] == 1 &&
                                              code[21153] == 97 &&
                                              code[21154] == 80 &&
                                              code[21155] == 137 &&
                                              code[21156] == 86
  }
  function Destinations(): set<nat> { {20617,20633,20655,20678,21105,21124,21145} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>) { Admitted(data) && (
                                                                                    if id == 0 then state == Running(499,[269019481],mem)
                                                                                    else if id == 1 then state == Running(500,[269019481],mem)
                                                                                    else if id == 2 then state == Running(503,[269019481,518],mem)
                                                                                    else if id == 3 then state == Running(506,[269019481,518,513],mem)
                                                                                    else if id == 4 then state == Running(507,[269019481,518,513,|data|],mem)
                                                                                    else if id == 5 then state == Running(509,[269019481,518,513,|data|,4],mem)
                                                                                    else if id == 6 then state == Running(512,[269019481,518,513,|data|,4,21105],mem)
                                                                                    else if id == 7 then state == Running(21105,[269019481,518,513,|data|,4],mem)
                                                                                    else if id == 8 then state == Running(21106,[269019481,518,513,|data|,4],mem)
                                                                                    else if id == 9 then state == Running(21107,[269019481,518,513,|data|,4,0],mem)
                                                                                    else if id == 10 then state == Running(21108,[269019481,518,513,|data|,4,0,0],mem)
                                                                                    else if id == 11 then state == Running(21109,[269019481,518,513,|data|,4,0,0,0],mem)
                                                                                    else if id == 12 then state == Running(21110,[269019481,518,513,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 13 then state == Running(21112,[269019481,518,513,|data|,4,0,0,0,0,64],mem)
                                                                                    else if id == 14 then state == Running(21113,[269019481,518,513,|data|,4,0,0,0,0,64,4],mem)
                                                                                    else if id == 15 then state == Running(21114,[269019481,518,513,|data|,4,0,0,0,0,64,4,|data|],mem)
                                                                                    else if id == 16 then state == Running(21115,[269019481,518,513,|data|,4,0,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem)
                                                                                    else if id == 17 then state == Running(21116,[269019481,518,513,|data|,4,0,0,0,0,0],mem)
                                                                                    else if id == 18 then state == Running(21117,[269019481,518,513,|data|,4,0,0,0,0,1],mem)
                                                                                    else if id == 19 then state == Running(21120,[269019481,518,513,|data|,4,0,0,0,0,1,21124],mem)
                                                                                    else if id == 20 then state == Running(21124,[269019481,518,513,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 21 then state == Running(21125,[269019481,518,513,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 22 then state == Running(21126,[269019481,518,513,|data|,4,0,0,0,0,4],mem)
                                                                                    else if id == 23 then state == Running(21127,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data)],mem)
                                                                                    else if id == 24 then state == Running(21129,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1],mem)
                                                                                    else if id == 25 then state == Running(21131,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,1],mem)
                                                                                    else if id == 26 then state == Running(21133,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,1,64],mem)
                                                                                    else if id == 27 then state == Running(21134,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,18446744073709551616],mem)
                                                                                    else if id == 28 then state == Running(21135,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),18446744073709551615],mem)
                                                                                    else if id == 29 then state == Running(21136,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),18446744073709551615,HeadA(data)],mem)
                                                                                    else if id == 30 then state == Running(21137,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),0],mem)
                                                                                    else if id == 31 then state == Running(21138,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1],mem)
                                                                                    else if id == 32 then state == Running(21141,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,21145],mem)
                                                                                    else if id == 33 then state == Running(21145,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data)],mem)
                                                                                    else if id == 34 then state == Running(21146,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data)],mem)
                                                                                    else if id == 35 then state == Running(21149,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157],mem)
                                                                                    else if id == 36 then state == Running(21150,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|],mem)
                                                                                    else if id == 37 then state == Running(21151,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadA(data)],mem)
                                                                                    else if id == 38 then state == Running(21152,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadA(data),4],mem)
                                                                                    else if id == 39 then state == Running(21153,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data)],mem)
                                                                                    else if id == 40 then state == Running(21156,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),20617],mem)
                                                                                    else if id == 41 then state == Running(20617,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data)],mem)
                                                                                    else if id == 42 then state == Running(20618,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data)],mem)
                                                                                    else if id == 43 then state == Running(20619,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0],mem)
                                                                                    else if id == 44 then state == Running(20620,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0],mem)
                                                                                    else if id == 45 then state == Running(20621,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|],mem)
                                                                                    else if id == 46 then state == Running(20623,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|,31],mem)
                                                                                    else if id == 47 then state == Running(20624,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|,31,HeadPositionA(data)],mem)
                                                                                    else if id == 48 then state == Running(20625,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|,((HeadPositionA(data) as nat)+(31 as nat))%G.Modulus()],mem)
                                                                                    else if id == 49 then state == Running(20626,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,1],mem)
                                                                                    else if id == 50 then state == Running(20629,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,1,20633],mem)
                                                                                    else if id == 51 then state == Running(20633,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0],mem)
                                                                                    else if id == 52 then state == Running(20634,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0],mem)
                                                                                    else if id == 53 then state == Running(20635,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0],mem)
                                                                                    else if id == 54 then state == Running(20636,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,HeadPositionA(data)],mem)
                                                                                    else if id == 55 then state == Running(20637,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data)],mem)
                                                                                    else if id == 56 then state == Running(20639,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1],mem)
                                                                                    else if id == 57 then state == Running(20641,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,1],mem)
                                                                                    else if id == 58 then state == Running(20643,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,1,64],mem)
                                                                                    else if id == 59 then state == Running(20644,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,18446744073709551616],mem)
                                                                                    else if id == 60 then state == Running(20645,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),18446744073709551615],mem)
                                                                                    else if id == 61 then state == Running(20646,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),18446744073709551615,LengthA(data)],mem)
                                                                                    else if id == 62 then state == Running(20647,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),0],mem)
                                                                                    else if id == 63 then state == Running(20648,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1],mem)
                                                                                    else if id == 64 then state == Running(20651,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,20655],mem)
                                                                                    else if id == 65 then state == Running(20655,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data)],mem)
                                                                                    else if id == 66 then state == Running(20656,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data)],mem)
                                                                                    else if id == 67 then state == Running(20658,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),32],mem)
                                                                                    else if id == 68 then state == Running(20659,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),32,HeadPositionA(data)],mem)
                                                                                    else if id == 69 then state == Running(20660,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),OffsetA(data)],mem)
                                                                                    else if id == 70 then state == Running(20661,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0],mem)
                                                                                    else if id == 71 then state == Running(20662,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data)],mem)
                                                                                    else if id == 72 then state == Running(20663,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|],mem)
                                                                                    else if id == 73 then state == Running(20665,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32],mem)
                                                                                    else if id == 74 then state == Running(20666,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32,LengthA(data)],mem)
                                                                                    else if id == 75 then state == Running(20667,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32,LengthA(data),HeadPositionA(data)],mem)
                                                                                    else if id == 76 then state == Running(20668,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32,((HeadPositionA(data) as nat)+(LengthA(data) as nat))%G.Modulus()],mem)
                                                                                    else if id == 77 then state == Running(20669,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,((((HeadPositionA(data) as nat)+(LengthA(data) as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                    else if id == 78 then state == Running(20670,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),1],mem)
                                                                                    else if id == 79 then state == Running(20671,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0],mem)
                                                                                    else if id == 80 then state == Running(20674,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0,20678],mem)
                                                                                    else if id == 81 then state == Running(20675,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data)],mem)
                                                                                    else if id == 82 then state == Running(20676,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0],mem)
                                                                                    else if id == 83 then state == Running(20677,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0,0],mem)
                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(499,[269019481],mem);
    assert Fetch(code,499) == Op(91,500,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(500,[269019481],mem);
    F.Push2(code,500);
    assert Fetch(code,500) == Op(97,503,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(503,[269019481,518],mem);
    F.Push2(code,503);
    assert Fetch(code,503) == Op(97,506,513);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(506,[269019481,518,513],mem);
    assert Fetch(code,506) == Op(54,507,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(507,[269019481,518,513,|data|],mem);
    F.Push1(code,507);
    assert Fetch(code,507) == Op(96,509,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(509,[269019481,518,513,|data|,4],mem);
    F.Push2(code,509);
    assert Fetch(code,509) == Op(97,512,21105);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(512,[269019481,518,513,|data|,4,21105],mem);
    assert Fetch(code,512) == Op(86,513,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21105,[269019481,518,513,|data|,4],mem);
    assert Fetch(code,21105) == Op(91,21106,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21106,[269019481,518,513,|data|,4],mem);
    assert Fetch(code,21106) == Op(95,21107,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21107,[269019481,518,513,|data|,4,0],mem);
    assert Fetch(code,21107) == Op(95,21108,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21108,[269019481,518,513,|data|,4,0,0],mem);
    assert Fetch(code,21108) == Op(95,21109,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21109,[269019481,518,513,|data|,4,0,0,0],mem);
    assert Fetch(code,21109) == Op(95,21110,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21110,[269019481,518,513,|data|,4,0,0,0,0],mem);
    F.Push1(code,21110);
    assert Fetch(code,21110) == Op(96,21112,64);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21112,[269019481,518,513,|data|,4,0,0,0,0,64],mem);
    assert Fetch(code,21112) == Op(133,21113,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21113,[269019481,518,513,|data|,4,0,0,0,0,64,4],mem);
    assert Fetch(code,21113) == Op(135,21114,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21114,[269019481,518,513,|data|,4,0,0,0,0,64,4,|data|],mem);
    assert Fetch(code,21114) == Op(3,21115,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21115,[269019481,518,513,|data|,4,0,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,21115) == Op(18,21116,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21116,[269019481,518,513,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,21116) == Op(21,21117,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21117,[269019481,518,513,|data|,4,0,0,0,0,1],mem);
    F.Push2(code,21117);
    assert Fetch(code,21117) == Op(97,21120,21124);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21120,[269019481,518,513,|data|,4,0,0,0,0,1,21124],mem);
    assert Fetch(code,21120) == Op(87,21121,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21124,[269019481,518,513,|data|,4,0,0,0,0],mem);
    assert Fetch(code,21124) == Op(91,21125,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(21,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21125,[269019481,518,513,|data|,4,0,0,0,0],mem);
    assert Fetch(code,21125) == Op(132,21126,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(22,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21126,[269019481,518,513,|data|,4,0,0,0,0,4],mem);
    assert Fetch(code,21126) == Op(53,21127,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(23,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21127,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data)],mem);
    F.Push1(code,21127);
    assert Fetch(code,21127) == Op(96,21129,1);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(24,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21129,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1],mem);
    F.Push1(code,21129);
    assert Fetch(code,21129) == Op(96,21131,1);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(25,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21131,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,1],mem);
    F.Push1(code,21131);
    assert Fetch(code,21131) == Op(96,21133,64);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(26,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21133,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,21133) == Op(27,21134,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(27,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21134,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,18446744073709551616],mem);
    assert Fetch(code,21134) == Op(3,21135,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(28,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21135,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),18446744073709551615],mem);
    assert Fetch(code,21135) == Op(129,21136,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(29,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21136,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),18446744073709551615,HeadA(data)],mem);
    assert Fetch(code,21136) == Op(17,21137,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(30,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21137,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),0],mem);
    assert Fetch(code,21137) == Op(21,21138,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(31,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21138,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1],mem);
    F.Push2(code,21138);
    assert Fetch(code,21138) == Op(97,21141,21145);
  }
  lemma Advance32(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(32,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21141,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),1,21145],mem);
    assert Fetch(code,21141) == Op(87,21142,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(33,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21145,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data)],mem);
    assert Fetch(code,21145) == Op(91,21146,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(34,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21146,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data)],mem);
    F.Push2(code,21146);
    assert Fetch(code,21146) == Op(97,21149,21157);
  }
  lemma Advance35(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(35,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21149,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157],mem);
    assert Fetch(code,21149) == Op(135,21150,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(36,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21150,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|],mem);
    assert Fetch(code,21150) == Op(130,21151,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(37,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21151,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadA(data)],mem);
    assert Fetch(code,21151) == Op(136,21152,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(38,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21152,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadA(data),4],mem);
    assert Fetch(code,21152) == Op(1,21153,0);
  }
  lemma Advance39(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(39,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21153,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data)],mem);
    F.Push2(code,21153);
    assert Fetch(code,21153) == Op(97,21156,20617);
  }
  lemma Advance40(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(40,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21156,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),20617],mem);
    assert Fetch(code,21156) == Op(86,21157,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(41,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20617,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data)],mem);
    assert Fetch(code,20617) == Op(91,20618,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(42,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20618,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data)],mem);
    assert Fetch(code,20618) == Op(95,20619,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(43,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20619,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0],mem);
    assert Fetch(code,20619) == Op(95,20620,0);
  }
  lemma Advance44(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(44,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20620,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0],mem);
    assert Fetch(code,20620) == Op(131,20621,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(45,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20621,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|],mem);
    F.Push1(code,20621);
    assert Fetch(code,20621) == Op(96,20623,31);
  }
  lemma Advance46(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(46,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20623,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|,31],mem);
    assert Fetch(code,20623) == Op(132,20624,0);
  }
  lemma Advance47(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(47,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20624,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|,31,HeadPositionA(data)],mem);
    assert Fetch(code,20624) == Op(1,20625,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(48,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20625,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,|data|,((HeadPositionA(data) as nat)+(31 as nat))%G.Modulus()],mem);
    assert Fetch(code,20625) == Op(18,20626,0);
  }
  lemma Advance49(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(49,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20626,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,1],mem);
    F.Push2(code,20626);
    assert Fetch(code,20626) == Op(97,20629,20633);
  }
  lemma Advance50(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(50,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20629,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0,1,20633],mem);
    assert Fetch(code,20629) == Op(87,20630,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(51,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20633,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0],mem);
    assert Fetch(code,20633) == Op(91,20634,0);
  }
  lemma Advance52(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(52,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20634,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,0],mem);
    assert Fetch(code,20634) == Op(80,20635,0);
  }
  lemma Advance53(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(53,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20635,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0],mem);
    assert Fetch(code,20635) == Op(129,20636,0);
  }
  lemma Advance54(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(54,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(55,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20636,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,HeadPositionA(data)],mem);
    assert Fetch(code,20636) == Op(53,20637,0);
  }
  lemma Advance55(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(55,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(56,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20637,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data)],mem);
    F.Push1(code,20637);
    assert Fetch(code,20637) == Op(96,20639,1);
  }
  lemma Advance56(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(56,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(57,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20639,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1],mem);
    F.Push1(code,20639);
    assert Fetch(code,20639) == Op(96,20641,1);
  }
  lemma Advance57(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(57,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(58,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20641,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,1],mem);
    F.Push1(code,20641);
    assert Fetch(code,20641) == Op(96,20643,64);
  }
  lemma Advance58(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(58,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(59,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20643,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,20643) == Op(27,20644,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(59,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(60,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20644,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,18446744073709551616],mem);
    assert Fetch(code,20644) == Op(3,20645,0);
  }
  lemma Advance60(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(60,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(61,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20645,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),18446744073709551615],mem);
    assert Fetch(code,20645) == Op(129,20646,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(61,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(62,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20646,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),18446744073709551615,LengthA(data)],mem);
    assert Fetch(code,20646) == Op(17,20647,0);
  }
  lemma Advance62(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(62,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(63,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20647,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),0],mem);
    assert Fetch(code,20647) == Op(21,20648,0);
  }
  lemma Advance63(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(63,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(64,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20648,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1],mem);
    F.Push2(code,20648);
    assert Fetch(code,20648) == Op(97,20651,20655);
  }
  lemma Advance64(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(64,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(65,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20651,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),1,20655],mem);
    assert Fetch(code,20651) == Op(87,20652,0);
  }
  lemma Advance65(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(65,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(66,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20655,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data)],mem);
    assert Fetch(code,20655) == Op(91,20656,0);
  }
  lemma Advance66(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(66,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(67,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20656,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data)],mem);
    F.Push1(code,20656);
    assert Fetch(code,20656) == Op(96,20658,32);
  }
  lemma Advance67(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(67,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(68,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20658,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),32],mem);
    assert Fetch(code,20658) == Op(131,20659,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(68,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(69,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20659,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),32,HeadPositionA(data)],mem);
    assert HeadA(data) < 0x10000000000000000;
    assert HeadPositionA(data) == (HeadA(data) as nat)+4;
    assert OffsetA(data) == (HeadA(data) as nat)+36;
    assert (HeadPositionA(data) as nat)+32 == OffsetA(data);
    assert Fetch(code,20659) == Op(1,20660,0);
  }
  lemma Advance69(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(69,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(70,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20660,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),0,LengthA(data),OffsetA(data)],mem);
    assert Fetch(code,20660) == Op(145,20661,0);
  }
  lemma Advance70(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(70,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(71,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20661,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0],mem);
    assert Fetch(code,20661) == Op(80,20662,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(71,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(72,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20662,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data)],mem);
    assert Fetch(code,20662) == Op(131,20663,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(72,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(73,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20663,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|],mem);
    F.Push1(code,20663);
    assert Fetch(code,20663) == Op(96,20665,32);
  }
  lemma Advance73(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(73,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(74,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20665,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32],mem);
    assert Fetch(code,20665) == Op(130,20666,0);
  }
  lemma Advance74(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(74,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(75,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20666,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32,LengthA(data)],mem);
    assert Fetch(code,20666) == Op(133,20667,0);
  }
  lemma Advance75(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(75,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(76,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20667,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32,LengthA(data),HeadPositionA(data)],mem);
    assert Fetch(code,20667) == Op(1,20668,0);
  }
  lemma Advance76(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(76,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(77,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20668,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,32,((HeadPositionA(data) as nat)+(LengthA(data) as nat))%G.Modulus()],mem);
    assert Fetch(code,20668) == Op(1,20669,0);
  }
  lemma Advance77(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(77,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(78,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20669,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),|data|,((((HeadPositionA(data) as nat)+(LengthA(data) as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,20669) == Op(17,20670,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(78,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(79,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20670,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),1],mem);
    assert Fetch(code,20670) == Op(21,20671,0);
  }
  lemma Advance79(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(79,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(80,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20671,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0],mem);
    F.Push2(code,20671);
    assert Fetch(code,20671) == Op(97,20674,20678);
  }
  lemma Advance80(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(80,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(81,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20674,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0,20678],mem);
    assert Fetch(code,20674) == Op(87,20675,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(81,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(82,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20675,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data)],mem);
    assert Fetch(code,20675) == Op(95,20676,0);
  }
  lemma Advance82(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(82,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(83,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20676,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0],mem);
    assert Fetch(code,20676) == Op(95,20677,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(83,state,data,mem)
    ensures state.Running? && |state.stack| <= 19 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20677,[269019481,518,513,|data|,4,0,0,0,0,HeadA(data),21157,|data|,HeadPositionA(data),OffsetA(data),LengthA(data),0,0],mem);
    assert Fetch(code,20677) == Op(253,20678,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(499,[269019481],mem),data,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 85 && trace[0] == Running(499,[269019481],mem) && trace[|trace|-1] == state
  {
    Start(data,mem);
    state := Running(499,[269019481],mem);
    trace := [state];
    Advance0(code,state,data,mem,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(499,[269019481],mem);
    state := next0;
    Advance1(code,state,data,mem,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(499,[269019481],mem);
    state := next1;
    Advance2(code,state,data,mem,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(499,[269019481],mem);
    state := next2;
    Advance3(code,state,data,mem,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(499,[269019481],mem);
    state := next3;
    Advance4(code,state,data,mem,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(499,[269019481],mem);
    state := next4;
    Advance5(code,state,data,mem,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(499,[269019481],mem);
    state := next5;
    Advance6(code,state,data,mem,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(499,[269019481],mem);
    state := next6;
    Advance7(code,state,data,mem,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(499,[269019481],mem);
    state := next7;
    Advance8(code,state,data,mem,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(499,[269019481],mem);
    state := next8;
    Advance9(code,state,data,mem,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(499,[269019481],mem);
    state := next9;
    Advance10(code,state,data,mem,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(499,[269019481],mem);
    state := next10;
    Advance11(code,state,data,mem,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(499,[269019481],mem);
    state := next11;
    Advance12(code,state,data,mem,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(499,[269019481],mem);
    state := next12;
    Advance13(code,state,data,mem,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(499,[269019481],mem);
    state := next13;
    Advance14(code,state,data,mem,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(499,[269019481],mem);
    state := next14;
    Advance15(code,state,data,mem,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(499,[269019481],mem);
    state := next15;
    Advance16(code,state,data,mem,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(499,[269019481],mem);
    state := next16;
    Advance17(code,state,data,mem,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(499,[269019481],mem);
    state := next17;
    Advance18(code,state,data,mem,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(499,[269019481],mem);
    state := next18;
    Advance19(code,state,data,mem,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(499,[269019481],mem);
    state := next19;
    Advance20(code,state,data,mem,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(499,[269019481],mem);
    state := next20;
    Advance21(code,state,data,mem,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(499,[269019481],mem);
    state := next21;
    Advance22(code,state,data,mem,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(499,[269019481],mem);
    state := next22;
    Advance23(code,state,data,mem,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(499,[269019481],mem);
    state := next23;
    Advance24(code,state,data,mem,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(499,[269019481],mem);
    state := next24;
    Advance25(code,state,data,mem,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(499,[269019481],mem);
    state := next25;
    Advance26(code,state,data,mem,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(499,[269019481],mem);
    state := next26;
    Advance27(code,state,data,mem,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(499,[269019481],mem);
    state := next27;
    Advance28(code,state,data,mem,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(499,[269019481],mem);
    state := next28;
    Advance29(code,state,data,mem,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(499,[269019481],mem);
    state := next29;
    Advance30(code,state,data,mem,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    assert trace[0] == Running(499,[269019481],mem);
    state := next30;
    Advance31(code,state,data,mem,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31];
    assert trace[0] == Running(499,[269019481],mem);
    state := next31;
    Advance32(code,state,data,mem,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32];
    assert trace[0] == Running(499,[269019481],mem);
    state := next32;
    Advance33(code,state,data,mem,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33];
    assert trace[0] == Running(499,[269019481],mem);
    state := next33;
    Advance34(code,state,data,mem,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34];
    assert trace[0] == Running(499,[269019481],mem);
    state := next34;
    Advance35(code,state,data,mem,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35];
    assert trace[0] == Running(499,[269019481],mem);
    state := next35;
    Advance36(code,state,data,mem,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36];
    assert trace[0] == Running(499,[269019481],mem);
    state := next36;
    Advance37(code,state,data,mem,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37];
    assert trace[0] == Running(499,[269019481],mem);
    state := next37;
    Advance38(code,state,data,mem,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);
    trace := trace+[next38];
    assert trace[0] == Running(499,[269019481],mem);
    state := next38;
    Advance39(code,state,data,mem,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);
    trace := trace+[next39];
    assert trace[0] == Running(499,[269019481],mem);
    state := next39;
    Advance40(code,state,data,mem,value);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);
    trace := trace+[next40];
    assert trace[0] == Running(499,[269019481],mem);
    state := next40;
    Advance41(code,state,data,mem,value);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);
    trace := trace+[next41];
    assert trace[0] == Running(499,[269019481],mem);
    state := next41;
    Advance42(code,state,data,mem,value);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);
    trace := trace+[next42];
    assert trace[0] == Running(499,[269019481],mem);
    state := next42;
    Advance43(code,state,data,mem,value);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);
    trace := trace+[next43];
    assert trace[0] == Running(499,[269019481],mem);
    state := next43;
    Advance44(code,state,data,mem,value);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);
    trace := trace+[next44];
    assert trace[0] == Running(499,[269019481],mem);
    state := next44;
    Advance45(code,state,data,mem,value);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);
    trace := trace+[next45];
    assert trace[0] == Running(499,[269019481],mem);
    state := next45;
    Advance46(code,state,data,mem,value);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);
    trace := trace+[next46];
    assert trace[0] == Running(499,[269019481],mem);
    state := next46;
    Advance47(code,state,data,mem,value);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);
    trace := trace+[next47];
    assert trace[0] == Running(499,[269019481],mem);
    state := next47;
    Advance48(code,state,data,mem,value);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);
    trace := trace+[next48];
    assert trace[0] == Running(499,[269019481],mem);
    state := next48;
    Advance49(code,state,data,mem,value);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);
    trace := trace+[next49];
    assert trace[0] == Running(499,[269019481],mem);
    state := next49;
    Advance50(code,state,data,mem,value);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);
    trace := trace+[next50];
    assert trace[0] == Running(499,[269019481],mem);
    state := next50;
    Advance51(code,state,data,mem,value);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);
    trace := trace+[next51];
    assert trace[0] == Running(499,[269019481],mem);
    state := next51;
    Advance52(code,state,data,mem,value);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);
    trace := trace+[next52];
    assert trace[0] == Running(499,[269019481],mem);
    state := next52;
    Advance53(code,state,data,mem,value);
    var next53 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);
    trace := trace+[next53];
    assert trace[0] == Running(499,[269019481],mem);
    state := next53;
    Advance54(code,state,data,mem,value);
    var next54 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);
    trace := trace+[next54];
    assert trace[0] == Running(499,[269019481],mem);
    state := next54;
    Advance55(code,state,data,mem,value);
    var next55 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55);
    trace := trace+[next55];
    assert trace[0] == Running(499,[269019481],mem);
    state := next55;
    Advance56(code,state,data,mem,value);
    var next56 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56);
    trace := trace+[next56];
    assert trace[0] == Running(499,[269019481],mem);
    state := next56;
    Advance57(code,state,data,mem,value);
    var next57 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57);
    trace := trace+[next57];
    assert trace[0] == Running(499,[269019481],mem);
    state := next57;
    Advance58(code,state,data,mem,value);
    var next58 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58);
    trace := trace+[next58];
    assert trace[0] == Running(499,[269019481],mem);
    state := next58;
    Advance59(code,state,data,mem,value);
    var next59 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59);
    trace := trace+[next59];
    assert trace[0] == Running(499,[269019481],mem);
    state := next59;
    Advance60(code,state,data,mem,value);
    var next60 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next60);
    trace := trace+[next60];
    assert trace[0] == Running(499,[269019481],mem);
    state := next60;
    Advance61(code,state,data,mem,value);
    var next61 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next61);
    trace := trace+[next61];
    assert trace[0] == Running(499,[269019481],mem);
    state := next61;
    Advance62(code,state,data,mem,value);
    var next62 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next62);
    trace := trace+[next62];
    assert trace[0] == Running(499,[269019481],mem);
    state := next62;
    Advance63(code,state,data,mem,value);
    var next63 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next63);
    trace := trace+[next63];
    assert trace[0] == Running(499,[269019481],mem);
    state := next63;
    Advance64(code,state,data,mem,value);
    var next64 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next64);
    trace := trace+[next64];
    assert trace[0] == Running(499,[269019481],mem);
    state := next64;
    Advance65(code,state,data,mem,value);
    var next65 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next65);
    trace := trace+[next65];
    assert trace[0] == Running(499,[269019481],mem);
    state := next65;
    Advance66(code,state,data,mem,value);
    var next66 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next66);
    trace := trace+[next66];
    assert trace[0] == Running(499,[269019481],mem);
    state := next66;
    Advance67(code,state,data,mem,value);
    var next67 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next67);
    trace := trace+[next67];
    assert trace[0] == Running(499,[269019481],mem);
    state := next67;
    Advance68(code,state,data,mem,value);
    var next68 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next68);
    trace := trace+[next68];
    assert trace[0] == Running(499,[269019481],mem);
    state := next68;
    Advance69(code,state,data,mem,value);
    var next69 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next69);
    trace := trace+[next69];
    assert trace[0] == Running(499,[269019481],mem);
    state := next69;
    Advance70(code,state,data,mem,value);
    var next70 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next70);
    trace := trace+[next70];
    assert trace[0] == Running(499,[269019481],mem);
    state := next70;
    Advance71(code,state,data,mem,value);
    var next71 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next71);
    trace := trace+[next71];
    assert trace[0] == Running(499,[269019481],mem);
    state := next71;
    Advance72(code,state,data,mem,value);
    var next72 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next72);
    trace := trace+[next72];
    assert trace[0] == Running(499,[269019481],mem);
    state := next72;
    Advance73(code,state,data,mem,value);
    var next73 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next73);
    trace := trace+[next73];
    assert trace[0] == Running(499,[269019481],mem);
    state := next73;
    Advance74(code,state,data,mem,value);
    var next74 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next74);
    trace := trace+[next74];
    assert trace[0] == Running(499,[269019481],mem);
    state := next74;
    Advance75(code,state,data,mem,value);
    var next75 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next75);
    trace := trace+[next75];
    assert trace[0] == Running(499,[269019481],mem);
    state := next75;
    Advance76(code,state,data,mem,value);
    var next76 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next76);
    trace := trace+[next76];
    assert trace[0] == Running(499,[269019481],mem);
    state := next76;
    Advance77(code,state,data,mem,value);
    var next77 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next77);
    trace := trace+[next77];
    assert trace[0] == Running(499,[269019481],mem);
    state := next77;
    Advance78(code,state,data,mem,value);
    var next78 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next78);
    trace := trace+[next78];
    assert trace[0] == Running(499,[269019481],mem);
    state := next78;
    Advance79(code,state,data,mem,value);
    var next79 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next79);
    trace := trace+[next79];
    assert trace[0] == Running(499,[269019481],mem);
    state := next79;
    Advance80(code,state,data,mem,value);
    var next80 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next80);
    trace := trace+[next80];
    assert trace[0] == Running(499,[269019481],mem);
    state := next80;
    Advance81(code,state,data,mem,value);
    var next81 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next81);
    trace := trace+[next81];
    assert trace[0] == Running(499,[269019481],mem);
    state := next81;
    Advance82(code,state,data,mem,value);
    var next82 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next82);
    trace := trace+[next82];
    assert trace[0] == Running(499,[269019481],mem);
    state := next82;
    Advance83(code,state,data,mem,value);
    var next83 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next83);
    trace := trace+[next83];
    assert trace[0] == Running(499,[269019481],mem);
    state := next83;
  }
}
