// SPDX-License-Identifier: MIT
// Exact OR bound for the compiled fixed-array footprint guard.
include "../../word-apply/word-conversion/Conversion.generated.dfy"
include "../../scans/Machine.dfy"
module BytecodeCollectionsArrayWordBound {
  import G = BytecodeGetterMachine
  import WC = BytecodeApplyWordConversion
  function Bound(): nat { 0x100000000 }
  lemma BitOrBound(left: bv256,right: bv256)
    requires left < 0x100000000 && right < 0x100000000
    ensures (left | right) < 0x100000000
  {}
  lemma NatBound(bits: bv256)
    requires bits < 0x100000000
    ensures (bits as nat) < Bound()
  {}
  lemma NatAtLeast(bits: bv256)
    requires bits >= 0x100000000
    ensures (bits as nat) >= Bound()
  {}
  lemma WordIdentity(a: G.Word)
    ensures ((a as bv256) as nat) == a
  { WC.Nat256(a); }
  lemma BelowBits(a: G.Word)
    requires a < Bound()
    ensures (a as bv256) < 0x100000000
  {
    WordIdentity(a);
    if (a as bv256) >= 0x100000000 {
      NatAtLeast(a as bv256);assert false;
    }
  }
  lemma Definition(a: G.Word,b: G.Word)
    ensures G.BitOr(a,b) == (((a as bv256) | (b as bv256)) as nat)
  {}
  lemma OrBound(a: G.Word,b: G.Word)
    requires a < Bound() && b < Bound()
    ensures G.BitOr(a,b) < Bound()
  {
    hide G.BitOr();
    BelowBits(a);BelowBits(b);
    Definition(a,b);
    BitOrBound(a as bv256,b as bv256);
    NatBound((a as bv256)|(b as bv256));
  }
}
