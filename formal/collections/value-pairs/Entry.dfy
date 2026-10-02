// SPDX-License-Identifier: MIT
include "EntryModel.dfy"
module CollectionsValuePairsEntry {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import E = CollectionsValuePairsEntryModel
  import M = CollectionsValuePairsModel
  import Ctrl = CollectionsValuePairsControl
  import S = CollectionsValuePairsSource
  import Prop = CollectionsValuePairsProperties
  import Parser = AbiParserSource
  import C = AbiConstructionContext
  import Errors = CollectionsCodecErrorEncoding
  import Validation = CollectionsValidationConnection
  import ABI = AbiConstructionModel
  import Assembly = AbiConstructionAssembly

  ghost method Prepare(k: E.Config) returns (r: E.RawPlan)
    requires E.Basic(k)
    ensures r == E.Admission(k)
    ensures r.Ready? ==> Admissible(Group(M.Fields(r.plan))) &&
                         k.leftType == Render(r.plan.left) && k.rightType == Render(r.plan.right)
    ensures r.Ready? ==> k.kind == E.Zip ==> |k.left| == |k.right|
    ensures r.Ready? ==> k.kind == E.Unzip ==> k.lane < 2
  {
    assert Ctrl.LengthMismatch(|k.left|,|k.right|) == (|k.left| != |k.right|);
    if k.kind == E.Zip && Ctrl.LengthMismatch(|k.left|,|k.right|) { r := E.Rejected(E.LengthError(|k.left|,|k.right|)); return; }
    assert Ctrl.LaneBad(k.lane) == (k.lane > 1);
    if k.kind == E.Unzip && Ctrl.LaneBad(k.lane) { r := E.Rejected(E.LaneError(k.lane)); return; }
    var l := Parser.Shape(k.leftType);
    if !l.Shaped? { r := E.Rejected(Errors.Encode(E.ShapeResult(l))); return; }
    var right := Parser.Shape(k.rightType);
    if !right.Shaped? { r := E.Rejected(Errors.Encode(E.ShapeResult(right))); return; }
    var head := Ctrl.Head(l.words,right.words);
    assert head == 32*(Width(l.syntax)+Width(right.syntax));
    if !Uint(head) { r := E.Rejected(Errors.Encode(C.Panic(17))); return; }
    var p := M.Plan(l.syntax,right.syntax);
    Prop.FieldsFacts(p);
    assert WidthSum(M.Fields(p)) == Width(p.left)+Width(p.right);
    r := E.Ready(p);
  }
  function Prefix(values: seq<seq<Byte>>,count: nat,rest: E.Outcome): E.Outcome {
    if rest.Failed? then E.Failed(rest.reason,count+rest.visited) else E.Returned(values+rest.values,count+rest.visited)
  }
  ghost method Zip(k: E.Config,p: M.Plan) returns (r: E.Outcome)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Zip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    ensures r == E.ZipTail(k,p,0)
  {
    var out: seq<seq<Byte>> := seq(|k.left|,i => []);
    var i: nat := 0;
    while i < |k.left|
      invariant i <= |k.left| && |out| == |k.left|
      invariant E.ZipTail(k,p,0) == Prefix(out[..i],i,E.ZipTail(k,p,i))
      decreases |k.left|-i
    {
      var leftIndex := Ctrl.ZipLeft(i); var rightIndex := Ctrl.ZipRight(i);
      assert leftIndex == i && rightIndex == i;
      var l; var lr;
      l,lr := Validation.Input(k.leftType,k.left[leftIndex]);
      if !l.Success? { r := E.Failed(Errors.Encode(l),i+1); return; }
      var right; var rr;
      right,rr := Validation.Input(k.rightType,k.right[rightIndex]);
      if !right.Success? { r := E.Failed(Errors.Encode(right),i+1); return; }
      var pair: seq<seq<Byte>> := [[],[]];
      var a := Ctrl.LeftSlot(); var b := Ctrl.RightSlot();
      assert a == 0 && b == 1;
      pair := pair[a := k.left[i]][b := k.right[i]];
      assert pair == [k.left[i],k.right[i]];
      assert Uint(32+ABI.TotalBytes(pair));
      assert ABI.ValidInputs(M.Fields(p),pair);
      ABI.CanonicalPieces(M.Fields(p),pair); ABI.PiecesIndex(M.Fields(p),pair); ABI.FrameBudget(M.Fields(p),pair);
      Prop.FieldsFacts(p);
      assert WidthSum(M.Fields(p)) == Width(p.left)+Width(p.right);
      var flags := [Dyn(p.left),Dyn(p.right)];
      assert Ctrl.ArrayMode() == false;
      var tuple := Assembly.Assemble(flags,M.Head(p),pair,Ctrl.ArrayMode(),ABI.Pieces(M.Fields(p),pair));
      assert Ctrl.Envelope(Dyn(p.left),Dyn(p.right)) == (M.Base(p) == 32);
      var encoded := (if Ctrl.Envelope(Dyn(p.left),Dyn(p.right)) then Word(32) else [])+tuple;
      assert encoded == Prop.Encoded(p,pair);
      out := out[i := encoded];
      i := i+1;
    }
    r := E.Returned(out,i);
  }
  ghost method Unzip(k: E.Config,p: M.Plan) returns (r: E.Outcome)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Unzip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    ensures r == E.UnzipTail(k,p,0)
  {
    var out: seq<seq<Byte>> := seq(|k.pairs|,i => []);
    var i: nat := 0;
    while i < |k.pairs|
      invariant i <= |k.pairs| && |out| == |k.pairs|
      invariant E.UnzipTail(k,p,0) == Prefix(out[..i],i,E.UnzipTail(k,p,i))
      decreases |k.pairs|-i
    {
      var split := S.Pair(p,k.pairs[i]);
      if !split.Parts? { r := E.Failed(E.SplitError(split),i+1); return; }
      M.PairLength(p,k.pairs[i]);
      var a := Ctrl.UnzipLeft(); var b := Ctrl.UnzipRight();
      assert a == 0 && b == 1;
      var l; var lr;
      l,lr := Validation.Input(k.leftType,split.values[a]);
      if !l.Success? { r := E.Failed(Errors.Encode(l),i+1); return; }
      var right; var rr;
      right,rr := Validation.Input(k.rightType,split.values[b]);
      if !right.Success? { r := E.Failed(Errors.Encode(right),i+1); return; }
      var lane := Ctrl.Selected(k.lane);
      assert lane == k.lane;
      out := out[i := split.values[lane]];
      i := i+1;
    }
    r := E.Returned(out,i);
  }
  ghost method Run(k: E.Config) returns (r: E.Outcome)
    requires E.Basic(k) && E.Budget(k)
    ensures r == E.Judge(k)
  {
    var ready := Prepare(k);
    if !ready.Ready? { r := E.Failed(ready.reason,0); return; }
    if k.kind == E.Zip { r := Zip(k,ready.plan); } else { r := Unzip(k,ready.plan); }
  }
}
