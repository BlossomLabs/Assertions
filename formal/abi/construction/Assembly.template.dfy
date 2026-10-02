// SPDX-License-Identifier: MIT
// Source $HASH; source kernels inserted by construction/generate.py.
include "Memory.dfy"

module AbiConstructionAssembly {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiConstructionMemory

  function Values(ps: seq<Piece>): seq<seq<Byte>>
    ensures |Values(ps)| == |ps|
  { seq(|ps|, i requires 0 <= i < |ps| => if ps[i].dynamic then Word(32)+ps[i].data else ps[i].data) }

  ghost method {:isolate_assertions} Assemble(flags: seq<bool>, headSize: nat, values: seq<seq<Byte>>, asArray: bool, ps: seq<Piece>)
    returns (out: seq<Byte>)
    requires values == Values(ps) && ValidPieces(ps)
    requires headSize == HeadSize(ps)
    requires if asArray then |flags| == 1 && (forall i :: 0 <= i < |ps| ==> flags[0] == ps[i].dynamic)
             else |flags| == |ps| && (forall i :: 0 <= i < |ps| ==> flags[i] == ps[i].dynamic)
    requires Uint(|ps|) && Uint((if asArray then 64 else 0)+HeadSize(ps)+TailSize(ps))
    ensures out == (if asArray then Word(32)+Word(|ps|) else [])+Frame(ps)
  {
    var prefix := $PREFIX;
    var size := headSize;
    var i := 0;
    while i < |values|
      invariant 0 <= i <= |ps|
      invariant size == headSize+TailSize(ps[..i])
      invariant size <= headSize+TailSize(ps)
    {
      assert values[i] == (if ps[i].dynamic then Word(32)+ps[i].data else ps[i].data);
      assert ps[..i+1] == ps[..i]+[ps[i]];
      SizesAppend(ps[..i],[ps[i]]);
      if flags[if asArray then 0 else i] { size := $SIZE_STEP; }
      i := i+1;
      assert ps == ps[..i]+ps[i..];
      SizesAppend(ps[..i],ps[i..]);
    }
    assert i == |ps| && ps[..i] == ps;
    assert size == headSize+TailSize(ps);
    out := Zeros(prefix+size);
    if asArray {
      ZeroSplit(32,32+size);
      WriteSpan([],Zeros(32),Zeros(32+size),Word(32));
      out := Store(out,0,32);
      ZeroSplit(32,size);
      WriteSpan(Word(32),Zeros(32),Zeros(size),Word(|values|));
      out := Store(out,32,|values|);
    }
    var pre := if asArray then Word(32)+Word(|ps|) else [];
    assert out == pre+Zeros(size);
    ZeroSplit(headSize,size-headSize);
    var head := 0;
    var tail := headSize;
    i := 0;
    while i < |values|
      invariant 0 <= i <= |ps|
      invariant head == HeadSize(ps[..i]) && tail == headSize+TailSize(ps[..i])
      invariant size == headSize+TailSize(ps)
      invariant head <= headSize && tail <= size
      invariant |out| == prefix+size
      invariant out == pre+Heads(ps[..i],headSize)+Zeros(headSize-head)+Tails(ps[..i])+Zeros(size-tail)
    {
      var v := values[i];
      assert v == (if ps[i].dynamic then Word(32)+ps[i].data else ps[i].data);
      assert ps[..i+1] == ps[..i]+[ps[i]];
      assert ps == ps[..i+1]+ps[i+1..];
      SizesAppend(ps[..i],[ps[i]]);
      SizesAppend(ps[..i+1],ps[i+1..]);
      Sizes(ps[..i],headSize);
      HeadsAppend(ps[..i],[ps[i]],headSize);
      TailsAppend(ps[..i],[ps[i]]);
      if flags[if asArray then 0 else i] {
        assert tail+|ps[i].data| == headSize+TailSize(ps[..i+1]);
        assert tail+|ps[i].data| <= size;
        PlaceNext(pre,Heads(ps[..i],headSize),headSize-head,Tails(ps[..i])+Zeros(size-tail),Word(tail));
        out := Store(out,prefix+head,tail);
        var heads := Heads(ps[..i+1],headSize);
        assert |heads| == head+32;
        assert out == (pre+heads+Zeros(headSize-head-32))+Tails(ps[..i])+Zeros(size-tail);
        PlaceNext(pre+heads+Zeros(headSize-head-32),Tails(ps[..i]),size-tail,[],ps[i].data);
        assert v[32..|v|] == ps[i].data;
        out := Copy(out,prefix+tail,v,32,|v|-32);
        head := $HEAD_DYNAMIC;
        tail := $TAIL_STEP;
        assert head == HeadSize(ps[..i+1]);
      } else {
        PlaceNext(pre,Heads(ps[..i],headSize),headSize-head,Tails(ps[..i])+Zeros(size-tail),v);
        out := Copy(out,prefix+head,v,0,|v|);
        head := $HEAD_STATIC;
        assert head == HeadSize(ps[..i+1]);
      }
      assert tail == headSize+TailSize(ps[..i+1]);
      i := i+1;
    }
    assert ps[..i] == ps;
  }
}
