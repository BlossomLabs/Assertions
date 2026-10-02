// SPDX-License-Identifier: MIT
// Gated source translation; Assertions.sol SHA-256: $HASH
include "Model.dfy"
module ConstraintEngine {
  import opened ConstraintModel

  ghost method Check(actual: Word, c: Constraint) returns (r: Verdict)
    requires c.kind != OR
    ensures r == Leaf(actual,c)
  {
    var kind := c.kind;
    var length := |c.data|;
    if kind == SKIP {
      if length != 0 { r := BadData(length); return; }
      r := Yes; return;
    }
    if kind == IN || kind == IN_SIGNED {
      if length != 64 { r := BadData(length); return; }
      var lower := Read(c.data[..32]);
      var upper := Read(c.data[32..]);
      if kind == IN_SIGNED {
        if $SIGNED_RANGE { r := BadRange; return; }
        var signed := Signed(actual);
        r := if $SIGNED_IN then Yes else No; return;
      }
      if $UNSIGNED_RANGE { r := BadRange; return; }
      r := if $UNSIGNED_IN then Yes else No; return;
    }
    if length != 32 { r := BadData(length); return; }
    assert c.data[..32] == c.data;
    var bound := Read(c.data);
    if kind == EQ { r := if $EQ then Yes else No; return; }
    if kind == GTE { r := if $GTE then Yes else No; return; }
    if kind == LTE { r := if $LTE then Yes else No; return; }
    if kind == GTE_SIGNED { r := if $GTE_SIGNED then Yes else No; return; }
    r := if $LTE_SIGNED then Yes else No;
  }

  ghost method Or(actual: Word, c: Constraint, decode: seq<Byte> -> Decoded) returns (r: Verdict)
    requires c.kind == OR
    ensures r == Judge(actual,c,decode)
  {
    var decoded := decode(c.data);
    if decoded.Rejected? { r := DecodeFailure; return; }
    var alternatives := decoded.items;
    if |alternatives| == 0 { r := BadOr; return; }
    var j := 0;
    while j < |alternatives|
      invariant 0 <= j <= |alternatives|
      invariant forall k :: 0 <= k < j ==> alternatives[k].kind != OR
    {
      if alternatives[j].kind == OR { r := BadOr; return; }
      j := j+1;
    }
    assert forall leaf <- alternatives :: leaf.kind != OR;
    j := 0;
    while j < |alternatives|
      invariant 0 <= j <= |alternatives|
      invariant Alternatives(actual,alternatives,0) == Alternatives(actual,alternatives,j)
    {
      var leaf := Check(actual,alternatives[j]);
      if leaf != No { r := leaf; return; }
      j := j+1;
    }
    r := No;
  }

  ghost method ValidateConstraints(cs: seq<Constraint>, data: seq<Byte>, decode: seq<Byte> -> Decoded) returns (r: Result)
    ensures r == Validate(cs,data,decode)
  {
    var length := |cs|;
    if length == 0 { r := Success; return; }
    var words := |data|/32;
    if $BOUNDS { r := Bounds(words,|data|); return; }
    var i := 0;
    while i < length
      invariant 0 <= i <= length <= |data|/32
      invariant Scan(cs,data,decode,0) == Scan(cs,data,decode,i)
    {
      var actual := Read(data[32*i..32*i+32]);
      var c := cs[i];
      var ok: Verdict;
      if c.kind == OR { ok := Or(actual,c,decode); }
      else { ok := Check(actual,c); }
      if ok != Yes { r := Failure(i,c,actual,ok); return; }
      i := i+1;
    }
    r := Success;
  }
  ghost method JudgeResolved(cs: seq<Constraint>, data: seq<Byte>, decode: seq<Byte> -> Decoded, context: Context) returns (r: Execution)
    ensures r == Execute(Validate(cs,data,decode),context)
    ensures r.Accepted? <==> |cs| <= |data|/32 &&
                             (forall i :: 0 <= i < |cs| ==> Judge(Read(data[32*i..32*i+32]),cs[i],decode) == Yes)
  {
    var result := ValidateConstraints(cs,data,decode);
    if |cs| <= |data|/32 {
      FirstFailure(cs,data,decode,0);
      FailureFields(cs,data,decode,0);
    }
    r := Execute(result,context);
  }

}
