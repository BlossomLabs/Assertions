// SPDX-License-Identifier: MIT
include "Zero.dfy"

module AbiDynamicSemantics {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiCursorSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiConnectionStatic
  import opened AbiConnectionDescriptor
  import opened AbiDynamicZero
  import AbiTupleSource

  // Sufficient arithmetic resource condition, independent of validation and
  // encoded values. It is used only to exclude the exact zero-copy overflow
  // paths characterized by ZeroWords; correspondence otherwise retains Panic.
  predicate CursorRoom(s: Descriptor, length: nat)
    decreases s
  {
    (Dyn(s) || Uint(length+32*Width(s))) &&
    match s
    case Name(_) => true
    case Group(fs) => forall i :: 0 <= i < |fs| ==> CursorRoom(fs[i],length)
    case _ => CursorRoom(s.element,length)
  }

  lemma {:isolate_assertions} BoundedZero(s: Descriptor, p: nat)
    requires Good(s) && !Dyn(s) && Uint(p+32*Width(s))
    ensures ZeroFits(s,p)
    decreases s
  {
    match s
    case Name(_) =>
    case Fixed(e,_) =>
      AbiSuffixSemantics.MultiplyAtLeast(Width(e),Number(s.digits));
      assert Width(e)*Number(s.digits) == Width(s);
      assert Width(e) <= Width(s);
      BoundedZero(e,p);
    case Group(fs) =>
      forall i | 0 <= i < |fs|
        ensures Uint(p+32*WidthSum(fs[..i])) && ZeroFits(fs[i],p+32*WidthSum(fs[..i]))
      {
        assert fs == fs[..i]+fs[i..];
        WidthConcat(fs[..i],fs[i..]);
        assert WidthSum(fs[i..]) == Width(fs[i])+WidthSum(fs[i+1..]);
        BoundedZero(fs[i],p+32*WidthSum(fs[..i]));
      }
    case Dynamic(_) => assert false;
  }

  lemma StaticFrame(s: Descriptor, n: nat, owner: AbiType, v: seq<Byte>, p: nat)
    requires Good(s) && !Dyn(s) && TypeOf(s) < owner
    requires p+32*Width(s)*n <= |v|
    ensures WellFormed(TypeOf(s))
    ensures RulesValid(Rules(s)) && |Rules(s)| == Width(s)
    ensures RulesValid(Repeat(Rules(s),n))
    ensures Types(TypesOf(Copies(s,n))) && Below(owner,TypesOf(Copies(s,n)))
    ensures WalkFrame(owner,TypesOf(Copies(s,n)),v[p..]).Parsed? == Scan(Repeat(Rules(s),n),v,p).Ok?
    ensures WalkFrame(owner,TypesOf(Copies(s,n)),v[p..]).Parsed? ==>
              WalkFrame(owner,TypesOf(Copies(s,n)),v[p..]).used == 32*Width(s)*n
  {
    ModelType(s); StaticRules(s); RepeatValid(Rules(s),n);
    CopyLayout(s,n); ModelFields(Copies(s,n));
    StaticFieldsWalk(owner,Copies(s,n),v[p..],0,32*Width(s)*n);
    ScanSlice(Repeat(Rules(s),n),v,p,0);
  }

  ghost method {:isolate_assertions} StaticCopies(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, p: nat, s: Descriptor, count: nat)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(count)
    requires Good(s) && !Dyn(s) && Located(t,ts,te,s)
    requires p+32*Width(s)*count <= |v|
    ensures RulesValid(Rules(s)) && |Rules(s)| == Width(s)
    ensures RulesValid(Repeat(Rules(s),count))
    ensures r == (if count == 0 && !ZeroFits(s,p) then Panic(17) else Scan(Repeat(Rules(s),count),v,p))
    ensures r.Panic? ==> count == 0 && !CursorRoom(s,|v|)
  {
    StaticRules(s); RepeatValid(Rules(s),count);
    var end: nat; var words: nat;
    if count == 0 {
      end,words,r := ZeroWords(t,ts,te,v,p,s);
      if CursorRoom(s,|v|) { BoundedZero(s,p); }
    } else {
      assert p+32*Width(s) <= p+32*Width(s)*count;
      end,words,r := AbiTupleSource.CheckWords(t,ts,te,count,v,p,s);
    }
  }

