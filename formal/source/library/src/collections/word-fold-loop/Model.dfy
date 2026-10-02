// SPDX-License-Identifier: MIT
include "../word-call/Connection.dfy"
include "../word-windows/Connection.dfy"
module CollectionsWordFoldLoopModel {
  import opened AbiFrames
  import Call = CollectionsWordCallModel
  import C = CollectionsCallsModel
  import W = CollectionsWordWindowsModel
  import Mem = CollectionsWordMemoryModel
  datatype Exit = Full | Any | All
  datatype Config = Config(domain: Call.Domain,count: nat,subject: seq<Byte>,template: seq<Byte>,accOffset: nat,offsets: seq<nat>,exit: Exit,operation: seq<Byte>,target: nat,env: Call.Environment)
  predicate Static(k: Config) {
    Mem.Fits(k.count) && Mem.Fits(|k.template|) && Mem.Fits(|k.offsets|) &&
    W.InBounds(|k.template|,k.accOffset) &&
    (forall j :: 0 <= j < |k.offsets| ==> W.InBounds(|k.template|,k.offsets[j])) &&
    (forall i :: 0 <= i < k.count ==> Call.DomainRoom(k.domain,i,k.subject))
  }
  function Writes(k: Config,acc: nat,elem: nat): seq<W.Write> {
    [W.Write(k.accOffset,acc)]+W.ElementWrites(k.offsets,elem)
  }
  function Data(k: Config,index: nat,acc: nat): seq<Byte>
    requires Static(k) && index < k.count
  { W.Patch(k.template,Writes(k,acc,Call.Element(k.domain,index,k.subject))) }
  predicate Stop(mode: Exit,value: nat) {
    (mode == Any && value != 0) || (mode == All && value == 0)
  }
  function Answer(k: Config,index: nat,acc: nat,h: seq<C.Event>): Call.Answer
    requires Static(k) && index < k.count
  { Call.Judge(k.operation,index,k.target,Data(k,index,acc),k.env(h,k.target,Data(k,index,acc))) }
  function After(k: Config,index: nat,acc: nat,h: seq<C.Event>): seq<C.Event>
    requires Static(k) && index < k.count
  { h+[C.External(k.target,Data(k,index,acc))] }
  datatype Row = Row(index: nat,acc: nat,before: seq<C.Event>,data: seq<Byte>,answer: Call.Answer)
  datatype Outcome = Finished(value: nat,stop: nat,history: seq<C.Event>,rows: seq<Row>)
                   | Failed(reason: seq<Byte>,index: nat,history: seq<C.Event>,rows: seq<Row>)
  function Attach(rows: seq<Row>,out: Outcome): Outcome {
    if out.Finished? then Finished(out.value,out.stop,out.history,rows+out.rows)
    else Failed(out.reason,out.index,out.history,rows+out.rows)
  }
  function Prepend(row: Row,out: Outcome): Outcome {
    if out.Finished? then Finished(out.value,out.stop,out.history,[row]+out.rows)
    else Failed(out.reason,out.index,out.history,[row]+out.rows)
  }
  function Tail(k: Config,index: nat,acc: nat,h: seq<C.Event>): Outcome
    requires Static(k) && index <= k.count
    decreases k.count-index
  {
    if index == k.count then Finished(acc,index,h,[]) else
    var answer := Answer(k,index,acc,h);
    var after := After(k,index,acc,h);
    var row := Row(index,acc,h,Data(k,index,acc),answer);
    if answer.Failure? then Failed(answer.reason,index,after,[row]) else
    if Stop(k.exit,answer.value) then Finished(answer.value,index+1,after,[row])
    else Prepend(row,Tail(k,index+1,answer.value,after))
  }
  ghost opaque predicate Budget(k: Config,index: nat,acc: nat,h: seq<C.Event>)
    requires Static(k) && index <= k.count
    decreases k.count-index
  {
    index == k.count ||
    (Call.Room(k.operation,index,k.target,Data(k,index,acc),k.env(h,k.target,Data(k,index,acc))) &&
     (Answer(k,index,acc,h).Word? && !Stop(k.exit,Answer(k,index,acc,h).value) ==>
        Budget(k,index+1,Answer(k,index,acc,h).value,After(k,index,acc,h))))
  }
}
