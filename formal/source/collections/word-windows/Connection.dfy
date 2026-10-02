// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsWordWindowsConnection {
  import opened AbiFrames
  import S = CollectionsWordWindowsSource
  import Mem = CollectionsWordMemoryModel
  import M = CollectionsWordWindowsModel
  import Proof = CollectionsWordWindowsProperties
  lemma Specification(n: nat,accOffset: nat,offsets: seq<nat>)
    ensures M.Windows(n,accOffset,offsets).Accepted? == (M.InBounds(n,accOffset) && (forall j :: 0 <= j < |offsets| ==> M.InBounds(n,offsets[j])))
  {
    if M.InBounds(n,accOffset) { Proof.ScanFacts(n,offsets,0); }
  }
  ghost method Run(memory: seq<Byte>,base: nat,original: seq<Byte>,accOffset: nat,acc: nat,offsets: seq<nat>,elem: nat)
    returns (admission: M.Admission,reason: seq<Byte>,after: seq<Byte>)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,base,original)
    requires Mem.Fits(accOffset) && Mem.Fits(acc) && Mem.Fits(elem) && Mem.Fits(|offsets|)
    requires forall j :: 0 <= j < |offsets| ==> Mem.Fits(offsets[j])
    ensures admission == M.Windows(|original|,accOffset,offsets)
    ensures admission.Rejected? ==> reason == S.ErrorBytes(admission.offset,|original|) && after == memory
    ensures admission.Accepted? ==> reason == [] && |after| == |memory| && Mem.Frame(after,base,M.Patch(original,[M.Write(accOffset,acc)]+M.ElementWrites(offsets,elem)))
    ensures admission.Accepted? ==> after[..base+32] == memory[..base+32] && after[base+32+|original|..] == memory[base+32+|original|..]
  {
    admission := S.CheckWindows(|original|,accOffset,offsets);
    after := memory; reason := [];
    if admission.Rejected? { reason := S.ErrorBytes(admission.offset,|original|); return; }
    Specification(|original|,accOffset,offsets);
    after := S.StampWindows(memory,base,original,accOffset,acc,offsets,elem);
  }

}
