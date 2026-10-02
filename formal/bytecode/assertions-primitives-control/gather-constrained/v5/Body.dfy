// SPDX-License-Identifier: MIT
// Exact gather body from its physical allocation through all RAW result objects.
include "../Allocation.dfy"
include "Loop.dfy"
module AssertionsGatherConstrainedBody {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import P = AssertionsGatherConstrainedLoopSpec
  import H = AssertionsGatherConstrainedAllocation
  import Q = AssertionsGatherAllocation
  import R = AssertionsGatherConstrainedLoop
  import I = AssertionsGatherConstrainedIteration
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
    requires Matches(code) && |prefix| <= 939
    requires ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b
    requires P.Calldata(data,args,items) && H.Space(initial,arrayBase,|items|) && S.Load(initial,64) == arrayBase
    requires P.Budget(Q.End(arrayBase,|items|),items)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(2379,prefix+[ret,args,|items|],initial),returned,cursor)
    ensures frames[|frames|-1] == frame && frame == E.Frame(S.Running(ret,prefix+[arrayBase],mem),returned,cursor)
    ensures P.Done(data,mem,arrayBase,Q.End(arrayBase,|items|),items,|items|)
    ensures S.Load(mem,arrayBase) == |items| && S.Load(mem,64) == Q.End(arrayBase,|items|)+P.Used(items,|items|)
    ensures I.Ready(mem,arrayBase,|items|,Q.End(arrayBase,|items|)+P.Used(items,|items|))
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
