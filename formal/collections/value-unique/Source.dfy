// SPDX-License-Identifier: MIT
include "Control.generated.dfy"
include "Flow.dfy"
module CollectionsValueUniqueSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import S = CollectionsValueUniqueSpec
  import F = CollectionsValueUniqueFlow
  import T = CollectionsTraversalModel
  import Ctrl = CollectionsValueUniqueControl
  function Values(k: S.Config,kept: seq<nat>): seq<seq<Byte>>
    requires forall j :: 0 <= j < |kept| ==> kept[j] < |k.values|
  { seq(|kept|,j requires 0 <= j < |kept| => k.values[kept[j]]) }
  ghost method Compare(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment) returns (out: S.Comparison)
    requires i < |k.values| && S.Indices(k,kept,i) && Uint(|k.values|) && |kept| <= i
    ensures out == S.Compare(k,i,kept,S.Start(k,kept),c,env)
  {
    var start := Ctrl.Start(k.ordered,|kept|);
    assert start == S.Start(k,kept);
    var j: nat := start as nat;
    var current := c;
    while Ctrl.CompareLoop(j,|kept|)
      invariant start <= j <= |kept|
      invariant S.Compare(k,i,kept,S.Start(k,kept),c,env) == S.Compare(k,i,kept,j,current,env)
      decreases |kept|-j
    {
      var a := Ctrl.First(j); var b := Ctrl.Second(i);
      var binary := Ctrl.Binary(); var index := Ctrl.Index(i); var other := Ctrl.Other(i,j);
      assert a == j && b == i && binary && index == i && other == j;
      var query := T.Predicate(k.values[kept[a]],k.values[b],binary,index as nat,other as nat);
      assert query == S.Query(k,i,kept,j);
      var called := T.Ask(query,current,env);
      if called.reply.Error? { out := S.CompareFailed(called.reply.reason,called.context); return; }
      if called.reply.truth { out := S.Compared(true,called.context); return; }
      assert Uint(j+1);
      j := j+1; current := called.context;
    }
    out := S.Compared(false,current);
  }
  ghost method Loop(k: S.Config,c: T.Context,env: T.Environment) returns (out: S.Outcome,values: seq<seq<Byte>>)
    requires Uint(|k.values|)
    ensures out == S.Tail(k,0,[],c,env)
    ensures out.Returned? ==> S.Indices(k,out.kept,|k.values|) && values == Values(k,out.kept)
  {
    var current := c; var i: nat := 0; var kept: seq<nat> := [];
    values := [];
    while Ctrl.Loop(i,|k.values|)
      invariant i <= |k.values| && |kept| <= i
      invariant S.Indices(k,kept,i)
      invariant values == Values(k,kept)
      invariant S.Tail(k,0,[],c,env) == S.Tail(k,i,kept,current,env)
      decreases |k.values|-i
    {
      var before := current;
      var at := Ctrl.Validate(i);
      assert at == i;
      var checked := T.Ask(T.Validate(k.inputType,k.values[at]),current,env);
      if checked.reply.Error? { out := S.Failed(checked.reply.reason,checked.context); return; }
      var compared := Compare(k,i,kept,checked.context,env);
      if compared.CompareFailed? { out := S.Failed(compared.reason,compared.context); return; }
      S.Append(k,kept,i);
      var keep := Ctrl.Keep(compared.duplicate);
      assert keep == !compared.duplicate;
      if keep {
        var write := Ctrl.Write(i); assert write == i;
        values := values+[k.values[write]]; kept := kept+[i];
      }
      assert Uint(i+1);
      current := compared.context; i := i+1;
    }
    var count := Ctrl.Shrink(|kept|); assert count == |kept|;
    out := S.Returned(kept,current);
  }
  ghost method Run(k: S.Config,c: T.Context,env: T.Environment) returns (out: S.Outcome,values: seq<seq<Byte>>)
    requires Uint(|k.values|)
    ensures out == S.Run(k,c,env)
    ensures out.Returned? ==> S.Indices(k,out.kept,|k.values|) && values == Values(k,out.kept)
  {
    values := [];
    var prepared := T.Ask(T.Prepare(true),c,env);
    if prepared.reply.Error? { out := S.Failed(prepared.reply.reason,prepared.context); return; }
    var shaped := T.Ask(T.Shape(k.inputType),prepared.context,env);
    if shaped.reply.Error? { out := S.Failed(shaped.reply.reason,shaped.context); return; }
    out,values := Loop(k,shaped.context,env);
  }
}
