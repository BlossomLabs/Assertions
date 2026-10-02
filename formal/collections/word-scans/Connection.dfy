// SPDX-License-Identifier: MIT
include "Source.dfy"
module CollectionsWordScansConnection {
  import opened AbiFrames
  import opened CollectionsWordScansModel
  import S = CollectionsWordScansSource
  import Mem = CollectionsWordMemoryModel
  ghost method Index(s: seq<Byte>,needle: nat) returns (out: Outcome)
    requires Basic(s,needle)
    ensures !Aligned(s) ==> out == Failed(S.UnalignedBytes(s))
    ensures Aligned(s) ==> out.Returned? && out.value <= Count(s)
    ensures Aligned(s) && out.value < Count(s) ==> Element(s,out.value) == needle
    ensures Aligned(s) ==> (forall j :: 0 <= j < out.value ==> Element(s,j) != needle)
    ensures Aligned(s) ==> out.value == Find(s,needle,0)
  { out := S.Index(s,needle); if Aligned(s) { FindFacts(s,needle,0); } }
  ghost method SumWords(s: seq<Byte>) returns (out: Outcome)
    requires Mem.Fits(|s|)
    ensures !Aligned(s) ==> out == Failed(S.UnalignedBytes(s))
    ensures Aligned(s) ==> out == (if Sum(s,Count(s)) < Limit() then Returned(Sum(s,Count(s))) else Failed(Panic()))
    ensures out.Returned? ==> Mem.Fits(out.value)
  { out := S.SumWords(s); if Aligned(s) { TotalFacts(s,0,0); } }
}
