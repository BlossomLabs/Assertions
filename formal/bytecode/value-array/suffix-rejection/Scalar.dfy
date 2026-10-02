// SPDX-License-Identifier: MIT
// Exact uint32 overflow detection for the compiled full-width OR guard.
include "../word-bound/Scalar.dfy"
module BytecodeCollectionsSuffixRejectionScalar {
  import G = BytecodeGetterMachine
  import W = BytecodeCollectionsArrayWordBound
  lemma BitOrWide(left: bv256,right: bv256)
    requires left >= 0x100000000 || right >= 0x100000000
    ensures (left | right) >= 0x100000000
  {}
  lemma AboveBits(a: G.Word)
    requires a >= W.Bound()
    ensures (a as bv256) >= 0x100000000
  {
    W.WordIdentity(a);
    if (a as bv256) < 0x100000000 {
      W.NatBound(a as bv256);assert false;
    }
  }
  lemma OrWide(a: G.Word,b: G.Word)
    requires a >= W.Bound() || b >= W.Bound()
    ensures G.BitOr(a,b) >= W.Bound()
  {
    hide G.BitOr();
    if a >= W.Bound() { AboveBits(a); }
    else { AboveBits(b); }
    W.Definition(a,b);BitOrWide(a as bv256,b as bv256);
    W.NatAtLeast((a as bv256)|(b as bv256));
  }
}
