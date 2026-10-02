// SPDX-License-Identifier: MIT
// Exact gather body from its physical allocation through all RAW result objects.
include "Allocation.dfy"
include "LoopComplete.dfy"
module AssertionsGatherRawBody {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import P = AssertionsGatherLoopSpec
  import O = AssertionsGatherObjects
  import H = AssertionsGatherMeasuredAllocation
  import Q = AssertionsGatherAllocation
  import R = AssertionsGatherRawLoopComplete
  import I = AssertionsGatherRawIteration
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  import D = AssertionsGatherCallerSpec
  import Z = AssertionsGatherCallerDone
  import HS = AssertionsControlGatherStart
  import HZ = AssertionsControlGatherStartZero
  import HE = AssertionsControlGatherHeaderExit
  import HF = AssertionsControlGatherFill
  import HL = AssertionsControlGatherFillLast
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) {
    I.Matches(code) && Z.Matches(code) && HS.Matches(code) && HZ.Matches(code) && HE.Matches(code) && HF.Matches(code) && HL.Matches(code)
  }
  function Destinations(ret: Word): set<nat> { H.Destinations(ret)+R.Destinations(ret) }
  ghost method Run(code: seq<Byte>, ret: Word, args: Word, arrayBase: Word, items: seq<P.Item>, prefix: seq<Word>, initial: seq<Byte>,
                   data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>, mem: seq<Byte>)
    requires Matches(code) && |prefix| <= 960
    requires ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b
    requires P.Calldata(data,args,items) && H.Space(initial,arrayBase,|items|) && S.Load(initial,64) == arrayBase
    requires Q.End(arrayBase,|items|)+P.Used(items,|items|)+96 < 0x10000000000000000
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(2379,prefix+[ret,args,|items|],initial),returned,cursor)
    ensures frames[|frames|-1] == frame && frame == E.Frame(S.Running(ret,prefix+[arrayBase],mem),returned,cursor)
    ensures P.Done(mem,arrayBase,Q.End(arrayBase,|items|),items,|items|) && O.Done(data,mem,Q.End(arrayBase,|items|),items,|items|)
    ensures S.Load(mem,arrayBase) == |items| && S.Load(mem,64) == Q.End(arrayBase,|items|)+P.Used(items,|items|)
  {
    var state,states,allocatedMem := H.Run(code,ret,args,|items|,arrayBase,prefix,initial,value,data);
    frames := F.Lift(code,H.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    var start: Word := Q.End(arrayBase,|items|);
    var tail: seq<E.Frame>;
    frame,tail,mem := R.Run(code,ret,args,arrayBase,start,items,prefix,allocatedMem,data,returned,cursor,self,value,observations);
    F.Widen(code,R.Destinations(ret),Destinations(ret),self,value,data,observations,tail);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,tail); frames := frames+tail[1..];
  }
}
