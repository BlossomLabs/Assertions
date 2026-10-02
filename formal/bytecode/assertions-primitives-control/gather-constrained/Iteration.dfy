// SPDX-License-Identifier: MIT
// One gather iteration resolving RAW bytes with arbitrarily many passing non-OR constraints.
include "../gather-composition/CallerElementSuccess.generated.dfy"
include "../GatherNext.generated.dfy"
include "../GatherParam.generated.dfy"
include "../GatherValueStore.generated.dfy"
include "../gather-composition/Frame.dfy"
include "Bounds.dfy"
include "ResolverFrameV2.dfy"
include "GatherMemory.dfy"
module AssertionsGatherConstrainedIteration {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import N = AssertionsControlGatherNext
  import D = AssertionsGatherCallerSuccess
  import DS = AssertionsGatherCallerSpec
  import P = AssertionsControlGatherParam
  import V = AssertionsControlGatherValueStore
  import Q = AssertionsPrimitivePreparation
  import H = AssertionsGatherLoopMemory
  import F = AssertionsGatherLoopFrame
  import B = AssertionsGatherConstrainedBounds
  import L = AssertionsPrimitiveExternalLift
  import RC = AssertionsGatherConstrainedResolverFrameV2
  import RB = AssertionsConstrainedRawBefore
  import RM = AssertionsRawResolveMemory
  import C = AssertionsConstraintLoopSpec
  import M = AssertionsGatherConstrainedMemory
  type Word = S.Word
  type Byte = S.Byte
  function Payload(operand: Word, relative: Word): Word
    requires (operand as nat)+relative+32 < G.Modulus()
  { operand+relative+32 }
  predicate Data(data: seq<Byte>, args: Word, count: Word, index: Word, operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word, cs: seq<C.Constraint>) {
    |data| < 0x10000000000000000 && index < count && (args as nat)+count*32 < G.Modulus() &&
    DS.Accepts(data,args+index*32,args) && DS.Pointer(data,args+index*32,args) == operand &&
    (operand as nat)+128 <= |data| && (operand as nat)+bytesRelative+32+length <= |data| &&
    (operand as nat)+constraintsRelative+32+|cs|*32 <= |data| && |cs|*32 <= length &&
    S.DataWord(data,operand+32) == 0 && S.DataWord(data,operand+64) == bytesRelative &&
    S.DataWord(data,operand+96) == constraintsRelative && S.DataWord(data,operand+bytesRelative) == length &&
    S.DataWord(data,operand+constraintsRelative) == |cs| &&
    C.Layout(data,operand+constraintsRelative+32,cs) &&
    C.Passes(data[Payload(operand,bytesRelative)..Payload(operand,bytesRelative)+length],data,operand+constraintsRelative+32,cs)
  }
  predicate Ready(mem: seq<Byte>, arrayBase: Word, count: Word, free: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= (free as nat)+32 && free%32 == 0 && 128 <= free &&
    (free as nat)+32 < 0x10000000000000000 &&
    128 <= arrayBase && (arrayBase as nat)+32+count*32 <= free && (arrayBase as nat)+32+count*32 <= |mem| &&
    S.Load(mem,arrayBase) == count && S.Load(mem,64) == free
  }
  predicate Heap(mem: seq<Byte>, arrayBase: Word, count: Word, free: Word, length: Word, cs: seq<C.Constraint>) {
    Ready(mem,arrayBase,count,free) && (free as nat)+64+S.Round32(length)+C.Cost(cs)+160 < 0x10000000000000000
  }
  function NextFree(free: Word, length: Word, cs: seq<C.Constraint>): Word
    requires (free as nat)+64+S.Round32(length)+C.Cost(cs)+160 < 0x10000000000000000
  { free+64+S.Round32(length)+C.Cost(cs) }
  predicate Matches(code: seq<Byte>) { N.Matches(code) && D.Matches(code) && P.Matches(code) && V.Matches(code) && RC.Matches(code,2530) }
  function Destinations(ret: Word): set<nat> { N.Destinations(ret)+D.Destinations(2508)+P.Destinations(ret)+V.Destinations(ret)+RC.Destinations(2530) }
  lemma ResolverLabel()
    ensures 2530 in RB.FullRuntimeDestinations()
  { reveal RB.FullRuntimeDestinations(); reveal RB.DestinationsChunk4(); }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, ret: Word, args: Word, count: Word, index: Word, arrayBase: Word, free: Word,
                   operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word, cs: seq<C.Constraint>,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word,
                   observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>, output: seq<Byte>)
    requires Matches(code) && |prefix| <= 939
    requires Data(data,args,count,index,operand,bytesRelative,constraintsRelative,length,cs) && Heap(mem,arrayBase,count,free,length,cs)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index],mem),returned,cursor)
    ensures frames[|frames|-1] == frame && frame == E.Frame(S.Running(2461,prefix+[ret,args,count,arrayBase,index+1],output),returned,cursor)
    ensures Ready(output,arrayBase,count,NextFree(free,length,cs))
    ensures S.Load(output,arrayBase+32+index*32) == free+32
    ensures (free as nat)+64+length <= |output| && S.Load(output,free+32) == length
    ensures output[free+64..free+64+length] == data[Payload(operand,bytesRelative)..Payload(operand,bytesRelative)+length]
    ensures M.End(mem,free) <= |output|
    ensures output[128..arrayBase+32+index*32] == mem[128..arrayBase+32+index*32]
    ensures output[arrayBase+64+index*32..M.End(mem,free)] == mem[arrayBase+64+index*32..M.End(mem,free)]
  {
    hide Q.EmptyAssertion(); hide RM.Construct(); hide P.Memory1(); hide P.Memory2(); hide V.Memory1();
    B.Labels(); ResolverLabel(); B.ElementReturn(code); B.CalldataSlot(args,count,index);
    B.ParamImages(ret,args,operand,arrayBase,count,index,free,prefix,mem);
    var prepared := Q.EmptyAssertion(mem,free);
    H.Prepared(mem,free);
    var payload := Payload(operand,bytesRelative);
    var end := M.End(mem,free);
    assert 128 <= end;
    M.PreparedWindow(mem,free,128,end-128);
    assert RM.Fits(prepared,free+32,payload,length,data);
    var state, states := N.Run(code,ret,args,0,0,0,count,index,arrayBase,prefix,mem,value,data);
    frames := F.Lift(code,N.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    var decoderPrefix := prefix+[ret,args,count,arrayBase,index,2530];
    state,states := D.Run(code,2508,args+index*32,args,decoderPrefix,mem,data,value);
    var part := F.Lift(code,D.Destinations(2508),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    state,states := P.Run(code,ret,args,operand,0,arrayBase,count,index,free,prefix,mem,value,data);
    assert P.Memory1(ret,args,operand,0,arrayBase,count,index,free,prefix,mem) == S.Store(mem,64,free+32);
    assert P.Memory2(ret,args,operand,0,arrayBase,count,index,free,prefix,mem) == prepared;
    part := F.Lift(code,P.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    var resolverPrefix := prefix+[ret,args,count,arrayBase,index];
    assert RC.Admitted(2530,operand,free,0,index,bytesRelative,constraintsRelative,length,free+32,cs,resolverPrefix,prepared,data);
    state,part := RC.Run(code,Destinations(ret),2530,operand,free,0,index,bytesRelative,constraintsRelative,length,free+32,cs,
                        resolverPrefix,prepared,self,value,data,returned,cursor,observations,128,end-128);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    var built := state.memory;
    assert built[128..end] == mem[128..end];
    var bytes := data[payload..payload+length];
    var finalFree := C.Free(free+64+S.Round32(length),cs,|cs|);
    assert cs[..|cs|] == cs;
    assert finalFree == NextFree(free,length,cs);
    assert C.Heap(built,free+32,bytes,finalFree);
    M.WindowWord(built,mem,128,end-128,arrayBase);
    assert S.Load(built,arrayBase) == count;
    state,states := B.Store(code,ret,args,arrayBase,count,index,free+32,prefix,built,value,data);
    part := F.Lift(code,V.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    B.ArrayOffsets(arrayBase,count,index);
    var slot: Word := arrayBase+32+index*32;
    output := S.Store(built,slot,free+32);
    R.StoredWord(built,slot,free+32);
    R.StoredFrame(built,slot,free+32,64);
    R.StoredFrame(built,slot,free+32,arrayBase);
    R.StoredFrame(built,slot,free+32,free+32);
    H.StoredRegion(built,slot,free+32,free+64,length);
    assert slot+32 <= |built| && S.Expand(built,slot+32) == built;
    assert |output| == |built|;
    M.WindowBytes(built,mem,128,end-128,128,(slot as nat)-128);
    H.StoredRegion(built,slot,free+32,128,(slot as nat)-128);
    M.WindowBytes(built,mem,128,end-128,slot+32,end-slot-32);
    H.StoredRegion(built,slot,free+32,slot+32,end-slot-32);
    frame := E.Frame(state,returned,cursor);
  }
}
