// SPDX-License-Identifier: MIT
include "Memory.dfy"
include "Control.generated.dfy"
module CollectionsWordApplyEngine {
  import opened AbiFrames
  import opened CollectionsWordApplyModel
  import Ctrl = CollectionsWordApplyControl
  import P = CollectionsWordApplyProperties
  import M = CollectionsWordApplyMemory
  import W = CollectionsWordWindowsModel
  import WP = CollectionsWordWindowsProperties
  import Mem = CollectionsWordMemoryModel
  import MP = CollectionsWordMemoryConnection
  import Call = CollectionsWordCallModel
  import Calls = CollectionsWordCallSource
  import C = CollectionsCallsModel
  import R = CollectionsCallbackResultsModel
  predicate Disjoint(a: nat,an: nat,b: nat,bn: nat) {
    a+32+an <= b || b+32+bn <= a
  }
  lemma PreserveOther(before: seq<Byte>,after: seq<Byte>,base: nat,n: nat,other: nat,payload: seq<Byte>)
    requires |before| == |after| && base+32+n <= |before|
    requires before[..base] == after[..base] && before[base+32+n..] == after[base+32+n..]
    requires Mem.Frame(before,other,payload) && Disjoint(base,n,other,|payload|)
    ensures Mem.Frame(after,other,payload)
  {
    if other+32+|payload| <= base {
      assert after[other..other+32+|payload|] == before[other..other+32+|payload|];
    } else {
      assert after[other..other+32+|payload|] == before[other..other+32+|payload|];
    }
  }
  ghost method Run(k: Config,start: seq<C.Event>,memory: seq<Byte>,callBase: nat,outBase: nat,initialPayload: seq<Byte>)
    returns (out: Outcome,after: seq<Byte>)
    requires Static(k) && Budget(k,0,start)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,callBase,k.template)
    requires Mem.Frame(memory,outBase,initialPayload) && |initialPayload| == |k.subject|
    requires Disjoint(callBase,|k.template|,outBase,|initialPayload|)
    ensures out == Tail(k,0,start) && |after| == |memory|
    ensures out.Finished? ==> Mem.Frame(after,outBase,Bytes(out.values))
  {
    after := memory;
    var payload := initialPayload;
    var previous: seq<W.Write> := [];
    var values: seq<nat> := []; var rows: seq<Row> := [];
    var i: nat := 0; var kept: nat := 0; var h := start;
    WP.Empty(k.template);
    while Ctrl.Loop(i,Count(k))
      invariant i <= Count(k) && kept == |values| && kept <= i
      invariant !k.filterMode ==> kept == i
      invariant Budget(k,i,h) && Tail(k,0,start) == Attach(values,rows,Tail(k,i,h))
      invariant |after| == |memory| && |payload| == |initialPayload|
      invariant Mem.Frame(after,outBase,payload) && payload[..32*kept] == Bytes(values)
      invariant Mem.Frame(after,callBase,W.Patch(k.template,previous))
      invariant previous == [] || (|previous| == |k.offsets| && (forall j :: 0 <= j < |previous| ==> previous[j].offset == k.offsets[j]))
      decreases Count(k)-i
    {
      var before := after;
      var data;
      after,data := M.Stamp(k,i,after,callBase,previous);
      PreserveOther(before,after,callBase,|k.template|,outBase,payload);
      var elem := Element(k,i);
      BytesNatRoundTrip(k.subject[32*i..32*i+32]);
      previous := W.ElementWrites(k.offsets,elem);
      assert Call.Room(k.operation,i,k.target,data,k.env(h,k.target,data)) by { reveal Budget(); }
      var answer; var nextHistory;
      answer,nextHistory := Calls.CallWord(k.operation,i,k.target,data,h,k.env);
      var row := Row(i,h,data,answer);
      if answer.Failure? {
        out := Attach(values,rows,Failed(answer.reason,i,nextHistory,[row])); return;
      }
      var word := answer.value;
      if Ctrl.Filter(k.filterMode) {
        if Ctrl.Invalid(word) {
          out := Attach(values,rows,Failed(R.InvalidBytes(R.Context(k.operation,i,0,k.target)),i,nextHistory,[row])); return;
        }
      }
      assert Checked(k,i,answer) == answer;
      assert Budget(k,i+1,nextHistory) by { reveal Budget(); }
      P.AttachNext(values,rows,Emit(k,i,word),row,Tail(k,i+1,nextHistory));
      before := after;
      if Ctrl.Filter(k.filterMode) {
        if Ctrl.Keep(word) {
          assert Ctrl.FilterIndex(kept) == |values|;
          after,payload := M.Append(after,outBase,payload,values,Ctrl.FilterValue(elem));
          assert Emit(k,i,word) == [elem];
          kept := kept+1;
        } else { assert Emit(k,i,word) == []; assert values+Emit(k,i,word) == values; }
      } else {
        assert Ctrl.MapIndex(i) == |values|;
        after,payload := M.Append(after,outBase,payload,values,Ctrl.MapValue(word,elem));
        assert Emit(k,i,word) == [word];
        kept := kept+1;
      }
      PreserveOther(before,after,outBase,|initialPayload|,callBase,W.Patch(k.template,previous));
      assert payload[..32*kept] == Bytes(values+Emit(k,i,word));
      values := values+Emit(k,i,word);
      rows := rows+[row]; h := nextHistory;
      assert i+1 < Pow256(32) && kept < Pow256(32);
      i := i+1;
    }
    out := Finished(values,h,rows);
    if Ctrl.ShrinkMode(k.filterMode) {
      M.Shrink(after,outBase,payload,kept);
      assert 32*kept <= |payload| < Pow256(32);
      MP.SmallMod(32*kept,Pow256(32));
      assert Ctrl.ShrinkBytes(kept) == 32*kept;
      after := Mem.Store(after,outBase,Ctrl.ShrinkBytes(kept));
    }
    assert payload[..32*kept] == Bytes(values);
  }
}
