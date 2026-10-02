// SPDX-License-Identifier: MIT
include "../bound-call/Connection.dfy"
module CollectionsPreparedEntryModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import P = CollectionsPreparationModel
  import C = CollectionsCallsModel
  import Admission = CollectionsAdmissionModel
  import D = AbiDynamicSemantics
  import A = AbiConstructionModel
  import Wire = CollectionsWireModel

  predicate Same(prep: P.Callback, call: C.Callback) {
    prep.descriptor == call.descriptor && prep.first == call.first && prep.second == call.second
  }
  function Replaced(prep: P.Callback, a: seq<Byte>, b: seq<Byte>, binary: bool): seq<seq<Byte>>
    requires P.Slots(prep,binary)
  { if binary then prep.constants[prep.first := a][prep.second := b] else prep.constants[prep.first := a] }
  ghost predicate Room(prep: P.Callback, call: C.Callback, a: seq<Byte>, b: seq<Byte>, binary: bool) {
    Same(prep,call) && Admission.Room(prep,binary) &&
    (P.Slots(prep,binary) ==> Uint(A.TotalBytes(Replaced(prep,a,b,binary))) &&
                              (P.Slots(prep,binary) && |call.expression| > 0 ==> Wire.ExpressionReady(call.expression,Replaced(prep,a,b,binary))) &&
                              (forall fs: seq<Descriptor> ::
                                 P.Slots(prep,binary) && Admissible(Group(fs)) && Render(Group(fs)) == prep.descriptor && |fs| == |prep.constants| ==>
                                   Uint(32*WidthSum(fs)) && Uint(prep.first) && Uint(|a|) && Uint(32*Width(fs[prep.first])) && D.CursorRoom(fs[prep.first],|a|) &&
                                   (binary ==> Uint(prep.second) && Uint(|b|) && Uint(32*Width(fs[prep.second])) && D.CursorRoom(fs[prep.second],|b|))))
  }
  datatype Outcome = Rejected(reason: seq<Byte>, history: seq<C.Event>)
                   | Invoked(call: C.Outcome)
  function History(out: Outcome): seq<C.Event> { if out.Rejected? then out.history else out.call.history }
  function Finish(prepared: P.Outcome, cb: C.Callback, c: C.Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<C.Event>, env: C.Environment): Outcome
    requires prepared.Ready? ==> C.Admitted(env) && C.Valid(cb,prepared.prepared,binary)
  {
    var after := h+C.CodecEvents(prepared.history);
    if !prepared.Ready? then Rejected(Admission.FailureBytes(prepared),after)
    else Invoked(C.Run(cb,prepared.prepared,c,a,b,binary,after,env))
  }
}
