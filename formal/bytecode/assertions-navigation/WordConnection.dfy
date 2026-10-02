// SPDX-License-Identifier: MIT
include "development/full-dest-v6/word/WordSuccess.generated.dfy"
include "development/full-dest-v8/word/WordPast.generated.dfy"
include "development/full-dest-v8/word/WordShort.generated.dfy"
module AssertionsNavigationWordConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import C0 = AssertionsNavigationWordSuccess
  import C1 = AssertionsNavigationWordPast
  import C2 = AssertionsNavigationWordShort
  ghost method Execute(code: seq<S.Byte>, ptr: S.Word, length: S.Word, pos: S.Word, word: S.Word, free: S.Word, ret: S.Word, prefix: seq<S.Word>, mem: seq<S.Byte>, value: S.Word, data: seq<S.Byte>) returns (state: S.State, trace: seq<S.State>)
    requires C0.Matches(code) && C0.ValidReturn(ret)
    requires C1.Matches(code) && C1.ValidReturn(ret)
    requires C2.Matches(code) && C2.ValidReturn(ret)
    requires |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && S.Load(mem,64) == free
    requires 128 <= free && (free as nat)+96 < G.Modulus()
    requires (ptr as nat)+32+(length as nat) <= |mem| && S.Load(mem,ptr) == length
    requires ret < |code| && code[ret] == 0x5b && |prefix| <= 980
    requires pos <= length && length-pos >= 32 ==> S.Load(mem,(ptr as nat)+32+(pos as nat)) == word
    ensures pos <= length && length-pos >= 32 ==> state == S.Running(ret,prefix+[word],mem)
    ensures pos > length || length-pos < 32 ==> state == S.Reverted(G.Encode(3586884662,4)+G.Encode(pos/32,32)+G.Encode(length,32))
    ensures E.Trace(code,C0.Destinations(ret),value,data,trace)
    ensures trace[0] == S.Running(8130,prefix+[ret,ptr,pos],mem) && trace[|trace|-1] == state
  {
    assert C0.Destinations(ret) == C1.Destinations(ret) by {
      reveal C0.Destinations(); reveal C1.Destinations();
      assert C0.DestinationChunk0() == C1.DestinationChunk0();
      assert C0.DestinationChunk1() == C1.DestinationChunk1();
      assert C0.DestinationChunk2() == C1.DestinationChunk2();
      assert C0.DestinationChunk3() == C1.DestinationChunk3();
      assert C0.DestinationChunk4() == C1.DestinationChunk4();
      assert C0.DestinationChunk5() == C1.DestinationChunk5();
      assert C0.DestinationChunk6() == C1.DestinationChunk6();
      assert C0.DestinationChunk7() == C1.DestinationChunk7();
      assert C0.DestinationChunk8() == C1.DestinationChunk8();
      assert C0.DestinationChunk9() == C1.DestinationChunk9();
      assert C0.DestinationChunk10() == C1.DestinationChunk10();
      assert C0.DestinationChunk11() == C1.DestinationChunk11();
      assert C0.DestinationChunk12() == C1.DestinationChunk12();
      assert C0.DestinationChunk13() == C1.DestinationChunk13();
      assert C0.DestinationChunk14() == C1.DestinationChunk14();
      assert C0.DestinationChunk15() == C1.DestinationChunk15();
      assert C0.DestinationChunk16() == C1.DestinationChunk16();
      assert C0.DestinationChunk17() == C1.DestinationChunk17();
      assert C0.DestinationChunk18() == C1.DestinationChunk18();
      assert C0.DestinationChunk19() == C1.DestinationChunk19();
      assert C0.DestinationChunk20() == C1.DestinationChunk20();
      assert C0.DestinationChunk21() == C1.DestinationChunk21();
      assert C0.DestinationChunk22() == C1.DestinationChunk22();
      assert C0.DestinationChunk23() == C1.DestinationChunk23();
      assert C0.DestinationChunk24() == C1.DestinationChunk24();
      assert C0.DestinationChunk25() == C1.DestinationChunk25();
      assert C0.DestinationChunk26() == C1.DestinationChunk26();
      assert C0.DestinationChunk27() == C1.DestinationChunk27();
      assert C0.DestinationChunk28() == C1.DestinationChunk28();
      assert C0.DestinationChunk29() == C1.DestinationChunk29();
      assert C0.DestinationChunk30() == C1.DestinationChunk30();
      assert C0.DestinationChunk31() == C1.DestinationChunk31();
      assert C0.DestinationChunk32() == C1.DestinationChunk32();
    }
    assert C0.Destinations(ret) == C2.Destinations(ret) by {
      reveal C0.Destinations(); reveal C2.Destinations();
      assert C0.DestinationChunk0() == C2.DestinationChunk0();
      assert C0.DestinationChunk1() == C2.DestinationChunk1();
      assert C0.DestinationChunk2() == C2.DestinationChunk2();
      assert C0.DestinationChunk3() == C2.DestinationChunk3();
      assert C0.DestinationChunk4() == C2.DestinationChunk4();
      assert C0.DestinationChunk5() == C2.DestinationChunk5();
      assert C0.DestinationChunk6() == C2.DestinationChunk6();
      assert C0.DestinationChunk7() == C2.DestinationChunk7();
      assert C0.DestinationChunk8() == C2.DestinationChunk8();
      assert C0.DestinationChunk9() == C2.DestinationChunk9();
      assert C0.DestinationChunk10() == C2.DestinationChunk10();
      assert C0.DestinationChunk11() == C2.DestinationChunk11();
      assert C0.DestinationChunk12() == C2.DestinationChunk12();
      assert C0.DestinationChunk13() == C2.DestinationChunk13();
      assert C0.DestinationChunk14() == C2.DestinationChunk14();
      assert C0.DestinationChunk15() == C2.DestinationChunk15();
      assert C0.DestinationChunk16() == C2.DestinationChunk16();
      assert C0.DestinationChunk17() == C2.DestinationChunk17();
      assert C0.DestinationChunk18() == C2.DestinationChunk18();
      assert C0.DestinationChunk19() == C2.DestinationChunk19();
      assert C0.DestinationChunk20() == C2.DestinationChunk20();
      assert C0.DestinationChunk21() == C2.DestinationChunk21();
      assert C0.DestinationChunk22() == C2.DestinationChunk22();
      assert C0.DestinationChunk23() == C2.DestinationChunk23();
      assert C0.DestinationChunk24() == C2.DestinationChunk24();
      assert C0.DestinationChunk25() == C2.DestinationChunk25();
      assert C0.DestinationChunk26() == C2.DestinationChunk26();
      assert C0.DestinationChunk27() == C2.DestinationChunk27();
      assert C0.DestinationChunk28() == C2.DestinationChunk28();
      assert C0.DestinationChunk29() == C2.DestinationChunk29();
      assert C0.DestinationChunk30() == C2.DestinationChunk30();
      assert C0.DestinationChunk31() == C2.DestinationChunk31();
      assert C0.DestinationChunk32() == C2.DestinationChunk32();
    }
    if pos > length {
      state,trace := C1.Run(code,ptr,length,pos,word,free,ret,prefix,mem,value,data);
    } else if length-pos < 32 {
      state,trace := C2.Run(code,ptr,length,pos,word,free,ret,prefix,mem,value,data);
    } else {
      state,trace := C0.Run(code,ptr,length,pos,word,free,ret,prefix,mem,value,data);
    }
  }
}
