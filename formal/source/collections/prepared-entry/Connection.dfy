// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsPreparedEntryConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import P = CollectionsPreparationModel
  import C = CollectionsCallsModel
  import Calls = CollectionsCallsConnection
  import A = AbiConstructionModel
  import V = AbiConstructionContext
  import K = CollectionsCodecStateModel
  import KS = CollectionsCodecStateConnection
  import Admission = CollectionsAdmissionModel
  import Prep = CollectionsAdmissionConnection
  import Call = CollectionsBoundCallConnection
  import Error = CollectionsCodecErrorEncoding
  import Wire = CollectionsWireModel
  import M = CollectionsPreparedEntryModel

  lemma CodecHistory(h: seq<P.Request>)
    ensures Calls.Targets(C.CodecEvents(h)) == [] && Calls.Calls(C.CodecEvents(h)) == []
    decreases |h|
  {
    if |h| > 0 {
      assert h == h[..|h|-1]+[h[|h|-1]];
      CodecHistory(h[..|h|-1]);
      CodecAppend(h[..|h|-1],h[|h|-1]);
      Calls.Append(C.CodecEvents(h[..|h|-1]),C.Codec(h[|h|-1]));
    }
  }
  lemma CodecAppend(h: seq<P.Request>, q: P.Request)
    ensures C.CodecEvents(h+[q]) == C.CodecEvents(h)+[C.Codec(q)]
    decreases |h|
  {
    if |h| > 0 {
      assert (h+[q])[0] == h[0];
      assert (h+[q])[1..] == h[1..]+[q];
      CodecAppend(h[1..],q);
    }
  }
  lemma EventConcat(a: seq<C.Event>, b: seq<C.Event>)
    ensures Calls.Targets(a+b) == Calls.Targets(a)+Calls.Targets(b)
    ensures Calls.Calls(a+b) == Calls.Calls(a)+Calls.Calls(b)
    decreases |b|
  {
    if |b| > 0 {
      assert b == b[..|b|-1]+[b[|b|-1]];
      assert a+b == (a+b[..|b|-1])+[b[|b|-1]];
      EventConcat(a,b[..|b|-1]);
      Calls.Append(a+b[..|b|-1],b[|b|-1]);
      Calls.Append(b[..|b|-1],b[|b|-1]);
    } else {
      assert b == [];
      assert a+b == a;
      assert Calls.Targets(b) == [];
      assert Calls.Calls(b) == [];
    }
  }

  ghost method Run(prep: P.Callback, cb: C.Callback, c: C.Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<C.Event>, base: C.Environment)
    returns (prepared: P.Outcome, fs: seq<Descriptor>, checks: seq<V.Result>, prepEnv: P.Environment, callEnv: C.Environment, out: M.Outcome)
    requires M.Room(prep,cb,a,b,binary)
    requires |cb.selector| == 4 && cb.target < Pow256(20) && |c.operation| == 4 && Uint(c.index) && Uint(c.other)
    ensures P.Admitted(prepEnv) && prepared == P.Prepare(prep,binary,[],prepEnv)
    ensures prepared.Ready? ==> P.Slots(prep,binary)
    ensures prepared.Ready? ==> C.Admitted(callEnv) && C.Valid(cb,prepared.prepared,binary)
    ensures out == M.Finish(prepared,cb,c,a,b,binary,h,callEnv)
    ensures out.Rejected? == !prepared.Ready?
    ensures Admission.Admission(prep,binary).Stop? ==> out.Rejected? && prepared == Admission.Admission(prep,binary).out
    ensures out.Rejected? ==> out.reason == Admission.FailureBytes(prepared) && out.history == h+C.CodecEvents(prepared.history)
    ensures prepared.Ready? ==> Admissible(Group(fs)) && Render(Group(fs)) == cb.descriptor && |fs| == |prep.constants|
    ensures prepared.Ready? ==> prepared.prepared == P.Prepared(K.Plan(fs),prep.constants,false) && K.CanonicalExcept(fs,prep.constants,if binary then {cb.first,cb.second} else {cb.first})
    ensures out.Invoked? && out.call.Returned? ==> A.ValidInputs(fs,out.call.prepared.args) && Wire.DirectReady(out.call.prepared) && out.call.prepared.targetChecked
    ensures out.Invoked? && out.call.Returned? ==> out.call.prepared.args == M.Replaced(prep,a,b,binary)
    ensures Calls.Targets(M.History(out)) == Calls.Targets(h)+(if prepared.Ready? then [cb.target] else [])
    ensures out.Rejected? ==> Calls.Calls(M.History(out)) == Calls.Calls(h)
    ensures |Calls.Calls(h)| <= |Calls.Calls(M.History(out))| <= |Calls.Calls(h)|+(if prepared.Ready? then 1 else 0)
  {
    prepared,fs,checks,prepEnv := Prep.Prepare(prep,binary,Error.Encode);
    callEnv := base;
    CodecHistory(prepared.history);
    EventConcat(h,C.CodecEvents(prepared.history));
    if !prepared.Ready? {
      out := M.Rejected(Admission.FailureBytes(prepared),h+C.CodecEvents(prepared.history));
      return;
    }
    assert P.Slots(prep,binary);
    var r1; var r2; var called;
    r1,r2,callEnv,called := Call.Run(fs,prep.constants,false,cb,c,a,b,binary,h+C.CodecEvents(prepared.history),base);
    out := M.Invoked(called);
  }
}
