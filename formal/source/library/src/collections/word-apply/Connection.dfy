// SPDX-License-Identifier: MIT
include "Source.dfy"
module CollectionsWordApplyConnection {
  import opened AbiFrames
  import opened CollectionsWordApplyEntryModel
  import S = CollectionsWordApplySource
  import L = CollectionsWordApplyModel
  import Loop = CollectionsWordApplyLoopConnection
  import P = CollectionsWordApplyProperties
  import O = CollectionsWordApplyOutput
  import Mem = CollectionsWordMemoryModel
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  lemma NoCopyOrCallbackBudget(k: Config,h: seq<C.Event>,memory: seq<Byte>,callBase: nat,outBase: nat)
    requires Basic(k) && !Reaches(k,h)
    requires Allocates(k) ==> Mem.Fits(|memory|) && Mem.Frame(memory,outBase,Zero(|k.subject|))
    ensures Budget(k,h,memory,callBase,outBase)
  {}
  lemma NoAllocationBudget(k: Config,h: seq<C.Event>,memory: seq<Byte>,callBase: nat,outBase: nat)
    requires Basic(k) && !Allocates(k)
    ensures Budget(k,h,memory,callBase,outBase)
  {}
  lemma RowAt(k: Config,h: seq<C.Event>,out: Outcome,j: nat)
    requires Basic(k) && Reaches(k,h) && L.Static(LoopConfig(k))
    requires out == Judge(k,h) && j < |out.rows|
    ensures j < L.Count(LoopConfig(k))
    ensures out.rows[j].index == j && out.rows[j].data == L.Data(LoopConfig(k),j)
    ensures out.rows[j].answer == L.Answer(LoopConfig(k),j,out.rows[j].before)
    ensures j == 0 ==> out.rows[j].before == h+[C.Target(k.target)]
    ensures j > 0 ==> L.Checked(LoopConfig(k),j-1,out.rows[j-1].answer).Word? && out.rows[j].before == out.rows[j-1].before+[C.External(k.target,out.rows[j-1].data)]
    ensures j < |out.rows|-1 ==> L.Checked(LoopConfig(k),j,out.rows[j].answer).Word?
  { P.Bounds(LoopConfig(k),0,h+[C.Target(k.target)]); P.RowAt(LoopConfig(k),0,h+[C.Target(k.target)],j); }
  ghost method Run(k: Config,h: seq<C.Event>,memory: seq<Byte>,callBase: nat,outBase: nat)
    returns (out: Outcome,after: seq<Byte>,tail: seq<L.Outcome>)
    requires Basic(k) && Budget(k,h,memory,callBase,outBase)
    ensures Allocates(k) ==> L.Static(LoopConfig(k))
    ensures out == Judge(k,h)
    ensures |tail| <= 1 && (|tail| == 1) == Reaches(k,h)
    ensures !Aligned(k) ==> out == Failed(Unaligned(k),h,[])
    ensures Allocates(k) && L.Count(LoopConfig(k)) == 0 ==> out == Returned([],h,[])
    ensures !Reaches(k,h) ==> after == memory && out.rows == []
    ensures Reaches(k,h) ==> tail[0] == L.Tail(LoopConfig(k),0,h+[C.Target(k.target)]) && out == Project(tail[0])
    ensures Reaches(k,h) ==> out.history == h+[C.Target(k.target)]+P.Events(LoopConfig(k),out.rows) && |out.rows| <= L.Count(LoopConfig(k))
    ensures Reaches(k,h) ==> (forall j :: 0 <= j < |out.rows| ==> out.rows[j].index == j && j < L.Count(LoopConfig(k)) && out.rows[j].data == L.Data(LoopConfig(k),j) && out.rows[j].answer == L.Answer(LoopConfig(k),j,out.rows[j].before))
    ensures Reaches(k,h) && out.Failed? ==> |out.rows| > 0 && out.rows[|out.rows|-1].index == |out.rows|-1 && L.Checked(LoopConfig(k),|out.rows|-1,out.rows[|out.rows|-1].answer) == Call.Failure(out.reason)
    ensures out.Returned? ==> Allocates(k) && Mem.Frame(after,outBase,L.Bytes(out.values)) && |out.rows| == L.Count(LoopConfig(k)) && |out.values| <= |out.rows|
    ensures out.Returned? && !k.filterMode ==> |out.values| == L.Count(LoopConfig(k))
    ensures out.Returned? ==> O.Good(LoopConfig(k),out.rows) && out.values == O.Values(LoopConfig(k),out.rows) && |out.values| == |O.Selected(LoopConfig(k),out.rows)|
    ensures out.Returned? ==> (forall i :: 0 <= i < L.Count(LoopConfig(k)) ==> (i in O.Selected(LoopConfig(k),out.rows) <==> (!k.filterMode || out.rows[i].answer.value == 1)))
    ensures out.Returned? && k.filterMode ==> (forall j :: 0 <= j < |out.values| ==> O.Selected(LoopConfig(k),out.rows)[j] < L.Count(LoopConfig(k)) && out.values[j] == L.Element(LoopConfig(k),O.Selected(LoopConfig(k),out.rows)[j]))
    ensures out.Returned? && !k.filterMode ==> (forall j :: 0 <= j < |out.values| ==> out.values[j] == out.rows[j].answer.value && O.Selected(LoopConfig(k),out.rows)[j] == j)
    ensures out.Returned? ==> (forall a,b :: 0 <= a < b < |O.Selected(LoopConfig(k),out.rows)| ==> O.Selected(LoopConfig(k),out.rows)[a] < O.Selected(LoopConfig(k),out.rows)[b])
  {
    out,after,tail := S.Run(k,h,memory,callBase,outBase);
    if Reaches(k,h) { Loop.Facts(LoopConfig(k),h+[C.Target(k.target)],tail[0]); }
  }
}
