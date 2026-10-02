// SPDX-License-Identifier: MIT
include "../iteration-chain/Connection.dfy"
module CollectionsValueUniqueSpec {
  import opened AbiFrames
  import T = CollectionsTraversalModel
  datatype Config = Config(inputType: seq<Byte>,values: seq<seq<Byte>>,ordered: bool)
  datatype Comparison = Compared(duplicate: bool,context: T.Context) | CompareFailed(reason: seq<Byte>,context: T.Context)
  function Start(k: Config,kept: seq<nat>): nat { if k.ordered && |kept| != 0 then |kept|-1 else 0 }
  predicate Indices(k: Config,kept: seq<nat>,before: nat) {
    before <= |k.values| && (forall j :: 0 <= j < |kept| ==> kept[j] < before) &&
    (forall a,b :: 0 <= a < b < |kept| ==> kept[a] < kept[b])
  }
  function Query(k: Config,i: nat,kept: seq<nat>,j: nat): T.Request
    requires i < |k.values| && j < |kept| && kept[j] < |k.values|
  { T.Predicate(k.values[kept[j]],k.values[i],true,i,j) }
  function Compare(k: Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,env: T.Environment): Comparison
    requires i < |k.values| && Indices(k,kept,i) && j <= |kept|
    decreases |kept|-j
  {
    if j == |kept| then Compared(false,c) else
    var called := T.Ask(Query(k,i,kept,j),c,env);
    if called.reply.Error? then CompareFailed(called.reply.reason,called.context) else
    if called.reply.truth then Compared(true,called.context) else Compare(k,i,kept,j+1,called.context,env)
  }
  datatype Outcome = Returned(kept: seq<nat>,context: T.Context) | Failed(reason: seq<Byte>,context: T.Context)
  function Tail(k: Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment): Outcome
    requires Indices(k,kept,i)
    decreases |k.values|-i
  {
    if i == |k.values| then Returned(kept,c) else
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
    if checked.reply.Error? then Failed(checked.reply.reason,checked.context) else
    var compared := Compare(k,i,kept,Start(k,kept),checked.context,env);
    if compared.CompareFailed? then Failed(compared.reason,compared.context) else
    Tail(k,i+1,if compared.duplicate then kept else kept+[i],compared.context,env)
  }
  function Run(k: Config,c: T.Context,env: T.Environment): Outcome {
    var prepared := T.Ask(T.Prepare(true),c,env);
    if prepared.reply.Error? then Failed(prepared.reply.reason,prepared.context) else
    var shape := T.Ask(T.Shape(k.inputType),prepared.context,env);
    if shape.reply.Error? then Failed(shape.reply.reason,shape.context) else Tail(k,0,[],shape.context,env)
  }
  lemma Append(k: Config,kept: seq<nat>,i: nat)
    requires i < |k.values| && Indices(k,kept,i)
    ensures Indices(k,kept,i+1) && Indices(k,kept+[i],i+1)
  {}
  lemma Stable(k: Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment)
    requires Indices(k,kept,i)
    ensures Tail(k,i,kept,c,env).Returned? ==> Indices(k,Tail(k,i,kept,c,env).kept,|k.values|) && kept <= Tail(k,i,kept,c,env).kept
    decreases |k.values|-i
  {
    if i < |k.values| {
      Append(k,kept,i);
      var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
      if checked.reply.Ok? {
        var compared := Compare(k,i,kept,Start(k,kept),checked.context,env);
        if compared.Compared? { Stable(k,i+1,if compared.duplicate then kept else kept+[i],compared.context,env); }
      }
    }
  }
}
