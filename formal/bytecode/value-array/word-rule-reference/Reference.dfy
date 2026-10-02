// SPDX-License-Identifier: MIT
// Independent canonical-word meaning of a complete accepted base-name window.
include "../named-parser/Parser.dfy"
include "../../../abi/tuples/Names.generated.dfy"
module BytecodeCollectionsWordRuleReference {
  import G = BytecodeGetterMachine
  import L = BytecodeCollectionsScanNameLoop
  import N = BytecodeCollectionsNamedParser
  import F = AbiFrames
  import A = AbiEncoding
  import W = AbiWordSemantics
  import Names = AbiTupleNames
  lemma NameWindowFits(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,end: G.Word)
    requires N.Name(data,offset,p,limit,end)
    ensures offset+end <= |data|
  {
    if offset+end > |data| {
      var i: nat := if |data| <= offset+p then p else |data|-offset;
      assert p <= i < end && offset+i >= |data|;
      assert L.DataByte(data,offset,i) == 0;
      assert L.Allowed(L.DataByte(data,offset,i));
      assert false;
    }
  }
  function RuleAt(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,end: G.Word): A.WordRule
    requires N.Name(data,offset,p,limit,end)
    ensures W.ClassifiedRule(RuleAt(data,offset,p,limit,end))
  {
    NameWindowFits(data,offset,p,limit,end);
    Names.RuleClassified(data[offset+p..offset+end]);
    Names.Rule(data[offset+p..offset+end])
  }
  function Kind(rule: A.WordRule): nat {
    if rule.Opaque? then 0 else if rule.Signed? then 2
    else if rule.HighBytes? || rule.Function? then 3 else 1
  }
  function Bits(rule: A.WordRule): nat {
    match rule
    case Opaque => 0
    case Unsigned(bits) => bits
    case Signed(bits) => bits
    case HighBytes(count) => 8*count
    case Address => 160
    case Boolean => 1
    case Function => 192
  }
  predicate Equivalent(rule: A.WordRule,kind: G.Word,bits: G.Word) {
    W.ClassifiedRule(rule) && kind == Kind(rule) &&
    (kind != 0 ==> bits == Bits(rule))
  }
  lemma EncodedBounds(rule: A.WordRule,kind: G.Word,bits: G.Word)
    requires Equivalent(rule,kind,bits)
    ensures kind <= 3
    ensures kind != 0 ==> 1 <= bits <= 248
    ensures kind == 2 || kind == 3 ==> bits%8 == 0
  {}
  lemma WordModulus()
    ensures G.Modulus() == F.Pow256(32)
  {}
  predicate Canonical(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,end: G.Word,word: G.Word)
    requires N.Name(data,offset,p,limit,end)
  { A.CanonicalWord(RuleAt(data,offset,p,limit,end),word) }
  lemma OpaqueAccepts(rule: A.WordRule,word: G.Word)
    requires rule.Opaque?
    ensures A.CanonicalWord(rule,word)
  { WordModulus(); }
}
