// SPDX-License-Identifier: MIT
// Base-name classification admits arbitrary scanner names; only bytes/string are dynamic.
include "ByteOpcode.dfy"
module AssertionsNavigationNameClass {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = AssertionsNavigationByteOpcode
  predicate Dynamic(name: seq<S.Byte>) {
    name == [98,121,116,101,115] || name == [115,116,114,105,110,103]
  }
  lemma Step(bs: seq<S.Byte>)
    requires |bs| > 0
    ensures G.Decode(bs) == G.Decode(bs[..|bs|-1])*256+bs[|bs|-1]
  {}
  lemma Inject(left: seq<S.Byte>,right: seq<S.Byte>)
    requires |left| == |right| && G.Decode(left) == G.Decode(right)
    ensures left == right
  { R.Encoding(left); R.Encoding(right); }
  lemma Five(name: seq<S.Byte>)
    requires |name| == 5
    ensures (G.Decode(name) == 0x6279746573) == Dynamic(name)
  {
    var bytes: seq<S.Byte> := [98,121,116,101,115];
    Step(bytes[..1]);
    assert bytes[..1][..0] == bytes[..0];
    assert G.Decode(bytes[..1]) == G.Decode(bytes[..0])*256+bytes[0];
    assert G.Decode(bytes[..1]) == 98;
    Step(bytes[..2]);
    assert bytes[..2][..1] == bytes[..1];
    assert G.Decode(bytes[..2]) == G.Decode(bytes[..1])*256+bytes[1];
    assert G.Decode(bytes[..2]) == 25209;
    Step(bytes[..3]);
    assert bytes[..3][..2] == bytes[..2];
    assert G.Decode(bytes[..3]) == G.Decode(bytes[..2])*256+bytes[2];
    assert G.Decode(bytes[..3]) == 6453620;
    Step(bytes[..4]);
    assert bytes[..4][..3] == bytes[..3];
    assert G.Decode(bytes[..4]) == G.Decode(bytes[..3])*256+bytes[3];
    assert G.Decode(bytes[..4]) == 1652126821;
    Step(bytes[..5]);
    assert bytes[..5][..4] == bytes[..4];
    assert G.Decode(bytes[..5]) == G.Decode(bytes[..4])*256+bytes[4];
    assert G.Decode(bytes[..5]) == 422944466291;
    assert G.Decode(bytes) == 0x6279746573;
    if G.Decode(name) == 0x6279746573 { Inject(name,bytes); }
  }
  lemma Six(name: seq<S.Byte>)
    requires |name| == 6
    ensures (G.Decode(name) == 0x737472696e67) == Dynamic(name)
  {
    var bytes: seq<S.Byte> := [115,116,114,105,110,103];
    Step(bytes[..1]);
    assert bytes[..1][..0] == bytes[..0];
    assert G.Decode(bytes[..1]) == G.Decode(bytes[..0])*256+bytes[0];
    assert G.Decode(bytes[..1]) == 115;
    Step(bytes[..2]);
    assert bytes[..2][..1] == bytes[..1];
    assert G.Decode(bytes[..2]) == G.Decode(bytes[..1])*256+bytes[1];
    assert G.Decode(bytes[..2]) == 29556;
    Step(bytes[..3]);
    assert bytes[..3][..2] == bytes[..2];
    assert G.Decode(bytes[..3]) == G.Decode(bytes[..2])*256+bytes[2];
    assert G.Decode(bytes[..3]) == 7566450;
    Step(bytes[..4]);
    assert bytes[..4][..3] == bytes[..3];
    assert G.Decode(bytes[..4]) == G.Decode(bytes[..3])*256+bytes[3];
    assert G.Decode(bytes[..4]) == 1937011305;
    Step(bytes[..5]);
    assert bytes[..5][..4] == bytes[..4];
    assert G.Decode(bytes[..5]) == G.Decode(bytes[..4])*256+bytes[4];
    assert G.Decode(bytes[..5]) == 495874894190;
    Step(bytes[..6]);
    assert bytes[..6][..5] == bytes[..5];
    assert G.Decode(bytes[..6]) == G.Decode(bytes[..5])*256+bytes[5];
    assert G.Decode(bytes[..6]) == 126943972912743;
    assert G.Decode(bytes) == 0x737472696e67;
    if G.Decode(name) == 0x737472696e67 { Inject(name,bytes); }
  }
  lemma Other(name: seq<S.Byte>)
    requires |name| != 5 && |name| != 6
    ensures !Dynamic(name)
  {}
}
