// SPDX-License-Identifier: MIT
include "Engine.dfy"
include "Source.dfy"
module CollectionsValueSearchEntryModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import S = CollectionsValueSearchSpec
  import M = CollectionsValueSearchModel
  import Ctrl = CollectionsValueSearchControl
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import A = CollectionsAdmissionModel
  import VM = CollectionsValidationModel
  datatype Config = Config(subject: S.Config,operation: seq<Byte>,cb: C.Callback,constants: seq<seq<Byte>>,base: C.Environment)
  function Operation(mode: S.Mode): seq<Byte> {
    if mode == S.IndexOf then Ctrl.indexOfValuesSelector() else if mode == S.Any then Ctrl.anyValuesSelector() else
    if mode == S.All then Ctrl.allValuesSelector() else Ctrl.findValuesSelector()
  }
  function Raw(k: Config): P.Callback { P.Callback(k.cb.descriptor,k.constants,k.cb.first,k.cb.second) }
  function TailConfig(k: Config,fs: seq<Descriptor>): M.Config { M.Config(k.subject,k.operation,fs,k.cb,k.base) }
  ghost predicate Room(k: Config) {
    k.operation == Operation(k.subject.mode) && |k.cb.selector| == 4 && k.cb.target < Pow256(20) &&
    Uint(k.cb.first) && Uint(k.cb.second) && Uint(32*|k.subject.values|) && Uint(|k.subject.needle|) && Uint(|k.cb.expression|) &&
    (forall i :: 0 <= i < |k.subject.values| ==> Uint(|k.subject.values[i]|)) &&
    (forall i :: 0 <= i < |k.constants| ==> Uint(|k.constants[i]|)) &&
    A.Room(Raw(k),S.Binary(k.subject)) && Uint(|k.subject.inputType|) &&
    (S.Binary(k.subject) ==> VM.Room(k.subject.inputType,k.subject.needle))
  }
  ghost predicate TypeAccepted(k: Config)
    requires Uint(|k.subject.inputType|)
  {
    VM.Reply(if S.Binary(k.subject) then T.Validate(k.subject.inputType,k.subject.needle) else T.Shape(k.subject.inputType),0,0).Ok?
  }
  ghost opaque predicate Budget(k: Config,h: seq<C.Event>)
    requires Room(k)
  {
    forall fs: seq<Descriptor>,env: P.Environment {:trigger P.Prepare(Raw(k),S.Binary(k.subject),[],env),TailConfig(k,fs)} ::
      P.Admitted(env) ==>
        var prep := P.Prepare(Raw(k),S.Binary(k.subject),[],env);
        prep.Ready? && Admissible(Group(fs)) && k.cb.descriptor == Render(Group(fs)) && |fs| == |k.constants| &&
        K.CanonicalExcept(fs,k.constants,if S.Binary(k.subject) then {k.cb.first,k.cb.second} else {k.cb.first}) &&
        prep.prepared == P.Prepared(K.Plan(fs),k.constants,false) && TypeAccepted(k) ==>
          M.Budget(TailConfig(k,fs),0,prep.prepared,h+C.CodecEvents(prep.history))
  }
  function Environment(k: Config,c: T.Context,prep: P.Outcome,typeReply: T.Reply): T.Environment {
    T.Environment((q: T.Request,at: T.Context) =>
                    if at == c && q == T.Prepare(S.Binary(k.subject)) then T.Observation(if prep.Ready? then T.Ok([],false) else T.Error(A.FailureBytes(prep)),c.state+1)
                    else if at == T.Context(c.state+1,c.history+[T.Prepare(S.Binary(k.subject))]) &&
                            q == (if S.Binary(k.subject) then T.Validate(k.subject.inputType,k.subject.needle) else T.Shape(k.subject.inputType)) then T.Observation(typeReply,at.state)
                    else T.Observation(T.Error([]),at.state))
  }
}
