// SPDX-License-Identifier: MIT
include "Selectors.generated.dfy"
include "../iteration-chain/Connection.dfy"
include "../value-loops/Connection.dfy"
module CollectionsValueEntryModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import A = CollectionsAdmissionModel
  import V = CollectionsValidationModel
  import N = CollectionsIterationChainModel
  import S = CollectionsValueEntrySelectors

  datatype Config = Config(mode: T.Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, initial: seq<Byte>, operation: seq<Byte>, cb: C.Callback, constants: seq<seq<Byte>>, base: C.Environment)
  function Raw(k: Config): P.Callback { P.Callback(k.cb.descriptor,k.constants,k.cb.first,k.cb.second) }
  function TailConfig(k: Config, fs: seq<Descriptor>): N.Config {
    N.Config(k.mode,k.inputType,k.outputType,k.values,k.operation,fs,k.cb,k.base)
  }
  ghost predicate Room(k: Config) {
    k.operation == (if k.mode == T.Map then S.mapValues() else if k.mode == T.Filter then S.filterValues() else S.foldValues()) &&
    |k.cb.selector| == 4 && k.cb.target < Pow256(20) && Uint(k.cb.first) && Uint(k.cb.second) &&
    Uint(|k.values|) && Uint(|k.initial|) && Uint(|k.cb.expression|) &&
    (forall i :: 0 <= i < |k.values| ==> Uint(|k.values[i]|)) &&
    (forall i :: 0 <= i < |k.constants| ==> Uint(|k.constants[i]|)) &&
    A.Room(Raw(k),k.mode == T.Fold) && Uint(|k.inputType|) && Uint(|k.outputType|) &&
    (k.mode == T.Fold ==> V.Room(k.outputType,k.initial))
  }
  function LastRequest(k: Config): T.Request {
    if k.mode == T.Map then T.Shape(k.outputType) else T.Validate(k.outputType,k.initial)
  }
  ghost predicate TypesAccepted(k: Config)
    requires Uint(|k.inputType|) && Uint(|k.outputType|)
  {
    V.Reply(T.Shape(k.inputType),0,0).Ok? &&
    (k.mode != T.Filter ==> V.Reply(LastRequest(k),0,0).Ok?)
  }
  ghost function Environment(k: Config, c: T.Context, prep: P.Outcome): T.Environment
    requires Uint(|k.inputType|) && Uint(|k.outputType|)
  {
    var q := T.Prepare(k.mode == T.Fold);
    var after := T.Context(c.state+1,c.history+[q]);
    var input := T.Shape(k.inputType);
    var next := T.Context(c.state+1,c.history+[q,input]);
    T.Environment((request: T.Request,at: T.Context) =>
                    if at == c && request == q then T.Observation(if prep.Ready? then T.Ok([],false) else T.Error(A.FailureBytes(prep)),c.state+1)
                    else if at == after && request == input then T.Observation(V.Reply(input,0,0),at.state)
                    else if k.mode != T.Filter && at == next && request == LastRequest(k) then T.Observation(V.Reply(LastRequest(k),0,0),at.state)
                    else T.Observation(T.Error([]),at.state))
  }
  ghost function Admission(k: Config, c: T.Context, prep: P.Outcome): T.Outcome
    requires Uint(|k.inputType|) && Uint(|k.outputType|)
  { T.Admission(k.mode,k.inputType,k.outputType,k.initial,c,Environment(k,c,prep)) }

  // Quantification is over possible admitted preparation receipts, not arbitrary
  // histories. Only successful preparation and type admission need a tail budget.
  ghost opaque predicate Budget(k: Config, h: seq<C.Event>)
    requires Room(k)
  {
    forall fs: seq<Descriptor>, env: P.Environment {:trigger P.Prepare(Raw(k),k.mode == T.Fold,[],env), TailConfig(k,fs)} ::
      P.Admitted(env) ==>
        var prep := P.Prepare(Raw(k),k.mode == T.Fold,[],env);
        prep.Ready? && Admissible(Group(fs)) && k.cb.descriptor == Render(Group(fs)) && |fs| == |k.constants| &&
        K.CanonicalExcept(fs,k.constants,if k.mode == T.Fold then {k.cb.first,k.cb.second} else {k.cb.first}) &&
        prep.prepared == P.Prepared(K.Plan(fs),k.constants,false) && TypesAccepted(k) ==>
          N.Budget(TailConfig(k,fs),0,k.initial,prep.prepared,h+C.CodecEvents(prep.history))
  }
}
