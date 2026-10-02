// SPDX-License-Identifier: MIT
include "../word-memory/Connection.dfy"
module CollectionsWordWindowsModel {
  import opened AbiFrames
  import Mem = CollectionsWordMemoryModel
  datatype Admission = Accepted | Rejected(stage: nat,index: nat,offset: nat)
  predicate InBounds(n: nat,offset: nat) { offset+32 <= n }
  function Scan(n: nat,offsets: seq<nat>,j: nat): Admission
    requires j <= |offsets|
    decreases |offsets|-j
  {
    if j == |offsets| then Accepted else
    if !InBounds(n,offsets[j]) then Rejected(2,j,offsets[j]) else Scan(n,offsets,j+1)
  }
  function Elements(n: nat,offsets: seq<nat>): Admission {
    if n < 32 then Rejected(1,0,0) else Scan(n,offsets,0)
  }
  function Windows(n: nat,accOffset: nat,offsets: seq<nat>): Admission {
    if !InBounds(n,accOffset) then Rejected(0,0,accOffset) else Elements(n,offsets)
  }
  datatype Write = Write(offset: nat,value: nat)
  predicate Valid(n: nat,writes: seq<Write>) {
    forall j :: 0 <= j < |writes| ==> InBounds(n,writes[j].offset) && Mem.Fits(writes[j].value)
  }
  function ElementWrites(offsets: seq<nat>,value: nat): seq<Write>
    ensures |ElementWrites(offsets,value)| == |offsets|
    ensures forall j :: 0 <= j < |offsets| ==> ElementWrites(offsets,value)[j] == Write(offsets[j],value)
  { seq(|offsets|,j requires 0 <= j < |offsets| => Write(offsets[j],value)) }
  // Independent last-writer specification, defined separately for every byte.
  function ByteAt(original: seq<Byte>,writes: seq<Write>,i: nat): Byte
    requires i < |original|
    decreases |writes|
  {
    if |writes| == 0 then original[i] else
    var last := writes[|writes|-1];
    if last.offset <= i < last.offset+32 then Word(last.value)[i-last.offset]
    else ByteAt(original,writes[..|writes|-1],i)
  }
  opaque function Patch(original: seq<Byte>,writes: seq<Write>): seq<Byte>
    ensures |Patch(original,writes)| == |original|
    ensures forall i :: 0 <= i < |original| ==> Patch(original,writes)[i] == ByteAt(original,writes,i)
  { seq(|original|,i requires 0 <= i < |original| => ByteAt(original,writes,i)) }
}
