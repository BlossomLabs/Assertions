// SPDX-License-Identifier: MIT
include "Validation.dfy"
include "../../foundations/SourceReplacementSpanV7.dfy"

module AbiConstructionMemory {
  import opened AbiFrames
  import F = SourceReplacementSpanV7
  import opened AbiByteSemantics

  // Byte-object projection of in-bounds MCOPY/MSTORE. Physical pointers,
  // allocator success and nonwrapping memory layout are explicit environment
  // assumptions; callers must prove both object-relative spans below.
  function Write(out: seq<Byte>, dest: nat, data: seq<Byte>): seq<Byte>
    requires dest+|data| <= |out|
    ensures |Write(out,dest,data)| == |out|
  { out[..dest]+data+out[dest+|data|..] }

  ghost method Copy(out: seq<Byte>, dest: nat, data: seq<Byte>, start: nat, n: nat)
    returns (result: seq<Byte>)
    requires dest+n <= |out| && start+n <= |data|
    ensures result == Write(out,dest,data[start..start+n])
    ensures |result| == |out|
  { result := Write(out,dest,data[start..start+n]); }

  ghost method Store(out: seq<Byte>, p: nat, value: nat) returns (result: seq<Byte>)
    requires p+32 <= |out| && Uint(value)
    ensures result == Write(out,p,Word(value))
    ensures |result| == |out|
  { result := Write(out,p,Word(value)); }

  lemma WriteSpan(prefix: seq<Byte>, hole: seq<Byte>, suffix: seq<Byte>, data: seq<Byte>)
    requires |hole| == |data|
    ensures Write(prefix+hole+suffix,|prefix|,data) == prefix+data+suffix
  {
    F.ReplaceSpan(prefix,hole,suffix,data);
  }

  lemma ZeroSplit(a: nat, b: nat)
    ensures Zeros(a+b) == Zeros(a)+Zeros(b)
  {
    assert forall i :: 0 <= i < a+b ==> Zeros(a+b)[i] == (Zeros(a)+Zeros(b))[i];
  }

  lemma PlaceNext(prefix: seq<Byte>, done: seq<Byte>, gap: nat, suffix: seq<Byte>, data: seq<Byte>)
    requires |data| <= gap
    ensures Write(prefix+done+Zeros(gap)+suffix,|prefix|+|done|,data) ==
            prefix+(done+data)+Zeros(gap-|data|)+suffix
  {
    ZeroSplit(|data|,gap-|data|);
    WriteSpan(prefix+done,Zeros(|data|),Zeros(gap-|data|)+suffix,data);
    assert prefix+done+Zeros(gap)+suffix == (prefix+done)+Zeros(|data|)+(Zeros(gap-|data|)+suffix);
  }

  ghost method Slice(data: seq<Byte>, p: nat, n: nat) returns (out: seq<Byte>, r: Outcome)
    requires Uint(|data|) && Uint(p) && Uint(n)
    ensures r == (if p > |data| || n > |data|-p then Invalid(p) else Ok(0))
    ensures r.Ok? ==> out == data[p..p+n]
  {
    out := [];
    if p > |data| || n > |data|-p { r := Invalid(p); return; }
    out := Zeros(n);
    out := Copy(out,0,data,p,n);
    r := Ok(0);
  }
}
