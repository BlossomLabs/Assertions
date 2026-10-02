// SPDX-License-Identifier: MIT
include "Engine.dfy"
include "Source.dfy"
module CollectionsValueUniqueEntryModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import S = CollectionsValueUniqueSpec
  import M = CollectionsValueUniqueModel
  import Ctrl = CollectionsValueUniqueControl
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import A = CollectionsAdmissionModel
  import VM = CollectionsValidationModel
  import F = CollectionsValueUniqueFlow
  datatype Config = Config(subject: S.Config,operation: seq<Byte>,cb: C.Callback,constants: seq<seq<Byte>>,base: C.Environment)
  function Operation(): seq<Byte> { Ctrl.uniqueValuesSelector() }
  function Raw(k: Config): P.Callback { P.Callback(k.cb.descriptor,k.constants,k.cb.first,k.cb.second) }
  function TailConfig(k: Config,fs: seq<Descriptor>): M.Config { M.Config(k.subject,k.operation,fs,k.cb,k.base) }
  ghost predicate Room(k: Config) {
    k.operation == Operation() && |k.cb.selector| == 4 && k.cb.target < Pow256(20) &&
    Uint(k.cb.first) && Uint(k.cb.second) && Uint(32*|k.subject.values|) && Uint(|k.cb.expression|) &&
    (forall i :: 0 <= i < |k.subject.values| ==> Uint(|k.subject.values[i]|)) &&
    (forall i :: 0 <= i < |k.constants| ==> Uint(|k.constants[i]|)) &&
    A.Room(Raw(k),true) && Uint(|k.subject.inputType|)
  }
  ghost predicate TypeAccepted(k: Config)
    requires Uint(|k.subject.inputType|)
  {
    VM.Reply(T.Shape(k.subject.inputType),0,0).Ok?
  }
  ghost opaque predicate Budget(k: Config,h: seq<C.Event>)
    requires Room(k)
  {
    forall fs: seq<Descriptor>,env: P.Environment {:trigger P.Prepare(Raw(k),true,[],env),TailConfig(k,fs)} ::
      P.Admitted(env) ==>
        var prep := P.Prepare(Raw(k),true,[],env);
        prep.Ready? && Admissible(Group(fs)) && k.cb.descriptor == Render(Group(fs)) && |fs| == |k.constants| &&
        K.CanonicalExcept(fs,k.constants,{k.cb.first,k.cb.second}) &&
        prep.prepared == P.Prepared(K.Plan(fs),k.constants,false) && TypeAccepted(k) ==>
          M.Budget(TailConfig(k,fs),0,[],prep.prepared,h+C.CodecEvents(prep.history))
  }
  function Environment(k: Config,c: T.Context,prep: P.Outcome,typeReply: T.Reply): T.Environment {
    T.Environment((q: T.Request,at: T.Context) =>
                    if at == c && q == T.Prepare(true) then T.Observation(if prep.Ready? then T.Ok([],false) else T.Error(A.FailureBytes(prep)),c.state+1)
                    else if at == T.Context(c.state+1,c.history+[T.Prepare(true)]) &&
                            q == T.Shape(k.subject.inputType) then T.Observation(typeReply,at.state)
                    else T.Observation(T.Error([]),at.state))
  }
}
