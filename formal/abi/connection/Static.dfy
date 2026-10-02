// SPDX-License-Identifier: MIT
include "Model.dfy"

module AbiConnectionStatic {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import opened AbiConnectionModel

  lemma ScanSlice(xs: seq<WordRule>, v: seq<Byte>, p: nat, q: nat)
    requires RulesValid(xs) && p+q+32*|xs| <= |v|
    ensures Scan(xs,v[p..],q).Ok? == Scan(xs,v,p+q).Ok?
    decreases |xs|
  {
    if |xs| > 0 {
      assert v[p..][q..q+32] == v[p+q..p+q+32];
      if CanonicalWord(xs[0],ReadNat(v[p+q..p+q+32])) { ScanSlice(xs[1..],v,p,q+32); }
    }
  }

  lemma StaticWalk(s: Descriptor, bs: seq<Byte>)
    requires Good(s) && !Dyn(s)
    requires 32*Width(s) <= |bs|
    ensures WellFormed(TypeOf(s)) && RulesValid(Rules(s)) && |Rules(s)| == Width(s)
    ensures Walk(TypeOf(s),bs).Parsed? == Scan(Rules(s),bs,0).Ok?
    ensures Walk(TypeOf(s),bs).Parsed? ==> Walk(TypeOf(s),bs).used == 32*Width(s)
    decreases TypeOf(s), 2, 0
  {
    ModelType(s); StaticRules(s);
    match s
    case Name(n) =>
    case Group(fs) =>
      ModelFields(fs); TypesIndex(fs);
      assert Below(TypeOf(s),TypesOf(fs));
      StaticFieldsWalk(TypeOf(s),fs,bs,0,32*Width(s));
    case Fixed(e,ds) =>
      var n := Number(ds);
      var fs := Copies(e,n);
      CopyLayout(e,n); ModelFields(fs);
      assert Children(TypeOf(s),n) == TypesOf(fs);
      assert Below(TypeOf(s),TypesOf(fs));
      StaticFieldsWalk(TypeOf(s),fs,bs,0,32*Width(s));
    case Dynamic(e) => assert false;
  }

  lemma StaticFieldsWalk(owner: AbiType, fs: seq<Descriptor>, bs: seq<Byte>, head: nat, tail: nat)
    requires forall i :: 0 <= i < |fs| ==> Good(fs[i]) && !Dyn(fs[i])
    requires Below(owner,TypesOf(fs))
    requires head+32*WidthSum(fs) == tail <= |bs|
    ensures Types(TypesOf(fs)) && RulesValid(FieldRules(fs))
    ensures ListHead(TypesOf(fs)) == 32*WidthSum(fs) && |FieldRules(fs)| == WidthSum(fs)
    ensures WalkFields(owner,TypesOf(fs),bs,head,tail).Fields? == Scan(FieldRules(fs),bs,head).Ok?
    ensures WalkFields(owner,TypesOf(fs),bs,head,tail).Fields? ==>
              WalkFields(owner,TypesOf(fs),bs,head,tail).end == tail
    decreases owner, 1, |fs|
  {
    ModelFields(fs); StaticFields(fs);
    if |fs| > 0 {
      var s := fs[0];
      StaticRules(s); StaticFields(fs[1..]);
      StaticWalk(s,bs[head..]);
      ScanSlice(Rules(s),bs,head,0);
      ScanAppend(Rules(s),FieldRules(fs[1..]),bs,head);
      if Walk(TypeOf(s),bs[head..]).Parsed? {
        StaticFieldsWalk(owner,fs[1..],bs,head+32*Width(s),tail);
      }
    }
  }

  // Turn the flattened source-traversal result into the independent validator's
  // acceptance predicate; its existing theorem then supplies canonical values.
  lemma StaticValidation(s: Descriptor, bs: seq<Byte>)
    requires Good(s) && !Dyn(s)
    requires |bs| == 32*Width(s) && Uint(|bs|)
    ensures WellFormed(TypeOf(s)) && RulesValid(Rules(s)) && |Rules(s)| == Width(s)
    ensures Scan(Rules(s),bs,0).Ok? == Validate(TypeOf(s),bs).Parsed?
    ensures Scan(Rules(s),bs,0).Ok? <==> exists value ::
                                           WellTyped(TypeOf(s),value) && Fits(TypeOf(s),value) && Encode(TypeOf(s),value) == bs
  {
    ModelType(s); StaticWalk(s,bs);
    AcceptedIffCanonical(TypeOf(s),bs);
  }
}
