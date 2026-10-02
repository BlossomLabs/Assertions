// SPDX-License-Identifier: MIT
// Small scalar kernels for the physical calldata Constraint allocator.
include "../../assertions-primitives-control/math/Mask.dfy"
include "../../scans/DecoderScalar.dfy"
module AssertionsConstraintDecoderScalar {
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import P = BytecodeScanScalar
  lemma Complement31()
    ensures S.BitNot(31) == G.Modulus()-32
  { P.Narrow(31); }
  lemma BoolOr(a: G.Word, b: G.Word)
    requires a <= 1 && b <= 1
    ensures G.BitOr(a,b) == (if a == 0 && b == 0 then 0 else 1)
  { reveal G.BitOr(); }
}
