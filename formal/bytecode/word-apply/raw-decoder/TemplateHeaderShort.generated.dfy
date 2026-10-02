// SPDX-License-Identifier: MIT
// Generated ordered raw four-head admission path; every reached instruction and terminal preserved.
include "Inputs.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyDecoderTemplateHeaderShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import A = BytecodeApplyAddressMask
  import R = BytecodeApplyRawScalar
  import AS = BytecodeApplyArrayStride
  import I = BytecodeApplyRawInputs
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < I.U64() && I.TargetFits(data) && I.TemplateHead(data) < I.U64() && (I.TemplateHead(data) as nat)+36 > |data| }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[784] == 91 &&
                                              code[1050] == 91 &&
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
                                              code[20630] == 95 &&
                                              code[20631] == 95 &&
                                              code[20632] == 253 &&
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
                                              code[20678] == 91 &&
                                              code[20679] == 146 &&
                                              code[20680] == 80 &&
                                              code[20681] == 146 &&
                                              code[20682] == 144 &&
                                              code[20683] == 80 &&
                                              code[20684] == 86 &&
                                              code[21566] == 91 &&
                                              code[21567] == 145 &&
                                              code[21568] == 144 &&
                                              code[21569] == 80 &&
                                              code[21570] == 86 &&
                                              code[22096] == 91 &&
                                              code[22097] == 128 &&
                                              code[22098] == 53 &&
                                              code[22099] == 96 &&
                                              code[22100] == 1 &&
                                              code[22101] == 96 &&
                                              code[22102] == 1 &&
                                              code[22103] == 96 &&
                                              code[22104] == 160 &&
                                              code[22105] == 27 &&
                                              code[22106] == 3 &&
                                              code[22107] == 129 &&
                                              code[22108] == 22 &&
                                              code[22109] == 129 &&
                                              code[22110] == 20 &&
                                              code[22111] == 97 &&
                                              code[22112] == 84 &&
                                              code[22113] == 62 &&
                                              code[22114] == 87 &&
                                              code[22579] == 91 &&
                                              code[22580] == 95 &&
                                              code[22581] == 95 &&
                                              code[22582] == 95 &&
                                              code[22583] == 95 &&
                                              code[22584] == 95 &&
                                              code[22585] == 95 &&
                                              code[22586] == 95 &&
                                              code[22587] == 96 &&
                                              code[22588] == 128 &&
                                              code[22589] == 136 &&
                                              code[22590] == 138 &&
                                              code[22591] == 3 &&
                                              code[22592] == 18 &&
                                              code[22593] == 21 &&
                                              code[22594] == 97 &&
                                              code[22595] == 88 &&
                                              code[22596] == 73 &&
                                              code[22597] == 87 &&
                                              code[22601] == 91 &&
                                              code[22602] == 135 &&
                                              code[22603] == 53 &&
                                              code[22604] == 96 &&
                                              code[22605] == 1 &&
                                              code[22606] == 96 &&
                                              code[22607] == 1 &&
                                              code[22608] == 96 &&
                                              code[22609] == 64 &&
                                              code[22610] == 27 &&
                                              code[22611] == 3 &&
                                              code[22612] == 129 &&
                                              code[22613] == 17 &&
                                              code[22614] == 21 &&
                                              code[22615] == 97 &&
                                              code[22616] == 88 &&
                                              code[22617] == 94 &&
                                              code[22618] == 87 &&
                                              code[22622] == 91 &&
                                              code[22623] == 97 &&
                                              code[22624] == 88 &&
                                              code[22625] == 106 &&
                                              code[22626] == 138 &&
                                              code[22627] == 130 &&
                                              code[22628] == 139 &&
                                              code[22629] == 1 &&
                                              code[22630] == 97 &&
                                              code[22631] == 80 &&
                                              code[22632] == 137 &&
                                              code[22633] == 86 &&
                                              code[22634] == 91 &&
                                              code[22635] == 144 &&
                                              code[22636] == 152 &&
                                              code[22637] == 80 &&
                                              code[22638] == 150 &&
                                              code[22639] == 80 &&
                                              code[22640] == 97 &&
                                              code[22641] == 88 &&
                                              code[22642] == 125 &&
                                              code[22643] == 144 &&
                                              code[22644] == 80 &&
                                              code[22645] == 96 &&
                                              code[22646] == 32 &&
                                              code[22647] == 137 &&
                                              code[22648] == 1 &&
                                              code[22649] == 97 &&
                                              code[22650] == 86 &&
                                              code[22651] == 80 &&
                                              code[22652] == 86 &&
                                              code[22653] == 91 &&
                                              code[22654] == 148 &&
                                              code[22655] == 80 &&
                                              code[22656] == 96 &&
                                              code[22657] == 64 &&
                                              code[22658] == 136 &&
                                              code[22659] == 1 &&
                                              code[22660] == 53 &&
                                              code[22661] == 96 &&
                                              code[22662] == 1 &&
                                              code[22663] == 96 &&
                                              code[22664] == 1 &&
                                              code[22665] == 96 &&
                                              code[22666] == 64 &&
                                              code[22667] == 27 &&
                                              code[22668] == 3 &&
                                              code[22669] == 129 &&
                                              code[22670] == 17 &&
                                              code[22671] == 21 &&
                                              code[22672] == 97 &&
                                              code[22673] == 88 &&
                                              code[22674] == 151 &&
                                              code[22675] == 87 &&
                                              code[22679] == 91 &&
                                              code[22680] == 97 &&
                                              code[22681] == 88 &&
                                              code[22682] == 163 &&
                                              code[22683] == 138 &&
                                              code[22684] == 130 &&
                                              code[22685] == 139 &&
                                              code[22686] == 1 &&
                                              code[22687] == 97 &&
                                              code[22688] == 80 &&
                                              code[22689] == 137 &&
                                              code[22690] == 86
  }
  function Destinations(): set<nat> { {784,1050,20617,20633,20655,20678,21566,22096,22601,22622,22634,22653,22679} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word) { Admitted(data) && (
                                                                                                                       if id == 0 then state == Running(22579,prefix+[returnPc,|data|,4],mem)
                                                                                                                       else if id == 1 then state == Running(22580,prefix+[returnPc,|data|,4],mem)
                                                                                                                       else if id == 2 then state == Running(22581,prefix+[returnPc,|data|,4,0],mem)
                                                                                                                       else if id == 3 then state == Running(22582,prefix+[returnPc,|data|,4,0,0],mem)
                                                                                                                       else if id == 4 then state == Running(22583,prefix+[returnPc,|data|,4,0,0,0],mem)
                                                                                                                       else if id == 5 then state == Running(22584,prefix+[returnPc,|data|,4,0,0,0,0],mem)
                                                                                                                       else if id == 6 then state == Running(22585,prefix+[returnPc,|data|,4,0,0,0,0,0],mem)
                                                                                                                       else if id == 7 then state == Running(22586,prefix+[returnPc,|data|,4,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 8 then state == Running(22587,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 9 then state == Running(22589,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128],mem)
                                                                                                                       else if id == 10 then state == Running(22590,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4],mem)
                                                                                                                       else if id == 11 then state == Running(22591,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4,|data|],mem)
                                                                                                                       else if id == 12 then state == Running(22592,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem)
                                                                                                                       else if id == 13 then state == Running(22593,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 14 then state == Running(22594,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1],mem)
                                                                                                                       else if id == 15 then state == Running(22597,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1,22601],mem)
                                                                                                                       else if id == 16 then state == Running(22601,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 17 then state == Running(22602,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 18 then state == Running(22603,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,4],mem)
                                                                                                                       else if id == 19 then state == Running(22604,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data)],mem)
                                                                                                                       else if id == 20 then state == Running(22606,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1],mem)
                                                                                                                       else if id == 21 then state == Running(22608,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,1],mem)
                                                                                                                       else if id == 22 then state == Running(22610,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,1,64],mem)
                                                                                                                       else if id == 23 then state == Running(22611,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,18446744073709551616],mem)
                                                                                                                       else if id == 24 then state == Running(22612,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),18446744073709551615],mem)
                                                                                                                       else if id == 25 then state == Running(22613,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),18446744073709551615,I.SourceHead(data)],mem)
                                                                                                                       else if id == 26 then state == Running(22614,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),0],mem)
                                                                                                                       else if id == 27 then state == Running(22615,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1],mem)
                                                                                                                       else if id == 28 then state == Running(22618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,22622],mem)
                                                                                                                       else if id == 29 then state == Running(22622,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data)],mem)
                                                                                                                       else if id == 30 then state == Running(22623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data)],mem)
                                                                                                                       else if id == 31 then state == Running(22626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634],mem)
                                                                                                                       else if id == 32 then state == Running(22627,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|],mem)
                                                                                                                       else if id == 33 then state == Running(22628,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.SourceHead(data)],mem)
                                                                                                                       else if id == 34 then state == Running(22629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.SourceHead(data),4],mem)
                                                                                                                       else if id == 35 then state == Running(22630,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 36 then state == Running(22633,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),20617],mem)
                                                                                                                       else if id == 37 then state == Running(20617,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 38 then state == Running(20618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 39 then state == Running(20619,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0],mem)
                                                                                                                       else if id == 40 then state == Running(20620,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0],mem)
                                                                                                                       else if id == 41 then state == Running(20621,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|],mem)
                                                                                                                       else if id == 42 then state == Running(20623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|,31],mem)
                                                                                                                       else if id == 43 then state == Running(20624,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|,31,I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 44 then state == Running(20625,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|,((I.Header(I.SourceHead(data)) as nat)+(31 as nat))%G.Modulus()],mem)
                                                                                                                       else if id == 45 then state == Running(20626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,1],mem)
                                                                                                                       else if id == 46 then state == Running(20629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,1,20633],mem)
                                                                                                                       else if id == 47 then state == Running(20633,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0],mem)
                                                                                                                       else if id == 48 then state == Running(20634,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0],mem)
                                                                                                                       else if id == 49 then state == Running(20635,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0],mem)
                                                                                                                       else if id == 50 then state == Running(20636,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 51 then state == Running(20637,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data)],mem)
                                                                                                                       else if id == 52 then state == Running(20639,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1],mem)
                                                                                                                       else if id == 53 then state == Running(20641,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,1],mem)
                                                                                                                       else if id == 54 then state == Running(20643,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,1,64],mem)
                                                                                                                       else if id == 55 then state == Running(20644,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,18446744073709551616],mem)
                                                                                                                       else if id == 56 then state == Running(20645,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),18446744073709551615],mem)
                                                                                                                       else if id == 57 then state == Running(20646,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),18446744073709551615,I.SourceLength(data)],mem)
                                                                                                                       else if id == 58 then state == Running(20647,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),0],mem)
                                                                                                                       else if id == 59 then state == Running(20648,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1],mem)
                                                                                                                       else if id == 60 then state == Running(20651,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,20655],mem)
                                                                                                                       else if id == 61 then state == Running(20655,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data)],mem)
                                                                                                                       else if id == 62 then state == Running(20656,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data)],mem)
                                                                                                                       else if id == 63 then state == Running(20658,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),32],mem)
                                                                                                                       else if id == 64 then state == Running(20659,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),32,I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 65 then state == Running(20660,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),I.Offset(I.SourceHead(data))],mem)
                                                                                                                       else if id == 66 then state == Running(20661,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),0],mem)
                                                                                                                       else if id == 67 then state == Running(20662,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem)
                                                                                                                       else if id == 68 then state == Running(20663,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|],mem)
                                                                                                                       else if id == 69 then state == Running(20665,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32],mem)
                                                                                                                       else if id == 70 then state == Running(20666,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32,I.SourceLength(data)],mem)
                                                                                                                       else if id == 71 then state == Running(20667,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32,I.SourceLength(data),I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 72 then state == Running(20668,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32,((I.Header(I.SourceHead(data)) as nat)+(I.SourceLength(data) as nat))%G.Modulus()],mem)
                                                                                                                       else if id == 73 then state == Running(20669,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,((((I.Header(I.SourceHead(data)) as nat)+(I.SourceLength(data) as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                                                       else if id == 74 then state == Running(20670,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),0],mem)
                                                                                                                       else if id == 75 then state == Running(20671,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),1],mem)
                                                                                                                       else if id == 76 then state == Running(20674,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),1,20678],mem)
                                                                                                                       else if id == 77 then state == Running(20678,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem)
                                                                                                                       else if id == 78 then state == Running(20679,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem)
                                                                                                                       else if id == 79 then state == Running(20680,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,I.SourceLength(data),I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),|data|],mem)
                                                                                                                       else if id == 80 then state == Running(20681,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,I.SourceLength(data),I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data))],mem)
                                                                                                                       else if id == 81 then state == Running(20682,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Header(I.SourceHead(data)),22634],mem)
                                                                                                                       else if id == 82 then state == Running(20683,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data),22634,I.Header(I.SourceHead(data))],mem)
                                                                                                                       else if id == 83 then state == Running(20684,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data),22634],mem)
                                                                                                                       else if id == 84 then state == Running(22634,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem)
                                                                                                                       else if id == 85 then state == Running(22635,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem)
                                                                                                                       else if id == 86 then state == Running(22636,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.SourceLength(data),I.Offset(I.SourceHead(data))],mem)
                                                                                                                       else if id == 87 then state == Running(22637,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),0,0,0,0,0,0,I.SourceHead(data),I.SourceLength(data),0],mem)
                                                                                                                       else if id == 88 then state == Running(22638,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),0,0,0,0,0,0,I.SourceHead(data),I.SourceLength(data)],mem)
                                                                                                                       else if id == 89 then state == Running(22639,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.SourceHead(data),0],mem)
                                                                                                                       else if id == 90 then state == Running(22640,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.SourceHead(data)],mem)
                                                                                                                       else if id == 91 then state == Running(22643,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.SourceHead(data),22653],mem)
                                                                                                                       else if id == 92 then state == Running(22644,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,I.SourceHead(data)],mem)
                                                                                                                       else if id == 93 then state == Running(22645,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653],mem)
                                                                                                                       else if id == 94 then state == Running(22647,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,32],mem)
                                                                                                                       else if id == 95 then state == Running(22648,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,32,4],mem)
                                                                                                                       else if id == 96 then state == Running(22649,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36],mem)
                                                                                                                       else if id == 97 then state == Running(22652,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,22096],mem)
                                                                                                                       else if id == 98 then state == Running(22096,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36],mem)
                                                                                                                       else if id == 99 then state == Running(22097,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36],mem)
                                                                                                                       else if id == 100 then state == Running(22098,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,36],mem)
                                                                                                                       else if id == 101 then state == Running(22099,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data)],mem)
                                                                                                                       else if id == 102 then state == Running(22101,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1],mem)
                                                                                                                       else if id == 103 then state == Running(22103,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,1],mem)
                                                                                                                       else if id == 104 then state == Running(22105,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,1,160],mem)
                                                                                                                       else if id == 105 then state == Running(22106,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,1461501637330902918203684832716283019655932542976],mem)
                                                                                                                       else if id == 106 then state == Running(22107,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1461501637330902918203684832716283019655932542975],mem)
                                                                                                                       else if id == 107 then state == Running(22108,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1461501637330902918203684832716283019655932542975,I.Target(data)],mem)
                                                                                                                       else if id == 108 then state == Running(22109,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),I.Target(data)],mem)
                                                                                                                       else if id == 109 then state == Running(22110,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),I.Target(data),I.Target(data)],mem)
                                                                                                                       else if id == 110 then state == Running(22111,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1],mem)
                                                                                                                       else if id == 111 then state == Running(22114,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,21566],mem)
                                                                                                                       else if id == 112 then state == Running(21566,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data)],mem)
                                                                                                                       else if id == 113 then state == Running(21567,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data)],mem)
                                                                                                                       else if id == 114 then state == Running(21568,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data),36,22653],mem)
                                                                                                                       else if id == 115 then state == Running(21569,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data),22653,36],mem)
                                                                                                                       else if id == 116 then state == Running(21570,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data),22653],mem)
                                                                                                                       else if id == 117 then state == Running(22653,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data)],mem)
                                                                                                                       else if id == 118 then state == Running(22654,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data)],mem)
                                                                                                                       else if id == 119 then state == Running(22655,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,0],mem)
                                                                                                                       else if id == 120 then state == Running(22656,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0],mem)
                                                                                                                       else if id == 121 then state == Running(22658,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,64],mem)
                                                                                                                       else if id == 122 then state == Running(22659,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,64,4],mem)
                                                                                                                       else if id == 123 then state == Running(22660,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,68],mem)
                                                                                                                       else if id == 124 then state == Running(22661,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data)],mem)
                                                                                                                       else if id == 125 then state == Running(22663,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1],mem)
                                                                                                                       else if id == 126 then state == Running(22665,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,1],mem)
                                                                                                                       else if id == 127 then state == Running(22667,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,1,64],mem)
                                                                                                                       else if id == 128 then state == Running(22668,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,18446744073709551616],mem)
                                                                                                                       else if id == 129 then state == Running(22669,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),18446744073709551615],mem)
                                                                                                                       else if id == 130 then state == Running(22670,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),18446744073709551615,I.TemplateHead(data)],mem)
                                                                                                                       else if id == 131 then state == Running(22671,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),0],mem)
                                                                                                                       else if id == 132 then state == Running(22672,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1],mem)
                                                                                                                       else if id == 133 then state == Running(22675,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,22679],mem)
                                                                                                                       else if id == 134 then state == Running(22679,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data)],mem)
                                                                                                                       else if id == 135 then state == Running(22680,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data)],mem)
                                                                                                                       else if id == 136 then state == Running(22683,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691],mem)
                                                                                                                       else if id == 137 then state == Running(22684,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|],mem)
                                                                                                                       else if id == 138 then state == Running(22685,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.TemplateHead(data)],mem)
                                                                                                                       else if id == 139 then state == Running(22686,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.TemplateHead(data),4],mem)
                                                                                                                       else if id == 140 then state == Running(22687,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data))],mem)
                                                                                                                       else if id == 141 then state == Running(22690,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),20617],mem)
                                                                                                                       else if id == 142 then state == Running(20617,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data))],mem)
                                                                                                                       else if id == 143 then state == Running(20618,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data))],mem)
                                                                                                                       else if id == 144 then state == Running(20619,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0],mem)
                                                                                                                       else if id == 145 then state == Running(20620,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0],mem)
                                                                                                                       else if id == 146 then state == Running(20621,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|],mem)
                                                                                                                       else if id == 147 then state == Running(20623,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|,31],mem)
                                                                                                                       else if id == 148 then state == Running(20624,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|,31,I.Header(I.TemplateHead(data))],mem)
                                                                                                                       else if id == 149 then state == Running(20625,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|,((I.Header(I.TemplateHead(data)) as nat)+(31 as nat))%G.Modulus()],mem)
                                                                                                                       else if id == 150 then state == Running(20626,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0],mem)
                                                                                                                       else if id == 151 then state == Running(20629,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0,20633],mem)
                                                                                                                       else if id == 152 then state == Running(20630,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0],mem)
                                                                                                                       else if id == 153 then state == Running(20631,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0],mem)
                                                                                                                       else if id == 154 then state == Running(20632,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0,0],mem)
                                                                                                                       else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(0,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22579,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22579) == Op(91,22580,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(1,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22580,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22580) == Op(95,22581,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(2,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22581,prefix+[returnPc,|data|,4,0],mem);
    assert Fetch(code,22581) == Op(95,22582,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(3,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22582,prefix+[returnPc,|data|,4,0,0],mem);
    assert Fetch(code,22582) == Op(95,22583,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(4,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22583,prefix+[returnPc,|data|,4,0,0,0],mem);
    assert Fetch(code,22583) == Op(95,22584,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(5,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22584,prefix+[returnPc,|data|,4,0,0,0,0],mem);
    assert Fetch(code,22584) == Op(95,22585,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(6,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22585,prefix+[returnPc,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,22585) == Op(95,22586,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(7,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22586,prefix+[returnPc,|data|,4,0,0,0,0,0,0],mem);
    assert Fetch(code,22586) == Op(95,22587,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(8,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22587,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    F.Push1(code,22587);
    assert Fetch(code,22587) == Op(96,22589,128);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(9,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22589,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128],mem);
    assert Fetch(code,22589) == Op(136,22590,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(10,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22590,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4],mem);
    assert Fetch(code,22590) == Op(138,22591,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(11,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22591,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4,|data|],mem);
    assert Fetch(code,22591) == Op(3,22592,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(12,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22592,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,22592) == Op(18,22593,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(13,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22593,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22593) == Op(21,22594,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(14,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22594,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1],mem);
    F.Push2(code,22594);
    assert Fetch(code,22594) == Op(97,22597,22601);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(15,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22597,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1,22601],mem);
    assert Fetch(code,22597) == Op(87,22598,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(16,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22601,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22601) == Op(91,22602,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(17,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22602,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22602) == Op(135,22603,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(18,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22603,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,4],mem);
    assert Fetch(code,22603) == Op(53,22604,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(19,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22604,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data)],mem);
    F.Push1(code,22604);
    assert Fetch(code,22604) == Op(96,22606,1);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(20,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22606,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1],mem);
    F.Push1(code,22606);
    assert Fetch(code,22606) == Op(96,22608,1);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(21,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22608,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,1],mem);
    F.Push1(code,22608);
    assert Fetch(code,22608) == Op(96,22610,64);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(22,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22610,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,22610) == Op(27,22611,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(23,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22611,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,18446744073709551616],mem);
    assert Fetch(code,22611) == Op(3,22612,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(24,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22612,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),18446744073709551615],mem);
    assert Fetch(code,22612) == Op(129,22613,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(25,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22613,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),18446744073709551615,I.SourceHead(data)],mem);
    assert Fetch(code,22613) == Op(17,22614,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(26,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22614,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),0],mem);
    assert Fetch(code,22614) == Op(21,22615,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(27,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22615,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1],mem);
    F.Push2(code,22615);
    assert Fetch(code,22615) == Op(97,22618,22622);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(28,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),1,22622],mem);
    assert Fetch(code,22618) == Op(87,22619,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(29,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22622,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data)],mem);
    assert Fetch(code,22622) == Op(91,22623,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(30,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data)],mem);
    F.Push2(code,22623);
    assert Fetch(code,22623) == Op(97,22626,22634);
  }
  lemma Advance31(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(31,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634],mem);
    assert Fetch(code,22626) == Op(138,22627,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(32,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22627,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|],mem);
    assert Fetch(code,22627) == Op(130,22628,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(33,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22628,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.SourceHead(data)],mem);
    assert Fetch(code,22628) == Op(139,22629,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(34,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.SourceHead(data),4],mem);
    assert Fetch(code,22629) == Op(1,22630,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(35,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22630,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data))],mem);
    F.Push2(code,22630);
    assert Fetch(code,22630) == Op(97,22633,20617);
  }
  lemma Advance36(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(36,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22633,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),20617],mem);
    assert Fetch(code,22633) == Op(86,22634,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(37,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20617,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data))],mem);
    assert Fetch(code,20617) == Op(91,20618,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(38,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data))],mem);
    assert Fetch(code,20618) == Op(95,20619,0);
  }
  lemma Advance39(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(39,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20619,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0],mem);
    assert Fetch(code,20619) == Op(95,20620,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(40,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20620,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0],mem);
    assert Fetch(code,20620) == Op(131,20621,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(41,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20621,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|],mem);
    F.Push1(code,20621);
    assert Fetch(code,20621) == Op(96,20623,31);
  }
  lemma Advance42(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(42,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|,31],mem);
    assert Fetch(code,20623) == Op(132,20624,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(43,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20624,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|,31,I.Header(I.SourceHead(data))],mem);
    assert Fetch(code,20624) == Op(1,20625,0);
  }
  lemma Advance44(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(44,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20625,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,|data|,((I.Header(I.SourceHead(data)) as nat)+(31 as nat))%G.Modulus()],mem);
    assert Fetch(code,20625) == Op(18,20626,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(45,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,1],mem);
    F.Push2(code,20626);
    assert Fetch(code,20626) == Op(97,20629,20633);
  }
  lemma Advance46(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(46,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0,1,20633],mem);
    assert Fetch(code,20629) == Op(87,20630,0);
  }
  lemma Advance47(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(47,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20633,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0],mem);
    assert Fetch(code,20633) == Op(91,20634,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(48,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20634,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,0],mem);
    assert Fetch(code,20634) == Op(80,20635,0);
  }
  lemma Advance49(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(49,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20635,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0],mem);
    assert Fetch(code,20635) == Op(129,20636,0);
  }
  lemma Advance50(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(50,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20636,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.Header(I.SourceHead(data))],mem);
    assert Fetch(code,20636) == Op(53,20637,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(51,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20637,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data)],mem);
    F.Push1(code,20637);
    assert Fetch(code,20637) == Op(96,20639,1);
  }
  lemma Advance52(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(52,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20639,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1],mem);
    F.Push1(code,20639);
    assert Fetch(code,20639) == Op(96,20641,1);
  }
  lemma Advance53(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(53,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20641,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,1],mem);
    F.Push1(code,20641);
    assert Fetch(code,20641) == Op(96,20643,64);
  }
  lemma Advance54(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(54,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(55,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20643,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,20643) == Op(27,20644,0);
  }
  lemma Advance55(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(55,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(56,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20644,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,18446744073709551616],mem);
    assert Fetch(code,20644) == Op(3,20645,0);
  }
  lemma Advance56(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(56,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(57,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20645,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),18446744073709551615],mem);
    assert Fetch(code,20645) == Op(129,20646,0);
  }
  lemma Advance57(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(57,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(58,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20646,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),18446744073709551615,I.SourceLength(data)],mem);
    assert Fetch(code,20646) == Op(17,20647,0);
  }
  lemma Advance58(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(58,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(59,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20647,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),0],mem);
    assert Fetch(code,20647) == Op(21,20648,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(59,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(60,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20648,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1],mem);
    F.Push2(code,20648);
    assert Fetch(code,20648) == Op(97,20651,20655);
  }
  lemma Advance60(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(60,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(61,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20651,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),1,20655],mem);
    assert Fetch(code,20651) == Op(87,20652,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(61,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(62,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20655,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data)],mem);
    assert Fetch(code,20655) == Op(91,20656,0);
  }
  lemma Advance62(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(62,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(63,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20656,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data)],mem);
    F.Push1(code,20656);
    assert Fetch(code,20656) == Op(96,20658,32);
  }
  lemma Advance63(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(63,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(64,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20658,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),32],mem);
    assert Fetch(code,20658) == Op(131,20659,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(64,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(65,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20659,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),32,I.Header(I.SourceHead(data))],mem);
    I.Pointer(I.SourceHead(data));
    assert Fetch(code,20659) == Op(1,20660,0);
  }
  lemma Advance65(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(65,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(66,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20660,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),0,I.SourceLength(data),I.Offset(I.SourceHead(data))],mem);
    assert Fetch(code,20660) == Op(145,20661,0);
  }
  lemma Advance66(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(66,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(67,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20661,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),0],mem);
    assert Fetch(code,20661) == Op(80,20662,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(67,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(68,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20662,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem);
    assert Fetch(code,20662) == Op(131,20663,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(68,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(69,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20663,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|],mem);
    F.Push1(code,20663);
    assert Fetch(code,20663) == Op(96,20665,32);
  }
  lemma Advance69(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(69,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(70,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20665,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32],mem);
    assert Fetch(code,20665) == Op(130,20666,0);
  }
  lemma Advance70(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(70,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(71,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20666,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32,I.SourceLength(data)],mem);
    assert Fetch(code,20666) == Op(133,20667,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(71,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(72,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20667,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32,I.SourceLength(data),I.Header(I.SourceHead(data))],mem);
    assert Fetch(code,20667) == Op(1,20668,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(72,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(73,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20668,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,32,((I.Header(I.SourceHead(data)) as nat)+(I.SourceLength(data) as nat))%G.Modulus()],mem);
    assert Fetch(code,20668) == Op(1,20669,0);
  }
  lemma Advance73(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(73,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(74,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20669,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),|data|,((((I.Header(I.SourceHead(data)) as nat)+(I.SourceLength(data) as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,20669) == Op(17,20670,0);
  }
  lemma Advance74(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(74,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(75,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20670,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),0],mem);
    assert Fetch(code,20670) == Op(21,20671,0);
  }
  lemma Advance75(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(75,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(76,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20671,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),1],mem);
    F.Push2(code,20671);
    assert Fetch(code,20671) == Op(97,20674,20678);
  }
  lemma Advance76(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(76,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(77,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20674,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data),1,20678],mem);
    assert Fetch(code,20674) == Op(87,20675,0);
  }
  lemma Advance77(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(77,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(78,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20678,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem);
    assert Fetch(code,20678) == Op(91,20679,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(78,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(79,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20679,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,|data|,I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem);
    assert Fetch(code,20679) == Op(146,20680,0);
  }
  lemma Advance79(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(79,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(80,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20680,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,I.SourceLength(data),I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data)),|data|],mem);
    assert Fetch(code,20680) == Op(80,20681,0);
  }
  lemma Advance80(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(80,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(81,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20681,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),22634,I.SourceLength(data),I.Header(I.SourceHead(data)),I.Offset(I.SourceHead(data))],mem);
    assert Fetch(code,20681) == Op(146,20682,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(81,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(82,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20682,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Header(I.SourceHead(data)),22634],mem);
    assert Fetch(code,20682) == Op(144,20683,0);
  }
  lemma Advance82(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(82,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(83,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20683,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data),22634,I.Header(I.SourceHead(data))],mem);
    assert Fetch(code,20683) == Op(80,20684,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(83,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(84,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20684,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data),22634],mem);
    assert Fetch(code,20684) == Op(86,20685,0);
  }
  lemma Advance84(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(84,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(85,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22634,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem);
    assert Fetch(code,22634) == Op(91,22635,0);
  }
  lemma Advance85(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(85,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(86,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22635,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.Offset(I.SourceHead(data)),I.SourceLength(data)],mem);
    assert Fetch(code,22635) == Op(144,22636,0);
  }
  lemma Advance86(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(86,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(87,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22636,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,I.SourceHead(data),I.SourceLength(data),I.Offset(I.SourceHead(data))],mem);
    assert Fetch(code,22636) == Op(152,22637,0);
  }
  lemma Advance87(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(87,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(88,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22637,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),0,0,0,0,0,0,I.SourceHead(data),I.SourceLength(data),0],mem);
    assert Fetch(code,22637) == Op(80,22638,0);
  }
  lemma Advance88(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(88,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(89,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22638,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),0,0,0,0,0,0,I.SourceHead(data),I.SourceLength(data)],mem);
    assert Fetch(code,22638) == Op(150,22639,0);
  }
  lemma Advance89(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(89,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(90,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22639,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.SourceHead(data),0],mem);
    assert Fetch(code,22639) == Op(80,22640,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(90,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(91,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22640,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.SourceHead(data)],mem);
    F.Push2(code,22640);
    assert Fetch(code,22640) == Op(97,22643,22653);
  }
  lemma Advance91(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(91,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(92,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22643,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.SourceHead(data),22653],mem);
    assert Fetch(code,22643) == Op(144,22644,0);
  }
  lemma Advance92(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(92,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(93,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22644,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,I.SourceHead(data)],mem);
    assert Fetch(code,22644) == Op(80,22645,0);
  }
  lemma Advance93(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(93,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(94,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22645,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653],mem);
    F.Push1(code,22645);
    assert Fetch(code,22645) == Op(96,22647,32);
  }
  lemma Advance94(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(94,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(95,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22647,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,32],mem);
    assert Fetch(code,22647) == Op(137,22648,0);
  }
  lemma Advance95(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(95,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(96,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22648,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,32,4],mem);
    assert Fetch(code,22648) == Op(1,22649,0);
  }
  lemma Advance96(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(96,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(97,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22649,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36],mem);
    F.Push2(code,22649);
    assert Fetch(code,22649) == Op(97,22652,22096);
  }
  lemma Advance97(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(97,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(98,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22652,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,22096],mem);
    assert Fetch(code,22652) == Op(86,22653,0);
  }
  lemma Advance98(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(98,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(99,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22096,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36],mem);
    assert Fetch(code,22096) == Op(91,22097,0);
  }
  lemma Advance99(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(99,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(100,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22097,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36],mem);
    assert Fetch(code,22097) == Op(128,22098,0);
  }
  lemma Advance100(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(100,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(101,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22098,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,36],mem);
    assert Fetch(code,22098) == Op(53,22099,0);
  }
  lemma Advance101(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(101,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(102,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22099,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data)],mem);
    F.Push1(code,22099);
    assert Fetch(code,22099) == Op(96,22101,1);
  }
  lemma Advance102(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(102,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(103,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22101,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1],mem);
    F.Push1(code,22101);
    assert Fetch(code,22101) == Op(96,22103,1);
  }
  lemma Advance103(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(103,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(104,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22103,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,1],mem);
    F.Push1(code,22103);
    assert Fetch(code,22103) == Op(96,22105,160);
  }
  lemma Advance104(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(104,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(105,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22105,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,1,160],mem);
    A.Limit();
    assert Fetch(code,22105) == Op(27,22106,0);
  }
  lemma Advance105(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(105,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(106,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22106,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,1461501637330902918203684832716283019655932542976],mem);
    assert Fetch(code,22106) == Op(3,22107,0);
  }
  lemma Advance106(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(106,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(107,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22107,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1461501637330902918203684832716283019655932542975],mem);
    assert Fetch(code,22107) == Op(129,22108,0);
  }
  lemma Advance107(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(107,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(108,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22108,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1461501637330902918203684832716283019655932542975,I.Target(data)],mem);
    R.Address(I.Target(data));
    assert Fetch(code,22108) == Op(22,22109,0);
  }
  lemma Advance108(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(108,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(109,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22109,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),I.Target(data)],mem);
    assert Fetch(code,22109) == Op(129,22110,0);
  }
  lemma Advance109(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(109,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(110,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22110,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),I.Target(data),I.Target(data)],mem);
    assert Fetch(code,22110) == Op(20,22111,0);
  }
  lemma Advance110(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(110,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(111,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22111,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1],mem);
    F.Push2(code,22111);
    assert Fetch(code,22111) == Op(97,22114,21566);
  }
  lemma Advance111(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(111,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(112,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22114,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data),1,21566],mem);
    assert Fetch(code,22114) == Op(87,22115,0);
  }
  lemma Advance112(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(112,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(113,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21566,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data)],mem);
    assert Fetch(code,21566) == Op(91,21567,0);
  }
  lemma Advance113(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(113,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(114,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21567,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,22653,36,I.Target(data)],mem);
    assert Fetch(code,21567) == Op(145,21568,0);
  }
  lemma Advance114(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(114,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(115,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21568,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data),36,22653],mem);
    assert Fetch(code,21568) == Op(144,21569,0);
  }
  lemma Advance115(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(115,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(116,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21569,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data),22653,36],mem);
    assert Fetch(code,21569) == Op(80,21570,0);
  }
  lemma Advance116(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(116,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(117,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21570,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data),22653],mem);
    assert Fetch(code,21570) == Op(86,21571,0);
  }
  lemma Advance117(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(117,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(118,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22653,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data)],mem);
    assert Fetch(code,22653) == Op(91,22654,0);
  }
  lemma Advance118(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(118,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(119,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22654,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),0,0,0,0,0,I.Target(data)],mem);
    assert Fetch(code,22654) == Op(148,22655,0);
  }
  lemma Advance119(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(119,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(120,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22655,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,0],mem);
    assert Fetch(code,22655) == Op(80,22656,0);
  }
  lemma Advance120(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(120,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(121,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22656,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0],mem);
    F.Push1(code,22656);
    assert Fetch(code,22656) == Op(96,22658,64);
  }
  lemma Advance121(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(121,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(122,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22658,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,64],mem);
    assert Fetch(code,22658) == Op(136,22659,0);
  }
  lemma Advance122(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(122,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(123,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22659,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,64,4],mem);
    assert Fetch(code,22659) == Op(1,22660,0);
  }
  lemma Advance123(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(123,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(124,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22660,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,68],mem);
    assert Fetch(code,22660) == Op(53,22661,0);
  }
  lemma Advance124(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(124,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(125,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22661,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data)],mem);
    F.Push1(code,22661);
    assert Fetch(code,22661) == Op(96,22663,1);
  }
  lemma Advance125(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(125,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(126,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22663,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1],mem);
    F.Push1(code,22663);
    assert Fetch(code,22663) == Op(96,22665,1);
  }
  lemma Advance126(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(126,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(127,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22665,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,1],mem);
    F.Push1(code,22665);
    assert Fetch(code,22665) == Op(96,22667,64);
  }
  lemma Advance127(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(127,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(128,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22667,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,22667) == Op(27,22668,0);
  }
  lemma Advance128(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(128,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(129,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22668,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,18446744073709551616],mem);
    assert Fetch(code,22668) == Op(3,22669,0);
  }
  lemma Advance129(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(129,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(130,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22669,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),18446744073709551615],mem);
    assert Fetch(code,22669) == Op(129,22670,0);
  }
  lemma Advance130(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(130,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(131,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22670,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),18446744073709551615,I.TemplateHead(data)],mem);
    assert Fetch(code,22670) == Op(17,22671,0);
  }
  lemma Advance131(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(131,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(132,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22671,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),0],mem);
    assert Fetch(code,22671) == Op(21,22672,0);
  }
  lemma Advance132(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(132,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(133,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22672,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1],mem);
    F.Push2(code,22672);
    assert Fetch(code,22672) == Op(97,22675,22679);
  }
  lemma Advance133(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(133,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(134,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22675,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),1,22679],mem);
    assert Fetch(code,22675) == Op(87,22676,0);
  }
  lemma Advance134(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(134,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(135,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22679,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data)],mem);
    assert Fetch(code,22679) == Op(91,22680,0);
  }
  lemma Advance135(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(135,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(136,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22680,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data)],mem);
    F.Push2(code,22680);
    assert Fetch(code,22680) == Op(97,22683,22691);
  }
  lemma Advance136(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(136,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(137,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22683,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691],mem);
    assert Fetch(code,22683) == Op(138,22684,0);
  }
  lemma Advance137(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(137,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(138,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22684,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|],mem);
    assert Fetch(code,22684) == Op(130,22685,0);
  }
  lemma Advance138(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(138,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(139,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22685,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.TemplateHead(data)],mem);
    assert Fetch(code,22685) == Op(139,22686,0);
  }
  lemma Advance139(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(139,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(140,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22686,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.TemplateHead(data),4],mem);
    assert Fetch(code,22686) == Op(1,22687,0);
  }
  lemma Advance140(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(140,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(141,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22687,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data))],mem);
    F.Push2(code,22687);
    assert Fetch(code,22687) == Op(97,22690,20617);
  }
  lemma Advance141(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(141,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(142,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22690,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),20617],mem);
    assert Fetch(code,22690) == Op(86,22691,0);
  }
  lemma Advance142(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(142,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(143,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20617,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data))],mem);
    assert Fetch(code,20617) == Op(91,20618,0);
  }
  lemma Advance143(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(143,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(144,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20618,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data))],mem);
    assert Fetch(code,20618) == Op(95,20619,0);
  }
  lemma Advance144(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(144,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(145,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20619,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0],mem);
    assert Fetch(code,20619) == Op(95,20620,0);
  }
  lemma Advance145(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(145,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(146,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20620,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0],mem);
    assert Fetch(code,20620) == Op(131,20621,0);
  }
  lemma Advance146(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(146,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(147,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20621,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|],mem);
    F.Push1(code,20621);
    assert Fetch(code,20621) == Op(96,20623,31);
  }
  lemma Advance147(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(147,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(148,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20623,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|,31],mem);
    assert Fetch(code,20623) == Op(132,20624,0);
  }
  lemma Advance148(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(148,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(149,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20624,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|,31,I.Header(I.TemplateHead(data))],mem);
    assert Fetch(code,20624) == Op(1,20625,0);
  }
  lemma Advance149(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(149,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(150,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20625,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,|data|,((I.Header(I.TemplateHead(data)) as nat)+(31 as nat))%G.Modulus()],mem);
    assert Fetch(code,20625) == Op(18,20626,0);
  }
  lemma Advance150(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(150,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(151,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20626,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0],mem);
    F.Push2(code,20626);
    assert Fetch(code,20626) == Op(97,20629,20633);
  }
  lemma Advance151(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(151,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(152,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20629,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0,20633],mem);
    assert Fetch(code,20629) == Op(87,20630,0);
  }
  lemma Advance152(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(152,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(153,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20630,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0],mem);
    assert Fetch(code,20630) == Op(95,20631,0);
  }
  lemma Advance153(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(153,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(154,next,data,mem,prefix,returnPc)
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20631,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0],mem);
    assert Fetch(code,20631) == Op(95,20632,0);
  }
  lemma Advance154(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(154,state,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20632,prefix+[returnPc,|data|,4,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),0,0,0,0,I.TemplateHead(data),22691,|data|,I.Header(I.TemplateHead(data)),0,0,0,0],mem);
    assert Fetch(code,20632) == Op(253,20633,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word)
    requires I.ValidReturn(returnPc) && Admitted(data)
    ensures Good(0,Running(22579,prefix+[returnPc,|data|,4],mem),data,mem,prefix,returnPc)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(0,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures Good(20,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14]; state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18]; state := next18;
    Advance19(code,state,data,mem,prefix,returnPc,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19]; state := next19;
  }
  ghost method Block1(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(20,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures Good(40,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20]; state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21]; state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22]; state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23]; state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24]; state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25]; state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26]; state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27]; state := next27;
    Advance28(code,state,data,mem,prefix,returnPc,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28]; state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29]; state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30]; state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31]; state := next31;
    Advance32(code,state,data,mem,prefix,returnPc,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32]; state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33]; state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34]; state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35]; state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36]; state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37]; state := next37;
    Advance38(code,state,data,mem,prefix,returnPc,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);
    trace := trace+[next38]; state := next38;
    Advance39(code,state,data,mem,prefix,returnPc,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);
    trace := trace+[next39]; state := next39;
  }
  ghost method Block2(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(40,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures Good(60,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance40(code,state,data,mem,prefix,returnPc,value);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);
    trace := trace+[next40]; state := next40;
    Advance41(code,state,data,mem,prefix,returnPc,value);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);
    trace := trace+[next41]; state := next41;
    Advance42(code,state,data,mem,prefix,returnPc,value);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);
    trace := trace+[next42]; state := next42;
    Advance43(code,state,data,mem,prefix,returnPc,value);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);
    trace := trace+[next43]; state := next43;
    Advance44(code,state,data,mem,prefix,returnPc,value);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);
    trace := trace+[next44]; state := next44;
    Advance45(code,state,data,mem,prefix,returnPc,value);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);
    trace := trace+[next45]; state := next45;
    Advance46(code,state,data,mem,prefix,returnPc,value);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);
    trace := trace+[next46]; state := next46;
    Advance47(code,state,data,mem,prefix,returnPc,value);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);
    trace := trace+[next47]; state := next47;
    Advance48(code,state,data,mem,prefix,returnPc,value);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);
    trace := trace+[next48]; state := next48;
    Advance49(code,state,data,mem,prefix,returnPc,value);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);
    trace := trace+[next49]; state := next49;
    Advance50(code,state,data,mem,prefix,returnPc,value);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);
    trace := trace+[next50]; state := next50;
    Advance51(code,state,data,mem,prefix,returnPc,value);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);
    trace := trace+[next51]; state := next51;
    Advance52(code,state,data,mem,prefix,returnPc,value);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);
    trace := trace+[next52]; state := next52;
    Advance53(code,state,data,mem,prefix,returnPc,value);
    var next53 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);
    trace := trace+[next53]; state := next53;
    Advance54(code,state,data,mem,prefix,returnPc,value);
    var next54 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);
    trace := trace+[next54]; state := next54;
    Advance55(code,state,data,mem,prefix,returnPc,value);
    var next55 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55);
    trace := trace+[next55]; state := next55;
    Advance56(code,state,data,mem,prefix,returnPc,value);
    var next56 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56);
    trace := trace+[next56]; state := next56;
    Advance57(code,state,data,mem,prefix,returnPc,value);
    var next57 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57);
    trace := trace+[next57]; state := next57;
    Advance58(code,state,data,mem,prefix,returnPc,value);
    var next58 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58);
    trace := trace+[next58]; state := next58;
    Advance59(code,state,data,mem,prefix,returnPc,value);
    var next59 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59);
    trace := trace+[next59]; state := next59;
  }
  ghost method Block3(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(60,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures Good(80,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance60(code,state,data,mem,prefix,returnPc,value);
    var next60 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next60);
    trace := trace+[next60]; state := next60;
    Advance61(code,state,data,mem,prefix,returnPc,value);
    var next61 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next61);
    trace := trace+[next61]; state := next61;
    Advance62(code,state,data,mem,prefix,returnPc,value);
    var next62 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next62);
    trace := trace+[next62]; state := next62;
    Advance63(code,state,data,mem,prefix,returnPc,value);
    var next63 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next63);
    trace := trace+[next63]; state := next63;
    Advance64(code,state,data,mem,prefix,returnPc,value);
    var next64 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next64);
    trace := trace+[next64]; state := next64;
    Advance65(code,state,data,mem,prefix,returnPc,value);
    var next65 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next65);
    trace := trace+[next65]; state := next65;
    Advance66(code,state,data,mem,prefix,returnPc,value);
    var next66 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next66);
    trace := trace+[next66]; state := next66;
    Advance67(code,state,data,mem,prefix,returnPc,value);
    var next67 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next67);
    trace := trace+[next67]; state := next67;
    Advance68(code,state,data,mem,prefix,returnPc,value);
    var next68 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next68);
    trace := trace+[next68]; state := next68;
    Advance69(code,state,data,mem,prefix,returnPc,value);
    var next69 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next69);
    trace := trace+[next69]; state := next69;
    Advance70(code,state,data,mem,prefix,returnPc,value);
    var next70 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next70);
    trace := trace+[next70]; state := next70;
    Advance71(code,state,data,mem,prefix,returnPc,value);
    var next71 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next71);
    trace := trace+[next71]; state := next71;
    Advance72(code,state,data,mem,prefix,returnPc,value);
    var next72 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next72);
    trace := trace+[next72]; state := next72;
    Advance73(code,state,data,mem,prefix,returnPc,value);
    var next73 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next73);
    trace := trace+[next73]; state := next73;
    Advance74(code,state,data,mem,prefix,returnPc,value);
    var next74 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next74);
    trace := trace+[next74]; state := next74;
    Advance75(code,state,data,mem,prefix,returnPc,value);
    var next75 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next75);
    trace := trace+[next75]; state := next75;
    Advance76(code,state,data,mem,prefix,returnPc,value);
    var next76 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next76);
    trace := trace+[next76]; state := next76;
    Advance77(code,state,data,mem,prefix,returnPc,value);
    var next77 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next77);
    trace := trace+[next77]; state := next77;
    Advance78(code,state,data,mem,prefix,returnPc,value);
    var next78 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next78);
    trace := trace+[next78]; state := next78;
    Advance79(code,state,data,mem,prefix,returnPc,value);
    var next79 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next79);
    trace := trace+[next79]; state := next79;
  }
  ghost method Block4(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(80,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures Good(100,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance80(code,state,data,mem,prefix,returnPc,value);
    var next80 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next80);
    trace := trace+[next80]; state := next80;
    Advance81(code,state,data,mem,prefix,returnPc,value);
    var next81 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next81);
    trace := trace+[next81]; state := next81;
    Advance82(code,state,data,mem,prefix,returnPc,value);
    var next82 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next82);
    trace := trace+[next82]; state := next82;
    Advance83(code,state,data,mem,prefix,returnPc,value);
    var next83 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next83);
    trace := trace+[next83]; state := next83;
    Advance84(code,state,data,mem,prefix,returnPc,value);
    var next84 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next84);
    trace := trace+[next84]; state := next84;
    Advance85(code,state,data,mem,prefix,returnPc,value);
    var next85 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next85);
    trace := trace+[next85]; state := next85;
    Advance86(code,state,data,mem,prefix,returnPc,value);
    var next86 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next86);
    trace := trace+[next86]; state := next86;
    Advance87(code,state,data,mem,prefix,returnPc,value);
    var next87 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next87);
    trace := trace+[next87]; state := next87;
    Advance88(code,state,data,mem,prefix,returnPc,value);
    var next88 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next88);
    trace := trace+[next88]; state := next88;
    Advance89(code,state,data,mem,prefix,returnPc,value);
    var next89 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next89);
    trace := trace+[next89]; state := next89;
    Advance90(code,state,data,mem,prefix,returnPc,value);
    var next90 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next90);
    trace := trace+[next90]; state := next90;
    Advance91(code,state,data,mem,prefix,returnPc,value);
    var next91 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next91);
    trace := trace+[next91]; state := next91;
    Advance92(code,state,data,mem,prefix,returnPc,value);
    var next92 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next92);
    trace := trace+[next92]; state := next92;
    Advance93(code,state,data,mem,prefix,returnPc,value);
    var next93 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next93);
    trace := trace+[next93]; state := next93;
    Advance94(code,state,data,mem,prefix,returnPc,value);
    var next94 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next94);
    trace := trace+[next94]; state := next94;
    Advance95(code,state,data,mem,prefix,returnPc,value);
    var next95 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next95);
    trace := trace+[next95]; state := next95;
    Advance96(code,state,data,mem,prefix,returnPc,value);
    var next96 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next96);
    trace := trace+[next96]; state := next96;
    Advance97(code,state,data,mem,prefix,returnPc,value);
    var next97 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next97);
    trace := trace+[next97]; state := next97;
    Advance98(code,state,data,mem,prefix,returnPc,value);
    var next98 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next98);
    trace := trace+[next98]; state := next98;
    Advance99(code,state,data,mem,prefix,returnPc,value);
    var next99 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next99);
    trace := trace+[next99]; state := next99;
  }
  ghost method Block5(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(100,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures Good(120,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance100(code,state,data,mem,prefix,returnPc,value);
    var next100 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next100);
    trace := trace+[next100]; state := next100;
    Advance101(code,state,data,mem,prefix,returnPc,value);
    var next101 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next101);
    trace := trace+[next101]; state := next101;
    Advance102(code,state,data,mem,prefix,returnPc,value);
    var next102 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next102);
    trace := trace+[next102]; state := next102;
    Advance103(code,state,data,mem,prefix,returnPc,value);
    var next103 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next103);
    trace := trace+[next103]; state := next103;
    Advance104(code,state,data,mem,prefix,returnPc,value);
    var next104 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next104);
    trace := trace+[next104]; state := next104;
    Advance105(code,state,data,mem,prefix,returnPc,value);
    var next105 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next105);
    trace := trace+[next105]; state := next105;
    Advance106(code,state,data,mem,prefix,returnPc,value);
    var next106 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next106);
    trace := trace+[next106]; state := next106;
    Advance107(code,state,data,mem,prefix,returnPc,value);
    var next107 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next107);
    trace := trace+[next107]; state := next107;
    Advance108(code,state,data,mem,prefix,returnPc,value);
    var next108 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next108);
    trace := trace+[next108]; state := next108;
    Advance109(code,state,data,mem,prefix,returnPc,value);
    var next109 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next109);
    trace := trace+[next109]; state := next109;
    Advance110(code,state,data,mem,prefix,returnPc,value);
    var next110 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next110);
    trace := trace+[next110]; state := next110;
    Advance111(code,state,data,mem,prefix,returnPc,value);
    var next111 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next111);
    trace := trace+[next111]; state := next111;
    Advance112(code,state,data,mem,prefix,returnPc,value);
    var next112 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next112);
    trace := trace+[next112]; state := next112;
    Advance113(code,state,data,mem,prefix,returnPc,value);
    var next113 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next113);
    trace := trace+[next113]; state := next113;
    Advance114(code,state,data,mem,prefix,returnPc,value);
    var next114 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next114);
    trace := trace+[next114]; state := next114;
    Advance115(code,state,data,mem,prefix,returnPc,value);
    var next115 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next115);
    trace := trace+[next115]; state := next115;
    Advance116(code,state,data,mem,prefix,returnPc,value);
    var next116 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next116);
    trace := trace+[next116]; state := next116;
    Advance117(code,state,data,mem,prefix,returnPc,value);
    var next117 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next117);
    trace := trace+[next117]; state := next117;
    Advance118(code,state,data,mem,prefix,returnPc,value);
    var next118 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next118);
    trace := trace+[next118]; state := next118;
    Advance119(code,state,data,mem,prefix,returnPc,value);
    var next119 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next119);
    trace := trace+[next119]; state := next119;
  }
  ghost method Block6(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(120,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures Good(140,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance120(code,state,data,mem,prefix,returnPc,value);
    var next120 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next120);
    trace := trace+[next120]; state := next120;
    Advance121(code,state,data,mem,prefix,returnPc,value);
    var next121 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next121);
    trace := trace+[next121]; state := next121;
    Advance122(code,state,data,mem,prefix,returnPc,value);
    var next122 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next122);
    trace := trace+[next122]; state := next122;
    Advance123(code,state,data,mem,prefix,returnPc,value);
    var next123 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next123);
    trace := trace+[next123]; state := next123;
    Advance124(code,state,data,mem,prefix,returnPc,value);
    var next124 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next124);
    trace := trace+[next124]; state := next124;
    Advance125(code,state,data,mem,prefix,returnPc,value);
    var next125 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next125);
    trace := trace+[next125]; state := next125;
    Advance126(code,state,data,mem,prefix,returnPc,value);
    var next126 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next126);
    trace := trace+[next126]; state := next126;
    Advance127(code,state,data,mem,prefix,returnPc,value);
    var next127 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next127);
    trace := trace+[next127]; state := next127;
    Advance128(code,state,data,mem,prefix,returnPc,value);
    var next128 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next128);
    trace := trace+[next128]; state := next128;
    Advance129(code,state,data,mem,prefix,returnPc,value);
    var next129 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next129);
    trace := trace+[next129]; state := next129;
    Advance130(code,state,data,mem,prefix,returnPc,value);
    var next130 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next130);
    trace := trace+[next130]; state := next130;
    Advance131(code,state,data,mem,prefix,returnPc,value);
    var next131 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next131);
    trace := trace+[next131]; state := next131;
    Advance132(code,state,data,mem,prefix,returnPc,value);
    var next132 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next132);
    trace := trace+[next132]; state := next132;
    Advance133(code,state,data,mem,prefix,returnPc,value);
    var next133 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next133);
    trace := trace+[next133]; state := next133;
    Advance134(code,state,data,mem,prefix,returnPc,value);
    var next134 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next134);
    trace := trace+[next134]; state := next134;
    Advance135(code,state,data,mem,prefix,returnPc,value);
    var next135 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next135);
    trace := trace+[next135]; state := next135;
    Advance136(code,state,data,mem,prefix,returnPc,value);
    var next136 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next136);
    trace := trace+[next136]; state := next136;
    Advance137(code,state,data,mem,prefix,returnPc,value);
    var next137 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next137);
    trace := trace+[next137]; state := next137;
    Advance138(code,state,data,mem,prefix,returnPc,value);
    var next138 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next138);
    trace := trace+[next138]; state := next138;
    Advance139(code,state,data,mem,prefix,returnPc,value);
    var next139 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next139);
    trace := trace+[next139]; state := next139;
  }
  ghost method Block7(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && Good(140,initial,data,mem,prefix,returnPc) && |prefix| <= 1004
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance140(code,state,data,mem,prefix,returnPc,value);
    var next140 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next140);
    trace := trace+[next140]; state := next140;
    Advance141(code,state,data,mem,prefix,returnPc,value);
    var next141 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next141);
    trace := trace+[next141]; state := next141;
    Advance142(code,state,data,mem,prefix,returnPc,value);
    var next142 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next142);
    trace := trace+[next142]; state := next142;
    Advance143(code,state,data,mem,prefix,returnPc,value);
    var next143 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next143);
    trace := trace+[next143]; state := next143;
    Advance144(code,state,data,mem,prefix,returnPc,value);
    var next144 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next144);
    trace := trace+[next144]; state := next144;
    Advance145(code,state,data,mem,prefix,returnPc,value);
    var next145 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next145);
    trace := trace+[next145]; state := next145;
    Advance146(code,state,data,mem,prefix,returnPc,value);
    var next146 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next146);
    trace := trace+[next146]; state := next146;
    Advance147(code,state,data,mem,prefix,returnPc,value);
    var next147 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next147);
    trace := trace+[next147]; state := next147;
    Advance148(code,state,data,mem,prefix,returnPc,value);
    var next148 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next148);
    trace := trace+[next148]; state := next148;
    Advance149(code,state,data,mem,prefix,returnPc,value);
    var next149 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next149);
    trace := trace+[next149]; state := next149;
    Advance150(code,state,data,mem,prefix,returnPc,value);
    var next150 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next150);
    trace := trace+[next150]; state := next150;
    Advance151(code,state,data,mem,prefix,returnPc,value);
    var next151 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next151);
    trace := trace+[next151]; state := next151;
    Advance152(code,state,data,mem,prefix,returnPc,value);
    var next152 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next152);
    trace := trace+[next152]; state := next152;
    Advance153(code,state,data,mem,prefix,returnPc,value);
    var next153 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next153);
    trace := trace+[next153]; state := next153;
    Advance154(code,state,data,mem,prefix,returnPc,value);
    var next154 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next154);
    trace := trace+[next154]; state := next154;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires I.ValidReturn(returnPc) && Matches(code) && Admitted(data) && |prefix| <= 1004
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 156 && trace[0] == Running(22579,prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc);
    state := Running(22579,prefix+[returnPc,|data|,4],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block3(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block4(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block5(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block6(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block7(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
