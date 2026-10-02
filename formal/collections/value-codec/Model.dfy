// SPDX-License-Identifier: MIT
include "../validation/Connection.dfy"
include "../../abi/construction/Inverses.dfy"
module CollectionsValueCodecModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiParserSpec
  import opened AbiShapeSemantics
  import V = CollectionsValidationModel
  import C = AbiConstructionContext
  import Exact = AbiExactOutcomeSpec
  import Model = AbiConnectionModel
  import Construction = AbiConstructionModel
  datatype Outcome = Packed(bytes: seq<Byte>) | Unpacked(values: seq<seq<Byte>>) | Failed(reason: C.Result)
  ghost function PackCheck(t: seq<Byte>,values: seq<seq<Byte>>,i: nat): C.Result
    requires Uint(|t|) && i <= |values|
    decreases |values|-i
  {
    if i == |values| then C.Success else
    var checked := V.Checked(t,values[i],C.Context(C.ValueKind,0,0,0,0));
    if !checked.Success? then checked else PackCheck(t,values,i+1)
  }
  ghost function PackJudge(t: seq<Byte>,values: seq<seq<Byte>>): Outcome
    requires Uint(|t|)
  {
    var parsed := Whole(t);
    if parsed.BadDescriptor? then Failed(C.InvalidDescriptor(parsed.at)) else
    if parsed.ArithmeticPanic? then Failed(C.Panic(17)) else
    var checked := PackCheck(t,values,0);
    if !checked.Success? then Failed(checked) else
    Packed(Word(32)+Word(|values|)+Frame(Construction.Pieces(Model.Copies(parsed.syntax,|values|),values)))
  }
  ghost function UnpackResult(t: seq<Byte>,encoded: seq<Byte>): C.Result
    requires Uint(|t|)
  {
    var parsed := Whole(t);
    if parsed.BadDescriptor? then C.InvalidDescriptor(parsed.at) else
    if parsed.ArithmeticPanic? then C.Panic(17) else
    if Good(parsed.syntax) then C.Route(Exact.Validate(Dynamic(parsed.syntax),encoded),C.Context(C.ValueKind,0,0,0,0)) else C.InvalidDescriptor(0)
  }
  lemma PackFailure(t: seq<Byte>,values: seq<seq<Byte>>,first: nat,bad: nat)
    requires Uint(|t|) && first <= bad < |values|
    requires forall i :: first <= i < bad ==> V.Checked(t,values[i],C.Context(C.ValueKind,0,0,0,0)).Success?
    requires !V.Checked(t,values[bad],C.Context(C.ValueKind,0,0,0,0)).Success?
    ensures PackCheck(t,values,first) == V.Checked(t,values[bad],C.Context(C.ValueKind,0,0,0,0))
    decreases bad-first
  { if first < bad { PackFailure(t,values,first+1,bad); } }
  lemma PackSuccess(t: seq<Byte>,values: seq<seq<Byte>>,first: nat)
    requires Uint(|t|) && first <= |values|
    requires forall i :: first <= i < |values| ==> V.Checked(t,values[i],C.Context(C.ValueKind,0,0,0,0)).Success?
    ensures PackCheck(t,values,first) == C.Success
    decreases |values|-first
  { if first < |values| { PackSuccess(t,values,first+1); } }
}
