// SPDX-License-Identifier: MIT
// Constructive text for the independent recursive grammar; physical parsing remains separate.
include "DescriptorSpec.dfy"
module AssertionsNavigationDescriptorEncoding {
  import S = AssertionsNavigationDescriptorSpec
  function Digits(n: nat): seq<nat>
    decreases n
  { if n < 10 then [48+n] else Digits(n/10)+[48+n%10] }
  function Encode(t: S.Type): seq<nat>
    decreases t
  {
    match t
    case Name(bytes) => bytes
    case Tuple(fields) => [40]+Fields(fields,|fields|)+[41]
    case Fixed(element,count) => Encode(element)+[91]+Digits(count)+[93]
    case Array(element) => Encode(element)+[91,93]
  }
  function Fields(fields: seq<S.Type>,count: nat): seq<nat>
    requires count <= |fields|
    decreases fields,count
  {
    if count == 0 then [] else
    Fields(fields,count-1)+(if count == 1 then [] else [44])+Encode(fields[count-1])
  }
  lemma DigitsValid(n: nat)
    ensures |Digits(n)| >= 1
    ensures forall i :: 0 <= i < |Digits(n)| ==> 48 <= Digits(n)[i] <= 57
    decreases n
  {
    if n >= 10 {
      DigitsValid(n/10);
      forall i | 0 <= i < |Digits(n)|
        ensures 48 <= Digits(n)[i] <= 57
      {
        if i < |Digits(n/10)| { assert Digits(n)[i] == Digits(n/10)[i]; }
      }
    }
  }
  lemma EncodeValid(t: S.Type)
    requires S.Valid(t)
    ensures |Encode(t)| >= 1
    ensures forall i :: 0 <= i < |Encode(t)| ==> Encode(t)[i] < 256
    decreases t
  {
    match t
    case Name(bytes) =>
    case Tuple(fields) => FieldsValid(fields,|fields|);
    case Fixed(element,count) => EncodeValid(element); DigitsValid(count);
    case Array(element) => EncodeValid(element);
  }
  lemma FieldsValid(fields: seq<S.Type>,count: nat)
    requires count <= |fields|
    requires forall i :: 0 <= i < |fields| ==> S.Valid(fields[i])
    ensures |Fields(fields,count)| >= count
    ensures forall i :: 0 <= i < |Fields(fields,count)| ==> Fields(fields,count)[i] < 256
    decreases fields,count
  {
    if count > 0 {
      FieldsValid(fields,count-1);
      EncodeValid(fields[count-1]);
    }
  }
}
