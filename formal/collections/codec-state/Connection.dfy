// SPDX-License-Identifier: MIT
include "Model.dfy"

module CollectionsCodecStateConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import opened CollectionsCodecStateModel
  import L = AbiLayoutCanonical
  import LS = AbiLayoutSpec
  import P = CollectionsPreparationModel
  import Bind = CollectionsPreparationSource
  import C = AbiConstructionModel
  import Component = AbiConstructionComponent
  import V = AbiConstructionContext
  import W = CollectionsWireModel
  import Wire = CollectionsWireConnection
  import A = AbiConstructionAssembly
  import D = AbiDynamicSemantics
  import T = AbiTupleSemantics
  import Validation = AbiValidation
  import E = AbiEncoding
  import Conn = AbiConnectionModel

  ghost method Layout(fs: seq<Descriptor>) returns (raw: LS.LayoutResult, plan: P.Layout)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    ensures raw == L.PlanFor(0,fs,0) && plan == Plan(fs)
    ensures P.ValidLayout(plan,Render(Group(fs)))
    ensures |plan.parts| == |fs| && plan.headSize == 32*WidthSum(fs)
    ensures forall i :: 0 <= i < |fs| ==> plan.parts[i].dynamic == Dyn(fs[i]) && plan.parts[i].words == Width(fs[i]) &&
                                          Render(Group(fs))[plan.parts[i].start..plan.parts[i].end] == Render(fs[i])
  {
    var t := Render(Group(fs));
    raw := L.CanonicalLayout(t,fs);
    plan := Plan(fs);
    L.PlanIndex(0,fs,0);
    forall i | 0 <= i < |fs|
      ensures plan.parts[i].start <= plan.parts[i].end <= |t|
      ensures t[plan.parts[i].start..plan.parts[i].end] == Render(fs[i])
    { T.LocateField(t,0,|t|,fs,i); }
  }

  ghost method Binding(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, unbound: set<nat>, slot: nat, value: seq<Byte>, error: V.Result -> seq<Byte>) returns (checked: V.Result, out: P.Outcome)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires CanonicalExcept(fs,args,unbound) && slot < |fs| && Uint(slot) && Uint(|value|)
    requires D.CursorRoom(fs[slot],|value|) && Uint(32*Width(fs[slot]))
    ensures !checked.Panic?
    ensures out.Ready? == checked.Success?
    ensures checked.Success? == C.ValidInput(fs[slot],value)
    ensures out.Ready? ==> out.prepared == P.Prepared(Plan(fs),args[slot := value],flag)
    ensures out.Ready? ==> CanonicalExcept(fs,out.prepared.args,unbound-{slot})
    ensures out.Failed? ==> out.reason == error(checked)
    ensures out.Ready? || out.Failed?
    ensures |out.history| == 1
  {
    var raw: LS.LayoutResult;
    var plan: P.Layout;
    raw,plan := Layout(fs);
    var t := Render(Group(fs));
    var part := plan.parts[slot];
    assert |Render(fs[slot])| <= |t|;
    checked := Component.Component(t[part.start..part.end],value,slot,part.dynamic,part.words,fs[slot]);
    var q := P.Validate(t[part.start..part.end],value,slot,part.dynamic,part.words);
    SingleAdmitted(q,checked,error);
    out := Bind.BindValue(t,P.Prepared(plan,args,flag),slot,value,[],SingleEnvironment(q,checked,error));
  }

  lemma Ready(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool)
    requires C.ValidInputs(fs,args) && Uint(|args|) && Uint(C.TotalBytes(args))
    ensures W.DirectReady(P.Prepared(Plan(fs),args,flag))
    ensures W.Pieces(P.Prepared(Plan(fs),args,flag)) == C.Pieces(fs,args)
  {
    L.PlanIndex(0,fs,0);
    C.CanonicalPieces(fs,args);
    C.PiecesIndex(fs,args);
    C.FrameBudget(fs,args);
    forall i | 0 <= i < |args|
      ensures Dyn(fs[i]) ==> |args[i]| >= 32
    { C.CanonicalPiece(fs[i],args[i]); }
    var p := P.Prepared(Plan(fs),args,flag);
    assert W.Shape(p);
    assert forall i :: 0 <= i < |args| ==> W.Pieces(p)[i] == C.Pieces(fs,args)[i];
    assert W.Pieces(p) == C.Pieces(fs,args);
  }

  ghost method CompleteBindings(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, first: nat, second: nat, a: seq<Byte>, b: seq<Byte>, binary: bool, error: V.Result -> seq<Byte>) returns (out: P.Outcome)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires first < |fs| && Uint(first) && (binary ==> second < |fs| && first != second && Uint(second))
    requires CanonicalExcept(fs,args,if binary then {first,second} else {first})
    requires Uint(|a|) && D.CursorRoom(fs[first],|a|) && Uint(32*Width(fs[first]))
    requires binary ==> Uint(|b|) && D.CursorRoom(fs[second],|b|) && Uint(32*Width(fs[second]))
    requires Uint(|args|) && Uint(C.TotalBytes(if binary then args[first := a][second := b] else args[first := a]))
    ensures out.Ready? ==> out.prepared == P.Prepared(Plan(fs),if binary then args[first := a][second := b] else args[first := a],flag)
    ensures out.Ready? ==> C.ValidInputs(fs,out.prepared.args) && W.DirectReady(out.prepared)
    ensures out.Ready? || out.Failed?
    ensures 1 <= |out.history| <= (if binary then 2 else 1)
    ensures out.Ready? ==> |out.history| == (if binary then 2 else 1)
  {
    var unbound := if binary then {first,second} else {first};
    var checked: V.Result;
    checked,out := Binding(fs,args,flag,unbound,first,a,error);
    if out.Failed? { return; }
    if binary {
      var priorHistory := out.history;
      checked,out := Binding(fs,out.prepared.args,flag,unbound-{first},second,b,error);
      out := if out.Ready? then P.Ready(out.prepared,priorHistory+out.history) else P.Failed(out.reason,priorHistory+out.history);
      if out.Failed? { return; }
      assert (unbound-{first})-{second} == {};
    } else { assert unbound-{first} == {}; }
    assert C.ValidInputs(fs,out.prepared.args);
    Ready(fs,out.prepared.args,flag);
  }

  ghost method Encode(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool) returns (data: seq<Byte>)
    requires C.ValidInputs(fs,args) && Uint(|args|) && Uint(C.TotalBytes(args))
    requires Admissible(Group(fs))
    ensures data == Frame(C.Pieces(fs,args))
    ensures E.WellTyped(Conn.TypeOf(Group(fs)),E.Items(C.Decoded(fs,args)))
    ensures data == E.Body(Conn.TypeOf(Group(fs)),E.Items(C.Decoded(fs,args)))
  {
    Ready(fs,args,flag);
    data := Wire.DirectAssembly(P.Prepared(Plan(fs),args,flag));
    C.CanonicalPieces(fs,args);
    Conn.ModelType(Group(fs));
    Conn.TypesIndex(fs);
    assert Validation.Children(Conn.TypeOf(Group(fs)),|fs|) == Conn.TypesOf(fs);
    Validation.AggregateParts(Conn.TypeOf(Group(fs)),C.Decoded(fs,args));
  }
}
