// SPDX-License-Identifier: MIT
include "../iteration-chain/Connection.dfy"
module CollectionsValueSearchSpec {
  import opened AbiFrames
  import opened AbiByteSemantics
  import T = CollectionsTraversalModel
  datatype Mode = IndexOf | Any | All | Find
  datatype Config = Config(mode: Mode,inputType: seq<Byte>,values: seq<seq<Byte>>,needle: seq<Byte>)
  datatype Outcome = Returned(index: nat,context: T.Context) | Failed(reason: seq<Byte>,context: T.Context)
  function Missing(): nat { Pow256(32)-1 }
  predicate Wanted(k: Config) { k.mode != All }
  predicate Binary(k: Config) { k.mode == IndexOf }
  function Query(k: Config,i: nat): T.Request
    requires i < |k.values|
  { T.Predicate(k.values[i],if Binary(k) then k.needle else [],Binary(k),i,0) }
  function Step(k: Config,i: nat,c: T.Context,env: T.Environment): Outcome
    requires i < |k.values|
  {
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
    if checked.reply.Error? then Failed(checked.reply.reason,checked.context) else
    var called := T.Ask(Query(k,i),checked.context,env);
    if called.reply.Error? then Failed(called.reply.reason,called.context) else
    Returned(if called.reply.truth == Wanted(k) then i else Missing(),called.context)
  }
  function Tail(k: Config,i: nat,c: T.Context,env: T.Environment): Outcome
    requires i <= |k.values| && Uint(|k.values|)
    decreases |k.values|-i
  {
    if i == |k.values| then Returned(Missing(),c) else
    var step := Step(k,i,c,env);
    if step.Failed? || step.index != Missing() then step else Tail(k,i+1,step.context,env)
  }
  function Admission(k: Config,c: T.Context,env: T.Environment): Outcome {
    var prep := T.Ask(T.Prepare(Binary(k)),c,env);
    if prep.reply.Error? then Failed(prep.reply.reason,prep.context) else
    var checked := T.Ask(if Binary(k) then T.Validate(k.inputType,k.needle) else T.Shape(k.inputType),prep.context,env);
    if checked.reply.Error? then Failed(checked.reply.reason,checked.context) else Returned(Missing(),checked.context)
  }
  function Run(k: Config,c: T.Context,env: T.Environment): Outcome
    requires Uint(|k.values|)
  {
    var admitted := Admission(k,c,env);
    if admitted.Failed? then admitted else Tail(k,0,admitted.context,env)
  }
  function Bool(k: Config,index: nat): bool { if k.mode == All then index == Missing() else index != Missing() }
  datatype Row = Row(index: nat,before: T.Context,checked: T.Attempt,calls: seq<T.Attempt>,out: Outcome)
  function Record(k: Config,i: nat,c: T.Context,env: T.Environment): Row
    requires i < |k.values|
  {
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
    var calls := if checked.reply.Error? then [] else [T.Ask(Query(k,i),checked.context,env)];
    Row(i,c,checked,calls,Step(k,i,c,env))
  }
  function Rows(k: Config,i: nat,c: T.Context,env: T.Environment): seq<Row>
    requires i <= |k.values| && Uint(|k.values|)
    decreases |k.values|-i
  {
    if i == |k.values| then [] else
    var row := Record(k,i,c,env);
    if row.out.Failed? || row.out.index != Missing() then [row] else [row]+Rows(k,i+1,row.out.context,env)
  }
  lemma RecordFacts(k: Config,i: nat,c: T.Context,env: T.Environment)
    requires i < |k.values| && Uint(|k.values|)
    ensures Record(k,i,c,env).out.Returned? ==> |Record(k,i,c,env).calls| == 1 && Record(k,i,c,env).calls[0].reply.Ok?
    ensures Record(k,i,c,env).out.Returned? ==> (Record(k,i,c,env).out.index == i) == (Record(k,i,c,env).calls[0].reply.truth == Wanted(k))
    ensures Record(k,i,c,env).out.Returned? ==> (Record(k,i,c,env).out.index == Missing()) == (Record(k,i,c,env).calls[0].reply.truth != Wanted(k))
    ensures c.history <= Record(k,i,c,env).out.context.history
    ensures |Record(k,i,c,env).out.context.history| == |c.history|+1+|Record(k,i,c,env).calls|
    ensures Record(k,i,c,env).out.Returned? ==> |Record(k,i,c,env).out.context.history| == |c.history|+2
  { assert i < Missing(); }
  lemma Facts(k: Config,i: nat,c: T.Context,env: T.Environment)
    requires i <= |k.values| && Uint(|k.values|)
    ensures |Rows(k,i,c,env)| <= |k.values|-i
    ensures i < |k.values| ==> |Rows(k,i,c,env)| > 0
    ensures Tail(k,i,c,env).Returned? ==> Tail(k,i,c,env).index == Missing() || i <= Tail(k,i,c,env).index < |k.values|
    ensures Tail(k,i,c,env).Returned? && Tail(k,i,c,env).index == Missing() ==> |Rows(k,i,c,env)| == |k.values|-i
    ensures Tail(k,i,c,env).Returned? && Tail(k,i,c,env).index != Missing() ==> |Rows(k,i,c,env)| == Tail(k,i,c,env).index-i+1
    ensures Tail(k,i,c,env).Failed? ==> |Rows(k,i,c,env)| > 0 && Rows(k,i,c,env)[|Rows(k,i,c,env)|-1].out == Tail(k,i,c,env)
    ensures forall p :: 0 <= p < |Rows(k,i,c,env)| ==> Rows(k,i,c,env)[p].index == i+p && |Rows(k,i,c,env)[p].calls| <= 1
    ensures forall p :: 0 <= p && p+1 < |Rows(k,i,c,env)| ==> Rows(k,i,c,env)[p].out.Returned? && Rows(k,i,c,env)[p].out.index == Missing()
    ensures forall p :: 0 <= p < |Rows(k,i,c,env)| ==> (|Rows(k,i,c,env)[p].calls| == 0) == Rows(k,i,c,env)[p].checked.reply.Error?
    decreases |k.values|-i
  {
    if i < |k.values| {
      assert i < Missing();
      var row := Record(k,i,c,env);
      if row.out.Returned? && row.out.index == Missing() {
        Facts(k,i+1,row.out.context,env);
        assert Rows(k,i,c,env) == [row]+Rows(k,i+1,row.out.context,env);
        forall p | 0 <= p < |Rows(k,i,c,env)|
          ensures Rows(k,i,c,env)[p].index == i+p && |Rows(k,i,c,env)[p].calls| <= 1
          ensures (|Rows(k,i,c,env)[p].calls| == 0) == Rows(k,i,c,env)[p].checked.reply.Error?
        { if p > 0 { assert Rows(k,i,c,env)[p] == Rows(k,i+1,row.out.context,env)[p-1]; } }
      }
    }
  }

}
