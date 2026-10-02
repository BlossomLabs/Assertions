// SPDX-License-Identifier: MIT
// Arbitrary-count physical gather loop with constrained RAW operands and retained result objects.
include "LoopSpec.dfy"
include "../../gather-composition/CallerGatherDone.generated.dfy"
module AssertionsGatherConstrainedLoop {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import I = AssertionsGatherConstrainedIteration
  import P = AssertionsGatherConstrainedLoopSpec
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  import Z = AssertionsGatherCallerDone
  import D = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  function Destinations(ret: Word): set<nat> { I.Destinations(ret) }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, ret: Word, args: Word, arrayBase: Word, start: Word, items: seq<P.Item>,
                   prefix: seq<Word>, initial: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word,
                   observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>, mem: seq<Byte>)
    requires I.Matches(code) && Z.Matches(code) && |prefix| <= 939
    requires ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b
    requires P.Calldata(data,args,items) && P.Budget(start,items)
    requires I.Ready(initial,arrayBase,|items|,start)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(2461,prefix+[ret,args,|items|,arrayBase,0],initial),returned,cursor)
    ensures frames[|frames|-1] == frame && frame == E.Frame(S.Running(ret,prefix+[arrayBase],mem),returned,cursor)
    ensures P.Done(data,mem,arrayBase,start,items,|items|)
    ensures I.Ready(mem,arrayBase,|items|,start+P.Used(items,|items|))
  {
    hide I.Data(); hide P.Done();
    P.AtZero(start,items);
    var count: Word := |items|;
    mem := initial;
    var index: nat := 0;
    var free: Word := start;
    frame := E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,0],mem),returned,cursor);
    frames := [frame];
    assert P.Done(data,mem,arrayBase,start,items,0) by { reveal P.Done(); }
    while index < count
      invariant index <= count && free == P.Position(start,items,index) && free < 0x10000000000000000
      invariant I.Ready(mem,arrayBase,count,free) && P.Done(data,mem,arrayBase,start,items,index)
      invariant L.Trace(code,Destinations(ret),self,value,data,observations,frames)
      invariant frames[0] == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,0],initial),returned,cursor)
      invariant frames[|frames|-1] == frame && frame == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index],mem),returned,cursor)
      decreases count-index
    {
      var item := items[index];
      P.Admit(mem,data,args,arrayBase,start,items,index);
      var part: seq<E.Frame>;
      var next: seq<Byte>;
      frame,part,next := I.Run(code,ret,args,count,index,arrayBase,free,item.operand,item.bytesRelative,item.constraintsRelative,item.length,item.constraints,
                              prefix,mem,data,returned,cursor,self,value,observations);
      F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
      P.Advance(data,mem,next,args,arrayBase,free,start,items,index);
      P.AdvancePosition(start,items,index);
      free := I.NextFree(free,item.length,item.constraints);
      mem := next; index := index+1;
    }
    P.Positions(start,items,|items|);
    var state, states := Z.Run(code,ret,args,0,0,0,count,count,arrayBase,prefix,mem,value,data);
    var finish := F.Lift(code,Z.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,finish); frames := frames+finish[1..];
    frame := E.Frame(state,returned,cursor);
  }
}
