// SPDX-License-Identifier: MIT
// Rank-driven main gather loop through real element decoding and RAW resolution.
include "IterationObject.dfy"
include "CallerGatherDone.generated.dfy"
module AssertionsGatherRawLoopComplete {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import I = AssertionsGatherRawIteration
  import P = AssertionsGatherLoopSpec
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  import Z = AssertionsGatherCallerDone
  import D = AssertionsGatherCallerSpec
  import O = AssertionsGatherObjects
  import C = AssertionsGatherRawIterationObject
  type Word = S.Word
  type Byte = S.Byte
  function Destinations(ret: Word): set<nat> { I.Destinations(ret) }
  ghost method Run(code: seq<Byte>, ret: Word, args: Word, arrayBase: Word, start: Word, items: seq<P.Item>,
                   prefix: seq<Word>, initial: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word,
                   observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>, mem: seq<Byte>)
    requires I.Matches(code) && Z.Matches(code) && |prefix| <= 960
    requires ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b
    requires P.Calldata(data,args,items) && start+P.Used(items,|items|)+96 < 0x10000000000000000
    requires P.Ready(initial,arrayBase,|items|,start)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(2461,prefix+[ret,args,|items|,arrayBase,0],initial),returned,cursor)
    ensures frames[|frames|-1] == frame && frame == E.Frame(S.Running(ret,prefix+[arrayBase],mem),returned,cursor)
    ensures P.Done(mem,arrayBase,start,items,|items|) && O.Done(data,mem,start,items,|items|)
    ensures S.Load(mem,64) == start+P.Used(items,|items|) && S.Load(mem,arrayBase) == |items|
  {
    hide I.Image(); hide I.Data(); hide P.Done(); hide O.Done();
    P.AtZero(start,items);
    var count: Word := |items|;
    mem := initial;
    var index: nat := 0;
    var free: Word := start;
    frame := E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,0],mem),returned,cursor);
    frames := [frame];
    assert P.Done(mem,arrayBase,start,items,0) by { reveal P.Done(); }
    assert O.Done(data,mem,start,items,0) by { reveal O.Done(); }
    while index < count
      invariant index <= count && free == P.Position(start,items,index) && free < 0x10000000000000000
      invariant P.Ready(mem,arrayBase,count,free) && P.Done(mem,arrayBase,start,items,index) && O.Done(data,mem,start,items,index)
      invariant L.Trace(code,Destinations(ret),self,value,data,observations,frames)
      invariant frames[0] == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,0],initial),returned,cursor)
      invariant frames[|frames|-1] == frame && frame == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index],mem),returned,cursor)
      decreases count-index
    {
      var item := items[index];
      P.Admit(mem,data,args,arrayBase,start,items,index);
      var part: seq<E.Frame>;
      frame,part := C.Run(code,ret,args,count,index,arrayBase,free,item,prefix,mem,data,returned,cursor,self,value,observations);
      // Every joined frame is still a step of the common external machine.
      assert L.Trace(code,Destinations(ret),self,value,data,observations,part);
      F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
      var next := I.Image(mem,arrayBase,index,free,item.operand,item.bytesRelative,item.length,data);
      P.ImageReady(mem,data,args,count,arrayBase,free,index,item.operand,item.bytesRelative,item.constraintsRelative,item.length);
      P.FillAdvance(mem,next,data,args,arrayBase,free,start,items,index);
      assert O.Value(data,next,item,free);
      O.Advance(mem,next,data,args,arrayBase,free,start,items,index);
      P.AdvancePosition(start,items,index);
      free := free+64+S.Round32(item.length);
      mem := next; index := index+1;
    }
    reveal P.Position();
    var state, states := Z.Run(code,ret,args,0,0,0,count,count,arrayBase,prefix,mem,value,data);
    var finish := F.Lift(code,Z.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,finish); frames := frames+finish[1..];
    frame := E.Frame(state,returned,cursor);
  }
}
