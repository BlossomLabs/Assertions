// SPDX-License-Identifier: MIT
// Fixed physical scanner constants, isolated from calldata and bytecode contexts.
include "HighByte.dfy"
module AssertionsNavigationConstants {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = AssertionsNavigationHighByte
  import W = AssertionsNavigationShift
  import J = AssertionsNavigationJoinProbe
  lemma Max62()
    ensures ((0x3fffffffffffffff as bv62) as nat) == 0x3fffffffffffffff
  {}
  lemma NotBridge(input: S.Word,bits: bv256,result: S.Word)
    requires !(input as bv256) == bits && (bits as nat) == result
    ensures S.BitNot(input) == result
  { W.NatEquality(!(input as bv256),bits); }
  lemma LowMask()
    ensures S.BitNot(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) == 0xff00000000000000000000000000000000000000000000000000000000000000
  {
    hide S.BitNot();
    Max62();
    var b62: bv62 := 0x3fffffffffffffff;
    J.Join124(b62,b62);
    var b124: bv124 := ((b62 as bv124)<<62)|(b62 as bv124);
    assert (b124 as nat) == 0xfffffffffffffffffffffffffffffff;
    J.Join248(b124,b124);
    var b248: bv248 := ((b124 as bv248)<<124)|(b124 as bv248);
    assert (b248 as nat) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    J.Join256(0,b248);
    var low: bv256 := b248 as bv256;
    assert (low as nat) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    W.Inverse256(low);
    var mask := H.MaskValue();
    assert !low == (mask as bv256);
    NotBridge(low as nat,mask as bv256,mask);
  }
  lemma AllOnes()
    ensures S.BitNot(0) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  {}
}
