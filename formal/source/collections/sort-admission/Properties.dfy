// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsSortAdmissionProperties {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened CollectionsSortAdmissionModel
  lemma IndexAppend(i: nat)
    ensures Indices(i)+[i] == Indices(i+1)
  {
    forall j | 0 <= j < i+1 ensures (Indices(i)+[i])[j] == Indices(i+1)[j] {}
  }
  lemma ScanVerdict(t: seq<Byte>,values: seq<seq<Byte>>,i: nat)
    requires Uint(|t|) && i <= |values|
    ensures Scan(t,values,i).Ready? == (forall j :: i <= j < |values| ==> Check(t,values[j]).Ok?)
    ensures Scan(t,values,i).Failure? ==> Scan(t,values,i).stage == 2 && i <= Scan(t,values,i).index < |values|
    ensures Scan(t,values,i).Failure? ==> (forall j :: i <= j < Scan(t,values,i).index ==> Check(t,values[j]).Ok?)
    ensures Scan(t,values,i).Failure? ==> Check(t,values[Scan(t,values,i).index]).Error? && Scan(t,values,i).reason == Check(t,values[Scan(t,values,i).index]).reason
    decreases |values|-i
  {
    if i < |values| && Check(t,values[i]).Ok? { ScanVerdict(t,values,i+1); }
  }
}
