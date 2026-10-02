// SPDX-License-Identifier: MIT
// Selected cache transitions in gated Expressions.sol $HASH; recursion is separate.
include "Model.dfy"
include "../admission/Source.generated.dfy"
module ExpressionCacheSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import AbiConstructionValidation
  import opened ExpressionCache
  import R = ResolutionModel
  import A = ExpressionAdmission
  import Admission = ExpressionAdmissionSource
  import AbiParserSource

  datatype InitialResult = AdmissionFailed(error: A.Error) | Initialized(types: seq<Descriptor>, cache: Cache)

  ghost method Initialize(types: seq<Descriptor>) returns (cache: Cache)
    requires ExpressionCache.Types(types)
    ensures cache == Cold(types) && Valid(types,cache)
    ensures forall i :: 0 <= i < |types| ==> !cache.ready[i]
  {
    var values: seq<seq<Byte>> := seq(|types|, i => []);
    var ready := seq(|types|, i => false);
    var dynamic := seq(|types|, i => false);
    var words: seq<nat> := seq(|types|, i => 0);
    var i := 0;
    while i < |types|
      invariant 0 <= i <= |types|
      invariant |dynamic| == |types| && |words| == |types|
      invariant forall j :: 0 <= j < i ==> dynamic[j] == Dyn(types[j]) && words[j] == Width(types[j])
    {
      dynamic := dynamic[i := Dyn(types[i])]; words := words[i := Width(types[i])]; i := i+1;
    }
    assert dynamic == Cold(types).dynamic && words == Cold(types).words;
    cache := Cache(values,ready,dynamic,words);
    ColdValid(types);
  }

  // Proof-only descriptor witness: no extra runtime parser invocation is claimed.
  ghost method DescriptorIdentity(t: seq<Byte>)
    requires Uint(|t|) && Whole(t).Shaped?
    ensures Admissible(Whole(t).syntax) && WellFormed(TypeOf(Whole(t).syntax))
    ensures Render(Whole(t).syntax) == t
  {
    var shape := AbiParserSource.Shape(t);
    ModelType(shape.syntax);
  }

  ghost method Begin(nodes: seq<A.Node>, result: nat, hash: seq<Byte> -> nat) returns (out: InitialResult)
    requires forall i :: 0 <= i < |nodes| ==> Uint(|nodes[i].valueType|)
    ensures A.Admit(nodes,result,hash).Rejected? ==> out == AdmissionFailed(A.Admit(nodes,result,hash).error)
    ensures A.Admit(nodes,result,hash).Accepted? ==> out.Initialized?
    ensures out.Initialized? ==> (Valid(out.types,out.cache) && out.cache == Cold(out.types) && |out.types| == |nodes| &&
                                  (forall i :: 0 <= i < |nodes| ==> Render(out.types[i]) == nodes[i].valueType && !out.cache.ready[i]))
  {
    var admitted := Admission.Prepare(nodes,result,hash);
    if admitted.Rejected? { out := AdmissionFailed(admitted.error); return; }
    var types := seq(|nodes|, i requires 0 <= i < |nodes| => admitted.shapes[i].syntax);
    var i := 0;
    while i < |nodes|
      invariant 0 <= i <= |nodes|
      invariant forall j :: 0 <= j < i ==> Admissible(types[j]) && WellFormed(TypeOf(types[j])) && Render(types[j]) == nodes[j].valueType
    {
      DescriptorIdentity(nodes[i].valueType);
      i := i+1;
    }
    var cache := Initialize(types);
    out := Initialized(types,cache);
  }

  ghost method CheckSelf(caller: nat, self: nat) returns (ok: bool)
    ensures ok == (caller == self)
  {
    if $AUTH_CHECK { ok := false; return; }
    ok := true;
  }

  ghost method Reuse(types: seq<Descriptor>, cache: Cache, index: nat) returns (value: seq<Byte>)
    requires Valid(types,cache) && index < |types| && cache.ready[index]
    ensures value == cache.values[index]
    ensures Validate(TypeOf(types[index]),value).Parsed?
  {
    value := cache.values[$HIT_INDEX];
    ReuseCanonical(types,cache,index);
  }

  ghost method ValidateAndStore(types: seq<Descriptor>, cache: Cache, index: nat, value: seq<Byte>) returns (out: Commit)
    requires Valid(types,cache) && index < |types| && !cache.ready[index]
    requires Uint(|Render(types[index])|) && Uint(|value|)
    ensures out.Stored? ==> out.value == value && out.cache == Store(cache,index,value) && Valid(types,out.cache) && Extends(cache,out.cache)
    ensures out.Invalid? ==> out.cache == cache && !out.reason.Ok?
    ensures !out.Invalid? || !out.reason.Panic? ==> (out.Stored? <==> Validate(TypeOf(types[index]),value).Parsed?)
  {
    var checked := AbiConstructionValidation.CachedValidate(Render(types[index]),value,types[index],cache.dynamic[index],cache.words[index]);
    if !checked.Ok? { out := Commit.Invalid(checked,cache); return; }
    var values := cache.values[index := value];
    var ready := cache.ready[index := $STORE_READY];
    var updated := Cache(values,ready,cache.dynamic,cache.words);
    StoreValid(types,cache,index,value);
    out := Stored(value,updated);
  }

  ghost method TryResult(original: Cache, attempted: Attempt) returns (out: GuardResult)
    ensures out == Guard(original,attempted)
  {
    if attempted.Succeeded? {
      var values := $ADOPT_VALUES;
      var ready := $ADOPT_READY;
      out := Accepted(attempted.value,Cache(values,ready,original.dynamic,original.words));
    } else {
      var observed := attempted.observation;
      var head := if |observed.data| == 4 then observed.data else [0,0,0,0];
      if $EXHAUSTED { out := Exhaustion(original); return; }
      out := OrdinaryFailure(original);
    }
  }
}
