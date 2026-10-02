// SPDX-License-Identifier: MIT
// Small independent calldata tuple-bounds constants used by validator indexing.
include "DecoderScalar.dfy"
module AssertionsConstraintLoopScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = BytecodeScanScalar
  import D = AssertionsConstraintDecoderScalar
  lemma Complement31() ensures S.BitNot(31) == G.Modulus()-32 { D.Complement31(); }
  lemma Complement62() ensures S.BitNot(62) == G.Modulus()-63 { P.Narrow(62); }
}