  lemma {:isolate_assertions} ArrayTypes(s: Descriptor, n: nat)
    requires Good(s) && (s.Fixed? || s.Dynamic?)
    requires s.Fixed? ==> n == Number(s.digits)
    ensures WellFormed(TypeOf(s)) && WellFormed(TypeOf(s.element))
    ensures Types(TypesOf(Copies(s.element,n))) && Below(TypeOf(s),TypesOf(Copies(s.element,n)))
    ensures TypesOf(Copies(s.element,n)) == Children(TypeOf(s),n)
    ensures ListHead(TypesOf(Copies(s.element,n))) == 32*Width(s.element)*n
  {
    ModelType(s); ModelType(s.element);
    CopyLayout(s.element,n); ModelFields(Copies(s.element,n));
    AbiTupleWords.ProductAssoc(32,Width(s.element),n);
    assert ListHead(TypesOf(Copies(s.element,n))) == 32*(Width(s.element)*n);
    assert TypeOf(s).element == TypeOf(s.element);
    assert Children(TypeOf(s),n) == seq(n,i requires 0 <= i < n => TypeOf(s.element));
    assert TypesOf(Copies(s.element,n)) == Children(TypeOf(s),n);
  }

  lemma HeadCountFits(count: nat, words: nat, length: nat)
    requires words > 0 && count*words*32 <= length && Uint(length)
    ensures Uint(count)
  {
    ProductNonnegative(count,words*32-1);
    assert count*(words*32-1) == count*words*32-count;
  }

  lemma ArrayView(s: Descriptor, v: seq<Byte>, p: nat, n: nat)
    requires Good(s) && (s.Fixed? || s.Dynamic?)
    requires p+(if s.Dynamic? then 32 else 0) <= |v|
    requires n == (if s.Dynamic? then ReadNat(v[p..p+32]) else Number(s.digits))
    ensures WellFormed(TypeOf(s))
    ensures Types(TypesOf(Copies(s.element,n))) && Below(TypeOf(s),TypesOf(Copies(s.element,n)))
    ensures ListHead(TypesOf(Copies(s.element,n))) == 32*Width(s.element)*n
    ensures Walk(TypeOf(s),v[p..]).Parsed? ==
            WalkFrame(TypeOf(s),TypesOf(Copies(s.element,n)),v[p+(if s.Dynamic? then 32 else 0)..]).Parsed?
    ensures Walk(TypeOf(s),v[p..]).Parsed? ==> Walk(TypeOf(s),v[p..]).used ==
                                               (if s.Dynamic? then 32 else 0)+WalkFrame(TypeOf(s),TypesOf(Copies(s.element,n)),v[p+(if s.Dynamic? then 32 else 0)..]).used
  {
    ArrayTypes(s,n);
    if s.Dynamic? {
      assert v[p..][..32] == v[p..p+32];
      assert v[p..][32..] == v[p+32..];
    } else { assert v[p..][0..] == v[p..]; }
  }

  lemma WidthByText(s: Descriptor)
    requires Good(s)
    ensures Width(s) <= 0x100000000*|Render(s)|
    decreases s, 1
  {
    Positive(s);
    if s.Group? && !Dyn(s) { FieldsWidthByText(s.fields); }
  }

  lemma FieldsWidthByText(fs: seq<Descriptor>)
    requires forall i :: 0 <= i < |fs| ==> Good(fs[i])
    ensures WidthSum(fs) <= 0x100000000*|FieldsText(fs)|
    decreases fs, 0
  {
    if |fs| > 0 { WidthByText(fs[0]); FieldsWidthByText(fs[1..]); }
  }

  lemma TextMember(fs: seq<Descriptor>, i: nat)
    requires i < |fs|
    ensures |Render(fs[i])| <= |FieldsText(fs)|
    decreases i
  { if i > 0 { TextMember(fs[1..],i-1); } }

  lemma RoomFromText(s: Descriptor, length: nat)
    requires Good(s) && Uint(length+32*0x100000000*|Render(s)|)
    ensures CursorRoom(s,length)
    decreases s
  {
    WidthByText(s);
    match s
    case Name(_) =>
    case Group(fs) =>
      forall i | 0 <= i < |fs| ensures CursorRoom(fs[i],length)
      { TextMember(fs,i); RoomFromText(fs[i],length); }
    case _ => RoomFromText(s.element,length);
  }

  lemma FirstByte(s: Descriptor)
    requires Good(s)
    ensures |Render(s)| > 0
    ensures !s.Fixed? && !s.Dynamic? ==> (Render(s)[0] == 40) == s.Group?
  {
    Positive(s);
    if s.Name? { assert NameByte(s.text[0]); }
  }
}
