// SPDX-License-Identifier: MIT
include "Entry.dfy"
include "Reconstruction.dfy"
module CollectionsValuePairsFacts {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import E = CollectionsValuePairsEntryModel
  import M = CollectionsValuePairsModel
  import Prop = CollectionsValuePairsProperties
  import Reconstruction = CollectionsValuePairsReconstruction
  import ABI = AbiConstructionModel
  import C = AbiConstructionContext
  import Validation = CollectionsValidationConnection
  import Canonical = AbiValidation
  import Encoding = AbiEncoding

  ghost method Zip(k: E.Config,p: M.Plan,i: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Zip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    requires i <= |k.left|
    ensures E.ZipTail(k,p,i).Returned? ==> |E.ZipTail(k,p,i).values| == |k.left|-i && E.ZipTail(k,p,i).visited == |k.left|-i
    ensures 0 <= E.ZipTail(k,p,i).visited <= |k.left|-i
    ensures E.ZipTail(k,p,i).Failed? ==> E.ZipTail(k,p,i).visited > 0
    decreases |k.left|-i
  {
    if i < |k.left| {
      var l := Validation.Verdict(k.leftType,k.left[i],C.Context(C.ValueKind,0,0,0,0));
      if !l.Success? { return; }
      var r := Validation.Verdict(k.rightType,k.right[i],C.Context(C.ValueKind,0,0,0,0));
      if !r.Success? { return; }
      Zip(k,p,i+1);

    }
  }
  ghost method ZipAt(k: E.Config,p: M.Plan,i: nat,j: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Zip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    requires i <= j < |k.left| && E.ZipTail(k,p,i).Returned?
    ensures ABI.ValidInputs(M.Fields(p),[k.left[j],k.right[j]])
    ensures j-i < |E.ZipTail(k,p,i).values| && E.ZipTail(k,p,i).values[j-i] == Prop.Encoded(p,[k.left[j],k.right[j]])
    decreases j-i
  {
    var l := Validation.Verdict(k.leftType,k.left[i],C.Context(C.ValueKind,0,0,0,0));
    var r := Validation.Verdict(k.rightType,k.right[i],C.Context(C.ValueKind,0,0,0,0));
    assert l.Success? && r.Success?;
    if j > i { ZipAt(k,p,i+1,j); }
  }
  ghost method UnzipAt(k: E.Config,p: M.Plan,i: nat,j: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Unzip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    requires i <= j < |k.pairs| && E.UnzipTail(k,p,i).Returned?
    ensures M.SplitPair(p,k.pairs[j]).Parts? && ABI.ValidInputs(M.Fields(p),M.SplitPair(p,k.pairs[j]).values)
    ensures j-i < |E.UnzipTail(k,p,i).values| && E.UnzipTail(k,p,i).values[j-i] == M.SplitPair(p,k.pairs[j]).values[k.lane]
    decreases j-i
  {
    var split := M.SplitPair(p,k.pairs[i]);
    assert split.Parts?;
    M.PairLength(p,k.pairs[i]);
    var l := Validation.Verdict(k.leftType,split.values[0],C.Context(C.ValueKind,0,0,0,0));
    var r := Validation.Verdict(k.rightType,split.values[1],C.Context(C.ValueKind,0,0,0,0));
    assert l.Success? && r.Success?;
    if j > i { UnzipAt(k,p,i+1,j); }
  }
  ghost method Unzip(k: E.Config,p: M.Plan,i: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Unzip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    requires i <= |k.pairs|
    ensures E.UnzipTail(k,p,i).Returned? ==> |E.UnzipTail(k,p,i).values| == |k.pairs|-i && E.UnzipTail(k,p,i).visited == |k.pairs|-i
    ensures 0 <= E.UnzipTail(k,p,i).visited <= |k.pairs|-i
    ensures E.UnzipTail(k,p,i).Failed? ==> E.UnzipTail(k,p,i).visited > 0
    decreases |k.pairs|-i
  {
    if i < |k.pairs| {
      var split := M.SplitPair(p,k.pairs[i]);
      if !split.Parts? { return; }
      M.PairLength(p,k.pairs[i]);
      var l := Validation.Verdict(k.leftType,split.values[0],C.Context(C.ValueKind,0,0,0,0));
      if !l.Success? { return; }
      var r := Validation.Verdict(k.rightType,split.values[1],C.Context(C.ValueKind,0,0,0,0));
      if !r.Success? { return; }
      assert ABI.ValidInputs(M.Fields(p),split.values);
      Unzip(k,p,i+1);

    }
  }
}
