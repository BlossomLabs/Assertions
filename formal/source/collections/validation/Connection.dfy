// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsValidationConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import Encoding = AbiEncoding
  import V = AbiValidation
  import C = AbiConstructionContext
  import E = AbiExactOutcomeSpec
  import Codec = AbiExactOutcomeCached
  import W = CollectionsCodecErrorEncoding
  import T = CollectionsTraversalModel
  import M = CollectionsValidationModel
  import S = CollectionsValidationSource
  import Parser = AbiParserSource

  ghost method Verdict(t: seq<Byte>, v: seq<Byte>, context: C.Context) returns (r: C.Result)
    requires M.Room(t,v)
    ensures Whole(t).Shaped? ==> Admissible(Whole(t).syntax) && Encoding.WellFormed(TypeOf(Whole(t).syntax))
    ensures r == M.Checked(t,v,context)
    ensures Whole(t).BadDescriptor? ==> r == C.InvalidDescriptor(Whole(t).at)
    ensures Whole(t).ArithmeticPanic? ==> r == C.Panic(17)
    ensures Whole(t).Shaped? ==> !r.Panic? && !r.InvalidDescriptor?
    ensures r.Success? == (Whole(t).Shaped? && V.Validate(TypeOf(Whole(t).syntax),v).Parsed?)
    ensures Whole(t).Shaped? && !r.Success? ==> E.Validate(Whole(t).syntax,v).Invalid? && r == C.Failure(E.Validate(Whole(t).syntax,v).offset,context)
  {
    r := S.Validate(t,v,context);
    var shape := Parser.Shape(t);
    if shape.Shaped? {
      var raw := Codec.CachedValidate(t,v,shape.syntax,shape.dynamic,shape.words);
    }
  }
  ghost method Input(t: seq<Byte>, v: seq<Byte>) returns (r: C.Result, reply: T.Reply)
    requires M.Room(t,v)
    ensures Whole(t).Shaped? ==> Admissible(Whole(t).syntax) && Encoding.WellFormed(TypeOf(Whole(t).syntax))
    ensures r == M.Checked(t,v,C.Context(C.ValueKind,0,0,0,0)) && reply == M.Project(r)
    ensures reply == M.Reply(T.Validate(t,v),0,0)
    ensures reply.Ok? == (Whole(t).Shaped? && V.Validate(TypeOf(Whole(t).syntax),v).Parsed?)
    ensures Whole(t).Shaped? && reply.Error? ==> E.Validate(Whole(t).syntax,v).Invalid?
    ensures Whole(t).Shaped? && reply.Error? ==> reply.reason == W.Selector(C.InvalidValue(E.Validate(Whole(t).syntax,v).offset))+Word(E.Validate(Whole(t).syntax,v).offset)
  {
    r := S.Input(t,v);
    var same := Verdict(t,v,C.Context(C.ValueKind,0,0,0,0));
    reply := M.Project(r);
  }
  ghost method {:fuel W.Words, 6} Result(t: seq<Byte>, v: seq<Byte>, operation: nat, index: nat, target: nat) returns (r: C.Result, reply: T.Reply)
    requires M.Room(t,v)
    ensures Whole(t).Shaped? ==> Admissible(Whole(t).syntax) && Encoding.WellFormed(TypeOf(Whole(t).syntax))
    ensures r == M.Checked(t,v,C.Context(C.CallbackKind,operation,index,0,target)) && reply == M.Project(r)
    ensures reply == M.Reply(T.ValidateResult(t,v,index),operation,target)
    ensures reply.Ok? == (Whole(t).Shaped? && V.Validate(TypeOf(Whole(t).syntax),v).Parsed?)
    ensures Whole(t).Shaped? && reply.Error? ==> r == C.InvalidCallbackResult(operation,index,0,target) && reply.reason == W.Selector(r)+NatBytes(operation,4)+Zeros(28)+Word(index)+Word(0)+Word(target)
    ensures Whole(t).BadDescriptor? ==> reply == T.Error(W.Encode(C.InvalidDescriptor(Whole(t).at)))
  {
    r := S.Result(t,v,operation,index,target);
    var same := Verdict(t,v,C.Context(C.CallbackKind,operation,index,0,target));
    reply := M.Project(r);
    W.Error(r);
  }
  ghost method Observe(q: T.Request, c: T.Context, operation: nat, target: nat) returns (observation: T.Observation)
    requires q.Shape? || q.Validate? || q.ValidateResult?
    requires q.Shape? ==> Uint(|q.descriptor|)
    requires !q.Shape? ==> M.Room(q.descriptor,q.value)
    ensures observation == T.Observation(M.Reply(q,operation,target),c.state)
  {
    var r: C.Result;
    var reply: T.Reply;
    if q.Shape? {
      var shape := Parser.Shape(q.descriptor);
      r := if shape.Shaped? then C.Success else if shape.BadDescriptor? then C.InvalidDescriptor(shape.at) else C.Panic(17);
      reply := M.Project(r);
    } else if q.Validate? { r,reply := Input(q.descriptor,q.value); }
    else { r,reply := Result(q.descriptor,q.value,operation,q.index,target); }
    observation := T.Observation(reply,c.state);
  }
}
