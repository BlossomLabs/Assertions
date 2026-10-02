include "../occurrence-index/Connection.dfy"
include "../concat/Connection.dfy"
module OperationsReplaceModel {
  import W = OperationsWordMatchModel
  import O = OperationsOccurrenceModel
  datatype Outcome = Bytes(data: seq<bv8>) | EmptyNeedle | Panic(code: int)
  predicate Valid(end: nat,n: nat,start: nat,hits: seq<nat>)
    decreases |hits|
  { start <= end && (|hits| == 0 || (start <= hits[0] && hits[0]+n <= end && Valid(end,n,hits[0]+n,hits[1..]))) }
  lemma Weaken(end: nat,n: nat,a: nat,b: nat,hits: seq<nat>)
    requires a <= b && Valid(end,n,b,hits)
    ensures Valid(end,n,a,hits)
  { }
  lemma PositionsValid(s: seq<bv8>,needle: seq<bv8>,p: nat)
    requires |needle| > 0 && p <= |s|
    ensures Valid(|s|,|needle|,p,O.Positions(s,needle,p))
    decreases |s|-p
  {
    if p+|needle| <= |s| {
      if W.Matches(s,needle,p) { PositionsValid(s,needle,p+|needle|); }
      else { PositionsValid(s,needle,p+1); Weaken(|s|,|needle|,p,p+1,O.Positions(s,needle,p+1)); }
    }
  }
  function Render(s: seq<bv8>,n: nat,repl: seq<bv8>,start: nat,hits: seq<nat>): seq<bv8>
    requires Valid(|s|,n,start,hits)
    decreases |hits|
  { if |hits| == 0 then s[start..] else s[start..hits[0]]+repl+Render(s,n,repl,hits[0]+n,hits[1..]) }
  lemma Consumed(end: nat,n: nat,start: nat,hits: seq<nat>)
    requires Valid(end,n,start,hits)
    ensures |hits|*n <= end-start
    decreases |hits|
  {
    if |hits| > 0 {
      Consumed(end,n,hits[0]+n,hits[1..]);
      assert |hits|*n == n+|hits[1..]|*n;
    }
  }
  lemma RenderLength(s: seq<bv8>,n: nat,repl: seq<bv8>,start: nat,hits: seq<nat>)
    requires Valid(|s|,n,start,hits)
    ensures |Render(s,n,repl,start,hits)| == |s|-start-|hits|*n+|hits|*|repl|
    decreases |hits|
  {
    if |hits| > 0 {
      RenderLength(s,n,repl,hits[0]+n,hits[1..]);
      assert |hits|*n == n+|hits[1..]|*n;
      assert |hits|*|repl| == |repl|+|hits[1..]|*|repl|;
    }
  }
  function Length(s: seq<bv8>,needle: seq<bv8>,repl: seq<bv8>): nat
    requires |needle| > 0
  {
    O.PositionsBounds(s,needle,0);
    |s|-|O.Positions(s,needle,0)|*|needle|+|O.Positions(s,needle,0)|*|repl|
  }
  function Rendered(s: seq<bv8>,needle: seq<bv8>,repl: seq<bv8>): seq<bv8>
    requires |needle| > 0
  { PositionsValid(s,needle,0); Render(s,|needle|,repl,0,O.Positions(s,needle,0)) }
  function Spec(s: seq<bv8>,needle: seq<bv8>,repl: seq<bv8>): Outcome {
    if |needle| == 0 then EmptyNeedle
    else if Length(s,needle,repl) >= W.Word then Panic(17)
    else Bytes(Rendered(s,needle,repl))
  }
  lemma FloorBound(n: nat,d: nat,c: nat)
    requires d > 0 && c*d <= n
    ensures c <= n/d
  {
    var q := n/d;
    assert n == q*d+n%d;
    if q < c {
      W.ProductMonotone(q+1,c,d);
      assert (q+1)*d == q*d+d;
    }
  }
}
