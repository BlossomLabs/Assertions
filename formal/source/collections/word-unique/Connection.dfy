// SPDX-License-Identifier: MIT
include "Source.dfy"
module CollectionsWordUniqueConnection {
  import opened AbiFrames
  import opened CollectionsWordUniqueModel
  import S = CollectionsWordUniqueSource
  import M = CollectionsWordMemoryModel
  import P = CollectionsWordMemoryConnection
  lemma Reconstruction(payload: seq<Byte>)
    requires |payload|%32 == 0
    ensures payload == Bytes(M.Words(payload))
    decreases |payload|
  {
    if |payload| > 0 {
      BytesNatRoundTrip(payload[..32]); Reconstruction(payload[32..]);
      forall j | 0 <= j < |M.Words(payload[32..])|
        ensures M.Words(payload)[1..][j] == M.Words(payload[32..])[j]
      { assert payload[32..][32*j..32*j+32] == payload[32*(j+1)..32*(j+1)+32]; }
      assert M.Words(payload)[1..] == M.Words(payload[32..]);
      assert payload == payload[..32]+payload[32..];
    }
  }
  ghost method Run(k: Config,memory: seq<Byte>,base: nat) returns (out: S.Outcome,after: seq<Byte>)
    requires M.Fits(|k.subject|)
    requires |k.subject|%32 == 0 ==> M.Fits(|memory|) && M.Frame(memory,base,Zero(|k.subject|))
    ensures |k.subject|%32 != 0 ==> out == S.Failed(S.Unaligned(k)) && after == memory
    ensures out.Returned? == (|k.subject|%32 == 0)
    ensures out.Returned? ==> |after| == |memory| && after[..base] == memory[..base] && after[base+32+|k.subject|..] == memory[base+32+|k.subject|..]
    ensures out.Returned? ==> out.indices == Selected(k,Count(k))
    ensures out.Returned? ==> |out.values| == |out.indices| && |out.values| <= Count(k) && M.Frame(after,base,Bytes(out.values))
    ensures out.Returned? ==> (forall j :: 0 <= j < |out.values| ==> out.indices[j] < Count(k) && out.values[j] == Element(k,out.indices[j]) && M.Fits(out.values[j]))
    ensures out.Returned? ==> (forall a,b :: 0 <= a < b < |out.indices| ==> out.indices[a] < out.indices[b])
    ensures out.Returned? ==> (forall i :: 0 <= i < Count(k) ==> (i in out.indices <==> Keep(k,i)))
    ensures out.Returned? && !k.ordered ==> (forall a,b :: 0 <= a < b < |out.values| ==> out.values[a] != out.values[b])
    ensures out.Returned? && Grouped(k) ==> out.indices == Selected(Config(k.subject,!k.ordered),Count(k))
  {
    var payload;
    out,after,payload := S.Run(k,memory,base);
    if out.Returned? {
      var n := Count(k); SelectedBounds(k,n); Reconstruction(payload); P.WordBounds(payload);
      forall j | 0 <= j < |out.values|
        ensures out.indices[j] < n && out.values[j] == Element(k,out.indices[j]) && M.Fits(out.values[j])
      { ProjectAt(k,out.indices,j); }
      forall i | 0 <= i < n ensures i in out.indices <==> Keep(k,i) { Selection(k,n,i); }
      if !k.ordered {
        forall a,b | 0 <= a < b < |out.values| ensures out.values[a] != out.values[b]
        { NoDuplicates(k,n,a,b); }
      }
      if Grouped(k) { GroupedEquivalent(k,n); }
    }
  }
}
