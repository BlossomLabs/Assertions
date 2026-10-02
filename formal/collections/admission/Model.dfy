// SPDX-License-Identifier: MIT
include "Signatures.generated.dfy"
include "../constants/Connection.dfy"
include "../../abi/layout/Soundness.dfy"

module CollectionsAdmissionModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import P = CollectionsPreparationModel
  import LS = AbiLayoutSpec
  import D = AbiDynamicSemantics
  import S = CollectionsAdmissionSignatures

  datatype Stage = Stop(out: P.Outcome) | Continue(layout: LS.LayoutResult)
  function ShapeError(r: ShapeResult): seq<Byte>
    requires !r.Shaped?
  { if r.BadDescriptor? then S.InvalidTypeDescriptor()+Word(r.at) else S.Panic()+Word(17) }
  function LayoutError(r: LS.LayoutResult): seq<Byte>
    requires !r.Plan?
  { if r.BadLayout? then S.InvalidTypeDescriptor()+Word(r.at) else S.Panic()+Word(17) }
  function Admission(cb: P.Callback, binary: bool): Stage
    requires Uint(|cb.descriptor|)
  {
    if !P.Slots(cb,binary) then Stop(P.InvalidCallback([])) else
    if |cb.descriptor| > 0 && !P.Parenthesized(cb.descriptor) then
      var r := Whole(cb.descriptor);
      Stop(if r.Shaped? then P.InvalidCallback([P.Shape(cb.descriptor)]) else P.Failed(ShapeError(r),[P.Shape(cb.descriptor)]))
    else
      var r := LS.Reference(cb.descriptor);
      if !r.Plan? then Stop(P.Failed(LayoutError(r),[P.Tuple(cb.descriptor)])) else
      if |r.starts| != |cb.constants| then Stop(P.InvalidCallback([P.Tuple(cb.descriptor)])) else Continue(r)
  }
  // Only the actual accepted tuple witness can trigger component checks.
  ghost predicate Room(cb: P.Callback, binary: bool) {
    Uint(|cb.descriptor|) && Uint(|cb.constants|) &&
    (P.Slots(cb,binary) ==> (forall fs: seq<Descriptor> :: Admissible(Group(fs)) && Render(Group(fs)) == cb.descriptor && |fs| == |cb.constants| ==>
                                                             (forall i :: 0 <= i < |fs| && !P.Substituted(cb,binary,i) ==> Uint(|cb.constants[i]|) && D.CursorRoom(fs[i],|cb.constants[i]|) && Uint(32*Width(fs[i])))))
  }
  function One(q: P.Request, r: P.Reply): P.Environment {
    P.Environment((h,request) => if request == q then r else P.Error([]))
  }
  lemma OneAdmitted(q: P.Request, r: P.Reply)
    requires q.Tuple? ==> (r.Error? || (r.Planned? && P.ValidLayout(r.plan,q.descriptor)))
    requires !q.Tuple? ==> (r.Error? || r.Ok?)
    ensures P.Admitted(One(q,r))
  {}
  function FailureBytes(out: P.Outcome): seq<Byte>
    requires !out.Ready?
  { if out.Failed? then out.reason else S.InvalidCallback() }
}
