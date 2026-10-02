// SPDX-License-Identifier: MIT
// Generated from the complete structurally gated _foldLoop body.
include "Memory.dfy"
module CollectionsWordFoldLoopSource {
  import opened AbiFrames
  import opened CollectionsWordFoldLoopModel
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  import Calls = CollectionsWordCallSource
  import Stamp = CollectionsWordFoldLoopMemory
  import W = CollectionsWordWindowsModel
  import WP = CollectionsWordWindowsProperties
  import Mem = CollectionsWordMemoryModel
  lemma AttachNext(rows: seq<Row>,row: Row,out: Outcome)
    ensures Attach(rows,Prepend(row,out)) == Attach(rows+[row],out)
  {}
  ghost method Run(k: Config,initial: nat,start: seq<C.Event>,memory: seq<Byte>,base: nat)
    returns (out: Outcome,after: seq<Byte>)
    requires Static(k) && Mem.Fits(initial) && Budget(k,0,initial,start)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,base,k.template)
    ensures out == Tail(k,0,initial,start)
    ensures |after| == |memory|
    ensures after[..base+32] == memory[..base+32] && after[base+32+|k.template|..] == memory[base+32+|k.template|..]
    ensures out.Finished? ==> Mem.Fits(out.value)
  {
    var i: nat := 0; var acc := initial; var h := start;
    var rows: seq<Row> := []; var previous: seq<W.Write> := [];
    after := memory; WP.Empty(k.template);
    while $LOOP
      invariant i <= k.count && Mem.Fits(acc) && Budget(k,i,acc,h)
      invariant Tail(k,0,initial,start) == Attach(rows,Tail(k,i,acc,h))
      invariant |after| == |memory| && Mem.Frame(after,base,W.Patch(k.template,previous))
      invariant previous == [] || (|previous| == |Writes(k,0,0)| && (forall j :: 0 <= j < |previous| ==> previous[j].offset == Writes(k,0,0)[j].offset))
      invariant after[..base+32] == memory[..base+32] && after[base+32+|k.template|..] == memory[base+32+|k.template|..]
      decreases k.count-i
    {
      var data;
      after,data := Stamp.Stamp(k,i,acc,after,base,previous);
      previous := Writes(k,acc,Call.Element(k.domain,i,k.subject));
      Stamp.SameOffsets(k,acc,Call.Element(k.domain,i,k.subject),0,0);
      assert Call.Room(k.operation,i,k.target,data,k.env(h,k.target,data)) by { reveal Budget(); }
      var answer; var nextHistory;
      answer,nextHistory := Calls.CallWord(k.operation,i,k.target,data,h,k.env);
      var row := Row(i,acc,h,data,answer);
      if answer.Failure? {
        out := Attach(rows,Failed(answer.reason,i,nextHistory,[row])); return;
      }
      var nextValue := answer.value;
      if Stop(k.exit,nextValue) {
        assert Tail(k,i,acc,h) == Finished(nextValue,i+1,nextHistory,[row]);
      } else {
        assert Budget(k,i+1,nextValue,nextHistory) by { reveal Budget(); }
        AttachNext(rows,row,Tail(k,i+1,nextValue,nextHistory));
      }
      acc := $FEEDBACK;
      if $ANY { out := Finished(acc,i+1,nextHistory,rows+[row]); return; }
      if $ALL { out := Finished(acc,i+1,nextHistory,rows+[row]); return; }
      rows := rows+[row]; h := nextHistory;
      assert i+1 < Pow256(32);
      i := i+1;
    }
    out := Finished(acc,i,h,rows);
  }
}
