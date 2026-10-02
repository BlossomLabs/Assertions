// SPDX-License-Identifier: MIT
include "Control.generated.dfy"
module CollectionsWordScansSource {
  import opened AbiFrames
  import opened CollectionsWordScansModel
  import Ctrl = CollectionsWordScansControl
  import Mem = CollectionsWordMemoryModel
  function UnalignedBytes(s: seq<Byte>): seq<Byte> { Ctrl.UnalignedSelector()+Word(|s|) }
  ghost method Index(s: seq<Byte>,needle: nat) returns (out: Outcome)
    requires Basic(s,needle)
    ensures !Aligned(s) ==> out == Failed(UnalignedBytes(s))
    ensures Aligned(s) ==> out == Returned(Find(s,needle,0))
  {
    if Ctrl.Unaligned(|s|) { out := Failed(UnalignedBytes(s)); return; }
    var count := Ctrl.Count(|s|); var i: nat := 0;
    while Ctrl.Loop(i,count)
      invariant i <= Count(s) && count == Count(s)
      invariant Find(s,needle,0) == Find(s,needle,i)
      decreases Count(s)-i
    {
      var element := Element(s,i);
      BytesNatRoundTrip(s[32*i..32*i+32]);
      if Ctrl.Equal(element,needle) { out := Returned(i); return; }
      assert 32*i+32 <= |s| && i+1 < Limit();
      i := i+1;
    }
    out := Returned(count);
  }
  ghost method SumWords(s: seq<Byte>) returns (out: Outcome)
    requires Mem.Fits(|s|)
    ensures !Aligned(s) ==> out == Failed(UnalignedBytes(s))
    ensures Aligned(s) ==> out == Total(s,0,0)
  {
    if Ctrl.Unaligned(|s|) { out := Failed(UnalignedBytes(s)); return; }
    var count := Ctrl.Count(|s|); var i: nat := 0; var total: nat := 0;
    while Ctrl.Loop(i,count)
      invariant i <= Count(s) && count == Count(s) && total < Limit()
      invariant Total(s,0,0) == Total(s,i,total)
      decreases Count(s)-i
    {
      var element := Element(s,i);
      BytesNatRoundTrip(s[32*i..32*i+32]);
      // Solidity checked +=: retain exact overflow Panic(0x11).
      var next := Ctrl.Next(total,element);
      if next >= Limit() { out := Failed(Panic()); return; }
      total := next;
      assert 32*i+32 <= |s| && i+1 < Limit();
      i := i+1;
    }
    out := Returned(total);
  }
}
