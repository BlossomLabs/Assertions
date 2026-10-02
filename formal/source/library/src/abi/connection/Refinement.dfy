// SPDX-License-Identifier: MIT
include "Bridge.generated.dfy"

module AbiConnectionRefinement {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened AbiConnectionModel
  import opened AbiConnectionDescriptor
  import opened AbiConnectionSource

  // The static branch of validate: successful source parsing supplies both the
  // descriptor witness and the exact cached width. No value-span premise is
  // assumed: the source length check establishes it or rejects at offset zero.
  ghost method StaticEntrypoint(t: seq<Byte>, v: seq<Byte>) returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|)
    requires Whole(t).Shaped? && !Whole(t).dynamic
    ensures WellFormed(TypeOf(Whole(t).syntax))
    ensures !r.Panic?
    ensures r.Ok? == Validate(TypeOf(Whole(t).syntax),v).Parsed?
    ensures r.Ok? <==> exists value :: WellTyped(TypeOf(Whole(t).syntax),value) &&
                                       Fits(TypeOf(Whole(t).syntax),value) && Encode(TypeOf(Whole(t).syntax),value) == v
  {
    var shape := AbiParserSource.Shape(t);
    r := ValidateStatic(t,v,shape.words,shape.syntax);
  }

  ghost method ParsedArrayHead(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, p: nat)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(p) && Uint(ts) && Uint(te)
    requires Parse(t,ts,te).Shaped? && Parse(t,ts,te).end == te
    requires Parse(t,ts,te).syntax.Fixed? || Parse(t,ts,te).syntax.Dynamic?
    ensures Good(Parse(t,ts,te).syntax)
    ensures r == ArrayPrelude(v,p,Parse(t,ts,te).syntax)
    ensures !r.Panic?
  {
    var shape := AbiParserSource.TypeShape(t,ts,te);
    var j: nat; var base: nat; var count: nat; var dynamic: bool; var words: nat;
    j,base,count,dynamic,words,r := ArrayHead(t,ts,te,v,p,shape.syntax);
  }

  ghost method ParsedTupleHead(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, p: nat)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|) && p <= |v| && Uint(ts) && Uint(te)
    requires Parse(t,ts,te).Shaped? && Parse(t,ts,te).end == te
    requires Parse(t,ts,te).syntax.Group?
    ensures r == (if 32*WidthSum(Parse(t,ts,te).syntax.fields) > |v|-p then Invalid(p)
                  else Ok(32*WidthSum(Parse(t,ts,te).syntax.fields)))
  {
    var shape := AbiParserSource.TypeShape(t,ts,te);
    r := TupleHead(t,ts,te,v,p,shape.syntax.fields);
  }
}
