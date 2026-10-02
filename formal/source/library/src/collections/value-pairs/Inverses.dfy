// SPDX-License-Identifier: MIT
include "Connection.dfy"
include "Success.dfy"
module CollectionsValuePairsInverses {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import E = CollectionsValuePairsEntryModel
  import M = CollectionsValuePairsModel
  import Prop = CollectionsValuePairsProperties
  import Public = CollectionsValuePairsConnection
  import Entry = CollectionsValuePairsEntry
  import Success = CollectionsValuePairsSuccess
  import Reconstruction = CollectionsValuePairsReconstruction
  import ABI = AbiConstructionModel
  function Zipped(k: E.Config,p: M.Plan): seq<seq<Byte>>
    requires |k.left| == |k.right|
  { seq(|k.left|,j requires 0 <= j < |k.left| => Prop.Encoded(p,[k.left[j],k.right[j]])) }
  function UnzipConfig(k: E.Config,p: M.Plan,lane: nat): E.Config
    requires |k.left| == |k.right|
  { E.Config(E.Unzip,k.leftType,k.rightType,[],[],Zipped(k,p),lane) }
  ghost function SplitLane(k: E.Config,p: M.Plan,lane: nat): seq<seq<Byte>>
    requires lane < 2
    requires forall j :: 0 <= j < |k.pairs| ==> M.SplitPair(p,k.pairs[j]).Parts? && |M.SplitPair(p,k.pairs[j]).values| == 2
  { seq(|k.pairs|,j requires 0 <= j < |k.pairs| => M.SplitPair(p,k.pairs[j]).values[lane]) }
  ghost function ZipConfig(k: E.Config,p: M.Plan): E.Config
    requires forall j :: 0 <= j < |k.pairs| ==> M.SplitPair(p,k.pairs[j]).Parts? && |M.SplitPair(p,k.pairs[j]).values| == 2
  { E.Config(E.Zip,k.leftType,k.rightType,SplitLane(k,p,0),SplitLane(k,p,1),[],0) }

  ghost method UnzipZip(k: E.Config,p: M.Plan,lane: nat) returns (zipped: E.Outcome,unzipped: E.Outcome)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Zip && E.Admission(k) == E.Ready(p) && lane < 2
    requires forall j :: 0 <= j < |k.left| ==> ABI.ValidInputs(M.Fields(p),[k.left[j],k.right[j]])
    requires E.Basic(UnzipConfig(k,p,lane)) && E.Budget(UnzipConfig(k,p,lane))
    ensures zipped.Returned? && unzipped.Returned?
    ensures unzipped.values == (if lane == 0 then k.left else k.right)
  {
    var ready := Entry.Prepare(k);
    Success.Zip(k,p,0);
    zipped := Public.Run(k);
    var j: nat := 0;
    while j < |k.left|
      invariant j <= |k.left|
      invariant forall at :: 0 <= at < j ==> zipped.values[at] == Zipped(k,p)[at]
      invariant forall at :: 0 <= at < j ==> M.SplitPair(p,Zipped(k,p)[at]) == M.Parts([k.left[at],k.right[at]])
      decreases |k.left|-j
    {
      Prop.SplitFrame(p,[k.left[j],k.right[j]]);
      j := j+1;
    }
    assert zipped.values == Zipped(k,p);
    var next := UnzipConfig(k,p,lane);
    var nextReady := Entry.Prepare(next);
    assert nextReady == E.Ready(p);
    Success.Unzip(next,p,0);
    unzipped := Public.Run(next);
    assert unzipped.values == (if lane == 0 then k.left else k.right);
  }
  ghost method ZipUnzip(k: E.Config,p: M.Plan) returns (left: E.Outcome,right: E.Outcome,zipped: E.Outcome)
    requires E.Basic(k) && E.Budget(k) && k.kind == E.Unzip && E.Admission(k) == E.Ready(p) && k.lane == 0
    requires forall j :: 0 <= j < |k.pairs| ==> M.SplitPair(p,k.pairs[j]).Parts? && ABI.ValidInputs(M.Fields(p),M.SplitPair(p,k.pairs[j]).values)
    requires E.Basic(ZipConfig(k,p)) && E.Budget(ZipConfig(k,p))
    requires E.Budget(E.Config(E.Unzip,k.leftType,k.rightType,[],[],k.pairs,1))
    ensures left.Returned? && right.Returned? && zipped.Returned? && zipped.values == k.pairs
  {
    var ready := Entry.Prepare(k);
    Success.Unzip(k,p,0);
    left := Public.Run(k);
    var other := E.Config(E.Unzip,k.leftType,k.rightType,[],[],k.pairs,1);
    var otherReady := Entry.Prepare(other);
    assert otherReady == E.Ready(p);
    Success.Unzip(other,p,0);
    right := Public.Run(other);
    var j: nat := 0;
    while j < |k.pairs|
      invariant j <= |k.pairs|
      invariant forall at :: 0 <= at < j ==> left.values[at] == SplitLane(k,p,0)[at] && right.values[at] == SplitLane(k,p,1)[at]
      invariant forall at :: 0 <= at < j ==> ABI.ValidInputs(M.Fields(p),[SplitLane(k,p,0)[at],SplitLane(k,p,1)[at]])
      decreases |k.pairs|-j
    {
      assert M.SplitPair(p,k.pairs[j]).values == [SplitLane(k,p,0)[j],SplitLane(k,p,1)[j]];
      j := j+1;
    }
    var next := ZipConfig(k,p);
    var nextReady := Entry.Prepare(next);
    assert nextReady == E.Ready(p);
    Success.Zip(next,p,0);
    zipped := Public.Run(next);
    j := 0;
    while j < |k.pairs|
      invariant j <= |k.pairs|
      invariant forall at :: 0 <= at < j ==> zipped.values[at] == k.pairs[at]
      decreases |k.pairs|-j
    {
      assert M.SplitPair(p,k.pairs[j]).values == [SplitLane(k,p,0)[j],SplitLane(k,p,1)[j]];
      Reconstruction.Reconstruct(p,k.pairs[j]);
      assert zipped.values[j] == Prop.Encoded(p,[SplitLane(k,p,0)[j],SplitLane(k,p,1)[j]]);
      assert zipped.values[j] == k.pairs[j];
      j := j+1;
    }
    assert zipped.values == k.pairs;
  }
}
