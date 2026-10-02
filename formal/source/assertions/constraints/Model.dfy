// SPDX-License-Identifier: MIT
module ConstraintModel {
  type Byte = x: nat | x < 256 witness 0
  type Word = x: nat | x < 0x10000000000000000000000000000000000000000000000000000000000000000 witness 0
  datatype Kind = EQ | GTE | LTE | IN | GTE_SIGNED | LTE_SIGNED | OR | SKIP | IN_SIGNED
  datatype Constraint = C(kind: Kind, data: seq<Byte>)
  // The Solidity ABI decoder is an explicit environmental input. It may reject
  // or return any finite decoded list; no canonical-encoding assumption is made.
  datatype Decoded = Rejected | Leaves(items: seq<Constraint>)
  datatype Verdict = Yes | No | BadData(length: nat) | BadRange | BadOr | DecodeFailure
  datatype Result = Success | Bounds(words: nat, length: nat)
                  | Failure(index: nat, constraint: Constraint, actual: Word, reason: Verdict)

  opaque function Read(bytes: seq<Byte>): Word
    decreases |bytes|
  { if |bytes| == 0 then 0 else (Read(bytes[..|bytes|-1])*256 + bytes[|bytes|-1]) % 0x10000000000000000000000000000000000000000000000000000000000000000 }

  function Signed(w: Word): int {
    if w as nat < 0x8000000000000000000000000000000000000000000000000000000000000000
    then w as nat else (w as nat) - 0x10000000000000000000000000000000000000000000000000000000000000000
  }

  function Width(k: Kind): nat { if k == SKIP then 0 else if k == IN || k == IN_SIGNED then 64 else 32 }

  // Independent declarative predicate: comparison semantics are a match on the
  // wire kind, separate from the imperative helper's branch/fallthrough order.
  function Holds(k: Kind, x: Word, lo: Word, hi: Word): bool
    requires k != OR
  {
    match k
    case EQ => x == lo
    case GTE => lo <= x
    case LTE => x <= lo
    case IN => lo <= x <= hi
    case GTE_SIGNED => Signed(lo) <= Signed(x)
    case LTE_SIGNED => Signed(x) <= Signed(lo)
    case IN_SIGNED => Signed(lo) <= Signed(x) <= Signed(hi)
    case SKIP => true
  }

  function Leaf(x: Word, c: Constraint): Verdict
    requires c.kind != OR
  {
    if |c.data| != Width(c.kind) then BadData(|c.data|) else
    if c.kind == SKIP then Yes else
    var lo := Read(c.data[..32]);
    var hi := if |c.data| == 64 then Read(c.data[32..]) else 0;
    if (c.kind == IN && hi < lo) || (c.kind == IN_SIGNED && Signed(hi) < Signed(lo)) then BadRange
    else if Holds(c.kind,x,lo,hi) then Yes else No
  }

  function Alternatives(x: Word, cs: seq<Constraint>, start: nat): Verdict
    requires start <= |cs| && (forall c <- cs :: c.kind != OR)
    decreases |cs|-start
  {
    if start == |cs| then No else
    var r := Leaf(x,cs[start]);
    if r == No then Alternatives(x,cs,start+1) else r
  }

  function Judge(x: Word, c: Constraint, decode: seq<Byte> -> Decoded): Verdict {
    if c.kind != OR then Leaf(x,c) else
    var d := decode(c.data);
    if d.Rejected? then DecodeFailure else
    if |d.items| == 0 || (exists leaf <- d.items :: leaf.kind == OR) then BadOr
    else Alternatives(x,d.items,0)
  }

  function Scan(cs: seq<Constraint>, data: seq<Byte>, decode: seq<Byte> -> Decoded, start: nat): Result
    requires start <= |cs| <= |data|/32
    decreases |cs|-start
  {
    if start == |cs| then Success else
    var x := Read(data[32*start..32*start+32]);
    var r := Judge(x,cs[start],decode);
    if r == Yes then Scan(cs,data,decode,start+1) else Failure(start,cs[start],x,r)
  }

  function Validate(cs: seq<Constraint>, data: seq<Byte>, decode: seq<Byte> -> Decoded): Result {
    if |data|/32 < |cs| then Bounds(|data|/32,|data|) else Scan(cs,data,decode,0)
  }

