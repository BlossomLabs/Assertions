// SPDX-License-Identifier: MIT
// Generated from _fold and the three complete public wrapper gates.
include "Ready.dfy"
module CollectionsWordFoldEntrySource {
  import opened AbiFrames
  import opened CollectionsWordFoldEntryModel
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  import Calls = CollectionsWordCallSource
  import L = CollectionsWordFoldLoopModel
  import Loop = CollectionsWordFoldLoopConnection
  import W = CollectionsWordWindowsModel
  import Windows = CollectionsWordWindowsSource
  import Mem = CollectionsWordMemoryModel
  import Ready = CollectionsWordFoldEntryReady
  function Build(k: Config): L.Config
    ensures Build(k) == LoopConfig(k)
  {
    if k.domain == Call.Range then L.Config(Call.Range,k.count,[],k.template,k.accOffset,k.offsets,k.exit,Operation(k),k.target,k.env) else
    if k.domain == Call.Bytes then L.Config(Call.Bytes,|k.subject|,k.subject,k.template,k.accOffset,k.offsets,k.exit,Operation(k),k.target,k.env) else
    L.Config(Call.Words,(|k.subject| / 32),k.subject,k.template,k.accOffset,k.offsets,k.exit,Operation(k),k.target,k.env)
  }
  ghost method Run(k: Config,h: seq<C.Event>,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>,tail: seq<L.Outcome>)
    requires Basic(k) && Budget(k,h,memory,base)
    ensures Admission(k).Accepted? ==> L.Static(LoopConfig(k))
    ensures out == Judge(k,h)
    ensures |tail| <= 1 && (|tail| == 1) == Reaches(k,h)
    ensures Reaches(k,h) ==> tail[0] == L.Tail(LoopConfig(k),0,k.initial,h+[C.Target(k.target)]) && out == Project(tail[0])
    ensures Reaches(k,h) ==> |after| == |memory| && after[..base+32] == memory[..base+32] && after[base+32+|k.template|..] == memory[base+32+|k.template|..]
    ensures !Reaches(k,h) ==> after == memory
    ensures out.Returned? ==> Mem.Fits(out.value)
  {
    after := memory; tail := []; Ready.Static(k);
    if k.domain == Call.Words && ((|k.subject| % 32) != 0) { out := Failed(Unaligned(k),h,[]); return; }
    var run := Build(k);
    var admitted := Windows.CheckWindows(|k.template|,k.accOffset,k.offsets);
    if admitted.Rejected? { out := Failed(Windows.ErrorBytes(admitted.offset,|k.template|),h,[]); return; }
    if (run.count == 0) { out := Returned(k.initial,h,[]); return; }
    var reason; var nextHistory;
    reason,nextHistory := Calls.CheckTarget(k.target,h,k.code);
    if reason != [] { out := Failed(reason,nextHistory,[]); return; }
    assert k.code(h,k.target) != 0;
    var result;
    result,after := Loop.Run(run,k.initial,nextHistory,memory,base);
    tail := [result]; out := Project(result);
  }
}
