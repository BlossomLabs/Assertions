// SPDX-License-Identifier: MIT
// Exact uint8 masks reached by typeShape's decimal array-size scanner.
include "Conversion.dfy"
include "HighByte.dfy"
module AssertionsNavigationArrayByteMask {
  import G = BytecodeGetterMachine
  import C = AssertionsNavigationConversion
  import H = AssertionsNavigationHighByte
  lemma Widen(bits: bv8)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  lemma MaskBits(bits: bv8)
    ensures ((bits as bv256) & 255) == (bits as bv256)
  {}
  lemma Mask(value: G.Word)
    requires value < 256
    ensures G.BitAnd(value,255) == value
    ensures G.BitAnd(255,value) == value
  {
    C.Nat8(value); C.Nat8(255);
    var small := value as bv8;
    var mask := 255 as bv8;
    Widen(small); Widen(mask);
    assert (small as bv256) == (value as bv256);
    assert (mask as bv256) == (255 as bv256);
    MaskBits(small);
    H.AndDefinition(value,255); H.AndDefinition(255,value);
  }
}
