// SPDX-License-Identifier: MIT
include "Source.dfy"
module CollectionsWordLayoutConnection {
  import opened AbiFrames
  import opened CollectionsWordLayoutModel
  import S = CollectionsWordLayoutSource
  import M = CollectionsWordMemoryModel
  import MP = CollectionsWordMemoryConnection
  lemma Reconstruction(payload: seq<Byte>)
    requires |payload|%32 == 0
    ensures payload == Bytes(M.Words(payload))
    decreases |payload|
  {
    if |payload| > 0 {
      BytesNatRoundTrip(payload[..32]);
      Reconstruction(payload[32..]);
      assert M.Words(payload)[0] == ReadNat(payload[..32]);
      assert |M.Words(payload)[1..]| == |M.Words(payload[32..])|;
      forall j | 0 <= j < |M.Words(payload[32..])|
        ensures M.Words(payload)[1..][j] == M.Words(payload[32..])[j]
      { assert payload[32..][32*j..32*j+32] == payload[32*(j+1)..32*(j+1)+32]; }
      assert M.Words(payload)[1..] == M.Words(payload[32..]);
      assert payload == payload[..32]+payload[32..];
    }
  }
  ghost method Run(k: Config,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>)
    requires Basic(k) && Budget(k,memory,base)
    ensures out == S.Judge(k)
    ensures out.Returned? == Admitted(k)
    ensures out.Failed? ==> after == memory
    ensures out.Returned? ==> M.Frame(after,base,Bytes(out.values)) && |Bytes(out.values)| == Size(k)
    ensures out.Returned? ==> after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
    ensures out.Returned? ==> (forall j :: 0 <= j < |out.values| ==> M.Fits(out.values[j]))
    ensures out.Returned? && k.kind == Iota ==> |out.values| == k.n && (forall j :: 0 <= j < k.n ==> out.values[j] == j)
    ensures out.Returned? && k.kind == Reverse ==> |out.values| == Count(k.a) && (forall j :: 0 <= j < |out.values| ==> out.values[j] == Element(k.a,Count(k.a)-1-j))
    ensures out.Returned? && k.kind == Zip ==> |out.values| == 2*Count(k.a) && (forall j :: 0 <= j < Count(k.a) ==> out.values[2*j] == Element(k.a,j) && out.values[2*j+1] == Element(k.b,j))
    ensures out.Returned? && k.kind == Unzip ==> |out.values| == LaneCount(Count(k.a),k.lane) && (forall j :: 0 <= j < |out.values| ==> out.values[j] == Element(k.a,2*j+k.lane))
  {
    var payload;
    if k.kind == Iota { out,after,payload := S.IotaWords(k,memory,base); }
    else if k.kind == Reverse { out,after,payload := S.ReverseWords(k,memory,base); }
    else if k.kind == Zip { out,after,payload := S.ZipWords(k,memory,base); }
    else { out,after,payload := S.UnzipWords(k,memory,base); }
    if out.Returned? { Reconstruction(payload);
                       MP.WordBounds(payload); }
  }
}