  lemma FirstFailure(cs: seq<Constraint>, data: seq<Byte>, decode: seq<Byte> -> Decoded, start: nat)
    requires start <= |cs| <= |data|/32
    ensures Scan(cs,data,decode,start).Success? <==>
            (forall i :: start <= i < |cs| ==> Judge(Read(data[32*i..32*i+32]),cs[i],decode) == Yes)
    ensures Scan(cs,data,decode,start).Failure? ==>
              start <= Scan(cs,data,decode,start).index < |cs| &&
              (forall i :: start <= i < Scan(cs,data,decode,start).index ==>
                             Judge(Read(data[32*i..32*i+32]),cs[i],decode) == Yes)
    decreases |cs|-start
  {
    if start < |cs| && Judge(Read(data[32*start..32*start+32]),cs[start],decode) == Yes {
      FirstFailure(cs,data,decode,start+1);
    }
  }

  lemma SignedBounds(w: Word)
    ensures -0x8000000000000000000000000000000000000000000000000000000000000000 <= Signed(w)
    ensures Signed(w) < 0x8000000000000000000000000000000000000000000000000000000000000000
  {}
  datatype Context = Context(assertion: seq<Byte>, entry: nat, param: nat)
  datatype Error = ReturnDataOutOfBounds(words: nat, length: nat)
                 | ConstraintFailed(context: Context, index: nat, kind: Kind, actual: Word, reference: seq<Byte>)
                 | InvalidConstraintData(entry: nat, param: nat, index: nat, length: nat)
                 | InvalidConstraintRange(entry: nat, param: nat, index: nat)
                 | InvalidOrConstraint(entry: nat, param: nat, index: nat)
                 | BareRevert
  datatype Execution = Accepted | Reverted(error: Error)

  function Execute(r: Result, context: Context): Execution {
    match r
    case Success => Accepted
    case Bounds(w,n) => Reverted(ReturnDataOutOfBounds(w,n))
    case Failure(i,c,x,v) =>
      match v
      case No => Reverted(ConstraintFailed(context,i,c.kind,x,c.data))
      case BadData(n) => Reverted(InvalidConstraintData(context.entry,context.param,i,n))
      case BadRange => Reverted(InvalidConstraintRange(context.entry,context.param,i))
      case BadOr => Reverted(InvalidOrConstraint(context.entry,context.param,i))
      case DecodeFailure => Reverted(BareRevert)
      case Yes => Accepted // unreachable for Validate, proved below
  }

  lemma FailureFields(cs: seq<Constraint>, data: seq<Byte>, decode: seq<Byte> -> Decoded, start: nat)
    requires start <= |cs| <= |data|/32
    ensures Scan(cs,data,decode,start).Failure? ==>
              Scan(cs,data,decode,start).reason != Yes &&
              start <= Scan(cs,data,decode,start).index < |cs| &&
              Scan(cs,data,decode,start).constraint == cs[Scan(cs,data,decode,start).index] &&
              Scan(cs,data,decode,start).actual == Read(data[32*Scan(cs,data,decode,start).index..32*Scan(cs,data,decode,start).index+32]) &&
              Scan(cs,data,decode,start).reason == Judge(Scan(cs,data,decode,start).actual,Scan(cs,data,decode,start).constraint,decode)
    decreases |cs|-start
  {
    if start < |cs| && Judge(Read(data[32*start..32*start+32]),cs[start],decode) == Yes {
      FailureFields(cs,data,decode,start+1);
    }
  }

  lemma AlternativeFirstStop(x: Word, cs: seq<Constraint>, start: nat, stop: nat)
    requires start <= stop < |cs| && (forall c <- cs :: c.kind != OR)
    requires forall j :: start <= j < stop ==> Leaf(x,cs[j]) == No
    requires Leaf(x,cs[stop]) != No
    ensures Alternatives(x,cs,start) == Leaf(x,cs[stop])
    decreases stop-start
  {
    if start < stop { AlternativeFirstStop(x,cs,start+1,stop); }
  }

  lemma StructuralRejection(x: Word, c: Constraint, decode: seq<Byte> -> Decoded)
    requires c.kind == OR && decode(c.data).Leaves?
    requires |decode(c.data).items| == 0 || (exists leaf <- decode(c.data).items :: leaf.kind == OR)
    ensures Judge(x,c,decode) == BadOr
  {}

  lemma WordWindow(length: nat, count: nat, i: nat)
    requires length < 0x10000000000000000000000000000000000000000000000000000000000000000
    requires i < count <= length/32
    ensures 32*i+32 <= length
    ensures i+1 <= count < 0x10000000000000000000000000000000000000000000000000000000000000000
    ensures length/32 < 0x8000000000000000000000000000000000000000000000000000000000000000
  {}

}
