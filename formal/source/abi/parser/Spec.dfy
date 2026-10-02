// SPDX-License-Identifier: MIT
include "../shape/Refinement.dfy"

module AbiParserSpec {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics

  // The grammar's checked-arithmetic admissibility condition. A dynamic tuple
  // still accumulates the widths of all children before selecting head width 1.
  predicate Admissible(s: Descriptor)
    decreases s
  {
    Good(s) &&
    match s
    case Group(fs) => Uint(WidthSum(fs)) && forall i :: 0 <= i < |fs| ==> Admissible(fs[i])
    case Fixed(e,_) => Admissible(e)
    case Dynamic(e) => Admissible(e)
    case Name(_) => true
  }

  function DigitsFrom(t: seq<Byte>, q: nat, limit: nat, k: nat): (nat,nat)
    requires q <= limit <= |t| && k < 10*0x100000000
    ensures q <= DigitsFrom(t,q,limit,k).0 <= limit
    ensures DigitsFrom(t,q,limit,k).1 < 10*0x100000000
    decreases limit-q
  {
    if q == limit || t[q] < 48 || t[q] > 57 || k > 0xffffffff then (q,k)
    else DigitsFrom(t,q+1,limit,10*k+t[q]-48)
  }

  // Pure recursive recognizer. Error positions follow the documented consumed
  // prefix boundary; arithmetic overflow is distinct from descriptor rejection.
  function Suffix(t: seq<Byte>, q: nat, limit: nat, s: Descriptor, d: bool, w: nat): ShapeResult
    requires q <= limit <= |t| && Uint(w)
    ensures Suffix(t,q,limit,s,d,w).Shaped? ==> q <= Suffix(t,q,limit,s,d,w).end <= limit
    ensures Suffix(t,q,limit,s,d,w).Shaped? ==> Uint(Suffix(t,q,limit,s,d,w).words)
    decreases limit-q
  {
    if q == limit || t[q] != 91 then Shaped(q,d,w,s) else
    var digits := DigitsFrom(t,q+1,limit,0);
    var e,k := digits.0,digits.1;
    var a := e == q+1;
    var nextD := a || d;
    var nextW := if a then 1 else if d then w else w*k;
    if nextW >= Limit() then ArithmeticPanic else
    if e == limit || t[e] != 93 || k > 0xffffffff || nextW > 0xffffffff || (k == 0 && !a)
    then BadDescriptor(e) else
    var next := if a then Dynamic(s) else Fixed(s,t[q+1..e]);
    Suffix(t,e+1,limit,next,nextD,nextW)
  }

  function Finish(t: seq<Byte>, limit: nat, base: ShapeResult): ShapeResult
    requires limit <= |t|
    requires base.Shaped? ==> base.end <= limit && Uint(base.words)
  { if base.Shaped? then Suffix(t,base.end,limit,base.syntax,base.dynamic,base.words) else base }

  function Parse(t: seq<Byte>, p: nat, limit: nat): ShapeResult
    requires Uint(|t|) && Uint(p) && Uint(limit)
    ensures Parse(t,p,limit).Shaped? ==> p < Parse(t,p,limit).end <= limit <= |t|
    ensures Parse(t,p,limit).Shaped? ==> Uint(Parse(t,p,limit).words)
    decreases if p < limit then limit-p else 0, 0
  {
    if limit > |t| then BadDescriptor(limit) else
    if p >= limit then BadDescriptor(p) else
    if t[p] == 40 then Finish(t,limit,Fields(t,p+1,limit,[],0,false)) else
    var e := NameEnd(t,p,limit);
    if e == p then BadDescriptor(p) else
    var s := Name(t[p..e]);
    Suffix(t,e,limit,s,Dyn(s),1)
  }

  function Fields(t: seq<Byte>, q: nat, limit: nat, fs: seq<Descriptor>, sum: nat, dyn: bool): ShapeResult
    requires Uint(|t|) && q <= limit <= |t| && Uint(sum)
    ensures Fields(t,q,limit,fs,sum,dyn).Shaped? ==> q < Fields(t,q,limit,fs,sum,dyn).end <= limit
    ensures Fields(t,q,limit,fs,sum,dyn).Shaped? ==> Uint(Fields(t,q,limit,fs,sum,dyn).words)
    decreases limit-q, 1
  {
    var child := Parse(t,q,limit);
    if !child.Shaped? then child else
    var e := child.end;
    var total := sum+child.words;
    var dynamic := dyn || child.dynamic;
    var fields := fs+[child.syntax];
    if total >= Limit() then ArithmeticPanic else
    if e == limit then BadDescriptor(e) else
    if t[e] == 44 then Fields(t,e+1,limit,fields,total,dynamic) else
    if t[e] == 41 then Shaped(e+1,dynamic,if dynamic then 1 else total,Group(fields)) else
    BadDescriptor(e)
  }

  function Whole(t: seq<Byte>): ShapeResult
    requires Uint(|t|)
  {
    var r := Parse(t,0,|t|);
    if r.Shaped? && r.end != |t| then BadDescriptor(r.end) else r
  }
}
