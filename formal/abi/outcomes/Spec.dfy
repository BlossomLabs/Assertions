// SPDX-License-Identifier: MIT
include "../dynamic/Semantics.dfy"

module AbiExactOutcomeSpec {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiTupleSemantics
  import opened AbiTupleWords
  import opened AbiConnectionDescriptor
  import opened AbiDynamicZero

  // Exact first-error semantics. Offsets are absolute in the input value.
  ghost function Static(s: Descriptor, v: seq<Byte>, p: nat, count: nat): Outcome
    requires Good(s) && !Dyn(s)
  {
    StaticRules(s); RepeatValid(Rules(s),count);
    if p+32*Width(s)*count > |v| then Invalid(p) else
    if count == 0 && !ZeroFits(s,p) then Panic(17) else
    Scan(Repeat(Rules(s),count),v,p)
  }

  ghost function {:opaque} Body(s: Descriptor, v: seq<Byte>, p: nat): Outcome
    requires Good(s) && Dyn(s)
    decreases s, 0, 0
  {
    if p > |v| then Invalid(p) else
    match s
    case Name(_) => BodySpec(v,p)
    case Group(fs) =>
      if p+32*WidthSum(fs) > |v| then Invalid(p) else
      Fields(fs,v,p,0,32*WidthSum(fs))
    case _ =>
      var head := ArrayPrelude(v,p,s);
      if !head.Ok? then head else
      var base := p+(if s.Dynamic? then 32 else 0);
      var count := if s.Dynamic? then ReadNat(v[p..p+32]) else Number(s.digits);
      var result := if Dyn(s.element) then Elements(s.element,v,base,count,0,head.used)
                    else Static(s.element,v,base,count);
      if !result.Ok? then result else
      Ok(base-p+(if Dyn(s.element) then result.used else head.used))
  }

  ghost function Elements(e: Descriptor, v: seq<Byte>, base: nat,
                          count: nat, i: nat, tail: nat): Outcome
    requires Good(e) && Dyn(e) && i <= count
    decreases e, 1, count-i
  {
    if i == count then Ok(tail) else
    var position := base+i*Width(e)*32;
    var offset := WordSpec(v,position);
    if !offset.Ok? then offset else
    if offset.used != tail then Invalid(position) else
    var child := Body(e,v,base+tail);
    if !child.Ok? then child else
    Elements(e,v,base,count,i+1,tail+child.used)
  }

  ghost function Fields(fs: seq<Descriptor>, v: seq<Byte>, base: nat,
                        head: nat, tail: nat): Outcome
    requires forall i :: 0 <= i < |fs| ==> Good(fs[i])
    decreases fs, 0, 0
  {
    if |fs| == 0 then Ok(tail) else
    var e := fs[0];
    var offset := WordSpec(v,base+head);
    if Dyn(e) && !offset.Ok? then offset else
    if Dyn(e) && offset.used != tail then Invalid(base+head) else
    var child := if Dyn(e) then Body(e,v,base+tail) else Static(e,v,base+head,1);
    if !child.Ok? then child else
    Fields(fs[1..],v,base,head+32*Width(e),tail+(if Dyn(e) then child.used else 0))
  }

  lemma ElementsStep(e: Descriptor, v: seq<Byte>, base: nat, count: nat,
                     i: nat, tail: nat, child: Outcome)
    requires Good(e) && Dyn(e) && i < count
    requires WordSpec(v,base+i*Width(e)*32) == Ok(tail)
    requires child == Body(e,v,base+tail) && child.Ok?
    ensures Elements(e,v,base,count,i,tail) == Elements(e,v,base,count,i+1,tail+child.used)
  {}

  lemma FieldsStep(fs: seq<Descriptor>, v: seq<Byte>, base: nat,
                   head: nat, tail: nat, child: Outcome)
    requires |fs| > 0 && forall i :: 0 <= i < |fs| ==> Good(fs[i])
    requires Dyn(fs[0]) ==> WordSpec(v,base+head) == Ok(tail)
    requires child.Ok? && child == (if Dyn(fs[0]) then Body(fs[0],v,base+tail) else Static(fs[0],v,base+head,1))
    ensures Fields(fs,v,base,head,tail) == Fields(fs[1..],v,base,head+32*Width(fs[0]),tail+(if Dyn(fs[0]) then child.used else 0))
  {}

  ghost function Validate(s: Descriptor, v: seq<Byte>): Outcome
    requires Good(s)
  {
    if !Dyn(s) then
      if |v| != 32*Width(s) then Invalid(0) else Static(s,v,0,1)
    else
      var offset := WordSpec(v,0);
      if !offset.Ok? then offset else
      if offset.used != 32 then Invalid(0) else
      var body := Body(s,v,32);
      if !body.Ok? then body else
      if !Uint(32+body.used) then Panic(17) else
      if 32+body.used != |v| then Invalid(32+body.used) else Ok(0)
  }
}
