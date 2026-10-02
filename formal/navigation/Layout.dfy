// SPDX-License-Identifier: MIT
include "Model.dfy"

module NavigationLayout {
  import opened AbiFrames
  import opened AbiEncoding
  import opened NavigationModel

  ghost predicate Located(t: AbiType, v: Value, data: seq<Byte>, base: nat)
    requires WellTyped(t,v)
  {
    base+|Body(t,v)| <= |data| && data[base..base+|Body(t,v)|] == Body(t,v)
  }

  ghost function Prefix(t: AbiType): nat {
    if t.Array? then 32 else 0
  }

  ghost function HeadOffset(t: AbiType, v: Value, i: nat): nat
    requires WellTyped(t,v) && Aggregate(t) && i < |v.values|
  { Prefix(t)+HeadSize(Parts(t,v)[..i]) }

  ghost function ChildOffset(t: AbiType, v: Value, i: nat): nat
    requires WellTyped(t,v) && Aggregate(t) && i < |v.values|
  {
    Prefix(t)+(if IsDynamic(Child(t,i)) then
                 HeadSize(Parts(t,v))+TailSize(Parts(t,v)[..i])
               else HeadSize(Parts(t,v)[..i]))
  }

  lemma Subrange(data: seq<Byte>, start: nat, end: nat, a: nat, b: nat)
    requires start <= end <= |data| && a <= b <= end-start
    ensures data[start..end][a..b] == data[start+a..start+b]
  {
    assert forall i :: 0 <= i < b-a ==>
                         data[start..end][a..b][i] == data[start+a..start+b][i];
  }

  lemma ChildLocation(t: AbiType, v: Value, data: seq<Byte>, base: nat, i: nat)
    requires WellTyped(t,v) && Fits(t,v) && Aggregate(t) && i < |v.values|
    requires Located(t,v,data,base)
    ensures Located(Child(t,i),v.values[i],data,base+ChildOffset(t,v,i))
    ensures base+ChildOffset(t,v,i)+|Body(Child(t,i),v.values[i])| <= base+|Body(t,v)|
    ensures base+HeadOffset(t,v,i)+32*HeadWords(Child(t,i)) <= base+|Body(t,v)|
    ensures IsDynamic(Child(t,i)) ==>
              ReadNat(data[base+HeadOffset(t,v,i)..base+HeadOffset(t,v,i)+32]) ==
              ChildOffset(t,v,i)-Prefix(t)
  {
    var ps := Parts(t,v);
    var frame := Frame(ps);
    var pre := Prefix(t);
    BodiesAreFrames(t,v);
    EncodedLengthsFit(t,v);
    HeadFootprint(Child(t,i),v.values[i]);
    ComponentLayout(ps,i);
    Sizes(ps,HeadSize(ps));
    assert Body(t,v)[pre..] == frame;
    var whole := Body(t,v);
    var h := HeadOffset(t,v,i);
    var p := ChildOffset(t,v,i);
    var len := |Body(Child(t,i),v.values[i])|;
    assert data[base..base+|whole|] == whole;
    assert whole[p..p+len] == ps[i].data;
    Subrange(data,base,base+|whole|,p,p+len);
    assert data[base+p..base+p+len] == whole[p..p+len];
    if ps[i].dynamic {
      TightOffsets(ps,i);
      assert whole[h..h+32] == frame[h-pre..h-pre+32];
      Subrange(data,base,base+|whole|,h,h+32);
      assert data[base+h..base+h+32] == whole[h..h+32];
    }
  }

  lemma HeadPrefix(t: AbiType, v: Value, i: nat)
    requires WellTyped(t,v) && Aggregate(t) && i <= |v.values|
    ensures HeadSize(Parts(t,v)[..i]) ==
            32*Sum(seq(i,j requires 0 <= j < i => HeadWords(Child(t,j))))
  {
    var ps := Parts(t,v)[..i];
    var ws := seq(i,j requires 0 <= j < i => HeadWords(Child(t,j)));
    forall j | 0 <= j < i
      ensures (if ps[j].dynamic then 32 else |ps[j].data|) == 32*ws[j]
    { HeadFootprint(Child(t,j),v.values[j]); }
    HeadSum(ps,ws);
  }

  lemma ArrayHead(t: AbiType, v: Value, i: nat)
    requires WellTyped(t,v) && (t.Array? || t.FixedArray?) && i <= |v.values|
    ensures HeadSize(Parts(t,v)[..i]) == 32*i*HeadWords(t.element)
  {
    HeadPrefix(t,v,i);
    assert seq(i,j requires 0 <= j < i => HeadWords(Child(t,j))) == seq(i,j => HeadWords(t.element));
    SumRepeated(i,HeadWords(t.element));
  }

  lemma LengthWord(t: AbiType, v: Value, data: seq<Byte>, base: nat)
    requires WellTyped(t,v) && Fits(t,v) && HasLength(t)
    requires Located(t,v,data,base)
    ensures base+32 <= |data|
    ensures ReadNat(data[base..base+32]) == Length(t,v)
  {
    EncodedLengthsFit(t,v);
    if t.Array? { ArrayCount(t,v); }
    else { BytePayload(t,v.payload); }
    assert data[base..base+32] == Body(t,v)[..32];
  }

  // Model of the actual cursor operation: a dynamic child address comes from
  // the input's offset word, not from a trusted recomputation of its tail size.
  ghost method ReadChild(t: AbiType, v: Value, data: seq<Byte>, base: nat, index: int)
    returns (next: nat)
    requires WellTyped(t,v) && Fits(t,v) && InRange(t,v,index)
    requires Located(t,v,data,base)
    ensures next == base+ChildOffset(t,v,Position(index,|v.values|))
    ensures Located(Child(t,Position(index,|v.values|)),v.values[Position(index,|v.values|)],data,next)
    ensures next >= base
  {
    var i := Position(index,|v.values|);
    ChildLocation(t,v,data,base,i);
    var head := base+HeadOffset(t,v,i);
    if IsDynamic(Child(t,i)) {
      next := base+Prefix(t)+ReadNat(data[head..head+32]);
    } else { next := head; }
  }

  ghost method Follow(t: AbiType, v: Value, data: seq<Byte>, base: nat, path: seq<int>)
    returns (next: nat)
    requires WellTyped(t,v) && Fits(t,v) && Located(t,v,data,base)
    requires Select(t,v,path).Selected?
    ensures Located(Select(t,v,path).selectedType,Select(t,v,path).selectedValue,data,next)
    ensures next >= base
    decreases |path|
  {
    if |path| == 0 { next := base; return; }
    var i := Position(path[0],|v.values|);
    var childBase := ReadChild(t,v,data,base,path[0]);
    next := Follow(Child(t,i),v.values[i],data,childBase,path[1..]);
  }
}
