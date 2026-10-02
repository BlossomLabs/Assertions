// SPDX-License-Identifier: MIT
// Independent finite earliest decimal-stop witness and exact uniqueness bridge.
include "../suffix-connection/Number.dfy"
include "../../../foundations/v5/ProductOrder.dfy"
module BytecodeCollectionsSuffixRejectSemantics {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import N = BytecodeCollectionsDecimalNumber
  import O = SharedFoundationProductOrderV5
  function Max(): nat { 0xffffffff }
  function StopBound(): nat { Max()*10+9 }
  predicate Witness(data: seq<G.Byte>,offset: G.Word,start: G.Word,limit: G.Word,q: G.Word,k: G.Word) {
    start <= q <= limit && k <= StopBound() && k == D.Number(data,offset,start,q) &&
    (forall i {:trigger D.DataByte(data,offset,i)} :: start <= i < q ==> D.Digit(D.DataByte(data,offset,i))) &&
    (forall i {:trigger D.Number(data,offset,start,i)} :: start <= i < q ==> D.Number(data,offset,start,i) <= Max()) &&
    (q == limit || !D.Digit(D.DataByte(data,offset,q)) || k > Max())
  }
  predicate ExecutionFacts(data: seq<G.Byte>,offset: G.Word,start: G.Word,limit: G.Word,q: G.Word,k: G.Word) {
    start <= q <= limit && k <= StopBound() && k == D.Number(data,offset,start,q) &&
    (forall i {:trigger D.DataByte(data,offset,i)} :: start <= i < q ==> D.Digit(D.DataByte(data,offset,i))) &&
    (q == limit || !D.Digit(D.DataByte(data,offset,q)) || k > Max())
  }
  ghost method Find(data: seq<G.Byte>,offset: G.Word,start: G.Word,limit: G.Word) returns (q: G.Word,k: G.Word)
    requires start <= limit < 0x10000000000000000
    ensures Witness(data,offset,start,limit,q,k)
  {
    q := start;k := 0;
    while q < limit && D.Digit(D.DataByte(data,offset,q)) && k <= Max()
      invariant start <= q <= limit && k <= StopBound() && k == D.Number(data,offset,start,q)
      invariant forall i {:trigger D.DataByte(data,offset,i)} :: start <= i < q ==> D.Digit(D.DataByte(data,offset,i))
      invariant forall i {:trigger D.Number(data,offset,start,i)} :: start <= i < q ==> D.Number(data,offset,start,i) <= Max()
      decreases limit-q
    {
      var b := D.DataByte(data,offset,q);D.NumberExtend(data,offset,start,q);
      assert 48 <= b <= 57;
      var next := k*10+(b as int)-48;
      assert 0 <= next <= StopBound() < G.Modulus();
      forall i {:trigger D.DataByte(data,offset,i)} | start <= i < q+1
        ensures D.Digit(D.DataByte(data,offset,i))
      { if i == q { assert D.DataByte(data,offset,i) == b; } }
      forall i {:trigger D.Number(data,offset,start,i)} | start <= i < q+1
        ensures D.Number(data,offset,start,i) <= Max()
      { if i == q { assert D.Number(data,offset,start,i) == k; } }
      k := next;q := q+1;
    }
  }
  lemma Unique(data: seq<G.Byte>,offset: G.Word,start: G.Word,limit: G.Word,q: G.Word,k: G.Word,actualQ: G.Word,actualK: G.Word)
    requires Witness(data,offset,start,limit,q,k)
    requires ExecutionFacts(data,offset,start,limit,actualQ,actualK)
    ensures actualQ == q && actualK == k
  {
    if actualQ < q {
      assert D.Digit(D.DataByte(data,offset,actualQ));
      assert actualK == D.Number(data,offset,start,actualQ) <= Max();
      assert actualQ < limit;
      assert false;
    } else if actualQ > q {
      assert q < limit && D.Digit(D.DataByte(data,offset,q));
      assert k > Max();D.NumberExtend(data,offset,start,q);
      assert D.Number(data,offset,start,q+1) > StopBound();
      N.PrefixBound(data,offset,start,q+1,actualQ);
      assert D.Number(data,offset,start,q+1) <= actualK <= StopBound();
      assert false;
    }
  }
  function UpdatedDynamic(end: G.Word,q: G.Word,dyn: G.Word): G.Word {
    if q == end+1 then 1 else dyn
  }
  function UpdatedWords(end: G.Word,q: G.Word,dyn: G.Word,words: G.Word,k: G.Word): G.Word
    requires words*k < G.Modulus()
  {
    O.ProductNonnegative(words,k);
    if q == end+1 then 1 else if dyn == 1 then words else words*k
  }
  predicate Rejected(data: seq<G.Byte>,offset: G.Word,end: G.Word,limit: G.Word,dyn: G.Word,words: G.Word,q: G.Word,k: G.Word)
    requires words*k < G.Modulus()
  {
    q >= limit || D.DataByte(data,offset,q) != 93 || k > Max() ||
    UpdatedWords(end,q,dyn,words,k) > Max() || (k == 0 && q != end+1)
  }
}
