// SPDX-License-Identifier: MIT
// Independent first-byte decomposition of a zero-padded calldata word.
include "../scans/Machine.dfy"
module AssertionsNavigationWordHead {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Byte = S.Byte
  type Word = S.Word
  lemma Head(bs: seq<Byte>)
    requires |bs| > 0
    ensures G.Decode(bs) == bs[0]*G.Pow256(|bs|-1)+G.Decode(bs[1..])
    decreases |bs|
  {
    if |bs| == 1 {
      assert bs == [bs[0]];
    } else {
      Head(bs[..|bs|-1]);
      assert bs[..|bs|-1][1..] == bs[1..][..|bs|-2];
    }
  }
  lemma Calldata(data: seq<Byte>,offset: Word)
    requires offset < |data|
    ensures S.DataWord(data,offset) == data[offset]*0x100000000000000000000000000000000000000000000000000000000000000+G.Decode(S.Window(data,offset,32)[1..])
    ensures G.Decode(S.Window(data,offset,32)[1..]) < 0x100000000000000000000000000000000000000000000000000000000000000
  {
    var bytes := S.Window(data,offset,32);
    G.WordPower();
    Head(bytes);
    G.DecodeBound(bytes);
    G.DecodeBound(bytes[1..]);
    assert G.Pow256(31) == 0x100000000000000000000000000000000000000000000000000000000000000;
    assert bytes[0] == data[offset];
  }
}
