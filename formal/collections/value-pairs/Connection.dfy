// SPDX-License-Identifier: MIT
include "Facts.dfy"
module CollectionsValuePairsConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import E = CollectionsValuePairsEntryModel
  import M = CollectionsValuePairsModel
  import Prop = CollectionsValuePairsProperties
  import Reconstruction = CollectionsValuePairsReconstruction
  import Entry = CollectionsValuePairsEntry
  import Facts = CollectionsValuePairsFacts
  import ABI = AbiConstructionModel
  import Canonical = AbiValidation
  import Encoding = AbiEncoding

  ghost opaque predicate PairResult(p: M.Plan,input: seq<Byte>,value: seq<Byte>,lane: nat)
    requires lane < 2
  {
    M.SplitPair(p,input).Parts? && ABI.ValidInputs(M.Fields(p),M.SplitPair(p,input).values) &&
    value == M.SplitPair(p,input).values[lane] && Prop.Encoded(p,M.SplitPair(p,input).values) == input
  }
  ghost opaque predicate ZipResult(p: M.Plan,left: seq<Byte>,right: seq<Byte>,value: seq<Byte>)
    requires Encoding.WellFormed(TypeOf(Group(M.Fields(p))))
  {
    ABI.ValidInputs(M.Fields(p),[left,right]) && value == Prop.Encoded(p,[left,right]) &&
    Canonical.Validate(TypeOf(Group(M.Fields(p))),value).Parsed?
  }
  ghost method ZipRow(k: E.Config,p: M.Plan,r: E.Outcome,j: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Zip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right)
    requires Encoding.WellFormed(TypeOf(Group(M.Fields(p))))
    requires r == E.ZipTail(k,p,0) && r.Returned? && j < |k.left| && j < |r.values|
    ensures ZipResult(p,k.left[j],k.right[j],r.values[j])
  {
    Facts.ZipAt(k,p,0,j); Prop.Canonical(p,[k.left[j],k.right[j]]); reveal ZipResult();
  }
  ghost method UnzipRow(k: E.Config,p: M.Plan,r: E.Outcome,j: nat)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Unzip && E.Admission(k) == E.Ready(p)
    requires Admissible(Group(M.Fields(p))) && k.leftType == Render(p.left) && k.rightType == Render(p.right) && k.lane < 2
    requires r == E.UnzipTail(k,p,0) && r.Returned? && j < |k.pairs| && j < |r.values|
    ensures PairResult(p,k.pairs[j],r.values[j],k.lane)
  {
    Facts.UnzipAt(k,p,0,j); Reconstruction.Reconstruct(p,k.pairs[j]); reveal PairResult();
  }
  ghost method {:fuel E.ZipTail,0,0} {:fuel E.UnzipTail,0,0} Run(k: E.Config) returns (r: E.Outcome)
    requires E.Basic(k) && E.Budget(k)
    ensures r == E.Judge(k)
    ensures !E.Admission(k).Ready? ==> r == E.Failed(E.Admission(k).reason,0)
    ensures r.Returned? ==> E.Admission(k).Ready?
    ensures E.Admission(k).Ready? ==> Whole(k.leftType).Shaped? && Whole(k.rightType).Shaped?
    ensures r.Returned? ==> |r.values| == (if k.kind == E.Zip then |k.left| else |k.pairs|) && r.visited == |r.values|
    ensures E.Admission(k).Ready? ==> E.Admission(k).plan.left == Whole(k.leftType).syntax && E.Admission(k).plan.right == Whole(k.rightType).syntax
    ensures E.Admission(k).Ready? ==> Encoding.WellFormed(TypeOf(Group(M.Fields(E.Admission(k).plan)))) && Encoding.WellFormed(TypeOf(E.Admission(k).plan.left)) && Encoding.WellFormed(TypeOf(E.Admission(k).plan.right))
    ensures r.Returned? && k.kind == E.Zip ==> forall j :: 0 <= j < |r.values| ==>
                                                             var p := E.Admission(k).plan;
                                                             ABI.ValidInputs(M.Fields(p),[k.left[j],k.right[j]]) && r.values[j] == Prop.Encoded(p,[k.left[j],k.right[j]]) && Canonical.Validate(TypeOf(Group(M.Fields(p))),r.values[j]).Parsed?
    ensures r.Returned? && k.kind == E.Unzip ==> forall j :: 0 <= j < |r.values| ==>
                                                               var p := E.Admission(k).plan;
                                                               M.SplitPair(p,k.pairs[j]).Parts? && ABI.ValidInputs(M.Fields(p),M.SplitPair(p,k.pairs[j]).values) &&
                                                               r.values[j] == M.SplitPair(p,k.pairs[j]).values[k.lane] && Prop.Encoded(p,M.SplitPair(p,k.pairs[j]).values) == k.pairs[j]
  {
    var ready := Entry.Prepare(k);
    r := Entry.Run(k);
    if !ready.Ready? { return; }
    var p := ready.plan;
    assert M.Fields(p)[0] == p.left && M.Fields(p)[1] == p.right;
    assert Good(p.left) && Good(p.right);
    ModelType(Group(M.Fields(p))); ModelType(p.left); ModelType(p.right);
    if k.kind == E.Zip {
      assert r == E.ZipTail(k,p,0);
      Facts.Zip(k,p,0);
      if r.Returned? {
        var j: nat := 0;
        while j < |r.values|
          invariant j <= |r.values|
          invariant forall at :: 0 <= at < j ==> ZipResult(p,k.left[at],k.right[at],r.values[at])
          decreases |r.values|-j
        {
          ZipRow(k,p,r,j);
          j := j+1;
        }
        reveal ZipResult();
      }
    } else {
      assert r == E.UnzipTail(k,p,0);
      Facts.Unzip(k,p,0);
      if r.Returned? {
        var j: nat := 0;
        while j < |r.values|
          invariant j <= |r.values|
          invariant forall at :: 0 <= at < j ==> PairResult(p,k.pairs[at],r.values[at],k.lane)
          decreases |r.values|-j
        {
          UnzipRow(k,p,r,j);
          j := j+1;
        }
        reveal PairResult();
      }
    }
  }
}
