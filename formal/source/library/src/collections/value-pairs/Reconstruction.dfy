// SPDX-License-Identifier: MIT
include "Properties.dfy"
module CollectionsValuePairsReconstruction {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import M = CollectionsValuePairsModel
  import Prop = CollectionsValuePairsProperties
  import ABI = AbiConstructionModel
  lemma ReadEqual(bytes: seq<Byte>,at: nat,number: nat)
    requires WordSpec(bytes,at) == Ok(number)
    ensures at+32 <= |bytes| && bytes[at..at+32] == Word(number)
  { BytesNatRoundTrip(bytes[at..at+32]); }
  lemma Reconstruct(p: M.Plan,bytes: seq<Byte>)
    requires M.SplitPair(p,bytes).Parts?
    ensures |M.SplitPair(p,bytes).values| == 2
    ensures Prop.Encoded(p,M.SplitPair(p,bytes).values) == bytes
  {
    M.PairLength(p,bytes); Prop.FieldsFacts(p);
    var values := M.SplitPair(p,bytes).values;
    var ps := ABI.Pieces(M.Fields(p),values);
    ABI.PiecesIndex(M.Fields(p),values);
    assert ps[0] == ABI.RawPiece(p.left,values[0]);
    assert ps[1] == ABI.RawPiece(p.right,values[1]);
    Prop.TwoFrame(ps);
    var base := M.Base(p); var head := M.Head(p);
    assert M.HeadAt(p,1) == 32*Width(p.left);
    if base == 32 { ReadEqual(bytes,0,32); }
    assert base <= |bytes|;
    assert M.SplitTail(p,bytes,0,head).Parts?;
    if Dyn(p.left) {
      assert head >= 32;
      ReadEqual(bytes,base,head);
      if Dyn(p.right) {
        assert head == 64;
        var boundary := WordSpec(bytes,base+32);
        assert boundary.Ok?;
        var end := boundary.used;
        ReadEqual(bytes,base+32,end);
        assert head <= end <= |bytes|-base;
        assert values[0] == Word(32)+bytes[base+head..base+end];
        assert values[1] == Word(32)+bytes[base+end..];
        assert ps[0].data == bytes[base+head..base+end] && ps[1].data == bytes[base+end..];
        assert HeadSize(ps) == head;
        Prop.TwoFrame(ps);
        assert bytes == bytes[..32]+bytes[32..64]+bytes[64..96]+bytes[96..base+end]+bytes[base+end..];
      } else {
        assert values[0] == Word(32)+bytes[base+head..];
        assert values[1] == bytes[base+32..base+head];
        assert ps[0].data == bytes[base+head..] && ps[1].data == bytes[base+32..base+head];
        assert HeadSize(ps) == head;
        Prop.TwoFrame(ps);
        assert bytes == bytes[..32]+bytes[32..64]+bytes[64..base+head]+bytes[base+head..];
      }
    } else if Dyn(p.right) {
      assert head >= 32;
      ReadEqual(bytes,base+32*Width(p.left),head);
      assert values[0] == bytes[base..base+head-32];
      assert values[1] == Word(32)+bytes[base+head..];
      assert ps[0].data == bytes[base..base+head-32] && ps[1].data == bytes[base+head..];
      assert HeadSize(ps) == head;
      Prop.TwoFrame(ps);
      assert bytes == bytes[..base]+bytes[base..base+head-32]+bytes[base+head-32..base+head]+bytes[base+head..];
    } else {
      assert |bytes| == head;
      assert values[0] == bytes[..32*Width(p.left)];
      assert values[1] == bytes[32*Width(p.left)..];
      assert ps[0].data == values[0] && ps[1].data == values[1];
      Prop.TwoFrame(ps);
    }
  }
}
