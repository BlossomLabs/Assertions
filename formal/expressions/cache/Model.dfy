// SPDX-License-Identifier: MIT
include "../../abi/construction/Validation.dfy"
include "../../resolution/Model.dfy"
module ExpressionCache {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import R = ResolutionModel

  datatype Cache = Cache(values: seq<seq<Byte>>, ready: seq<bool>, dynamic: seq<bool>, words: seq<nat>)
  datatype Commit = Stored(value: seq<Byte>, cache: Cache) | Invalid(reason: AbiByteSemantics.Outcome, cache: Cache)
  datatype Attempt = Succeeded(value: seq<Byte>, updated: Cache) | Failed(observation: R.Observation, discarded: Cache)
  datatype GuardResult = Accepted(value: seq<Byte>, cache: Cache) | OrdinaryFailure(cache: Cache) | Exhaustion(cache: Cache)

  ghost predicate Types(types: seq<Descriptor>) {
    forall i :: 0 <= i < |types| ==> Admissible(types[i]) && WellFormed(TypeOf(types[i]))
  }

  ghost predicate Metadata(types: seq<Descriptor>, cache: Cache) {
    Types(types) && |cache.values| == |types| && |cache.ready| == |types| &&
    |cache.dynamic| == |types| && |cache.words| == |types| &&
    (forall i :: 0 <= i < |types| ==> cache.dynamic[i] == Dyn(types[i]) && cache.words[i] == Width(types[i]))
  }

  ghost predicate Valid(types: seq<Descriptor>, cache: Cache) {
    Metadata(types,cache) &&
    (forall i :: 0 <= i < |types| && cache.ready[i] ==> Validate(TypeOf(types[i]),cache.values[i]).Parsed?)
  }

  predicate Extends(before: Cache, after: Cache) {
    |after.values| == |before.values| && |after.ready| == |before.ready| &&
    after.dynamic == before.dynamic && after.words == before.words &&
    (forall i :: 0 <= i < |before.ready| ==> i < |before.values| &&
                                             (before.ready[i] ==> after.ready[i] && after.values[i] == before.values[i]))
  }

  function Cold(types: seq<Descriptor>): Cache {
    Cache(seq(|types|, i => []),seq(|types|, i => false),seq(|types|, i requires 0 <= i < |types| => Dyn(types[i])),seq(|types|, i requires 0 <= i < |types| => Width(types[i])))
  }

  function Store(cache: Cache, index: nat, value: seq<Byte>): Cache
    requires index < |cache.values| && index < |cache.ready|
  { Cache(cache.values[index := value],cache.ready[index := true],cache.dynamic,cache.words) }

  function Adopt(original: Cache, updated: Cache): Cache {
    Cache(updated.values,updated.ready,original.dynamic,original.words)
  }

  function Guard(original: Cache, attempted: Attempt): GuardResult {
    match attempted
    case Succeeded(value,updated) => Accepted(value,Adopt(original,updated))
    case Failed(observation,_) => if R.Exhausted(observation) then Exhaustion(original) else OrdinaryFailure(original)
  }

  lemma ColdValid(types: seq<Descriptor>)
    requires Types(types)
    ensures Valid(types,Cold(types))
    ensures forall i :: 0 <= i < |types| ==> !Cold(types).ready[i]
  {}

  lemma StoreValid(types: seq<Descriptor>, cache: Cache, index: nat, value: seq<Byte>)
    requires Valid(types,cache) && index < |types| && !cache.ready[index]
    requires Validate(TypeOf(types[index]),value).Parsed?
    ensures Valid(types,Store(cache,index,value)) && Extends(cache,Store(cache,index,value))
    ensures Store(cache,index,value).ready[index] && Store(cache,index,value).values[index] == value
  {}

  lemma AdoptValid(types: seq<Descriptor>, original: Cache, updated: Cache)
    requires Valid(types,original) && Valid(types,updated) && Extends(original,updated)
    ensures Adopt(original,updated) == updated
    ensures Valid(types,Adopt(original,updated)) && Extends(original,Adopt(original,updated))
  {}

  lemma ReuseCanonical(types: seq<Descriptor>, cache: Cache, index: nat)
    requires Valid(types,cache) && index < |types| && cache.ready[index]
    ensures Validate(TypeOf(types[index]),cache.values[index]).Parsed?
    ensures WellTyped(TypeOf(types[index]),Validate(TypeOf(types[index]),cache.values[index]).value)
    ensures cache.values[index] == Encode(TypeOf(types[index]),Validate(TypeOf(types[index]),cache.values[index]).value)
  { ValidationSound(TypeOf(types[index]),cache.values[index]); }

  lemma ExtensionsCompose(a: Cache, b: Cache, c: Cache)
    requires Extends(a,b) && Extends(b,c)
    ensures Extends(a,c)
  {}

  lemma FailureDiscards(original: Cache, observed: R.Observation, discarded: Cache)
    ensures Guard(original,Failed(observed,discarded)) == (if R.Exhausted(observed) then Exhaustion(original) else OrdinaryFailure(original))
    ensures Guard(original,Failed(observed,discarded)).cache == original
  {}
  ghost predicate SuccessfulReceipt(types: seq<Descriptor>, index: nat, original: Cache, attempt: Attempt) {
    index < |types| && Valid(types,original) && attempt.Succeeded? &&
    Valid(types,attempt.updated) && Extends(original,attempt.updated) &&
    attempt.updated.ready[index] && attempt.value == attempt.updated.values[index]
  }

  lemma GuardSuccessValid(types: seq<Descriptor>, index: nat, original: Cache, attempt: Attempt)
    requires SuccessfulReceipt(types,index,original,attempt)
    ensures Guard(original,attempt).Accepted? && Valid(types,Guard(original,attempt).cache)
    ensures Extends(original,Guard(original,attempt).cache)
    ensures Validate(TypeOf(types[index]),Guard(original,attempt).value).Parsed?
  { AdoptValid(types,original,attempt.updated); }

}
