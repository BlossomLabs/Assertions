// SPDX-License-Identifier: MIT
include "../bound-call/Connection.dfy"
include "../../abi/source/BytesBody.generated.dfy"
module CollectionsSortComparatorModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import B = CollectionsBoundCallModel
  import K = CollectionsCodecStateModel
  import A = AbiConstructionModel
  import V = AbiConstructionContext
  import R = CollectionsCallbackResultsModel
  import W = CollectionsWireModel
  datatype Decision = TakeLeft(value: bool) | Failure(reason: seq<Byte>)
  function Signed(word: nat): int {
    if word < 128*Pow256(31) then word else word-Pow256(32)
  }
  // Independent byte criterion: exactly one word, sign bit set or every byte zero.
  predicate NonPositive(data: seq<Byte>) {
    |data| == 32 && (data[0] >= 128 || (forall i :: 0 <= i < |data| ==> data[i] == 0))
  }
  function Judge(out: C.Outcome,c: R.Context): Decision {
    if out.Failed? then Failure(W.ErrorBytes(out.error)) else
    if |out.value| != 32 then Failure(R.InvalidBytes(c)) else TakeLeft(NonPositive(out.value))
  }
  predicate Room(out: C.Outcome,c: R.Context) {
    R.Fits(c) && (out.Failed? ==> W.ErrorFits(out.error))
  }
  lemma Leading(data: seq<Byte>)
    requires |data| > 0
    ensures data[0]*Pow256(|data|-1) <= ReadNat(data) < (data[0]+1)*Pow256(|data|-1)
    decreases |data|
  {
    if |data| > 1 {
      var prefix := data[..|data|-1];
      Leading(prefix);
      assert prefix[0] == data[0];
      assert Pow256(|data|-1) == 256*Pow256(|data|-2);
    }
  }
  lemma Zero(data: seq<Byte>)
    ensures (ReadNat(data) == 0) == (forall i :: 0 <= i < |data| ==> data[i] == 0)
    decreases |data|
  {
    if |data| > 0 {
      Zero(data[..|data|-1]);
      if ReadNat(data) == 0 {
        forall i | 0 <= i < |data| ensures data[i] == 0
        { if i < |data|-1 { assert data[..|data|-1][i] == data[i]; } }
      }
    }
  }
  lemma Scale(a: nat,b: nat,p: nat)
    requires a <= b
    ensures a*p <= b*p
  { assert (b-a)*p >= 0; }
  lemma Sign(data: seq<Byte>)
    requires |data| == 32
    ensures (Signed(ReadNat(data)) <= 0) == NonPositive(data)
    ensures -128*Pow256(31) <= Signed(ReadNat(data)) < 128*Pow256(31)
  {
    Leading(data); Zero(data); BytesNatRoundTrip(data);
    assert Pow256(32) == 256*Pow256(31);
    if data[0] < 128 { Scale(data[0]+1,128,Pow256(31)); assert ReadNat(data) < 128*Pow256(31); }
    else { Scale(128,data[0],Pow256(31)); assert ReadNat(data) >= 128*Pow256(31); }
  }

  ghost predicate AfterRoom(fs: seq<Descriptor>,args: seq<seq<Byte>>,flag: bool,cb: C.Callback,c: C.Context,a: seq<Byte>,b: seq<Byte>,h: seq<C.Event>,base: C.Environment)
    requires cb.first < |fs| && cb.second < |fs|
  {
    forall r1: V.Result,r2: V.Result {:trigger B.Environment(base,B.Query(fs,cb.first,a),r1,B.Query(fs,cb.second,b),r2)} ::
      var env := B.Environment(base,B.Query(fs,cb.first,a),r1,B.Query(fs,cb.second,b),r2);
      C.Admitted(env) && C.Valid(cb,P.Prepared(K.Plan(fs),args,flag),true) &&
      (r1.Success? == A.ValidInput(fs[cb.first],a)) && (r2.Success? == A.ValidInput(fs[cb.second],b)) ==>
        Room(C.Run(cb,P.Prepared(K.Plan(fs),args,flag),c,a,b,true,h,env),R.Context(c.operation,c.index,c.other,cb.target))
  }
}
