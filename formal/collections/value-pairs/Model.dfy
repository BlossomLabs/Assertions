// SPDX-License-Identifier: MIT
include "../validation/Connection.dfy"
module CollectionsValuePairsModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import V = CollectionsValidationModel
  import C = AbiConstructionContext
  import ABI = AbiConstructionModel
  import Errors = CollectionsCodecErrorEncoding
  datatype Plan = Plan(left: Descriptor,right: Descriptor)
  function Fields(p: Plan): seq<Descriptor> { [p.left,p.right] }
  function Base(p: Plan): nat { if Dyn(p.left) || Dyn(p.right) then 32 else 0 }
  function Head(p: Plan): nat { 32*(Width(p.left)+Width(p.right)) }
  function HeadAt(p: Plan,i: nat): nat
    requires i <= 2
  { if i == 0 then 0 else if i == 1 then 32*Width(p.left) else Head(p) }
  function Side(p: Plan,i: nat): Descriptor
    requires i < 2
  { if i == 0 then p.left else p.right }
  datatype Split = Parts(values: seq<seq<Byte>>) | SplitError(offset: nat) | SplitPanic(code: nat)
  function Span(bytes: seq<Byte>,start: nat,length: nat): Split {
    if start > |bytes| || length > |bytes|-start then SplitError(start) else Parts([bytes[start..start+length]])
  }
  // Independent finite two-component framing specification. Offset and slice
  // failures are judged before validating either extracted component.
  function SplitTail(p: Plan,bytes: seq<Byte>,i: nat,tail: nat): Split
    requires i <= 2 && Base(p) <= |bytes|
    decreases 2-i
  {
    if i == 2 then (if Base(p)+tail != |bytes| then SplitError(Base(p)+tail) else Parts([])) else
    var head := HeadAt(p,i);
    if Dyn(Side(p,i)) then
      var offset := WordSpec(bytes,Base(p)+head);
      if !offset.Ok? then SplitError(offset.offset) else
      if offset.used != tail then SplitError(Base(p)+head) else
      var boundary := if i == 0 && Dyn(p.right) then WordSpec(bytes,Base(p)+head+32) else Ok(|bytes|-Base(p));
      if !boundary.Ok? then SplitError(boundary.offset) else
      if boundary.used < tail then SplitError(Base(p)+head) else
      var part := Span(bytes,Base(p)+tail,boundary.used-tail);
      if !part.Parts? then part else
      var rest := SplitTail(p,bytes,i+1,boundary.used);
      if !rest.Parts? then rest else Parts([Word(32)+part.values[0]]+rest.values)
    else
      var part := Span(bytes,Base(p)+head,32*Width(Side(p,i)));
      if !part.Parts? then part else
      var rest := SplitTail(p,bytes,i+1,tail);
      if !rest.Parts? then rest else Parts([part.values[0]]+rest.values)
  }
  function SplitPair(p: Plan,bytes: seq<Byte>): Split {
    var first := WordSpec(bytes,0);
    if Base(p) != 0 && (!first.Ok? || first.used != 32) then SplitError(0) else
    SplitTail(p,bytes,0,Head(p))
  }
  lemma SplitLength(p: Plan,bytes: seq<Byte>,i: nat,tail: nat)
    requires i <= 2 && Base(p) <= |bytes|
    ensures SplitTail(p,bytes,i,tail).Parts? ==> |SplitTail(p,bytes,i,tail).values| == 2-i
    decreases 2-i
  {
    if i < 2 {
      if Dyn(Side(p,i)) {
        var offset := WordSpec(bytes,Base(p)+HeadAt(p,i));
        if offset.Ok? && offset.used == tail {
          var boundary := if i == 0 && Dyn(p.right) then WordSpec(bytes,Base(p)+HeadAt(p,i)+32) else Ok(|bytes|-Base(p));
          if boundary.Ok? && boundary.used >= tail { SplitLength(p,bytes,i+1,boundary.used); }
        }
      } else { SplitLength(p,bytes,i+1,tail); }
    }
  }
  lemma PairLength(p: Plan,bytes: seq<Byte>)
    ensures SplitPair(p,bytes).Parts? ==> |SplitPair(p,bytes).values| == 2
  {
    if Base(p) == 0 || (WordSpec(bytes,0).Ok? && WordSpec(bytes,0).used == 32) {
      SplitLength(p,bytes,0,Head(p));
    }
  }
}
