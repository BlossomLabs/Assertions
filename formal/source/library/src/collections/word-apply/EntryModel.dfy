// SPDX-License-Identifier: MIT
include "LoopConnection.dfy"
module CollectionsWordApplyEntryModel {
  import opened AbiFrames
  import L = CollectionsWordApplyModel
  import E = CollectionsWordApplyEngine
  import Ctrl = CollectionsWordApplyControl
  import W = CollectionsWordWindowsModel
  import Windows = CollectionsWordWindowsSource
  import Mem = CollectionsWordMemoryModel
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  import Wire = CollectionsWireModel
  datatype Config = Config(subject: seq<Byte>,template: seq<Byte>,offsets: seq<nat>,filterMode: bool,target: nat,code: (seq<C.Event>,nat)->nat,env: Call.Environment)
  predicate Basic(k: Config) {
    Mem.Fits(|k.subject|) && Mem.Fits(|k.template|) && Mem.Fits(|k.offsets|) && k.target < Pow256(20) &&
    (forall j :: 0 <= j < |k.offsets| ==> Mem.Fits(k.offsets[j]))
  }
  function Operation(k: Config): seq<Byte> { if k.filterMode then Ctrl.FilterSelector() else Ctrl.MapSelector() }
  function LoopConfig(k: Config): L.Config { L.Config(k.subject,k.template,k.offsets,k.filterMode,Operation(k),k.target,k.env) }
  predicate Aligned(k: Config) { |k.subject| % 32 == 0 }
  function Admission(k: Config): W.Admission { W.Elements(|k.template|,k.offsets) }
  function Unaligned(k: Config): seq<Byte> { Ctrl.UnalignedSelector()+Word(|k.subject|) }
  predicate Allocates(k: Config) { Aligned(k) && Admission(k).Accepted? }
  predicate Reaches(k: Config,h: seq<C.Event>) { Allocates(k) && L.Count(LoopConfig(k)) > 0 && k.code(h,k.target) != 0 }
  function Zero(n: nat): seq<Byte> { seq(n,i => 0 as Byte) }
  // The memory argument is the compiler allocation/copy projection at the stage
  // reached by this call. Rejection before allocation imposes no frame premise.
  ghost predicate Budget(k: Config,h: seq<C.Event>,memory: seq<Byte>,callBase: nat,outBase: nat)
    requires Basic(k)
  {
    (Allocates(k) ==> Mem.Fits(|memory|) && Mem.Frame(memory,outBase,Zero(|k.subject|))) &&
    (Reaches(k,h) && L.Static(LoopConfig(k)) ==> Mem.Frame(memory,callBase,k.template) &&
                                                 E.Disjoint(callBase,|k.template|,outBase,|k.subject|) && L.Budget(LoopConfig(k),0,h+[C.Target(k.target)]))
  }
  datatype Outcome = Returned(values: seq<nat>,history: seq<C.Event>,rows: seq<L.Row>) | Failed(reason: seq<Byte>,history: seq<C.Event>,rows: seq<L.Row>)
  function Project(out: L.Outcome): Outcome { if out.Finished? then Returned(out.values,out.history,out.rows) else Failed(out.reason,out.history,out.rows) }
  ghost function Judge(k: Config,h: seq<C.Event>): Outcome
    requires Basic(k)
    requires Allocates(k) ==> L.Static(LoopConfig(k))
  {
    if !Aligned(k) then Failed(Unaligned(k),h,[]) else
    if Admission(k).Rejected? then Failed(Windows.ErrorBytes(Admission(k).offset,|k.template|),h,[]) else
    if L.Count(LoopConfig(k)) == 0 then Returned([],h,[]) else
    if k.code(h,k.target) == 0 then Failed(Wire.ErrorBytes(C.InvalidTarget(k.target)),h+[C.Target(k.target)],[])
    else Project(L.Tail(LoopConfig(k),0,h+[C.Target(k.target)]))
  }
}
