// SPDX-License-Identifier: MIT
include "Admission.dfy"
module CollectionsValueEntryConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import M = CollectionsValueEntryModel
  import Admission = CollectionsValueEntryAdmission
  import T = CollectionsTraversalModel
  import TP = CollectionsTraversalProperties
  import P = CollectionsPreparationModel
  import C = CollectionsCallsModel
  import VC = AbiConstructionContext
  import K = CollectionsCodecStateModel
  import N = CollectionsIterationChainModel
  import Tail = CollectionsIterationChainConnection
  import E = CollectionsEnvironmentModel
  import Assemble = CollectionsEnvironmentConnection
  import Source = CollectionsValueLoopsConnection
  import VM = CollectionsValidationModel

  lemma EmptyBudget(k: M.Config, h: seq<C.Event>)
    requires M.Room(k) && |k.values| == 0
    ensures M.Budget(k,h)
  { reveal M.Budget(); reveal N.Budget(); }
  lemma RejectedTypesBudget(k: M.Config, h: seq<C.Event>)
    requires M.Room(k) && !M.TypesAccepted(k)
    ensures M.Budget(k,h)
  { reveal M.Budget(); }

  lemma Row(k: M.Config, fs: seq<Descriptor>, c: T.Context, p: P.Prepared, h: seq<C.Event>, rows: seq<E.Row>, records: seq<N.Record>, j: nat)
    requires Uint(|k.inputType|) && Uint(|k.outputType|)
    requires N.Trace(M.TailConfig(k,fs),0,k.initial,c,p,h,rows,records) && j < |rows|
    ensures j < |k.values| && |records[j].calls| <= 1
    ensures N.RecordAt(M.TailConfig(k,fs),j,rows[j].accumulator,records[j].before,records[j].history,records[j])
    ensures rows[j].out.Success? ==> VM.Reply(T.Validate(k.inputType,k.values[j]),0,0).Ok? && |records[j].calls| == 1 && records[j].calls[0].Returned?
    ensures rows[j].out.Success? && k.mode != T.Filter ==> VM.Reply(T.ValidateResult(k.outputType,records[j].calls[0].value,j),ReadNat(k.operation),k.cb.target).Ok?
    ensures rows[j].out.Success? && k.mode == T.Map ==> rows[j].out.values == [records[j].calls[0].value] && rows[j].out.accumulator == rows[j].accumulator
    ensures rows[j].out.Success? && k.mode == T.Fold ==> rows[j].out.values == [] && rows[j].out.accumulator == records[j].calls[0].value
    ensures rows[j].out.Success? && k.mode == T.Filter ==> records[j].calls[0].value == Word(0) || records[j].calls[0].value == Word(1)
    ensures rows[j].out.Success? && k.mode == T.Filter ==> rows[j].out.values == (if records[j].calls[0].value == Word(1) then [k.values[j]] else []) && rows[j].out.accumulator == rows[j].accumulator
  {
    Tail.At(M.TailConfig(k,fs),0,k.initial,c,p,h,rows,records,j);
    NatBytesRoundTrip(0,32); NatBytesRoundTrip(1,32);
    assert Word(0) != Word(1);
  }

  ghost method Run(k: M.Config, c: T.Context, h: seq<C.Event>)
    returns (env: T.Environment, out: T.Outcome, positions: seq<nat>, stop: nat,
             prep: P.Outcome, fs: seq<Descriptor>, checks: seq<VC.Result>, prepEnv: P.Environment,
             admitted: T.Outcome, rows: seq<E.Row>, records: seq<N.Record>, finalState: seq<P.Prepared>, lowHistory: seq<C.Event>)
    requires M.Room(k) && M.Budget(k,h)
    requires k.mode == T.Fold || k.initial == []
    requires k.mode != T.Filter || k.outputType == []
    ensures P.Admitted(prepEnv) && prep == P.Prepare(M.Raw(k),k.mode == T.Fold,[],prepEnv)
    ensures prep.Ready? ==> Admissible(Group(fs)) && k.cb.descriptor == Render(Group(fs)) && |fs| == |k.constants|
    ensures prep.Ready? ==> K.CanonicalExcept(fs,k.constants,if k.mode == T.Fold then {k.cb.first,k.cb.second} else {k.cb.first}) && prep.prepared == P.Prepared(K.Plan(fs),k.constants,false)
    ensures admitted == M.Admission(k,c,prep)
    ensures admitted.Success? == (prep.Ready? && M.TypesAccepted(k))
    ensures E.Window(env,M.Environment(k,c,prep),|c.history|,|admitted.context.history|)
    ensures out == T.Run(k.mode,k.inputType,k.outputType,k.values,k.initial,c,env)
    ensures admitted.Failure? ==> out == admitted && rows == [] && records == [] && lowHistory == h+C.CodecEvents(prep.history) && finalState == (if prep.Ready? then [prep.prepared] else [])
    ensures admitted.Success? ==> N.Trace(M.TailConfig(k,fs),0,k.initial,admitted.context,prep.prepared,h+C.CodecEvents(prep.history),rows,records)
    ensures admitted.Success? ==> out == E.Collected(rows,k.initial,admitted.context)
    ensures admitted.Success? ==> finalState == [N.FinalPrepared(prep.prepared,records)] && lowHistory == N.FinalHistory(h+C.CodecEvents(prep.history),records)
    ensures forall j :: 0 <= j < |rows| ==> E.Window(env,rows[j].env,|rows[j].start.history|,|rows[j].out.context.history|)
    ensures forall j :: 0 <= j < |rows|-1 ==> rows[j].out.Success?
    ensures admitted.Success? && out.Failure? ==> |rows| > 0 && rows[|rows|-1].out == out
    ensures |rows| <= |k.values| && |records| == |rows|
    ensures stop <= |k.values| && c.history <= out.context.history
    ensures TP.Calls(out.context.history) == TP.Calls(c.history)+TP.Range(0,stop)
    ensures out.Success? ==> stop == |k.values| && |rows| == |k.values|
    ensures out.Success? && k.mode == T.Map ==> |out.values| == |k.values|
    ensures out.Success? && k.mode == T.Fold ==> out.values == []
    ensures out.Success? && k.mode != T.Fold ==> out.accumulator == k.initial
    ensures out.Success? && k.mode == T.Filter ==> |positions| == |out.values| &&
                                                   (forall j :: 0 <= j < |positions| ==> positions[j] < |k.values| && out.values[j] == k.values[positions[j]]) &&
                                                   (forall j :: 0 <= j < |positions|-1 ==> positions[j] < positions[j+1])
    ensures |k.values| == 0 ==> rows == [] && records == [] && lowHistory == h+C.CodecEvents(prep.history) && finalState == (if prep.Ready? then [prep.prepared] else [])
    ensures |k.values| == 0 && out.Success? ==> out.values == [] && out.accumulator == k.initial
  {
    var local;
    local,admitted,prep,fs,checks,prepEnv := Admission.Run(k,c);
    env := local;
    rows := []; records := [];
    finalState := if prep.Ready? then [prep.prepared] else [];
    lowHistory := h+C.CodecEvents(prep.history);
    if admitted.Success? {
      var config := M.TailConfig(k,fs);
      assert N.Budget(config,0,k.initial,prep.prepared,lowHistory) by { reveal M.Budget(); }
      var later; var tail; var p;
      later,tail,rows,records,p,lowHistory := Tail.Run(config,0,k.initial,admitted.context,prep.prepared,lowHistory);
      finalState := [p];
      env := E.Splice(local,later,|admitted.context.history|);
      Assemble.JoinAdmission(k.mode,k.inputType,k.outputType,k.values,k.initial,c,local,later);
      E.Before(local,later,|c.history|,|admitted.context.history|);
      E.After(local,later,|admitted.context.history|);
      Assemble.ChainBounds(k.mode,k.inputType,k.outputType,k.values,0,k.initial,admitted.context,rows);
      forall j | 0 <= j < |rows|
        ensures E.Window(env,rows[j].env,|rows[j].start.history|,|rows[j].out.context.history|)
      {
        assert |admitted.context.history| <= |rows[j].start.history|;
      }
    }
    out,positions,stop := Source.Run(k.mode,k.inputType,k.outputType,k.values,k.initial,c,env);
  }
}
