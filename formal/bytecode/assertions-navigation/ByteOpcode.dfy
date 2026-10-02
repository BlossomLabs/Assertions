// SPDX-License-Identifier: MIT
// BYTE(0,CALLDATALOAD) reads the first byte of a zero-padded word.
include "../assertions-machine/Bytes.dfy"
module AssertionsNavigationByteOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = AssertionsByteMachine
  lemma Encoding(bs: seq<S.Byte>)
    ensures G.Encode(G.Decode(bs),|bs|) == bs
    decreases |bs|
  {
    if |bs| > 0 {
      Encoding(bs[..|bs|-1]);
      assert G.Decode(bs)/256 == G.Decode(bs[..|bs|-1]);
      assert G.Decode(bs)%256 == bs[|bs|-1];
    }
  }
  lemma Read(data: seq<S.Byte>,offset: S.Word)
    ensures B.ByteAt(0,S.DataWord(data,offset)) ==
            (if offset < |data| then data[offset] else 0)
  {
    var bytes := S.Window(data,offset,32);
    Encoding(bytes);
    assert |bytes| == 32;
    G.DecodeBound(bytes);
    G.WordPower();
    assert S.DataWord(data,offset) == G.Decode(bytes);
    assert bytes[0] == (if offset < |data| then data[offset] else 0);
  }
}
