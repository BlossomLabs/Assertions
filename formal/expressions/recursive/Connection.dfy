// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
include "../evaluation/CacheBridge.dfy"
module ExpressionRecursiveConnection {
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import A = ExpressionAdmission
  import S = ExpressionRecursiveSpec
  import Source = ExpressionRecursiveSource
  import AbiConstructionValidation
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics

  ghost method ValidationProjection(types: seq<Descriptor>, cache: C.Cache, index: nat, value: seq<Byte>)
    returns (checked: Outcome)
    requires C.Metadata(types,cache) && index < |types|
    requires Uint(|Render(types[index])|) && Uint(|value|) && CursorRoom(types[index],|value|)
    ensures !checked.Panic?
    ensures checked.Ok? == B.Canonical(types)(index,value)
  {
    checked := AbiConstructionValidation.CachedValidate(Render(types[index]),value,types[index],cache.dynamic[index],cache.words[index]);
    B.ByteIdentity(value);
  }

  ghost method EvaluateInitialized(nodes: seq<A.Node>, types: seq<Descriptor>, original: C.Cache,
                                   hash: seq<Byte>->nat, truth: E.Value->bool,
                                   reject: (nat,E.Value)->E.Error, oracle: (E.Request,seq<E.Request>)->E.Raw,
                                   index: nat, history: seq<E.Request>) returns (out: E.Result)
    requires forall i | 0 <= i < |nodes| :: Uint(|nodes[i].valueType|)
    requires A.Admit(nodes,index,hash).Accepted?
    requires |nodes| == |types| && C.Valid(types,original)
    requires forall i | 0 <= i < |types| :: Render(types[i]) == nodes[i].valueType
    ensures index < |types| && E.Program(B.Project(nodes))
    ensures E.Good(B.Project(nodes),B.Canonical(types),out.memo) && E.Extends(B.View(original),out.memo)
    ensures out == S.Evaluate(B.Project(nodes),B.Canonical(types),truth,reject,oracle,index,B.View(original),history)
    ensures out.Success? ==> B.Bytes(out.value)
    ensures out.Success? ==> C.SuccessfulReceipt(types,index,original,
                                                 C.Succeeded(B.Narrow(out.value),B.Reify(types,original,out.memo)))
    ensures out.Success? ==> Validate(TypeOf(types[index]),B.Narrow(out.value)).Parsed?
    ensures out.Success? ==> WellTyped(TypeOf(types[index]),Validate(TypeOf(types[index]),B.Narrow(out.value)).value)
    ensures out.Success? ==> B.Narrow(out.value) == Encode(TypeOf(types[index]),Validate(TypeOf(types[index]),B.Narrow(out.value)).value)
    ensures index in B.View(original) ==> out == E.Success(B.View(original)[index],B.View(original),history)
  {
    B.AdmittedGraph(nodes,index,hash);
    B.ViewValid(B.Project(nodes),types,original);
    out := Source.Run(B.Project(nodes),B.Canonical(types),truth,reject,oracle,index,B.View(original),history);
    B.ReifyValid(B.Project(nodes),types,original,out.memo);
    if out.Success? { C.ReuseCanonical(types,B.Reify(types,original,out.memo),index); }
  }
}
