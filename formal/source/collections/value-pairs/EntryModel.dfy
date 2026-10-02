// SPDX-License-Identifier: MIT
include "Properties.dfy"
include "Source.dfy"
module CollectionsValuePairsEntryModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import M = CollectionsValuePairsModel
  import Prop = CollectionsValuePairsProperties
  import Ctrl = CollectionsValuePairsControl
  import V = CollectionsValidationModel
  import C = AbiConstructionContext
  import Errors = CollectionsCodecErrorEncoding
  import ABI = AbiConstructionModel
  datatype Kind = Zip | Unzip
  datatype Config = Config(kind: Kind,leftType: seq<Byte>,rightType: seq<Byte>,left: seq<seq<Byte>>,right: seq<seq<Byte>>,pairs: seq<seq<Byte>>,lane: nat)
  datatype RawPlan = Ready(plan: M.Plan) | Rejected(reason: seq<Byte>)
  function Basic(k: Config): bool {
    Uint(|k.leftType|) && Uint(|k.rightType|) && Uint(k.lane) &&
    Uint(32*|k.left|) && Uint(32*|k.right|) && Uint(32*|k.pairs|) &&
    (forall i :: 0 <= i < |k.left| ==> Uint(|k.left[i]|)) &&
    (forall i :: 0 <= i < |k.right| ==> Uint(|k.right[i]|)) &&
    (forall i :: 0 <= i < |k.pairs| ==> Uint(|k.pairs[i]|+32))
  }
  function ShapeResult(r: ShapeResult): C.Result {
    if r.Shaped? then C.Success else if r.BadDescriptor? then C.InvalidDescriptor(r.at) else C.Panic(17)
  }
  function LengthError(a: nat,b: nat): seq<Byte> { Ctrl.LengthMismatchSelector()+Word(a)+Word(b) }
  function LaneError(lane: nat): seq<Byte> { Ctrl.InvalidLaneSelector()+Word(lane) }
  ghost function Admission(k: Config): RawPlan
    requires Basic(k)
  {
    if k.kind == Zip && |k.left| != |k.right| then Rejected(LengthError(|k.left|,|k.right|)) else
    if k.kind == Unzip && k.lane > 1 then Rejected(LaneError(k.lane)) else
    var l := Whole(k.leftType);
    if !l.Shaped? then Rejected(Errors.Encode(ShapeResult(l))) else
    var r := Whole(k.rightType);
    if !r.Shaped? then Rejected(Errors.Encode(ShapeResult(r))) else
    if !Uint(32*(Width(l.syntax)+Width(r.syntax))) then Rejected(Errors.Encode(C.Panic(17))) else Ready(M.Plan(l.syntax,r.syntax))
  }
  ghost function Checked(t: seq<Byte>,value: seq<Byte>): C.Result
    requires Uint(|t|)
  { V.Checked(t,value,C.Context(C.ValueKind,0,0,0,0)) }
  ghost predicate Budget(k: Config)
    requires Basic(k)
  {
    Admission(k).Ready? ==>
      var p := Admission(k).plan;
      Uint(M.Head(p)+64) &&
      (if k.kind == Zip then
         (forall i :: 0 <= i < |k.left| ==> V.Room(k.leftType,k.left[i]) && V.Room(k.rightType,k.right[i]) && Uint(32+ABI.TotalBytes([k.left[i],k.right[i]])))
       else
         (forall i :: 0 <= i < |k.pairs| ==> M.SplitPair(p,k.pairs[i]).Parts? ==>
                          var parts := M.SplitPair(p,k.pairs[i]).values;
                          |parts| == 2 && V.Room(k.leftType,parts[0]) && V.Room(k.rightType,parts[1])))
  }
  datatype Outcome = Returned(values: seq<seq<Byte>>,visited: nat) | Failed(reason: seq<Byte>,visited: nat)
  ghost function ZipTail(k: Config,p: M.Plan,i: nat): Outcome
    requires Basic(k) && |k.left| == |k.right| && i <= |k.left|
    decreases |k.left|-i
  {
    if i == |k.left| then Returned([],0) else
    var l := Checked(k.leftType,k.left[i]);
    if !l.Success? then Failed(Errors.Encode(l),1) else
    var r := Checked(k.rightType,k.right[i]);
    if !r.Success? then Failed(Errors.Encode(r),1) else
    var later := ZipTail(k,p,i+1);
    if later.Failed? then Failed(later.reason,1+later.visited) else
    Returned([Prop.Encoded(p,[k.left[i],k.right[i]])]+later.values,1+later.visited)
  }
  function SplitError(r: M.Split): seq<Byte>
    requires !r.Parts?
  { Errors.Encode(if r.SplitError? then C.InvalidValue(r.offset) else C.Panic(r.code)) }
  ghost function UnzipTail(k: Config,p: M.Plan,i: nat): Outcome
    requires Basic(k) && k.lane < 2 && i <= |k.pairs|
    decreases |k.pairs|-i
  {
    if i == |k.pairs| then Returned([],0) else
    var split := M.SplitPair(p,k.pairs[i]);
    if !split.Parts? then Failed(SplitError(split),1) else
    if |split.values| != 2 then Failed([],1) else
    var l := Checked(k.leftType,split.values[0]);
    if !l.Success? then Failed(Errors.Encode(l),1) else
    var r := Checked(k.rightType,split.values[1]);
    if !r.Success? then Failed(Errors.Encode(r),1) else
    var later := UnzipTail(k,p,i+1);
    if later.Failed? then Failed(later.reason,1+later.visited) else
    Returned([split.values[k.lane]]+later.values,1+later.visited)
  }
  ghost function Judge(k: Config): Outcome
    requires Basic(k)
  {
    var ready := Admission(k);
    if !ready.Ready? then Failed(ready.reason,0) else
    if k.kind == Zip then ZipTail(k,ready.plan,0) else UnzipTail(k,ready.plan,0)
  }
}
