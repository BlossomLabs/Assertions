// SPDX-License-Identifier: MIT
include "Control.generated.dfy"
module CollectionsWordUniqueSource {
  import opened AbiFrames
  import opened CollectionsWordUniqueModel
  import Ctrl = CollectionsWordUniqueControl
  import M = CollectionsWordMemoryModel
  import P = CollectionsWordMemoryConnection
  datatype Outcome = Returned(values: seq<nat>,indices: seq<nat>) | Failed(reason: seq<Byte>)
  function Unaligned(k: Config): seq<Byte> { Ctrl.UnalignedSelector()+Word(|k.subject|) }
  lemma Shrink(memory: seq<Byte>,base: nat,payload: seq<Byte>,kept: nat)
    requires M.Fits(|memory|) && M.Frame(memory,base,payload) && 32*kept <= |payload|
    ensures M.Frame(M.Store(memory,base,32*kept),base,payload[..32*kept])
    ensures M.Store(memory,base,32*kept)[..base] == memory[..base]
    ensures M.Store(memory,base,32*kept)[base+32..] == memory[base+32..]
  {
    P.Outside(memory,base,32*kept,base+32,|memory|);
    assert memory[base+32..base+32+32*kept] == payload[..32*kept];
  }
  ghost method Scan(memory: seq<Byte>,base: nat,payload: seq<Byte>,kept: nat,word: nat) returns (seen: bool)
    requires M.Fits(|memory|) && M.Frame(memory,base,payload) && kept <= |payload|/32 && M.Fits(word)
    ensures seen == (word in M.Words(payload)[..kept])
  {
    var j: nat := 0;
    while Ctrl.Scan(j,kept)
      invariant j <= kept
      invariant forall x :: 0 <= x < j ==> M.Words(payload)[x] != word
      decreases kept-j
    {
      var previous := P.Read(memory,base,payload,j);
      if Ctrl.Equal(previous,word) { seen := true; assert word in M.Words(payload)[..kept]; return; }
      assert j+1 < Pow256(32); j := j+1;
    }
    assert j == kept;
    seen := false;
    if word in M.Words(payload)[..kept] {
      var x :| 0 <= x < kept && M.Words(payload)[..kept][x] == word;
      assert M.Words(payload)[x] == word;
    }
  }
  ghost method Run(k: Config,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>,payload: seq<Byte>)
    requires M.Fits(|k.subject|)
    requires |k.subject|%32 == 0 ==> M.Fits(|memory|) && M.Frame(memory,base,Zero(|k.subject|))
    ensures |k.subject|%32 != 0 ==> out == Failed(Unaligned(k)) && after == memory
    ensures forall j :: 0 <= j < |Selected(k,Count(k))| ==> Selected(k,Count(k))[j] < Count(k)
    ensures |k.subject|%32 == 0 ==> out == Returned(Project(k,Selected(k,Count(k))),Selected(k,Count(k)))
    ensures out.Returned? ==> |after| == |memory| && after[..base] == memory[..base] && after[base+32+|k.subject|..] == memory[base+32+|k.subject|..]
    ensures out.Returned? ==> M.Frame(after,base,payload) && |payload| == 32*|out.values| && M.Words(payload) == out.values
  {
    after := memory; payload := []; SelectedBounds(k,Count(k));
    if Ctrl.Unaligned(|k.subject|) { out := Failed(Unaligned(k)); return; }
    payload := Zero(|k.subject|);
    var i: nat := 0; var kept: nat := 0;
    SelectedBounds(k,0);
    while Ctrl.Loop(i,|k.subject|)
      invariant i <= Count(k) && kept == |Selected(k,i)| && kept <= i
      invariant i > 0 ==> kept > 0
      invariant forall j :: 0 <= j < |Selected(k,i)| ==> Selected(k,i)[j] < Count(k)
      invariant |after| == |memory| && M.Frame(after,base,payload) && |payload| == |k.subject|
      invariant after[..base+32] == memory[..base+32] && after[base+32+|k.subject|..] == memory[base+32+|k.subject|..]
      invariant M.Words(payload)[..kept] == Project(k,Selected(k,i))
      decreases Count(k)-i
    {
      var word := Element(k,i); BytesNatRoundTrip(k.subject[32*i..32*i+32]);
      var seen := false;
      if Ctrl.Ordered(k.ordered) {
        if Ctrl.Nonempty(kept) {
          var previous := P.Read(after,base,payload,kept-1);
          Last(k,i);
          seen := Ctrl.Equal(previous,word);
          assert seen == (Element(k,i-1) == word);
        } else { assert i == 0; }
      } else {
        seen := Scan(after,base,payload,kept,word);
        Member(k,i,word);
      }
      assert seen == !Keep(k,i);
      assert Ctrl.Unseen(seen) == Keep(k,i);
      if Ctrl.Unseen(seen) {
        var beforeWords := M.Words(payload);
        after := P.Write(after,base,payload,kept,word);
        P.Assignment(payload,kept,word);
        payload := M.Store(payload,32*kept,word);
        ProjectAppend(k,Selected(k,i),i);
        assert M.Words(payload)[..kept+1] == beforeWords[..kept]+[word];
        kept := kept+1;
      }
      SelectedBounds(k,i+1);
      if Keep(k,i) {
        ProjectAppend(k,Selected(k,i),i);
        assert Selected(k,i+1) == Selected(k,i)+[i];
      } else { assert Selected(k,i+1) == Selected(k,i); }
      assert M.Words(payload)[..kept] == Project(k,Selected(k,i+1));
      assert i+1 < Pow256(32); i := i+1;
    }
    var values := Project(k,Selected(k,Count(k)));
    Shrink(after,base,payload,kept); P.SmallMod(32*kept,Pow256(32));
    assert Ctrl.ShrinkBytes(kept) == 32*kept;
    after := M.Store(after,base,Ctrl.ShrinkBytes(kept));
    var original := payload; payload := payload[..32*kept];
    forall j | 0 <= j < kept
      ensures M.Words(payload)[j] == M.Words(original)[j]
    { assert payload[32*j..32*j+32] == original[32*j..32*j+32]; }
    assert M.Words(payload) == M.Words(original)[..kept];
    out := Returned(values,Selected(k,Count(k)));
  }
}
