// SPDX-License-Identifier: MIT
// Independent canonical-word rule versus actual EVM shift/sign-extension checks.
include "Shifts.generated.dfy"
include "../word-rule-reference/Reference.dfy"
module BytecodeCollectionsWordCanonicality {
  import R = BytecodeCollectionsWordRuleReference
  import C = BytecodeCollectionsWordCanonicalShifts
  import M = BytecodeCollectionsArrayWordMathematics
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import A = AbiEncoding
  import F = AbiFrames
  predicate Checked(word: G.Word,kind: G.Word,bits: G.Word) {
    kind == 0 || if kind == 1 then S.ShiftRight(word,bits) == 0
    else if kind == 2 then M.SignExtend((S.ShiftRight(bits,3)+G.Modulus()-1)%G.Modulus(),word) == word
    else S.ShiftLeft(word,bits) == 0
  }
  lemma Canonical(rule: A.WordRule,kind: G.Word,bits: G.Word,word: G.Word)
    requires R.Equivalent(rule,kind,bits)
    ensures Checked(word,kind,bits) <==> A.CanonicalWord(rule,word)
  {
    R.EncodedBounds(rule,kind,bits);R.WordModulus();
    match rule
    case Opaque => R.OpaqueAccepts(rule,word);
    case Unsigned(width) => C.Unsigned(word,bits);
    case Signed(width) =>
      C.Index(bits);M.CanonicalSigned(width,word);
      assert 1 <= bits/8 <= 31;
      assert (S.ShiftRight(bits,3)+G.Modulus()-1)%G.Modulus() == bits/8-1;
    case HighBytes(count) =>
      C.High(word,bits);M.PowerAgreement(32-count);
    case Address =>
      C.Unsigned(word,bits);M.ByteBits(20);M.PowerAgreement(20);
    case Boolean => C.Unsigned(word,bits);
    case Function =>
      C.High(word,bits);M.PowerAgreement(8);
  }
}
