// SPDX-License-Identifier: MIT
// Compiler-gated exact public pack source composition; edit this template only.
include "Control.generated.dfy"

module CollectionsValueCodecPackSource {
  import T = CollectionsTraversalModel
  import M = CollectionsValueCodecModel
  import Ctrl = CollectionsValueCodecControl
  import Validation = CollectionsValidationConnection
  import V = CollectionsValidationModel
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened AbiConnectionModel
  import opened AbiDynamicValidation
  import opened AbiDynamicSemantics
  import opened AbiConstructionModel
  import opened AbiConstructionContext
  import opened AbiConstructionAssembly
  import opened AbiConstructionSplitting

  ghost method {:isolate_assertions} Pack(t: seq<Byte>, values: seq<seq<Byte>>)
    returns (out: seq<Byte>, r: Result)
    requires Uint(|t|) && Uint(|values|)
    requires forall i :: 0 <= i < |values| ==> Uint(|values[i]|)
    requires Uint(64+TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> V.Room(t,values[i])
    ensures Whole(t).Shaped? ==> r == M.PackCheck(t,values,0)
    ensures r.Success? ==> Whole(t).Shaped? && ValidInputs(Copies(Whole(t).syntax,|values|),values)
    ensures Whole(t).Shaped? && !r.Panic? ==> r.Success? == ValidInputs(Copies(Whole(t).syntax,|values|),values)
    ensures r.Success? ==> |out| == 64+TotalBytes(values)
    ensures r.Success? ==> out == Word(32)+Word(|values|)+Frame(Pieces(Copies(Whole(t).syntax,|values|),values))
    ensures r.Success? ==> WellTyped(Array(TypeOf(Whole(t).syntax)),Items(Decoded(Copies(Whole(t).syntax,|values|),values)))
    ensures r.Success? ==> out == Encode(Array(TypeOf(Whole(t).syntax)),Items(Decoded(Copies(Whole(t).syntax,|values|),values)))
    ensures Whole(t).BadDescriptor? ==> r == InvalidDescriptor(Whole(t).at)
    ensures Whole(t).ArithmeticPanic? ==> r == Result.Panic(17)
    ensures Whole(t).Shaped? && r.Panic? ==> (exists i :: 0 <= i < |values| && !CursorRoom(Whole(t).syntax,|values[i]|))
  {
    out := [];
    var shape := AbiParserSource.Shape(t);
    if shape.BadDescriptor? { r := InvalidDescriptor(shape.at); return; }
    if shape.ArithmeticPanic? { r := Result.Panic(17); return; }
    var s := shape.syntax;
    var fs := Copies(s,|values|);
    var i := 0;
    while i < |values|
      invariant 0 <= i <= |values|
      invariant forall j :: 0 <= j < i ==> ValidInput(s,values[j])
      invariant forall j :: 0 <= j < i ==> V.Checked(t,values[j],Context(ValueKind,0,0,0,0)).Success?
    {
      assert Ctrl.PackValidate(i) == i;
      var reply: T.Reply;
      r,reply := Validation.Input(t,values[Ctrl.PackValidate(i)]);
      if !r.Success? {
        M.PackFailure(t,values,0,i);
        return;
      }
      i := i+1;
    }
    M.PackSuccess(t,values,0);
    assert ValidInputs(fs,values);
    CanonicalPieces(fs,values); PiecesIndex(fs,values); FrameBudget(fs,values);
    Sizes(Pieces(fs,values),HeadSize(Pieces(fs,values)));
    CopyLayout(s,|values|);
    AbiTupleWords.ProductAssoc(|values|,shape.words,32);
    assert |values|*shape.words*32 == HeadSize(Pieces(fs,values));
    assert Uint(|values|*shape.words) && Uint(|values|*shape.words*32);
    var flags := [shape.dynamic];
    assert Ctrl.ArrayMode() == true;
    out := Assemble(flags,|values|*shape.words*32,values,Ctrl.ArrayMode(),Pieces(fs,values));
    ModelType(s);
    var owner := Array(TypeOf(s));
    assert Children(owner,|values|) == TypesOf(fs);
    AggregateParts(owner,Decoded(fs,values));
    r := Success;
  }
}
