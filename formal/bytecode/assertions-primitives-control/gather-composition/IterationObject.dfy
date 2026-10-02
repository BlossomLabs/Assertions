// SPDX-License-Identifier: MIT
// Cold bytes-object contract for the physical RAW gather iteration.
include "Objects.dfy"
module AssertionsGatherRawIterationObject {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import I = AssertionsGatherRawIteration
  import P = AssertionsGatherLoopSpec
  import O = AssertionsGatherObjects
  import Q = AssertionsPrimitivePreparation
  import M = AssertionsRawResolveMemory
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  ghost method Run(code: seq<Byte>, ret: Word, args: Word, count: Word, index: Word, arrayBase: Word, free: Word, item: P.Item,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word,
                   observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires I.Matches(code) && |prefix| <= 960
    requires I.Data(data,args,count,index,item.operand,item.bytesRelative,item.constraintsRelative,item.length) && I.Heap(mem,arrayBase,count,free,item.length)
    requires M.Fits(Q.EmptyAssertion(mem,free),free+32,item.operand+item.bytesRelative+32,item.length,data)
    ensures L.Trace(code,I.Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index+1],I.Image(mem,arrayBase,index,free,item.operand,item.bytesRelative,item.length,data)),returned,cursor)
    ensures S.Load(frame.state.memory,64) == free+64+S.Round32(item.length) && S.Load(frame.state.memory,arrayBase) == count
    ensures S.Load(frame.state.memory,arrayBase+32+index*32) == free+32
    ensures O.Value(data,frame.state.memory,item,free)
  {
    hide I.Image(); hide O.Value();
    frame,frames := I.Run(code,ret,args,count,index,arrayBase,free,item.operand,item.bytesRelative,item.constraintsRelative,item.length,prefix,mem,data,returned,cursor,self,value,observations);
    O.Produced(data,frame.state.memory,item,free);
  }
}
