// SPDX-License-Identifier: MIT
// Independent recursive descriptor grammar. No physical parser theorem is assumed.
module AssertionsNavigationDescriptorSpec {
  datatype Type = Name(bytes: seq<nat>) | Tuple(fields: seq<Type>) | Fixed(element: Type,count: nat) | Array(element: Type)
  predicate NameByte(b: nat) { 97 <= b <= 122 || 48 <= b <= 57 }
  predicate Dynamic(t: Type)
    decreases t
  {
    match t
    case Name(bytes) => bytes == [98,121,116,101,115] || bytes == [115,116,114,105,110,103]
    case Tuple(fields) => exists i :: 0 <= i < |fields| && Dynamic(fields[i])
    case Fixed(element,count) => Dynamic(element)
    case Array(element) => true
  }
  function Words(t: Type): nat
    decreases t
  {
    if Dynamic(t) then 1 else
    match t
    case Name(bytes) => 1
    case Tuple(fields) => Sum(fields,|fields|)
    case Fixed(element,count) => Words(element)*count
    case Array(element) => 1
  }
  function Sum(fields: seq<Type>,count: nat): nat
    requires count <= |fields|
    decreases fields,count
  { if count == 0 then 0 else Sum(fields,count-1)+Words(fields[count-1]) }
  predicate Valid(t: Type)
    decreases t
  {
    match t
    case Name(bytes) => |bytes| > 0 && forall i :: 0 <= i < |bytes| ==> NameByte(bytes[i])
    case Tuple(fields) => |fields| > 0 && (forall i :: 0 <= i < |fields| ==> Valid(fields[i])) && Sum(fields,|fields|) < 0x10000000000000000000000000000000000000000000000000000000000000000
    case Fixed(element,count) => Valid(element) && 1 <= count <= 0xffffffff && (Dynamic(element) || Words(element)*count <= 0xffffffff)
    case Array(element) => Valid(element)
  }
  lemma Positive(t: Type)
    requires Valid(t)
    ensures Words(t) >= 1
    decreases t
  {
    if !Dynamic(t) {
      match t
      case Name(bytes) =>
      case Tuple(fields) => PositiveSum(fields,|fields|);
      case Fixed(element,count) => Positive(element);
      case Array(element) =>
    }
  }
  lemma PositiveSum(fields: seq<Type>,count: nat)
    requires count <= |fields|
    requires forall i :: 0 <= i < |fields| ==> Valid(fields[i])
    ensures Sum(fields,count) >= count
    decreases fields,count
  {
    if count > 0 {
      PositiveSum(fields,count-1);
      Positive(fields[count-1]);
    }
  }
  lemma WordBound(t: Type)
    requires Valid(t)
    ensures Words(t) < 0x10000000000000000000000000000000000000000000000000000000000000000
  {}
}
