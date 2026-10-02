// SPDX-License-Identifier: MIT
include "EntryModel.dfy"
module CollectionsValueUniqueEntry {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import S = CollectionsValueUniqueSpec
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import A = CollectionsAdmissionModel
  import E = CollectionsEnvironmentModel
  import M = CollectionsValueUniqueEntryModel
  import Engine = CollectionsValueUniqueEngine
  import Admission = CollectionsAdmissionConnection
  import Validation = CollectionsValidationConnection
  import VC = AbiConstructionContext
  import Errors = CollectionsCodecErrorEncoding
  import Replay = CollectionsValueUniqueFlowReplay
  import Source = CollectionsValueUniqueSource
  import F = CollectionsValueUniqueFlow

  ghost method Run(k: M.Config,c: T.Context,h: seq<C.Event>)
    returns (out: S.Outcome,env: T.Environment,prep: P.Outcome,fs: seq<Descriptor>,records: seq<Engine.Record>,prepared: P.Prepared,lowHistory: seq<C.Event>)
    requires M.Room(k) && M.Budget(k,h)
    ensures out == S.Run(k.subject,c,env)
    ensures out.Returned? ==> prep.Ready? && M.TypeAccepted(k)
    ensures !prep.Ready? ==> out.Failed? && out.reason == A.FailureBytes(prep) && |records| == 0
    ensures lowHistory == (if |records| == 0 then h+C.CodecEvents(prep.history) else records[|records|-1].lowHistory)
    ensures |records| <= |k.subject.values|
    ensures prep.Ready? && M.TypeAccepted(k) ==> F.Admission(k.subject,c,env).Returned? &&
                                                 Engine.Trace(M.TailConfig(k,fs),0,[],F.Admission(k.subject,c,env).context,prep.prepared,h+C.CodecEvents(prep.history),env,records)
  {
    reveal M.Budget();
    var checks; var prepEnv;
    prep,fs,checks,prepEnv := Admission.Prepare(M.Raw(k),true,Errors.Encode);
    records := []; lowHistory := h+C.CodecEvents(prep.history);
    prepared := if prep.Ready? then prep.prepared else P.Prepared(P.Layout([],0),[],false);
    var local := M.Environment(k,c,prep,T.Error([]));
    var admitted := F.Admission(k.subject,c,local);
    out := admitted;
    env := local;
    if !prep.Ready? { return; }
    var reply: T.Reply;
    var observation := Validation.Observe(T.Shape(k.subject.inputType),T.Context(0,[]),0,0);
    reply := observation.reply;
    local := M.Environment(k,c,prep,reply);
    admitted := F.Admission(k.subject,c,local);
    env := local;
    if reply.Error? { out := admitted; return; }
    var tailEnv: T.Environment;
    tailEnv,out,records,prepared,lowHistory := Engine.Run(M.TailConfig(k,fs),0,[],admitted.context,prep.prepared,lowHistory);
    env := E.Splice(local,tailEnv,|admitted.context.history|);
    Replay.JoinAdmission(k.subject,c,local,tailEnv);
    E.Before(local,tailEnv,|c.history|,|admitted.context.history|);
    Replay.AdmissionReplay(k.subject,c,local,env);
    E.After(local,tailEnv,|admitted.context.history|);
    Engine.TraceReplay(M.TailConfig(k,fs),0,[],admitted.context,prep.prepared,h+C.CodecEvents(prep.history),tailEnv,env,records);
    var source; var values;
    source,values := Source.Run(k.subject,c,env);
  }
}
