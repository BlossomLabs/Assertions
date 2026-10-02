// SPDX-License-Identifier: MIT
include "../../abi/Frames.dfy"

module CollectionsPreparationModel {
  import opened AbiFrames
  datatype Component = Component(start: nat, end: nat, dynamic: bool, words: nat)
  datatype Layout = Layout(parts: seq<Component>, headSize: nat)
  datatype Callback = Callback(descriptor: seq<Byte>, constants: seq<seq<Byte>>, first: nat, second: nat)
  datatype Prepared = Prepared(plan: Layout, args: seq<seq<Byte>>, targetChecked: bool)
  datatype Request = Shape(descriptor: seq<Byte>) | Tuple(descriptor: seq<Byte>)
                   | Validate(descriptor: seq<Byte>, value: seq<Byte>, slot: nat, dynamic: bool, words: nat)
  datatype Reply = Ok | Planned(plan: Layout) | Error(reason: seq<Byte>)
  datatype Environment = Environment(step: (seq<Request>,Request) -> Reply)
  datatype Outcome = Ready(prepared: Prepared, history: seq<Request>)
                   | Failed(reason: seq<Byte>, history: seq<Request>) | InvalidCallback(history: seq<Request>)
  predicate ValidLayout(plan: Layout, descriptor: seq<Byte>) {
    forall i :: 0 <= i < |plan.parts| ==> plan.parts[i].start <= plan.parts[i].end <= |descriptor|
  }
  ghost predicate Admitted(env: Environment) {
    forall h: seq<Request>, q: Request ::
      (q.Tuple? ==> (env.step(h,q).Error? || (env.step(h,q).Planned? && ValidLayout(env.step(h,q).plan,q.descriptor)))) &&
      (!q.Tuple? ==> (env.step(h,q).Ok? || env.step(h,q).Error?))
  }
  predicate Slots(cb: Callback, binary: bool) {
    cb.first < |cb.constants| && (!binary || (cb.second < |cb.constants| && cb.first != cb.second))
  }
  predicate Substituted(cb: Callback, binary: bool, i: nat) {
    i == cb.first || (binary && i == cb.second)
  }
  predicate Parenthesized(descriptor: seq<Byte>) {
    |descriptor| > 0 && descriptor[0] == 40 && descriptor[|descriptor|-1] == 41
  }
  function CheckRequest(descriptor: seq<Byte>, plan: Layout, args: seq<seq<Byte>>, i: nat): Request
    requires ValidLayout(plan,descriptor) && i < |plan.parts| && i < |args|
  {
    var part := plan.parts[i];
    Validate(descriptor[part.start..part.end],args[i],i,part.dynamic,part.words)
  }
  function Constants(cb: Callback, binary: bool, plan: Layout, i: nat, h: seq<Request>, env: Environment): Outcome
    requires Admitted(env) && ValidLayout(plan,cb.descriptor) && |plan.parts| == |cb.constants| && i <= |cb.constants|
    decreases |cb.constants|-i
  {
    if i == |cb.constants| then Ready(Prepared(plan,cb.constants,false),h) else
    if Substituted(cb,binary,i) then Constants(cb,binary,plan,i+1,h,env) else
    var q := CheckRequest(cb.descriptor,plan,cb.constants,i);
    var r := env.step(h,q);
    if r.Error? then Failed(r.reason,h+[q]) else Constants(cb,binary,plan,i+1,h+[q],env)
  }
  function Prepare(cb: Callback, binary: bool, h: seq<Request>, env: Environment): Outcome
    requires Admitted(env)
  {
    if !Slots(cb,binary) then InvalidCallback(h) else
    if |cb.descriptor| > 0 && !Parenthesized(cb.descriptor) then
      var q := Shape(cb.descriptor);
      var r := env.step(h,q);
      if r.Error? then Failed(r.reason,h+[q]) else InvalidCallback(h+[q])
    else
      var q := Tuple(cb.descriptor);
      var r := env.step(h,q);
      if r.Error? then Failed(r.reason,h+[q]) else
      if |r.plan.parts| != |cb.constants| then InvalidCallback(h+[q]) else
      Constants(cb,binary,r.plan,0,h+[q],env)
  }
  function Bind(descriptor: seq<Byte>, p: Prepared, slot: nat, value: seq<Byte>, h: seq<Request>, env: Environment): Outcome
    requires Admitted(env) && ValidLayout(p.plan,descriptor) && |p.plan.parts| == |p.args| && slot < |p.args|
  {
    var part := p.plan.parts[slot];
    var q := Validate(descriptor[part.start..part.end],value,slot,part.dynamic,part.words);
    var r := env.step(h,q);
    if r.Error? then Failed(r.reason,h+[q]) else Ready(Prepared(p.plan,p.args[slot := value],p.targetChecked),h+[q])
  }
}
