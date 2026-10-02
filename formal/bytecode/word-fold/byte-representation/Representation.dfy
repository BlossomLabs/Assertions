// SPDX-License-Identifier: MIT
// First raw byte projection, including the final source byte and zero-filled calldata tail.
include "Shift.generated.dfy"
include "../../scans/Machine.dfy"
module BytecodeFoldByteRepresentation {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import V = BytecodeApplyWordConversion
  import B = BytecodeFoldByteShift
  lemma Head(bs: seq<Byte>)
    requires 0 < |bs|
    ensures G.Decode(bs) == bs[0]*G.Pow256(|bs|-1)+G.Decode(bs[1..])
    decreases |bs|
  {
    if |bs| > 1 {
      Head(bs[..|bs|-1]);
      assert bs[..|bs|-1][1..] == bs[1..][..|bs|-2];
      assert G.Decode(bs[1..]) == G.Decode(bs[1..][..|bs|-2])*256+bs[|bs|-1];
    }
  }
  lemma First(data: seq<Byte>,offset: Word)
    requires offset < |data|
    ensures ShiftRight(DataWord(data,offset),248) == data[offset]
  {
    var bytes := Window(data,offset,32);
    Head(bytes); G.WordPower(); G.DecodeBound(bytes); G.DecodeBound(bytes[1..]);
    assert bytes[0] == data[offset];
    assert G.Pow256(31) == 452312848583266388373324160190187140051835877600158453279131187530910662656;
    var word := DataWord(data,offset);
    assert word == G.Decode(bytes);
    assert word/452312848583266388373324160190187140051835877600158453279131187530910662656 == data[offset];
    V.Nat256(word); B.Top256(word as bv256);
  }
  lemma Source(data: seq<Byte>,sourceOffset: Word,sourceLength: Word,index: Word)
    requires (sourceOffset as nat)+sourceLength <= |data| < G.Modulus() && index < sourceLength
    ensures ShiftRight(DataWord(data,sourceOffset+index),248) == data[sourceOffset+index]
  { First(data,sourceOffset+index); }
}
