// SPDX-License-Identifier: MIT
include "../value-sort-execution/Connection.dfy"
include "../sort-admission/Connection.dfy"
module CollectionsValueSortEntryModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import A = CollectionsSortAdmissionModel
  import T = CollectionsValueSortTraceModel
  import E = CollectionsValueSortExecutionModel
  import Execute = CollectionsValueSortExecutionConnection
  datatype Config = Config(inputType: seq<Byte>,values: seq<seq<Byte>>,cb: C.Callback,constants: seq<seq<Byte>>,base: C.Environment)
  function Raw(k: Config): P.Callback { P.Callback(k.cb.descriptor,k.constants,k.cb.first,k.cb.second) }
  function MergeConfig(k: Config,fs: seq<Descriptor>): E.Config { E.Config(k.values,fs,k.cb,k.base) }
  ghost predicate Room(k: Config) {
    A.Room(Raw(k),k.inputType,k.values) && T.CountRoom(|k.values|) &&
    |k.cb.selector| == 4 && k.cb.target < Pow256(20) && Uint(k.cb.first) && Uint(k.cb.second) && Uint(|k.cb.expression|)
  }
  ghost opaque predicate Budget(k: Config,h: seq<C.Event>)
    requires Room(k)
  {
    forall fs: seq<Descriptor>,env: P.Environment {:trigger P.Prepare(Raw(k),true,[],env),MergeConfig(k,fs)} ::
      P.Admitted(env) ==>
        var prep := P.Prepare(Raw(k),true,[],env);
        prep.Ready? && Admissible(Group(fs)) && k.cb.descriptor == Render(Group(fs)) && |fs| == |k.constants| &&
        K.CanonicalExcept(fs,k.constants,{k.cb.first,k.cb.second}) &&
        prep.prepared == P.Prepared(K.Plan(fs),k.constants,false) && A.Judge(k.inputType,k.values,prep).Ready? ==>
          E.Budget(MergeConfig(k,fs),Execute.Cost(|k.values|,1),prep.prepared,h+C.CodecEvents(prep.history))
  }
  datatype Outcome = Success(ids: seq<nat>,values: seq<seq<Byte>>) | Failure(reason: seq<Byte>)
  function Project(values: seq<seq<Byte>>,ids: seq<nat>): seq<seq<Byte>>
    requires forall i :: 0 <= i < |ids| ==> ids[i] < |values|
    ensures |Project(values,ids)| == |ids|
    ensures forall i :: 0 <= i < |ids| ==> Project(values,ids)[i] == values[ids[i]]
  { seq(|ids|,i requires 0 <= i < |ids| => values[ids[i]]) }
  ghost function Judge(k: Config,admission: A.Verdict,tail: seq<T.Outcome>): Outcome
    requires admission.Ready? ==> |tail| == 1
    requires |tail| == 1 && tail[0].Success? ==> (forall i :: 0 <= i < |tail[0].ids| ==> tail[0].ids[i] < |k.values|)
  {
    if admission.Failure? then Failure(admission.reason) else
    if tail[0].Failure? then Failure(tail[0].reason) else Success(tail[0].ids,Project(k.values,tail[0].ids))
  }
}
