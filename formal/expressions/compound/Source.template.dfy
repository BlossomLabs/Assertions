// SPDX-License-Identifier: MIT
// Compound source adapters for Expressions.sol $HASH.
include "../../arguments/Source.generated.dfy"
include "../../abi/construction/Pack.generated.dfy"
module ExpressionCompoundSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiLayoutSpec
  import opened AbiLayoutCanonical
  import opened AbiConstructionModel
  import opened AbiConstructionContext
  import opened AbiConstructionComponent
  import opened AbiConstructionAssembly

  import ArgumentsModel
  import ArgumentsTuple
  import AbiLayoutSource
  import AbiLayoutSoundness
  import AbiConstructionTuple
  import AbiConstructionPack

  ghost method Arguments(t: seq<Byte>, values: seq<seq<Byte>>) returns (receipt: ArgumentsModel.Receipt, dynamic: bool)
    requires Uint(|t|) && Uint(|values|) && Uint(TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> Uint(|values[i]|)
    ensures ArgumentsModel.CodecPost(t,values,receipt)
    ensures receipt.result.Success? ==>
              if ArgumentsModel.EmptyArguments(t,values) then !dynamic else dynamic == IsDynamic(TypeOf(Group(receipt.fields)))
  {
    dynamic := false;
    if |t| == 2 && t[0] == 40 && t[1] == 41 && |values| == 0 {
      assert t == [40,41]; receipt := ArgumentsModel.Encoded([],Success,[]); return;
    }
    var plan := AbiLayoutSource.Layout(t);
    if plan.BadLayout? { receipt := ArgumentsModel.Encoded([],InvalidDescriptor(plan.at),[]); return; }
    if plan.LayoutPanic? { receipt := ArgumentsModel.Encoded([],Result.Panic(17),[]); return; }
    var fs := AbiLayoutSoundness.LayoutWitness(t);
    var data,r := ArgumentsTuple.TupleChecked(plan,t,values,fs);
    receipt := ArgumentsModel.Encoded(data,r,fs);
    if !r.Success? { return; }
    dynamic := AbiConstructionTuple.IsDynamic(plan);
    PlanIndex(0,fs,0);
    ModelType(Group(fs));
    assert plan == PlanFor(0,fs,0);
    assert |plan.dynamics| == |fs|;
    if dynamic {
      var i :| 0 <= i < |plan.dynamics| && plan.dynamics[i];
      assert plan.dynamics[i] == Dyn(fs[i]);
      assert exists j :: 0 <= j < |fs| && Dyn(fs[j]);
    } else if exists i :: 0 <= i < |fs| && Dyn(fs[i]) {
      var i :| 0 <= i < |fs| && Dyn(fs[i]);
      assert plan.dynamics[i] == Dyn(fs[i]);
      assert false;
    }
    assert dynamic == (exists i :: 0 <= i < |fs| && Dyn(fs[i]));
  }

  ghost method Tuple(t: seq<Byte>, values: seq<seq<Byte>>) returns (out: seq<Byte>, receipt: ArgumentsModel.Receipt)
    requires Uint(|t|) && Uint(|values|) && Uint(TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> Uint(|values[i]|)
    ensures ArgumentsModel.CodecPost(t,values,receipt)
    ensures receipt.result.Success? && ArgumentsModel.EmptyArguments(t,values) ==> out == []
    ensures receipt.result.Success? && !ArgumentsModel.EmptyArguments(t,values) ==>
              out == Encode(TypeOf(Group(receipt.fields)),Items(Decoded(receipt.fields,values)))
  {
    var dynamic;
    receipt,dynamic := Arguments(t,values);
    out := receipt.data;
    if !receipt.result.Success? { return; }
    if dynamic { out := Word($TUPLE_OFFSET)+out; }
  }

  ghost method CallArguments(selector: seq<Byte>, t: seq<Byte>, values: seq<seq<Byte>>) returns (out: seq<Byte>, receipt: ArgumentsModel.Receipt)
    requires |selector| == 4 && Uint(|t|) && Uint(|values|) && Uint(TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> Uint(|values[i]|)
    ensures ArgumentsModel.CodecPost(t,values,receipt)
    ensures receipt.result.Success? ==> out == selector+receipt.data
    ensures receipt.result.Success? && ArgumentsModel.EmptyArguments(t,values) ==> out == selector
    ensures receipt.result.Success? && !ArgumentsModel.EmptyArguments(t,values) ==>
              out == selector+Body(TypeOf(Group(receipt.fields)),Items(Decoded(receipt.fields,values)))
  {
    var dynamic;
    receipt,dynamic := Arguments(t,values);
    out := [];
    if !receipt.result.Success? { return; }
    out := selector+receipt.data;
  }

  ghost method Wrap(value: seq<Byte>) returns (out: seq<Byte>)
    requires Uint(|value|+96)
    ensures out == Encode(Bytes,Buffer(value))
    ensures Validate(Bytes,out).Parsed?
  {
    out := Word(32)+Word(|value|)+Padded(value);
    PaddingLayout(value);
    ValidationComplete(Bytes,Buffer(value));
  }

  ghost method Array(t: seq<Byte>, values: seq<seq<Byte>>) returns (out: seq<Byte>, r: Result)
    requires Uint(|t|) && Uint(|values|) && Uint(64+TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> Uint(|values[i]|)
    ensures r.Success? ==> Whole(t).Shaped? && ValidInputs(Copies(Whole(t).syntax,|values|),values)
    ensures Whole(t).Shaped? && !r.Panic? ==> r.Success? == ValidInputs(Copies(Whole(t).syntax,|values|),values)
    ensures r.Success? ==> WellTyped(AbiEncoding.Array(TypeOf(Whole(t).syntax)),Items(Decoded(Copies(Whole(t).syntax,|values|),values)))
    ensures r.Success? ==> out == Encode(AbiEncoding.Array(TypeOf(Whole(t).syntax)),Items(Decoded(Copies(Whole(t).syntax,|values|),values)))
    ensures Whole(t).BadDescriptor? ==> r == InvalidDescriptor(Whole(t).at)
    ensures Whole(t).ArithmeticPanic? ==> r == Result.Panic(17)
  {
    out,r := AbiConstructionPack.Pack(t,values);
  }
}
