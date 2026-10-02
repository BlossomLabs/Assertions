// SPDX-License-Identifier: MIT
include "Facts.dfy"
module CollectionsValuePairsSuccess {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import E = CollectionsValuePairsEntryModel
  import M = CollectionsValuePairsModel
  import ABI = AbiConstructionModel
  import Validation = CollectionsValidationConnection
  import C = AbiConstructionContext
  ghost method Zip(k: E.Config,p: M.Plan,i: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Zip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    requires i <= |k.left| && forall j :: i <= j < |k.left| ==> ABI.ValidInputs(M.Fields(p),[k.left[j],k.right[j]])
    ensures E.ZipTail(k,p,i).Returned?
    decreases |k.left|-i
  {
    if i < |k.left| {
      assert M.Fields(p)[0] == p.left && M.Fields(p)[1] == p.right;
      assert ABI.ValidInput(p.left,k.left[i]) && ABI.ValidInput(p.right,k.right[i]);
      assert Whole(k.leftType).Shaped? && Whole(k.leftType).syntax == p.left;
      assert Whole(k.rightType).Shaped? && Whole(k.rightType).syntax == p.right;
      var l := Validation.Verdict(k.leftType,k.left[i],C.Context(C.ValueKind,0,0,0,0));
      var r := Validation.Verdict(k.rightType,k.right[i],C.Context(C.ValueKind,0,0,0,0));
      assert l.Success? && r.Success?;
      Zip(k,p,i+1);
    }
  }
  ghost method Unzip(k: E.Config,p: M.Plan,i: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Unzip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    requires i <= |k.pairs|
    requires forall j :: i <= j < |k.pairs| ==> M.SplitPair(p,k.pairs[j]).Parts? && ABI.ValidInputs(M.Fields(p),M.SplitPair(p,k.pairs[j]).values)
    ensures E.UnzipTail(k,p,i).Returned?
    decreases |k.pairs|-i
  {
    if i < |k.pairs| {
      var split := M.SplitPair(p,k.pairs[i]);
      M.PairLength(p,k.pairs[i]);
      var l := Validation.Verdict(k.leftType,split.values[0],C.Context(C.ValueKind,0,0,0,0));
      var r := Validation.Verdict(k.rightType,split.values[1],C.Context(C.ValueKind,0,0,0,0));
      assert l.Success? && r.Success?;
      Unzip(k,p,i+1);
    }
  }
}
