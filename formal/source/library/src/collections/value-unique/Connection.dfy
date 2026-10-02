// SPDX-License-Identifier: MIT
include "Facts.dfy"
module CollectionsValueUniqueConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import Shape = AbiShapeSemantics
  import S = CollectionsValueUniqueSpec
  import F = CollectionsValueUniqueFlow
  import D = CollectionsValueUniqueDecisions
  import M = CollectionsValueUniqueEntryModel
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import A = CollectionsAdmissionModel
  import Entry = CollectionsValueUniqueEntry
  import Source = CollectionsValueUniqueSource
  import Engine = CollectionsValueUniqueEngine
  import Facts = CollectionsValueUniqueFacts
  ghost method Run(k: M.Config,c: T.Context,h: seq<C.Event>)
    returns (out: S.Outcome,values: seq<seq<Byte>>,env: T.Environment,prep: P.Outcome,fs: seq<Shape.Descriptor>,records: seq<Engine.Record>)
    requires M.Room(k) && M.Budget(k,h)
    ensures out == S.Run(k.subject,c,env)
    ensures !prep.Ready? ==> out.Failed? && out.reason == A.FailureBytes(prep) && |records| == 0
    ensures out.Returned? ==> prep.Ready? && M.TypeAccepted(k)
    ensures out.Returned? ==> S.Indices(k.subject,out.kept,|k.subject.values|) && values == Source.Values(k.subject,out.kept)
    ensures out.Returned? ==> |records| == |k.subject.values|
    ensures prep.Ready? && M.TypeAccepted(k) ==> F.Admission(k.subject,c,env).Returned? &&
                                                 Engine.Trace(M.TailConfig(k,fs),0,[],F.Admission(k.subject,c,env).context,prep.prepared,h+C.CodecEvents(prep.history),env,records)
    ensures prep.Ready? && M.TypeAccepted(k) ==> |records| == |D.Rows(k.subject,0,[],F.Admission(k.subject,c,env).context,env)|
    ensures prep.Ready? && M.TypeAccepted(k) ==> forall j :: 0 <= j < |records| ==>
                                                               records[j].kept == D.Rows(k.subject,0,[],F.Admission(k.subject,c,env).context,env)[j].kept && |records[j].comparisons| == |D.Rows(k.subject,0,[],F.Admission(k.subject,c,env).context,env)[j].comparisons|
    ensures out.Returned? && |k.subject.values| <= 1 ==> forall j :: 0 <= j < |records| ==> |records[j].comparisons| == 0
  {
    var prepared; var history;
    out,env,prep,fs,records,prepared,history := Entry.Run(k,c,h);
    var source;
    source,values := Source.Run(k.subject,c,env);
    assert source == out;
    var admitted := F.Admission(k.subject,c,env);
    F.AdmissionFacts(k.subject,c,env);
    if prep.Ready? && M.TypeAccepted(k) {
      Facts.TraceFacts(M.TailConfig(k,fs),0,[],admitted.context,prep.prepared,h+C.CodecEvents(prep.history),env,records);
      D.Length(k.subject,0,[],admitted.context,env);
    }
  }
}
