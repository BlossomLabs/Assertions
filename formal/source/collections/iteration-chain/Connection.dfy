// SPDX-License-Identifier: MIT
include "Step.dfy"
module CollectionsIterationChainConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import ABI = AbiConstructionModel
  import D = AbiDynamicSemantics
  import VC = AbiConstructionContext
  import V = CollectionsValidationConnection
  import VM = CollectionsValidationModel
  import Call = CollectionsBoundCallConnection
  import B = CollectionsBoundCallModel
  import R = CollectionsCallbackResultsModel
  import Result = CollectionsCallResultsConnection
  import RM = CollectionsCallResultsModel
  import Wire = CollectionsWireModel
  import M = CollectionsIterationModel
  import N = CollectionsIterationChainModel
  import S = CollectionsIterationChainStep
  import E = CollectionsEnvironmentModel
  import Assemble = CollectionsEnvironmentConnection

  lemma EmptyBudget(k: N.Config, acc: seq<Byte>, p: P.Prepared, h: seq<C.Event>)
    ensures N.Budget(k,|k.values|,acc,p,h)
  { reveal N.Budget(); }
  lemma InputFailureBudget(k: N.Config, index: nat, acc: seq<Byte>, p: P.Prepared, h: seq<C.Event>)
    requires index < |k.values| && N.LocalRoom(k,index,acc,p,h)
    requires VM.Reply(T.Validate(k.inputType,k.values[index]),0,0).Error?
    ensures N.Budget(k,index,acc,p,h)
  { reveal N.Budget(); }
  lemma At(k: N.Config, index: nat, acc: seq<Byte>, c: T.Context, p: P.Prepared, h: seq<C.Event>, rows: seq<E.Row>, records: seq<N.Record>, j: nat)
    requires index <= |k.values| && N.Trace(k,index,acc,c,p,h,rows,records)
    requires j < |rows|
    ensures index+j < |k.values|
    ensures Uint(|k.inputType|) && Uint(|k.outputType|) && |records[j].calls| <= 1
    ensures N.RecordAt(k,index+j,rows[j].accumulator,records[j].before,records[j].history,records[j])
    ensures rows[j].env == N.Environment(k.mode,k.inputType,k.outputType,k.values[index+j],index+j,rows[j].accumulator,k.operation,k.cb.target,rows[j].start,records[j].calls)
    ensures rows[j].out == T.Step(k.mode,k.inputType,k.outputType,k.values[index+j],index+j,rows[j].accumulator,rows[j].start,rows[j].env)
    ensures j == 0 ==> records[j].before == p && records[j].history == h && rows[j].start == c && rows[j].accumulator == acc
    ensures j > 0 ==> rows[j-1].out.Success? && records[j].before == records[j-1].prepared && records[j].history == records[j-1].lowHistory && rows[j].start == rows[j-1].out.context && rows[j].accumulator == rows[j-1].out.accumulator
    ensures rows[j].out.Success? ==> |records[j].calls| == 1 && records[j].calls[0].Returned? && ABI.ValidInputs(k.fs,records[j].prepared.args) && records[j].prepared.targetChecked
    ensures rows[j].out.Success? ==> rows[j].out.accumulator == (if k.mode == T.Fold then records[j].calls[0].value else rows[j].accumulator)
    decreases j
  {
    assert records[0].before == p && records[0].history == h by { reveal N.RecordAt(); }
    if j > 0 {
      assert rows[0].out.Success?;
      At(k,index+1,rows[0].out.accumulator,rows[0].out.context,records[0].prepared,records[0].lowHistory,rows[1..],records[1..],j-1);
      assert rows[1..][j-1] == rows[j];
      assert records[1..][j-1] == records[j];
      if j > 1 {
        assert rows[1..][j-2] == rows[j-1];
        assert records[1..][j-2] == records[j-1];
      }
    }
  }
  lemma Stop(k: N.Config, index: nat, acc: seq<Byte>, c: T.Context, p: P.Prepared, h: seq<C.Event>, rows: seq<E.Row>, records: seq<N.Record>)
    requires index <= |k.values| && N.Trace(k,index,acc,c,p,h,rows,records)
    ensures |rows| <= |k.values|-index
    ensures forall j :: 0 <= j < |rows|-1 ==> rows[j].out.Success?
    ensures E.Collected(rows,acc,c).Success? ==> |rows| == |k.values|-index
    ensures E.Collected(rows,acc,c).Failure? ==> |rows| > 0 && rows[|rows|-1].out == E.Collected(rows,acc,c)
    decreases |k.values|-index
  {
    if index == |k.values| { return; }
    if rows[0].out.Failure? { return; }
    Stop(k,index+1,rows[0].out.accumulator,rows[0].out.context,records[0].prepared,records[0].lowHistory,rows[1..],records[1..]);
    if |rows| > 1 { assert rows[1..][|rows|-2] == rows[|rows|-1]; }
    forall j | 0 <= j < |rows|-1
      ensures rows[j].out.Success?
    {
      if j > 0 { assert rows[1..][j-1] == rows[j]; }
    }
  }

  ghost method Build(k: N.Config, index: nat, acc: seq<Byte>, c: T.Context, p: P.Prepared, h: seq<C.Event>)
    returns (rows: seq<E.Row>, records: seq<N.Record>, prepared: P.Prepared, lowHistory: seq<C.Event>)
    requires index <= |k.values| && N.Budget(k,index,acc,p,h)
    ensures N.Trace(k,index,acc,c,p,h,rows,records)
    ensures |rows| <= |k.values|-index
    ensures (|rows| == 0) == (index == |k.values|)
    ensures prepared == N.FinalPrepared(p,records) && lowHistory == N.FinalHistory(h,records)
    decreases |k.values|-index
  {
    rows := []; records := []; prepared := p; lowHistory := h;
    if index == |k.values| { return; }
    assert N.LocalRoom(k,index,acc,p,h) by { reveal N.Budget(); }
    var env; var out; var next; var calls; var nextHistory; var callEnv; var r1; var r2;
    env,out,next,calls,nextHistory,callEnv,r1,r2 := S.Step(k.mode,k.inputType,k.outputType,k.values[index],index,acc,k.operation,c,k.fs,k.cb,p.args,p.targetChecked,h,k.base);
    var row := E.Row(c,acc,env,out);
    var record := N.Record(p,h,next,nextHistory,calls,callEnv,r1,r2);
    assert N.RecordAt(k,index,acc,p,h,record) by { reveal N.RecordAt(); }
    rows := [row]; records := [record]; prepared := next; lowHistory := nextHistory;
    if out.Failure? { return; }
    assert |calls| == 1 && calls[0].Returned?;
    assert VM.Reply(T.Validate(k.inputType,k.values[index]),0,0).Ok?;
    assert RM.Reply(calls[0],k.outputType,R.Context(k.operation,index,0,k.cb.target),k.mode == T.Filter).Ok?;
    assert out.accumulator == (if k.mode == T.Fold then calls[0].value else acc);
    assert N.Budget(k,index+1,out.accumulator,next,nextHistory) by { reveal N.Budget(); }
    var rest; var tail;
    rest,tail,prepared,lowHistory := Build(k,index+1,out.accumulator,out.context,next,nextHistory);
    rows := [row]+rest; records := [record]+tail;
    if |tail| > 0 { assert records[|records|-1] == tail[|tail|-1]; }
  }

  ghost method Run(k: N.Config, index: nat, acc: seq<Byte>, c: T.Context, p: P.Prepared, h: seq<C.Event>)
    returns (env: T.Environment, out: T.Outcome, rows: seq<E.Row>, records: seq<N.Record>, prepared: P.Prepared, lowHistory: seq<C.Event>)
    requires index <= |k.values| && N.Budget(k,index,acc,p,h)
    ensures N.Trace(k,index,acc,c,p,h,rows,records)
    ensures |rows| <= |k.values|-index
    ensures out == T.Tail(k.mode,k.inputType,k.outputType,k.values,index,acc,c,env)
    ensures out == E.Collected(rows,acc,c)
    ensures forall j :: 0 <= j < |rows|-1 ==> rows[j].out.Success?
    ensures out.Success? ==> |rows| == |k.values|-index
    ensures out.Failure? ==> |rows| > 0 && rows[|rows|-1].out == out
    ensures forall j :: 0 <= j < |rows| ==> E.Window(env,rows[j].env,|rows[j].start.history|,|rows[j].out.context.history|)
    ensures prepared == N.FinalPrepared(p,records) && lowHistory == N.FinalHistory(h,records)
  {
    rows,records,prepared,lowHistory := Build(k,index,acc,c,p,h);
    env := Assemble.Assemble(k.mode,k.inputType,k.outputType,k.values,index,acc,c,rows);
    out := E.Collected(rows,acc,c);
    Stop(k,index,acc,c,p,h,rows,records);
  }
}
