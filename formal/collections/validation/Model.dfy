// SPDX-License-Identifier: MIT
include "../codec-errors/Connection.dfy"
include "../../abi/outcomes/Cached.generated.dfy"
module CollectionsValidationModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import D = AbiDynamicSemantics
  import E = AbiExactOutcomeSpec
  import C = AbiConstructionContext
  import W = CollectionsCodecErrorEncoding
  import T = CollectionsTraversalModel

  ghost predicate Room(t: seq<Byte>, v: seq<Byte>) {
    Uint(|t|) && Uint(|v|) && (Whole(t).Shaped? ==> D.CursorRoom(Whole(t).syntax,|v|))
  }
  ghost function Checked(t: seq<Byte>, v: seq<Byte>, c: C.Context): C.Result
    requires Uint(|t|)
  {
    var shape := Whole(t);
    if shape.BadDescriptor? then C.InvalidDescriptor(shape.at)
    else if shape.ArithmeticPanic? then C.Panic(17)
    else if Good(shape.syntax) then C.Route(E.Validate(shape.syntax,v),c)
    else C.InvalidDescriptor(0) // Unreachable after the proved source parser.
  }
  function Project(r: C.Result): T.Reply {
    if r.Success? then T.Ok([],false) else T.Error(W.Encode(r))
  }
  ghost function Reply(q: T.Request, operation: nat, target: nat): T.Reply
    requires q.Shape? || q.Validate? || q.ValidateResult?
    requires Uint(|q.descriptor|)
  {
    if q.Shape? then
      var shape := Whole(q.descriptor);
      Project(if shape.Shaped? then C.Success else if shape.BadDescriptor? then C.InvalidDescriptor(shape.at) else C.Panic(17))
    else Project(Checked(q.descriptor,q.value,
                         if q.Validate? then C.Context(C.ValueKind,0,0,0,0)
                         else C.Context(C.CallbackKind,operation,q.index,0,target)))
  }
}
