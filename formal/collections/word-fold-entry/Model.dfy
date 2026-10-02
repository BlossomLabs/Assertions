// SPDX-License-Identifier: MIT
include "Selectors.generated.dfy"
include "../word-fold-loop/Connection.dfy"
module CollectionsWordFoldEntryModel {
  import opened AbiFrames
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  import L = CollectionsWordFoldLoopModel
  import W = CollectionsWordWindowsModel
  import Windows = CollectionsWordWindowsSource
  import Mem = CollectionsWordMemoryModel
  import Wire = CollectionsWireModel
  import S = CollectionsWordFoldEntrySelectors
  datatype Config = Config(domain: Call.Domain,count: nat,subject: seq<Byte>,template: seq<Byte>,accOffset: nat,offsets: seq<nat>,initial: nat,exit: L.Exit,target: nat,code: (seq<C.Event>,nat)->nat,env: Call.Environment)
  predicate Basic(k: Config) {
    Mem.Fits(k.count) && Mem.Fits(|k.subject|) && Mem.Fits(|k.template|) && Mem.Fits(|k.offsets|) &&
    Mem.Fits(k.accOffset) && Mem.Fits(k.initial) && k.target < Pow256(20) &&
    (forall j :: 0 <= j < |k.offsets| ==> Mem.Fits(k.offsets[j]))
  }
  function Count(k: Config): nat {
    if k.domain == Call.Range then k.count else if k.domain == Call.Bytes then |k.subject| else |k.subject|/32
  }
  function Operation(k: Config): seq<Byte> {
    if k.domain == Call.Range then S.RangeSelector() else if k.domain == Call.Bytes then S.BytesSelector() else S.WordsSelector()
  }
  function LoopConfig(k: Config): L.Config {
    L.Config(k.domain,Count(k),if k.domain == Call.Range then [] else k.subject,k.template,k.accOffset,k.offsets,k.exit,Operation(k),k.target,k.env)
  }
  predicate Aligned(k: Config) { k.domain != Call.Words || |k.subject| % 32 == 0 }
  function Unaligned(k: Config): seq<Byte> { S.UnalignedSelector()+Word(|k.subject|) }
  function Admission(k: Config): W.Admission { W.Windows(|k.template|,k.accOffset,k.offsets) }
  predicate Reaches(k: Config,h: seq<C.Event>) { Aligned(k) && Admission(k).Accepted? && Count(k) > 0 && k.code(h,k.target) != 0 }
  ghost predicate Budget(k: Config,h: seq<C.Event>,memory: seq<Byte>,base: nat)
    requires Basic(k)
  {
    Reaches(k,h) && L.Static(LoopConfig(k)) ==>
      Mem.Fits(|memory|) && Mem.Frame(memory,base,k.template) && L.Budget(LoopConfig(k),0,k.initial,h+[C.Target(k.target)])
  }
  datatype Outcome = Returned(value: nat,history: seq<C.Event>,rows: seq<L.Row>) | Failed(reason: seq<Byte>,history: seq<C.Event>,rows: seq<L.Row>)
  function Project(out: L.Outcome): Outcome {
    if out.Finished? then Returned(out.value,out.history,out.rows) else Failed(out.reason,out.history,out.rows)
  }
  ghost function Judge(k: Config,h: seq<C.Event>): Outcome
    requires Basic(k)
    requires Admission(k).Accepted? ==> L.Static(LoopConfig(k))
  {
    if !Aligned(k) then Failed(Unaligned(k),h,[]) else
    if Admission(k).Rejected? then Failed(Windows.ErrorBytes(Admission(k).offset,|k.template|),h,[]) else
    if Count(k) == 0 then Returned(k.initial,h,[]) else
    if k.code(h,k.target) == 0 then Failed(Wire.ErrorBytes(C.InvalidTarget(k.target)),h+[C.Target(k.target)],[])
    else Project(L.Tail(LoopConfig(k),0,k.initial,h+[C.Target(k.target)]))
  }
}
