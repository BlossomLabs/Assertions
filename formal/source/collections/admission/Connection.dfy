// SPDX-License-Identifier: MIT
include "Model.dfy"

module CollectionsAdmissionConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import opened CollectionsAdmissionModel
  import P = CollectionsPreparationModel
  import PS = CollectionsPreparationSource
  import LS = AbiLayoutSpec
  import Layout = AbiLayoutSource
  import Witness = AbiLayoutSoundness
  import WholeSource = AbiParserCompleteness
  import K = CollectionsCodecStateModel
  import KS = CollectionsCodecStateConnection
  import C = CollectionsConstantsModel
  import Constants = CollectionsConstantsConnection
  import V = AbiConstructionContext

  lemma StopSource(cb: P.Callback, binary: bool, env: P.Environment)
    requires Uint(|cb.descriptor|) && P.Admitted(env)
    requires |cb.descriptor| > 0 && !P.Parenthesized(cb.descriptor) ==>
               env.step([],P.Shape(cb.descriptor)) == (if Whole(cb.descriptor).Shaped? then P.Ok else P.Error(ShapeError(Whole(cb.descriptor))))
    requires !(|cb.descriptor| > 0 && !P.Parenthesized(cb.descriptor)) && !LS.Reference(cb.descriptor).Plan? ==>
               env.step([],P.Tuple(cb.descriptor)) == P.Error(LayoutError(LS.Reference(cb.descriptor)))
    requires !(|cb.descriptor| > 0 && !P.Parenthesized(cb.descriptor)) && LS.Reference(cb.descriptor).Plan? ==>
               env.step([],P.Tuple(cb.descriptor)).Planned? && |env.step([],P.Tuple(cb.descriptor)).plan.parts| == |LS.Reference(cb.descriptor).starts|
    ensures Admission(cb,binary).Stop? ==> P.Prepare(cb,binary,[],env) == Admission(cb,binary).out
  { reveal P.Prepare(); }

  ghost method Prepare(cb: P.Callback, binary: bool, error: V.Result -> seq<Byte>) returns (out: P.Outcome, fs: seq<Descriptor>, checks: seq<V.Result>, env: P.Environment)
    requires Room(cb,binary)
    ensures P.Admitted(env) && out == P.Prepare(cb,binary,[],env)
    ensures Admission(cb,binary).Stop? ==> out == Admission(cb,binary).out
    ensures out.Ready? ==> Admission(cb,binary).Continue? && Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |fs| == |cb.constants|
    ensures out.Ready? ==> K.CanonicalExcept(fs,cb.constants,if binary then {cb.first,cb.second} else {cb.first}) && out.prepared == P.Prepared(K.Plan(fs),cb.constants,false)
    ensures Admission(cb,binary).Continue? ==> Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |fs| == |cb.constants|
    ensures Admission(cb,binary).Continue? ==> (out.Ready? == K.CanonicalExcept(fs,cb.constants,if binary then {cb.first,cb.second} else {cb.first}))
  {
    fs := []; checks := [];
    env := One(P.Shape(cb.descriptor),P.Error([]));
    OneAdmitted(P.Shape(cb.descriptor),P.Error([]));
    if !P.Slots(cb,binary) {
      out := PS.PrepareCallback(cb,binary,[],env);
      reveal P.Prepare();
      return;
    }
    if |cb.descriptor| > 0 && !P.Parenthesized(cb.descriptor) {
      var shape := WholeSource.WholeCorrespondence(cb.descriptor);
      var reply := if shape.Shaped? then P.Ok else P.Error(ShapeError(shape));
      env := One(P.Shape(cb.descriptor),reply);
      OneAdmitted(P.Shape(cb.descriptor),reply);
      StopSource(cb,binary,env);
      out := PS.PrepareCallback(cb,binary,[],env);
      return;
    }
    var raw := Layout.Layout(cb.descriptor);
    if !raw.Plan? {
      env := One(P.Tuple(cb.descriptor),P.Error(LayoutError(raw)));
      OneAdmitted(P.Tuple(cb.descriptor),P.Error(LayoutError(raw)));
      StopSource(cb,binary,env);
      out := PS.PrepareCallback(cb,binary,[],env);
      return;
    }
    fs := Witness.LayoutWitness(cb.descriptor);
    var canonical: LS.LayoutResult;
    var plan: P.Layout;
    canonical,plan := KS.Layout(fs);
    if |raw.starts| != |cb.constants| {
      env := One(P.Tuple(cb.descriptor),P.Planned(plan));
      OneAdmitted(P.Tuple(cb.descriptor),P.Planned(plan));
      StopSource(cb,binary,env);
      out := PS.PrepareCallback(cb,binary,[],env);
      return;
    }
    var failure: nat;
    out,checks,failure := Constants.Prepare(fs,cb,binary,error);
    env := C.Environment(cb,plan,checks,error);
    C.Admitted(cb,plan,checks,error);
  }
}
