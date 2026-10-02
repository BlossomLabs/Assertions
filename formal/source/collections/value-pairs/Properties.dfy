// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsValuePairsProperties {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiConnectionModel
  import M = CollectionsValuePairsModel
  import ABI = AbiConstructionModel
  function Encoded(p: M.Plan,values: seq<seq<Byte>>): seq<Byte>
    requires |values| == 2
  { (if M.Base(p) == 32 then Word(32) else [])+Frame(ABI.Pieces(M.Fields(p),values)) }
  lemma {:fuel WidthSum, 4} FieldsFacts(p: M.Plan)
    ensures WidthSum(M.Fields(p)) == Width(p.left)+Width(p.right)
    ensures Dyn(Group(M.Fields(p))) == (Dyn(p.left) || Dyn(p.right))
  { assert M.Fields(p) == [p.left,p.right]; }
  lemma WordAt(prefix: seq<Byte>,number: nat,suffix: seq<Byte>)
    requires Uint(number)
    ensures WordSpec(prefix+Word(number)+suffix,|prefix|) == Ok(number)
  {
    NatBytesRoundTrip(number,32);
    assert (prefix+Word(number)+suffix)[|prefix|..|prefix|+32] == Word(number);
  }
  lemma Canonical(p: M.Plan,values: seq<seq<Byte>>)
    requires ABI.ValidInputs(M.Fields(p),values) && Good(Group(M.Fields(p)))
    requires Uint(32+ABI.TotalBytes(values))
    ensures WellFormed(TypeOf(Group(M.Fields(p)))) && WellTyped(TypeOf(Group(M.Fields(p))),Items(ABI.Decoded(M.Fields(p),values)))
    ensures ValidInput(p,values)
    ensures Validate(TypeOf(Group(M.Fields(p))),Encoded(p,values)).Parsed?
    ensures Encoded(p,values) == Encode(TypeOf(Group(M.Fields(p))),Items(ABI.Decoded(M.Fields(p),values)))
  {
    FieldsFacts(p);
    ABI.CanonicalPieces(M.Fields(p),values);
    ModelType(Group(M.Fields(p))); TypesIndex(M.Fields(p));
    assert Children(TypeOf(Group(M.Fields(p))),2) == TypesOf(M.Fields(p));
    AggregateParts(TypeOf(Group(M.Fields(p))),ABI.Decoded(M.Fields(p),values));
    ABI.FrameBudget(M.Fields(p),values); Sizes(ABI.Pieces(M.Fields(p),values),M.Head(p));
    assert Encoded(p,values) == Encode(TypeOf(Group(M.Fields(p))),Items(ABI.Decoded(M.Fields(p),values)));
    assert |Encoded(p,values)| <= 32+ABI.TotalBytes(values);
    FitsFromSize(TypeOf(Group(M.Fields(p))),Items(ABI.Decoded(M.Fields(p),values)));
    ValidationComplete(TypeOf(Group(M.Fields(p))),Items(ABI.Decoded(M.Fields(p),values)));
  }
  ghost predicate ValidInput(p: M.Plan,values: seq<seq<Byte>>) {
    |values| == 2 && ABI.ValidInputs(M.Fields(p),values)
  }
  lemma {:fuel HeadSize, 4} TwoFrame(ps: seq<Piece>)
    requires |ps| == 2
    ensures HeadSize(ps) == (if ps[0].dynamic then 32 else |ps[0].data|)+(if ps[1].dynamic then 32 else |ps[1].data|)
    ensures Frame(ps) ==
            (if ps[0].dynamic then Word(HeadSize(ps)) else ps[0].data)+
            (if ps[1].dynamic then Word(HeadSize(ps)+(if ps[0].dynamic then |ps[0].data| else 0)) else ps[1].data)+
            (if ps[0].dynamic then ps[0].data else [])+(if ps[1].dynamic then ps[1].data else [])
  {
    assert ps == [ps[0]]+[ps[1]];
    HeadsAppend([ps[0]],[ps[1]],HeadSize(ps));
    TailsAppend([ps[0]],[ps[1]]);
    assert Heads([ps[0]],HeadSize(ps)) == (if ps[0].dynamic then Word(HeadSize(ps)) else ps[0].data);
    assert Heads([ps[1]],HeadSize(ps)+(if ps[0].dynamic then |ps[0].data| else 0)) ==
           (if ps[1].dynamic then Word(HeadSize(ps)+(if ps[0].dynamic then |ps[0].data| else 0)) else ps[1].data);
  }
  lemma {:fuel M.SplitTail, 3} Last(p: M.Plan,bytes: seq<Byte>,tail: nat,value: seq<Byte>)
    requires M.Base(p) <= |bytes|
    requires if Dyn(p.right) then
               WordSpec(bytes,M.Base(p)+M.HeadAt(p,1)) == Ok(tail) && tail <= |bytes|-M.Base(p) && value == Word(32)+bytes[M.Base(p)+tail..]
             else M.Base(p)+M.HeadAt(p,1)+32*Width(p.right) <= |bytes| &&
                  value == bytes[M.Base(p)+M.HeadAt(p,1)..M.Base(p)+M.HeadAt(p,1)+32*Width(p.right)] && M.Base(p)+tail == |bytes|
    ensures M.SplitTail(p,bytes,1,tail) == M.Parts([value])
  {
    assert M.Side(p,1) == p.right;
    if Dyn(p.right) {
      reveal M.Span();
      assert M.Base(p)+tail <= |bytes|;
      assert |bytes|-M.Base(p)-tail == |bytes|-(M.Base(p)+tail);
      assert bytes[M.Base(p)+tail..M.Base(p)+tail+(|bytes|-M.Base(p)-tail)] == bytes[M.Base(p)+tail..];
      assert M.Base(p)+tail+(|bytes|-M.Base(p)-tail) == |bytes|;
      assert M.Span(bytes,M.Base(p)+tail,|bytes|-M.Base(p)-tail) == M.Parts([bytes[M.Base(p)+tail..]]);
      assert M.SplitTail(p,bytes,2,|bytes|-M.Base(p)) == M.Parts([]);
    }
    else { assert M.SplitTail(p,bytes,2,tail) == M.Parts([]); }
  }
  lemma First(p: M.Plan,bytes: seq<Byte>,end: nat,data: seq<Byte>,rest: seq<seq<Byte>>)
    requires Dyn(p.left) && M.Base(p) <= |bytes|
    requires WordSpec(bytes,M.Base(p)) == Ok(M.Head(p))
    requires if Dyn(p.right) then WordSpec(bytes,M.Base(p)+32) == Ok(end) else end == |bytes|-M.Base(p)
    requires end >= M.Head(p) && M.Span(bytes,M.Base(p)+M.Head(p),end-M.Head(p)) == M.Parts([data])
    requires M.SplitTail(p,bytes,1,end) == M.Parts(rest)
    ensures M.SplitTail(p,bytes,0,M.Head(p)) == M.Parts([Word(32)+data]+rest)
  {
    assert M.HeadAt(p,0) == 0 && M.Side(p,0) == p.left;
  }
  lemma {:fuel M.SplitTail, 4} SplitFrame(p: M.Plan,values: seq<seq<Byte>>)
    requires ABI.ValidInputs(M.Fields(p),values)
    requires Uint(32+ABI.TotalBytes(values))
    ensures M.SplitPair(p,Encoded(p,values)) == M.Parts(values)
  {
    reveal M.Span(); reveal WordSpec();
    FieldsFacts(p);
    ABI.CanonicalPieces(M.Fields(p),values); ABI.PiecesIndex(M.Fields(p),values);
    ABI.FrameBudget(M.Fields(p),values);
    var ps := ABI.Pieces(M.Fields(p),values);
    assert values == [values[0],values[1]];
    assert M.Fields(p) == [p.left,p.right];
    assert WidthSum(M.Fields(p)) == Width(p.left)+Width(p.right);
    assert ps[0] == ABI.RawPiece(p.left,values[0]);
    assert ps[1] == ABI.RawPiece(p.right,values[1]);
    ABI.CanonicalPiece(p.left,values[0]); ABI.CanonicalPiece(p.right,values[1]);
    assert values[0] == (if Dyn(p.left) then Word(32) else [])+ps[0].data;
    assert values[1] == (if Dyn(p.right) then Word(32) else [])+ps[1].data;
    var a := ps[0].data; var b := ps[1].data;
    var head := M.Head(p);
    Sizes(ps,head); TwoFrame(ps);
    assert HeadSize(ps) == head;
    assert ps == [ps[0],ps[1]];
    assert M.HeadAt(p,1) == 32*Width(p.left);
    var bytes := Encoded(p,values);
    if Dyn(p.left) || Dyn(p.right) { WordAt([],32,Frame(ps)); }
    if Dyn(p.left) {
      assert Width(p.left) == 1;
      if Dyn(p.right) {
        assert head == 64;
        assert M.HeadAt(p,1) == 32;
        assert bytes == Word(32)+Word(head)+Word(head+|a|)+a+b;
        WordAt(Word(32),head,Word(head+|a|)+a+b);
        assert |Word(32)| == 32;
        assert bytes == Word(32)+Word(head)+(Word(head+|a|)+a+b);
        assert WordSpec(bytes,|Word(32)|) == Ok(head);
        assert WordSpec(bytes,32) == Ok(head);
        WordAt(Word(32)+Word(head),head+|a|,a+b);
        assert bytes[32+head..32+head+|a|] == a;
        assert bytes[32+head+|a|..] == b;
        assert M.SplitTail(p,bytes,2,head+|a|+|b|) == M.Parts([]);
        assert M.Base(p) == 32;
        assert |Word(32)+Word(head)| == 64;
        assert bytes == (Word(32)+Word(head))+Word(head+|a|)+(a+b);
        assert WordSpec(bytes,|Word(32)+Word(head)|) == Ok(head+|a|);
        assert WordSpec(bytes,64) == Ok(head+|a|);
        assert |bytes| == 32+head+|a|+|b|;
        assert head+|a| <= |bytes|-32;
        assert values[1] == Word(32)+bytes[32+head+|a|..];
        Last(p,bytes,head+|a|,values[1]);
        assert M.Span(bytes,32+head,|a|) == M.Parts([a]);
        First(p,bytes,head+|a|,a,[values[1]]);
      } else {
        assert bytes == Word(32)+Word(head)+b+a;
        WordAt(Word(32),head,b+a);
        assert M.Base(p) == 32;
        assert |Word(32)| == 32;
        assert bytes == Word(32)+Word(head)+(b+a);
        assert WordSpec(bytes,|Word(32)|) == Ok(head);
        assert WordSpec(bytes,32) == Ok(head);
        assert bytes[64..64+|b|] == b;
        assert bytes[32+head..] == a;
        assert M.SplitTail(p,bytes,2,head+|a|) == M.Parts([]);
        Last(p,bytes,head+|a|,values[1]);
        assert |bytes|-32 == head+|a|;
        assert 32+head+|a| == |bytes|;
        assert bytes[32+head..32+head+|a|] == a;
        assert M.Span(bytes,32+head,|a|) == M.Parts([a]);
        First(p,bytes,head+|a|,a,[values[1]]);
      }
      assert M.Side(p,0) == p.left;
      assert M.HeadAt(p,0) == 0;
      if Dyn(p.right) {
        var end := head+|a|;
        assert M.Span(bytes,32+head,end-head) == M.Parts([a]);
      } else {
        assert |bytes|-32-head == |a|;
        assert bytes[32+head..32+head+|a|] == a;
        assert M.Span(bytes,32+head,|a|) == M.Parts([a]);
      }
      assert M.SplitTail(p,bytes,0,head) == M.Parts(values);
    } else if Dyn(p.right) {
      assert bytes == Word(32)+a+Word(head)+b;
      WordAt(Word(32)+a,head,b);
      assert bytes[32..32+|a|] == a;
      assert bytes[32+head..] == b;
      assert M.SplitTail(p,bytes,2,head+|b|) == M.Parts([]);
      Last(p,bytes,head,values[1]);
      assert M.SplitTail(p,bytes,0,head) == M.Parts(values);
    } else {
      assert bytes == a+b && |bytes| == head;
      assert M.SplitTail(p,bytes,2,head) == M.Parts([]);
      Last(p,bytes,head,values[1]);
      assert M.SplitTail(p,bytes,0,head) == M.Parts(values);
    }
  }
}
