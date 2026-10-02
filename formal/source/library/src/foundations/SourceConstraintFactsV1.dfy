// SPDX-License-Identifier: MIT
include "../assertions/constraints/Model.dfy"
module SourceConstraintFactsV1 {
  import opened ConstraintModel
  lemma NoAlternativeStep(actual: Word, cs: seq<Constraint>, start: nat)
    requires start < |cs| && (forall c <- cs :: c.kind != OR)
    requires Leaf(actual,cs[start]) == No
    ensures Alternatives(actual,cs,start) == Alternatives(actual,cs,start+1)
  { }
  lemma SuccessfulScanStep(cs: seq<Constraint>, data: seq<Byte>, decode: seq<Byte> -> Decoded, start: nat)
    requires start < |cs| <= |data|/32
    requires Judge(Read(data[32*start..32*start+32]),cs[start],decode) == Yes
    ensures Scan(cs,data,decode,start) == Scan(cs,data,decode,start+1)
  { }
}
