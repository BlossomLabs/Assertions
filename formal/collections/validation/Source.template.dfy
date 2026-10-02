// SPDX-License-Identifier: MIT
// Restricted source correspondence, gated complete function ASTs. Source $HASH.
include "Model.dfy"
module CollectionsValidationSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import C = AbiConstructionContext
  import Codec = AbiExactOutcomeCached
  import Parser = AbiParserSource
  import M = CollectionsValidationModel

  ghost method Validate(t: seq<Byte>, v: seq<Byte>, context: C.Context) returns (r: C.Result)
    requires M.Room(t,v)
    ensures r == M.Checked(t,v,context)
  {
    var shape := Parser.Shape(t);
    if shape.BadDescriptor? { r := C.InvalidDescriptor(shape.at); return; }
    if shape.ArithmeticPanic? { r := C.Panic(17); return; }
    var raw := Codec.CachedValidate(t,v,shape.syntax,shape.dynamic,shape.words);
    r := C.Route(raw,context);
  }
  ghost method Input(t: seq<Byte>, v: seq<Byte>) returns (r: C.Result)
    requires M.Room(t,v)
    ensures r == M.Checked(t,v,C.Context(C.ValueKind,0,0,0,0))
  { r := Validate(t,v,C.Context(C.ValueKind,0,0,0,0)); }
  ghost method Result(t: seq<Byte>, v: seq<Byte>, operation: nat, index: nat, target: nat) returns (r: C.Result)
    requires M.Room(t,v)
    ensures r == M.Checked(t,v,C.Context(C.CallbackKind,operation,index,0,target))
  { r := Validate(t,v,C.Context(C.CallbackKind,$OPERATION,$INDEX,$OTHER,$TARGET)); }
}
