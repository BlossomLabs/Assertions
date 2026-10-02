// SPDX-License-Identifier: MIT
include "Entry.dfy"
module CollectionsValueSearchConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import Shape = AbiShapeSemantics
  import Ctrl = CollectionsValueSearchControl
  import S = CollectionsValueSearchSpec
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import M = CollectionsValueSearchEntryModel
  import Engine = CollectionsValueSearchEngine
  import Entry = CollectionsValueSearchEntry
  import Source = CollectionsValueSearchSource
  import A = CollectionsAdmissionModel
  import E = CollectionsEnvironmentModel
  import B = CollectionsBoundCallModel
  import ABI = AbiConstructionModel
  import R = CollectionsCallbackResultsModel
  import RM = CollectionsCallResultsModel

  ghost method Run(k: M.Config,c: T.Context,h: seq<C.Event>)
    returns (out: S.Outcome,env: T.Environment,prep: P.Outcome,fs: seq<Shape.Descriptor>,records: seq<Engine.Record>)
    requires M.Room(k) && M.Budget(k,h)
    ensures out == S.Run(k.subject,c,env)
    ensures !prep.Ready? ==> out.Failed? && out.reason == A.FailureBytes(prep) && |records| == 0
    ensures prep.Ready? && M.TypeAccepted(k) ==> S.Admission(k.subject,c,env).Returned? &&
                                                 Engine.Trace(M.TailConfig(k,fs),0,S.Admission(k.subject,c,env).context,prep.prepared,h+C.CodecEvents(prep.history),env,records)
    ensures out.Returned? ==> out.index == S.Missing() || out.index < |k.subject.values|
    ensures out.Returned? && out.index != S.Missing() ==> |S.Rows(k.subject,0,S.Admission(k.subject,c,env).context,env)| == out.index+1
    ensures out.Returned? && out.index == S.Missing() ==> |S.Rows(k.subject,0,S.Admission(k.subject,c,env).context,env)| == |k.subject.values|
    ensures out.Returned? && (k.subject.mode == S.Any || k.subject.mode == S.All) ==> (if k.subject.mode == S.Any then Ctrl.AnyResult(out.index) else Ctrl.AllResult(out.index)) == S.Bool(k.subject,out.index)
    ensures prep.Ready? && M.TypeAccepted(k) ==> |records| == |S.Rows(k.subject,0,S.Admission(k.subject,c,env).context,env)|
    ensures out.Returned? && |k.subject.values| == 0 ==> out.index == S.Missing() && S.Bool(k.subject,out.index) == (k.subject.mode == S.All)
  {
    var prepared; var history;
    out,env,prep,fs,records,prepared,history := Entry.Run(k,c,h);
    Source.WrapperWanted(k.subject.mode);
    if out.Returned? && (k.subject.mode == S.Any || k.subject.mode == S.All) { Source.WrapperResult(k.subject,out.index); }
    var source := Source.Run(k.subject,c,env);
    var admitted := S.Admission(k.subject,c,env);
    if admitted.Returned? { S.Facts(k.subject,0,admitted.context,env); }
    if prep.Ready? && M.TypeAccepted(k) { Engine.TraceFacts(M.TailConfig(k,fs),0,admitted.context,prep.prepared,h+C.CodecEvents(prep.history),env,records); }
  }
}
