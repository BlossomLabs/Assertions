// SPDX-License-Identifier: MIT
include "Control.generated.dfy"
module CollectionsValuePairsSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import M = CollectionsValuePairsModel
  import Ctrl = CollectionsValuePairsControl
  import Memory = AbiConstructionMemory
  import Words = AbiBytesSource
  ghost method Slice(bytes: seq<Byte>,start: nat,length: nat) returns (out: M.Split)
    requires Uint(|bytes|) && Uint(start) && Uint(length)
    ensures out == M.Span(bytes,start,length)
  {
    var copied; var r;
    copied,r := Memory.Slice(bytes,start,length);
    out := if r.Ok? then M.Parts([copied]) else M.SplitError(r.offset);
  }
  function Append(prefix: seq<seq<Byte>>,rest: M.Split): M.Split {
    if rest.Parts? then M.Parts(prefix+rest.values) else rest
  }
  ghost method Pair(p: M.Plan,bytes: seq<Byte>) returns (out: M.Split)
    requires Uint(|bytes|+32) && Uint(M.Head(p)+64)
    ensures out == M.SplitPair(p,bytes)
  {
    var base := Ctrl.Base(Dyn(p.left),Dyn(p.right));
    assert base == M.Base(p);
    if base != 0 {
      var first := Words.ReadWord(bytes,0);
      if !first.Ok? { out := M.SplitError(0); return; }
      assert Ctrl.EnvelopeWrong(first.used) == (first.used != 32);
      if Ctrl.EnvelopeWrong(first.used) { out := M.SplitError(0); return; }
    }
    assert base <= |bytes|;
    var parts: seq<seq<Byte>> := [];
    var head: nat := 0;
    var tail: nat := M.Head(p);
    var i: nat := 0;
    while Ctrl.Loop(i)
      invariant i <= 2 && head == M.HeadAt(p,i)
      invariant |parts| == i
      invariant Uint(base+tail) && Uint(base+head+32)
      invariant M.SplitPair(p,bytes) == Append(parts,M.SplitTail(p,bytes,i,tail))
      decreases 2-i
    {
      if Dyn(M.Side(p,i)) {
        var offset := Words.ReadWord(bytes,(base+head) as nat);
        if !offset.Ok? { out := M.SplitError(offset.offset); return; }
        assert Ctrl.OffsetWrong(offset.used,tail) == (offset.used != tail);
        if Ctrl.OffsetWrong(offset.used,tail) { out := M.SplitError((base+head) as nat); return; }
        assert Ctrl.NextBoundary(i,Dyn(p.right)) == (i == 0 && Dyn(p.right));
        var end: Outcome;
        if Ctrl.NextBoundary(i,Dyn(p.right)) { end := Words.ReadWord(bytes,(base+head+32) as nat); }
        else { end := Ok((|bytes|-base) as nat); }
        if !end.Ok? { out := M.SplitError(end.offset); return; }
        assert Ctrl.BoundaryWrong(end.used,tail) == (end.used < tail);
        if Ctrl.BoundaryWrong(end.used,tail) { out := M.SplitError((base+head) as nat); return; }
        var length := Ctrl.Span(end.used,tail);
        assert length == end.used-tail;
        var part := Slice(bytes,(base+tail) as nat,length as nat);
        if !part.Parts? { out := part; return; }
        parts := parts+[Word(32)+part.values[0]];
        tail := end.used;
      } else {
        var part := Slice(bytes,(base+head) as nat,32*Width(M.Side(p,i)));
        if !part.Parts? { out := part; return; }
        parts := parts+[part.values[0]];
      }
      head := head+32*Width(M.Side(p,i));
      i := i+1;
    }
    assert Ctrl.TailWrong(base as nat,tail,|bytes|) == (base+tail != |bytes|);
    if Ctrl.TailWrong(base as nat,tail,|bytes|) { out := M.SplitError((base+tail) as nat); return; }
    out := M.Parts(parts);
  }
}
