// SPDX-License-Identifier: MIT
// Complete admitted actual body from original copy/allocation through stable merge and ABI RETURN.
include "../allocation-connection/Connection.dfy"
include "../sort-engine/Engine.dfy"
include "../serialization-connection/Connection.dfy"
module BytecodeSortWholeBody {
  import opened BytecodeScanMachine
  import A = BytecodeSortAllocationConnection
  import B = BytecodeSortEngine
  import R = BytecodeSortSerializationConnection
  import C = BytecodeSortBytesReturnControl
  import RM = BytecodeSortBytesReturnMemory
  import D = BytecodeSortCopyAllocationMemory
  import M = BytecodeWordSortMemory
  import O = BytecodeWordSortOriginalSpec
  import S = CollectionsSortModel
  import E = BytecodeScanExecution
  import X = BytecodeCopyExecution
  predicate Matches(code: seq<Byte>) { A.Matches(code) && B.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { A.Destinations()+B.Destinations()+C.Destinations() }
  lemma Lift(code: seq<Byte>, small: set<nat>, value: Word, data: seq<Byte>, trace: seq<State>)
    requires small <= Destinations() && E.Trace(code,small,value,data,trace)
    ensures X.Trace(code,Destinations(),value,data,trace)
  {
    forall i {:trigger trace[i]} | 0 <= i < |trace|-1
      ensures !trace[i].Running? || trace[i].pc >= |code| || Fetch(code,trace[i].pc).op !in {0x37,0x5e}
    { assert Step(code,small,trace[i],value,data) != Bad; reveal Step(); }
    X.Lift(code,small,value,data,trace);
    X.WidenTrace(code,small,Destinations(),value,data,trace);
  }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, data: seq<Byte>, value: Word)
    returns (state: State, trace: seq<State>, ids: seq<nat>)
    requires Matches(code) && D.Fits(n,offset,data)
    ensures |ids| == n && multiset(ids) == multiset(S.Range(0,n)) && O.Bounds(n,ids) && O.Sorted(O.Values(data,offset,n),ids)
    ensures state == Returned(RM.Bytes(n,O.Payload(data,offset,n,ids)))
    ensures X.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3468,[785862473,518,offset,n*32,96],Store([],64,128)) && trace[|trace|-1] == state
  {
    state,trace := A.Run(code,n,offset,value,data);
    X.WidenTrace(code,A.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>; var left: seq<nat>; var right: seq<nat>; var which: bool;
    state,part,left,right,which,ids := B.Run(code,n,offset,data,value);
    Lift(code,B.Destinations(),value,data,part);
    X.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..];
    state,part := R.Run(code,n,left,right,offset,data,which,value);
    X.WidenTrace(code,C.Destinations(),Destinations(),value,data,part);
    X.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..];
  }
}
