// SPDX-License-Identifier: MIT
include "Engine.dfy"
include "Output.dfy"
module CollectionsWordApplyLoopConnection {
  import opened AbiFrames
  import opened CollectionsWordApplyModel
  import E = CollectionsWordApplyEngine
  import O = CollectionsWordApplyOutput
  import P = CollectionsWordApplyProperties
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  import Mem = CollectionsWordMemoryModel
  ghost method Run(k: Config,start: seq<C.Event>,memory: seq<Byte>,callBase: nat,outBase: nat,initialPayload: seq<Byte>)
    returns (out: Outcome,after: seq<Byte>)
    requires Static(k) && Budget(k,0,start)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,callBase,k.template)
    requires Mem.Frame(memory,outBase,initialPayload) && |initialPayload| == |k.subject|
    requires E.Disjoint(callBase,|k.template|,outBase,|initialPayload|)
    ensures out == Tail(k,0,start) && |after| == |memory|
    ensures out.history == start+P.Events(k,out.rows) && |out.history| == |start|+|out.rows|
    ensures |out.rows| <= Count(k)
    ensures out.Failed? ==> |out.rows| > 0 && out.index == |out.rows|-1 && Checked(k,out.index,out.rows[|out.rows|-1].answer) == Call.Failure(out.reason)
    ensures forall j :: 0 <= j < |out.rows| ==> out.rows[j].index == j && j < Count(k) && out.rows[j].data == Data(k,j) && out.rows[j].answer == Answer(k,j,out.rows[j].before)
    ensures |out.rows| > 0 ==> out.rows[0].before == start
    ensures out.Finished? ==> Mem.Frame(after,outBase,Bytes(out.values)) && |out.rows| == Count(k) && |out.values| <= Count(k)
    ensures out.Finished? && !k.filterMode ==> |out.values| == Count(k)
    ensures out.Finished? ==> O.Good(k,out.rows) && out.values == O.Values(k,out.rows) && |out.values| == |O.Selected(k,out.rows)|
    ensures out.Finished? ==> (forall i :: 0 <= i < Count(k) ==> (i in O.Selected(k,out.rows) <==> (!k.filterMode || out.rows[i].answer.value == 1)))
    ensures out.Finished? && k.filterMode ==> (forall j :: 0 <= j < |out.values| ==> O.Selected(k,out.rows)[j] < Count(k) && out.values[j] == Element(k,O.Selected(k,out.rows)[j]))
    ensures out.Finished? && !k.filterMode ==> (forall j :: 0 <= j < |out.values| ==> out.values[j] == out.rows[j].answer.value && O.Selected(k,out.rows)[j] == j)
    ensures out.Finished? ==> (forall a,b :: 0 <= a < b < |O.Selected(k,out.rows)| ==> O.Selected(k,out.rows)[a] < O.Selected(k,out.rows)[b])
  {
    out,after := E.Run(k,start,memory,callBase,outBase,initialPayload);
    Facts(k,start,out);
  }
  lemma Facts(k: Config,start: seq<C.Event>,out: Outcome)
    requires Static(k) && out == Tail(k,0,start)
    ensures out.history == start+P.Events(k,out.rows) && |out.history| == |start|+|out.rows|
    ensures |out.rows| <= Count(k)
    ensures out.Failed? ==> |out.rows| > 0 && out.index == |out.rows|-1 && Checked(k,out.index,out.rows[|out.rows|-1].answer) == Call.Failure(out.reason)
    ensures forall j :: 0 <= j < |out.rows| ==> out.rows[j].index == j && j < Count(k) && out.rows[j].data == Data(k,j) && out.rows[j].answer == Answer(k,j,out.rows[j].before)
    ensures |out.rows| > 0 ==> out.rows[0].before == start
    ensures out.Finished? ==> |out.rows| == Count(k) && |out.values| <= Count(k)
    ensures out.Finished? && !k.filterMode ==> |out.values| == Count(k)
    ensures out.Finished? ==> O.Good(k,out.rows) && out.values == O.Values(k,out.rows) && |out.values| == |O.Selected(k,out.rows)|
    ensures out.Finished? ==> (forall i :: 0 <= i < Count(k) ==> (i in O.Selected(k,out.rows) <==> (!k.filterMode || out.rows[i].answer.value == 1)))
    ensures out.Finished? && k.filterMode ==> (forall j :: 0 <= j < |out.values| ==> O.Selected(k,out.rows)[j] < Count(k) && out.values[j] == Element(k,O.Selected(k,out.rows)[j]))
    ensures out.Finished? && !k.filterMode ==> (forall j :: 0 <= j < |out.values| ==> out.values[j] == out.rows[j].answer.value && O.Selected(k,out.rows)[j] == j)
    ensures out.Finished? ==> (forall a,b :: 0 <= a < b < |O.Selected(k,out.rows)| ==> O.Selected(k,out.rows)[a] < O.Selected(k,out.rows)[b])
  {
    P.Bounds(k,0,start); P.History(k,0,start); P.Last(k,0,start);
    forall j {:trigger out.rows[j]} | 0 <= j < |out.rows|
      ensures out.rows[j].index == j && j < Count(k) && out.rows[j].data == Data(k,j) && out.rows[j].answer == Answer(k,j,out.rows[j].before)
      ensures j == 0 ==> out.rows[j].before == start
      ensures j > 0 ==> Checked(k,j-1,out.rows[j-1].answer).Word? && out.rows[j].before == out.rows[j-1].before+[C.External(k.target,out.rows[j-1].data)]
    { P.RowAt(k,0,start,j); }
    if out.Finished? {
      O.Success(k,0,start); O.Length(k,out.rows);
      forall i | 0 <= i < Count(k)
        ensures i in O.Selected(k,out.rows) <==> (!k.filterMode || out.rows[i].answer.value == 1)
      {
        P.RowAt(k,0,start,i);
        O.Membership(k,out.rows,i);
        if !k.filterMode || out.rows[i].answer.value == 1 {
          assert exists j :: 0 <= j < |out.rows| && out.rows[j].index == i && (!k.filterMode || out.rows[j].answer.value == 1);
        }
        if exists j :: 0 <= j < |out.rows| && out.rows[j].index == i && (!k.filterMode || out.rows[j].answer.value == 1) {
          var j :| 0 <= j < |out.rows| && out.rows[j].index == i && (!k.filterMode || out.rows[j].answer.value == 1);
          assert j == i;
        }
      }
      forall j | 0 <= j < |out.values|
        ensures k.filterMode ==> O.Selected(k,out.rows)[j] < Count(k) && out.values[j] == Element(k,O.Selected(k,out.rows)[j])
        ensures !k.filterMode ==> out.values[j] == out.rows[j].answer.value && O.Selected(k,out.rows)[j] == j
      { if k.filterMode { O.FilterAt(k,out.rows,j); } else { O.MapAt(k,out.rows,j); } }
      forall a,b | 0 <= a < b < |O.Selected(k,out.rows)|
        ensures O.Selected(k,out.rows)[a] < O.Selected(k,out.rows)[b]
      { O.Stable(k,out.rows,a,b); }
    }
  }
}
