// SPDX-License-Identifier: MIT
include "BytesBody.generated.dfy"
include "../Examples.dfy"

module AbiBytesCorrespondence {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource

  ghost method BodyRefinesWalker(v: seq<Byte>, p: nat) returns (r: Outcome)
    requires Uint(|v|) && Uint(p)
    ensures !r.Panic?
    ensures r.Ok? <==> p <= |v| && WalkBytes(v[p..]).Parsed?
    ensures r.Ok? ==> r.used == WalkBytes(v[p..]).used
    ensures r == BodySpec(v,p)
  {
    r := BytesBody(v,p);
    BodySpecMatchesWalker(v,p);
  }

  ghost method ValidationAcceptsExactlyCanonical(t: AbiType, v: seq<Byte>) returns (r: Outcome)
    requires t.Bytes? || t.String?
    requires Uint(|v|)
    ensures !r.Panic?
    ensures r == ValidationSpec(v)
    ensures r.Ok? <==> Validate(t,v).Parsed?
    ensures r.Ok? <==> exists value :: WellTyped(t,value) && Fits(t,value) && Encode(t,value) == v
  {
    r := ValidateBytes(v);
    ValidationSpecMatchesModel(v);
    AcceptedIffCanonical(t,v);
  }
}
