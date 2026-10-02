// SPDX-License-Identifier: MIT
include "../validation/Connection.dfy"
include "../prepared-entry/Connection.dfy"
module CollectionsSortAdmissionModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import P = CollectionsPreparationModel
  import A = CollectionsAdmissionModel
  import V = CollectionsValidationModel
  import T = CollectionsTraversalModel
  datatype Verdict = Ready | Failure(stage: nat,index: nat,reason: seq<Byte>)
  ghost function Check(t: seq<Byte>,value: seq<Byte>): T.Reply
    requires Uint(|t|)
  { V.Reply(T.Validate(t,value),0,0) }
  ghost function Scan(t: seq<Byte>,values: seq<seq<Byte>>,i: nat): Verdict
    requires Uint(|t|) && i <= |values|
    decreases |values|-i
  {
    if i == |values| then Ready else
    var checked := Check(t,values[i]);
    if checked.Error? then Failure(2,i,checked.reason) else Scan(t,values,i+1)
  }
  ghost function Judge(t: seq<Byte>,values: seq<seq<Byte>>,prep: P.Outcome): Verdict
    requires Uint(|t|)
  {
    if !prep.Ready? then Failure(0,0,A.FailureBytes(prep)) else
    var shape := V.Reply(T.Shape(t),0,0);
    if shape.Error? then Failure(1,0,shape.reason) else Scan(t,values,0)
  }
  ghost predicate Room(cb: P.Callback,t: seq<Byte>,values: seq<seq<Byte>>) {
    A.Room(cb,true) && Uint(|t|) && Uint(|values|) &&
    (forall i :: 0 <= i < |values| ==> V.Room(t,values[i]))
  }
  function Indices(n: nat): seq<nat> { seq(n,i requires 0 <= i < n => i) }
}
