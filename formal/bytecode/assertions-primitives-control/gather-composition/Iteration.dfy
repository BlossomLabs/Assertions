// SPDX-License-Identifier: MIT
// One complete RAW_BYTES/no-constraints iteration through actual compiler helpers.
include "CallerElementSuccess.generated.dfy"
include "../GatherNext.generated.dfy"
include "../GatherParam.generated.dfy"
include "../GatherValueStore.generated.dfy"
include "../../assertions-resolution/raw/Connection.dfy"
include "Memory.dfy"
include "Frame.dfy"
include "Bounds.dfy"
module AssertionsGatherRawIteration {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import M = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import N = AssertionsControlGatherNext
  import D = AssertionsGatherCallerSuccess
  import DS = AssertionsGatherCallerSpec
  import P = AssertionsControlGatherParam
  import V = AssertionsControlGatherValueStore
  import Q = AssertionsPrimitivePreparation
  import H = AssertionsGatherLoopMemory
  import F = AssertionsGatherLoopFrame
  import B = AssertionsGatherLoopBounds
  import L = AssertionsPrimitiveExternalLift
  import RC = AssertionsRawResolveConnection
  import RR = AssertionsRawResolve
  import RM = AssertionsRawResolveMemory
  import RF = AssertionsRawResolveFrame
  type Word = S.Word
  type Byte = S.Byte
  predicate Data(data: seq<Byte>, args: Word, count: Word, index: Word, operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word) {
    |data| < 0x10000000000000000 && index < count && args+count*32 < G.Modulus() &&
    DS.Accepts(data,args+index*32,args) && DS.Pointer(data,args+index*32,args) == operand &&
    operand+128 <= |data| && operand+bytesRelative+32+length <= |data| && operand+constraintsRelative+32 <= |data| &&
    S.DataWord(data,operand+32) == 0 && S.DataWord(data,operand+64) == bytesRelative &&
    S.DataWord(data,operand+96) == constraintsRelative && S.DataWord(data,operand+bytesRelative) == length && S.DataWord(data,operand+constraintsRelative) == 0
  }
  predicate Heap(mem: seq<Byte>, arrayBase: Word, count: Word, free: Word, length: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 && 128 <= free &&
    free+S.Round32(length)+96 < 0x10000000000000000 &&
    128 <= arrayBase && arrayBase+32+count*32 <= free && arrayBase+32+count*32 <= |mem| &&
    S.Load(mem,arrayBase) == count && S.Load(mem,64) == free
  }
  predicate Matches(code: seq<Byte>) { N.Matches(code) && D.Matches(code) && P.Matches(code) && V.Matches(code) && RR.Matches(code,2530) }
  function Destinations(ret: Word): set<nat> { N.Destinations(ret)+D.Destinations(2508)+P.Destinations(ret)+V.Destinations(ret)+RR.Destinations(2530) }
  function Image(mem: seq<Byte>, arrayBase: Word, index: Word, free: Word, operand: Word, bytesRelative: Word, length: Word, data: seq<Byte>): seq<Byte>
    requires free+32 < G.Modulus() && operand+bytesRelative+32 < G.Modulus() && arrayBase+32+index*32 < G.Modulus()
    requires RM.Fits(Q.EmptyAssertion(mem,free),free+32,operand+bytesRelative+32,length,data)
  { S.Store(RM.Construct(Q.EmptyAssertion(mem,free),free+32,operand+bytesRelative+32,length,data),arrayBase+32+index*32,free+32) }
  ghost method Run(code: seq<Byte>, ret: Word, args: Word, count: Word, index: Word, arrayBase: Word, free: Word,
                   operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word,
                   observations: seq<A.Observation>) returns (frame: M.Frame, frames: seq<M.Frame>)
    requires Matches(code) && |prefix| <= 960
    requires Data(data,args,count,index,operand,bytesRelative,constraintsRelative,length) && Heap(mem,arrayBase,count,free,length)
    requires RM.Fits(Q.EmptyAssertion(mem,free),free+32,operand+bytesRelative+32,length,data)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == M.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame == M.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index+1],Image(mem,arrayBase,index,free,operand,bytesRelative,length,data)),returned,cursor)
    ensures S.Load(frame.state.memory,64) == free+64+S.Round32(length) && S.Load(frame.state.memory,arrayBase) == count
    ensures S.Load(frame.state.memory,arrayBase+32+index*32) == free+32
    ensures free+64+length <= |frame.state.memory|
    ensures S.Load(frame.state.memory,free+32) == length
    ensures frame.state.memory[free+64..free+64+length] == data[operand+bytesRelative+32..operand+bytesRelative+32+length]
  {
    hide Q.EmptyAssertion(); hide RM.Construct(); hide P.Memory1(); hide P.Memory2(); hide V.Memory1();
    B.Labels(); B.ElementReturn(code); B.CalldataSlot(args,count,index);
    B.ParamImages(ret,args,operand,arrayBase,count,index,free,prefix,mem);
    var prepared := Q.EmptyAssertion(mem,free);
    H.Prepared(mem,free);
    var payload: Word := operand+bytesRelative+32;
    assert RM.Fits(prepared,free+32,payload,length,data);
    var state, states := N.Run(code,ret,args,0,0,0,count,index,arrayBase,prefix,mem,value,data);
    frames := F.Lift(code,N.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);

    var decoderPrefix := prefix+[ret,args,count,arrayBase,index,2530];
    var part: seq<M.Frame>;
    state,states := D.Run(code,2508,args+index*32,args,decoderPrefix,mem,data,value);
    part := F.Lift(code,D.Destinations(2508),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    state,states := P.Run(code,ret,args,operand,0,arrayBase,count,index,free,prefix,mem,value,data);
    assert P.Memory1(ret,args,operand,0,arrayBase,count,index,free,prefix,mem) == S.Store(mem,64,free+32);
    assert P.Memory2(ret,args,operand,0,arrayBase,count,index,free,prefix,mem) == prepared;
    part := F.Lift(code,P.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    var resolverPrefix := prefix+[ret,args,count,arrayBase,index];
    frame,part := RC.Run(code,Destinations(ret),2530,operand,free,0,index,bytesRelative,constraintsRelative,length,free+32,resolverPrefix,prepared,data,returned,cursor,self,value,observations);
    assert L.Trace(code,Destinations(ret),self,value,data,observations,part);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    var built := RM.Construct(prepared,free+32,payload,length,data);
    RM.Built(prepared,free+32,payload,length,data);
    H.IterationFrame(mem,free,payload,length,data,arrayBase);
    assert S.Load(built,arrayBase) == count;
    state,states := B.Store(code,ret,args,arrayBase,count,index,free+32,prefix,built,value,data);
    part := F.Lift(code,V.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    B.ArrayOffsets(arrayBase,count,index);
    B.StoreImage(ret,args,arrayBase,count,index,free+32,prefix,built);
    var slot: Word := arrayBase+32+index*32;
    assert V.Memory1(ret,args,0,0,free+32,count,index,arrayBase,prefix,built) == S.Store(built,slot,free+32);
    R.StoredWord(built,slot,free+32);
    R.StoredFrame(built,slot,free+32,64);
    R.StoredFrame(built,slot,free+32,arrayBase);
    R.StoredFrame(built,slot,free+32,free+32);
    H.StoredRegion(built,slot,free+32,free+64,length);
    assert state == S.Running(2461,prefix+[ret,args,count,arrayBase,index+1],S.Store(built,slot,free+32));
    assert S.Store(built,slot,free+32) == Image(mem,arrayBase,index,free,operand,bytesRelative,length,data);
    frame := M.Frame(state,returned,cursor);
  }
}
