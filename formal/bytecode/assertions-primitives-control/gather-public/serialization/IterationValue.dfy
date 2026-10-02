// SPDX-License-Identifier: MIT
// Cold independent observable effects of one physical serializer iteration.
include "Iteration.dfy"
module AssertionsGatherArrayIterationValue {
  import I = AssertionsGatherArrayIteration
  import D = AssertionsGatherArraySpec
  import M = AssertionsGatherArrayMemory
  import B = AssertionsGatherBytesSpec
  import E = BytecodeExternalMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = AssertionsExternalMachine
  import L = AssertionsPrimitiveExternalLift
  import DS = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  ghost method Run(code: seq<Byte>, ret: Word, arrayBase: Word, base: Word, tail: Word, head: Word,
                   count: Word, source: Word, index: Word, ptr: Word, length: Word,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   self: Word, value: Word, observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires I.Matches(code,ret) && ret in DS.RuntimeDestinations() && |prefix| <= 940
    requires I.Heap(mem,arrayBase,base,tail,head,count,source,index,ptr,length)
    requires B.Heap(D.Slot(mem,base,tail,head),tail,ptr,length)
    ensures L.Trace(code,I.Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,tail,head,count,source,index],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame == E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,B.End(tail,length),head+32,count,source+32,index+1],B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)),returned,cursor)
    ensures D.LoopHeap(frame.state.memory,arrayBase,base,B.End(tail,length),head+32,count,source+32,index+1)
    ensures |mem| <= |frame.state.memory|
    ensures S.Load(frame.state.memory,head) == D.Offset(base,tail)
    ensures frame.state.memory[tail..tail+32] == G.Encode(length,32)
    ensures frame.state.memory[tail+32..tail+32+length] == mem[ptr+32..ptr+32+length]
    ensures forall p: nat {:trigger frame.state.memory[p]} :: tail+32+length <= p < B.End(tail,length) ==> frame.state.memory[p] == 0
    ensures forall p: nat {:trigger frame.state.memory[p]} :: p < |mem| && p < tail && (p < head || head+32 <= p) ==> frame.state.memory[p] == mem[p]
    ensures forall p: nat {:trigger frame.state.memory[p]} :: p < |mem| && p < base ==> frame.state.memory[p] == mem[p]
  {
    frame,frames := I.Run(code,ret,arrayBase,base,tail,head,count,source,index,ptr,length,prefix,mem,data,returned,cursor,self,value,observations);
    M.After(mem,arrayBase,base,tail,head,count,source,index,ptr,length);
    M.Effect(mem,arrayBase,base,tail,head,count,source,index,ptr,length);
  }
}
