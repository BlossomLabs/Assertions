// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsWordFoldEntryConnection {
  import opened AbiFrames
  import opened CollectionsWordFoldEntryModel
  import S = CollectionsWordFoldEntrySource
  import C = CollectionsCallsModel
  import L = CollectionsWordFoldLoopModel
  import Loop = CollectionsWordFoldLoopConnection
  import Mem = CollectionsWordMemoryModel
  lemma NoLoopBudget(k: Config,h: seq<C.Event>,memory: seq<Byte>,base: nat)
    requires Basic(k) && !Reaches(k,h)
    ensures Budget(k,h,memory,base)
  {}
  ghost method Run(k: Config,h: seq<C.Event>,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>,tail: seq<L.Outcome>)
    requires Basic(k) && Budget(k,h,memory,base)
    ensures Admission(k).Accepted? ==> L.Static(LoopConfig(k))
    ensures out == Judge(k,h)
    ensures |tail| <= 1 && (|tail| == 1) == Reaches(k,h)
    ensures !Aligned(k) ==> out == Failed(Unaligned(k),h,[])
    ensures Aligned(k) && Admission(k).Accepted? && Count(k) == 0 ==> out == Returned(k.initial,h,[])
    ensures Reaches(k,h) ==> tail[0] == L.Tail(LoopConfig(k),0,k.initial,h+[C.Target(k.target)]) && out == Project(tail[0])
    ensures out.Returned? ==> Mem.Fits(out.value)
    ensures Reaches(k,h) ==> out.history == h+[C.Target(k.target)]+Loop.Events(LoopConfig(k),out.rows)
    ensures Reaches(k,h) ==> |out.rows| <= Count(k)
    ensures Reaches(k,h) && out.Returned? && k.exit == L.Full ==> |out.rows| == Count(k)
    ensures Reaches(k,h) && out.Returned? && |out.rows| > 0 ==> out.rows[|out.rows|-1].answer.Word? && out.rows[|out.rows|-1].answer.value == out.value && (|out.rows| == Count(k) || L.Stop(k.exit,out.value))
    ensures Reaches(k,h) && out.Failed? ==> |out.rows| > 0 && out.rows[|out.rows|-1].answer.Failure? && out.rows[|out.rows|-1].answer.reason == out.reason
    ensures Reaches(k,h) ==> (forall j :: 0 <= j < |out.rows| ==> out.rows[j].index == j && j < Count(k) && out.rows[j].data == L.Data(LoopConfig(k),j,out.rows[j].acc) && out.rows[j].answer == L.Answer(LoopConfig(k),j,out.rows[j].acc,out.rows[j].before))
    ensures Reaches(k,h) ==> (forall j :: 0 <= j < |out.rows|-1 ==> out.rows[j].answer.Word? && !L.Stop(k.exit,out.rows[j].answer.value))
    ensures !Reaches(k,h) ==> after == memory && out.rows == []
  {
    out,after,tail := S.Run(k,h,memory,base);
    if Reaches(k,h) {
      var cfg := LoopConfig(k); var start := h+[C.Target(k.target)];
      Loop.Bounds(cfg,0,k.initial,start); Loop.History(cfg,0,k.initial,start); Loop.Last(cfg,0,k.initial,start);
      forall j | 0 <= j < |out.rows|
        ensures out.rows[j].index == j && j < Count(k) && out.rows[j].data == L.Data(cfg,j,out.rows[j].acc) && out.rows[j].answer == L.Answer(cfg,j,out.rows[j].acc,out.rows[j].before)
        ensures j < |out.rows|-1 ==> out.rows[j].answer.Word? && !L.Stop(k.exit,out.rows[j].answer.value)
      { Loop.RowAt(cfg,0,k.initial,start,j); }
    }
  }
}
