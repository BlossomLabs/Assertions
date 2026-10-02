// SPDX-License-Identifier: MIT
include "../word-call/Connection.dfy"
include "../word-windows/Connection.dfy"
module CollectionsWordApplyModel {
  import opened AbiFrames
  import Call = CollectionsWordCallModel
  import C = CollectionsCallsModel
  import R = CollectionsCallbackResultsModel
  import W = CollectionsWordWindowsModel
  import Mem = CollectionsWordMemoryModel
  datatype Config = Config(subject: seq<Byte>,template: seq<Byte>,offsets: seq<nat>,filterMode: bool,operation: seq<Byte>,target: nat,env: Call.Environment)
  function Count(k: Config): nat { |k.subject|/32 }
  predicate Static(k: Config) {
    Mem.Fits(|k.subject|) && |k.subject| % 32 == 0 && Mem.Fits(|k.template|) && Mem.Fits(|k.offsets|) &&
    (forall j :: 0 <= j < |k.offsets| ==> W.InBounds(|k.template|,k.offsets[j]))
  }
  function Element(k: Config,index: nat): nat
    requires Static(k) && index < Count(k)
  { Call.Element(Call.Words,index,k.subject) }
  function Data(k: Config,index: nat): seq<Byte>
    requires Static(k) && index < Count(k)
  { W.Patch(k.template,W.ElementWrites(k.offsets,Element(k,index))) }
  function Answer(k: Config,index: nat,h: seq<C.Event>): Call.Answer
    requires Static(k) && index < Count(k)
  { Call.Judge(k.operation,index,k.target,Data(k,index),k.env(h,k.target,Data(k,index))) }
  function Checked(k: Config,index: nat,answer: Call.Answer): Call.Answer {
    if answer.Word? && k.filterMode && answer.value > 1
    then Call.Failure(R.InvalidBytes(R.Context(k.operation,index,0,k.target))) else answer
  }
  function Emit(k: Config,index: nat,value: nat): seq<nat>
    requires Static(k) && index < Count(k)
  { if !k.filterMode then [value] else if value == 1 then [Element(k,index)] else [] }
  function After(k: Config,index: nat,h: seq<C.Event>): seq<C.Event>
    requires Static(k) && index < Count(k)
  { h+[C.External(k.target,Data(k,index))] }
  datatype Row = Row(index: nat,before: seq<C.Event>,data: seq<Byte>,answer: Call.Answer)
  datatype Outcome = Finished(values: seq<nat>,history: seq<C.Event>,rows: seq<Row>)
                   | Failed(reason: seq<Byte>,index: nat,history: seq<C.Event>,rows: seq<Row>)
  function Attach(values: seq<nat>,rows: seq<Row>,out: Outcome): Outcome {
    if out.Finished? then Finished(values+out.values,out.history,rows+out.rows)
    else Failed(out.reason,out.index,out.history,rows+out.rows)
  }
  function Tail(k: Config,index: nat,h: seq<C.Event>): Outcome
    requires Static(k) && index <= Count(k)
    decreases Count(k)-index
  {
    if index == Count(k) then Finished([],h,[]) else
    var raw := Answer(k,index,h);
    var answer := Checked(k,index,raw);
    var row := Row(index,h,Data(k,index),raw);
    if answer.Failure? then Failed(answer.reason,index,After(k,index,h),[row]) else
    Attach(Emit(k,index,answer.value),[row],Tail(k,index+1,After(k,index,h)))
  }
  ghost opaque predicate Budget(k: Config,index: nat,h: seq<C.Event>)
    requires Static(k) && index <= Count(k)
    decreases Count(k)-index
  {
    index == Count(k) ||
    (Call.Room(k.operation,index,k.target,Data(k,index),k.env(h,k.target,Data(k,index))) &&
     (Checked(k,index,Answer(k,index,h)).Word? ==> Budget(k,index+1,After(k,index,h))))
  }
  function Bytes(values: seq<nat>): seq<Byte>
    decreases |values|
  { if |values| == 0 then [] else Word(values[0])+Bytes(values[1..]) }
}
