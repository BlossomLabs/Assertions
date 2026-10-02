// SPDX-License-Identifier: MIT
include "EntryReady.dfy"
module CollectionsWordApplySource {
  import opened AbiFrames
  import opened CollectionsWordApplyEntryModel
  import Ctrl = CollectionsWordApplyControl
  import Ready = CollectionsWordApplyEntryReady
  import L = CollectionsWordApplyModel
  import Loop = CollectionsWordApplyLoopConnection
  import C = CollectionsCallsModel
  import Calls = CollectionsWordCallSource
  import W = CollectionsWordWindowsModel
  import Windows = CollectionsWordWindowsSource
  import M = CollectionsWordApplyMemory
  import MP = CollectionsWordMemoryConnection
  import Mem = CollectionsWordMemoryModel
  function Build(k: Config): L.Config
    ensures Build(k) == LoopConfig(k)
  { L.Config(k.subject,k.template,k.offsets,if k.filterMode then Ctrl.FilterMode() else Ctrl.MapMode(),Operation(k),k.target,k.env) }
  ghost method Run(k: Config,h: seq<C.Event>,memory: seq<Byte>,callBase: nat,outBase: nat)
    returns (out: Outcome,after: seq<Byte>,tail: seq<L.Outcome>)
    requires Basic(k) && Budget(k,h,memory,callBase,outBase)
    ensures Allocates(k) ==> L.Static(LoopConfig(k))
    ensures out == Judge(k,h)
    ensures |tail| <= 1 && (|tail| == 1) == Reaches(k,h)
    ensures Reaches(k,h) ==> tail[0] == L.Tail(LoopConfig(k),0,h+[C.Target(k.target)]) && out == Project(tail[0])
    ensures out.Returned? ==> Mem.Frame(after,outBase,L.Bytes(out.values))
    ensures !Reaches(k,h) ==> after == memory
    ensures Allocates(k) ==> |after| == |memory|
  {
    out := Failed([],h,[]); after := memory; tail := []; Ready.Static(k);
    if Ctrl.Unaligned(|k.subject|) { out := Failed(Unaligned(k),h,[]); return; }
    var admitted := Windows.CheckElements(|k.template|,k.offsets);
    if admitted.Rejected? { out := Failed(Windows.ErrorBytes(admitted.offset,|k.template|),h,[]); return; }
    var count := Ctrl.Count(|k.subject|);
    // new bytes(s.length): the reached allocation is projected by Budget.
    assert Mem.Frame(memory,outBase,Zero(|k.subject|));
    if Ctrl.Nonempty(count) {
      var reason; var nextHistory;
      reason,nextHistory := Calls.CheckTarget(k.target,h,k.code);
      if reason != [] { out := Failed(reason,nextHistory,[]); return; }
      // bytes memory callData = template: the faithful disjoint copy is
      // required only after the nonempty target check succeeds.
      var result;
      result,after := Loop.Run(Build(k),nextHistory,memory,callBase,outBase,Zero(|k.subject|));
      tail := [result]; out := Project(result);
    } else {
      out := Returned([],h,[]);
      if Ctrl.ShrinkMode(k.filterMode) {
        M.Shrink(after,outBase,Zero(0),0);
        MP.SmallMod(0,Pow256(32));
        assert Ctrl.ShrinkBytes(0) == 0;
        assert Mem.Store(after,outBase,0) == after;
        after := Mem.Store(after,outBase,Ctrl.ShrinkBytes(0));
      }
    }
  }
}
