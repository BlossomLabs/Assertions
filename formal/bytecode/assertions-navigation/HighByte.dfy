// SPDX-License-Identifier: MIT
// Constructive high-byte word projection for calldata descriptor reads.
include "Conversion.dfy"
include "Shift.dfy"
include "development/join-probe-v1/Join.dfy"
module AssertionsNavigationHighByte {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = AssertionsNavigationConversion
  import W = AssertionsNavigationShift
  import J = AssertionsNavigationJoinProbe
  type Byte = S.Byte
  type Word = S.Word
  lemma Widen62(bits: bv62)
    ensures ((bits as bv64) as nat) == (bits as nat)
  {}
  lemma Nat62(value: nat)
    requires value < 0x4000000000000000
    ensures (value as bv62) as nat == value
  {
    C.Nat64(value);
    var wide := value as bv64;
    assert wide < 0x4000000000000000;
    assert ((wide as bv62) as bv64) == wide;
    Widen62(wide as bv62);
  }
  function Join124(high: bv62,low: bv62): bv124 { ((high as bv124)<<62) | (low as bv124) }
  lemma Join124Nat(high: bv62,low: bv62)
    ensures (Join124(high,low) as nat) == 0x4000000000000000*(high as nat)+(low as nat)
  { J.Join124(high,low); }
  lemma Inverse124(bits: bv124)
    ensures ((bits as nat) as bv124) == bits
  {}
  lemma Nat124(value: nat)
    requires value < 0x10000000000000000000000000000000
    ensures (value as bv124) as nat == value
  {
    var high := value/0x4000000000000000; var low := value%0x4000000000000000;
    Nat62(high); Nat62(low);
    Join124Nat(high as bv62,low as bv62);
    var bits := Join124(high as bv62,low as bv62);
    assert (bits as nat) == value;
    Inverse124(bits);
  }
  function Join248(high: bv124,low: bv124): bv248 { ((high as bv248)<<124) | (low as bv248) }
  lemma Join248Nat(high: bv124,low: bv124)
    ensures (Join248(high,low) as nat) == 0x10000000000000000000000000000000*(high as nat)+(low as nat)
  { J.Join248(high,low); }
  lemma Inverse248(bits: bv248)
    ensures ((bits as nat) as bv248) == bits
  {}
  lemma Nat248(value: nat)
    requires value < 0x100000000000000000000000000000000000000000000000000000000000000
    ensures (value as bv248) as nat == value
  {
    var high := value/0x10000000000000000000000000000000; var low := value%0x10000000000000000000000000000000;
    Nat124(high); Nat124(low);
    Join248Nat(high as bv124,low as bv124);
    var bits := Join248(high as bv124,low as bv124);
    assert (bits as nat) == value;
    Inverse248(bits);
  }
  function Join256(high: bv8,low: bv248): bv256 { ((high as bv256)<<248) | (low as bv256) }
  lemma Join256Nat(high: bv8,low: bv248)
    ensures (Join256(high,low) as nat) == 0x100000000000000000000000000000000000000000000000000000000000000*(high as nat)+(low as nat)
  { J.Join256(high,low); }
  lemma MaskBits(high: bv8,low: bv248)
    ensures (Join256(high,low) & 0xff00000000000000000000000000000000000000000000000000000000000000) == ((high as bv256)<<248)
  {}
  lemma AndDefinition(value: Word,mask: Word)
    ensures G.BitAnd(value,mask) == (((value as bv256)&(mask as bv256)) as nat)
  { reveal G.BitAnd(); }
  lemma MaskValue() returns (mask: Word)
    ensures mask == 0xff00000000000000000000000000000000000000000000000000000000000000
    ensures (mask as bv256) == 0xff00000000000000000000000000000000000000000000000000000000000000
  {
    J.Join256(255,0);
    var bits: bv256 := 0xff00000000000000000000000000000000000000000000000000000000000000;
    assert bits == ((255 as bv256)<<248);
    assert (bits as nat) == 0xff00000000000000000000000000000000000000000000000000000000000000;
    W.Inverse256(bits);
    mask := bits as nat;
  }
  lemma AndBridge(value: Word,mask: Word,bits: bv256,result: Word)
    requires ((value as bv256)&(mask as bv256)) == bits
    requires (bits as nat) == result
    ensures G.BitAnd(value,mask) == result
  {
    hide G.BitAnd();
    W.NatEquality((value as bv256)&(mask as bv256),bits);
    AndDefinition(value,mask);
  }
  lemma Mask(high: Byte,low: nat)
    requires low < 0x100000000000000000000000000000000000000000000000000000000000000
    ensures G.BitAnd(high*0x100000000000000000000000000000000000000000000000000000000000000+low,0xff00000000000000000000000000000000000000000000000000000000000000) == high*0x100000000000000000000000000000000000000000000000000000000000000
  {
    hide G.BitAnd();
    C.Nat8(high); Nat248(low);
    Join256Nat(high as bv8,low as bv248);
    var bits := Join256(high as bv8,low as bv248);
    assert (bits as nat) == high*0x100000000000000000000000000000000000000000000000000000000000000+low;
    W.Inverse256(bits);
    MaskBits(high as bv8,low as bv248);
    J.Join256(high as bv8,0);
    var output := (high as bv256)<<248;
    assert (output as nat) == high*0x100000000000000000000000000000000000000000000000000000000000000;
    var value: Word := high*0x100000000000000000000000000000000000000000000000000000000000000+low;
    var result: Word := high*0x100000000000000000000000000000000000000000000000000000000000000;
    var mask := MaskValue();
    AndBridge(value,mask,output,result);
  }
}
