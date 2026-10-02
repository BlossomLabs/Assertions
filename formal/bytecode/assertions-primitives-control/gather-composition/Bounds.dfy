// SPDX-License-Identifier: MIT
// Isolated canonical return labels and compiler-memory expression normalization.
include "../GatherParam.generated.dfy"
include "../GatherValueStore.generated.dfy"
include "CallerElementSpec.dfy"
include "../../assertions-resolution/raw/Raw.generated.dfy"
include "../Preparation.dfy"
module AssertionsGatherLoopBounds {
  import S = BytecodeScanMachine
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import P = AssertionsControlGatherParam
  import V = AssertionsControlGatherValueStore
  import D = AssertionsGatherCallerSpec
  import R = AssertionsRawResolve
  import Q = AssertionsPrimitivePreparation
  type Word = S.Word
  type Byte = S.Byte
  lemma Labels()
    ensures 2508 in D.RuntimeDestinations() && 2530 in R.FullRuntimeDestinations()
  {
    reveal D.RuntimeDestinations(); reveal D.Chunk4();
    reveal R.FullRuntimeDestinations(); reveal R.DestinationsChunk4();
  }
  lemma ElementReturn(code: seq<Byte>)
    requires P.Matches(code)
    ensures 2508 < |code| && code[2508] == 0x5b
  { reveal P.Matches(); }
  lemma ArrayOffsets(arrayBase: Word, count: Word, index: Word)
    requires index < count && arrayBase+32+count*32 < G.Modulus()
    ensures (32*(index as nat))%G.Modulus() == 32*index
    ensures (32+32*(index as nat))%G.Modulus() == 32+32*index
    ensures ((arrayBase as nat)+32+32*(index as nat))%G.Modulus() == arrayBase+32+32*index
    ensures ((32+(arrayBase as nat))%G.Modulus()+((32*(index as nat))%G.Modulus()))%G.Modulus() == arrayBase+32+index*32
    ensures index+1 < G.Modulus()
  {}
  lemma CalldataSlot(args: Word, count: Word, index: Word)
    requires index < count && args+count*32 < G.Modulus()
    ensures (32*(index as nat))%G.Modulus() == index*32
    ensures ((args as nat)+((32*(index as nat))%G.Modulus()))%G.Modulus() == args+index*32
  {}
  lemma ParamImages(ret: Word, args: Word, operand: Word, arrayBase: Word, count: Word, index: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+64 < G.Modulus()
    ensures P.Memory1(ret,args,operand,0,arrayBase,count,index,free,prefix,mem) == S.Store(mem,64,free+32)
    ensures P.Memory2(ret,args,operand,0,arrayBase,count,index,free,prefix,mem) == Q.EmptyAssertion(mem,free)
  {}
  lemma StoreImage(ret: Word, args: Word, arrayBase: Word, count: Word, index: Word, result: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires index < count && arrayBase+32+count*32 < G.Modulus()
    ensures V.Memory1(ret,args,0,0,result,count,index,arrayBase,prefix,mem) == S.Store(mem,arrayBase+32+index*32,result)
  { ArrayOffsets(arrayBase,count,index); }
  ghost method Store(code: seq<Byte>, ret: Word, args: Word, arrayBase: Word, count: Word, index: Word, result: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: S.State, states: seq<S.State>)
    requires V.Matches(code) && V.Admitted(code,ret,args,0,0,result,count,index,arrayBase,prefix,mem)
    ensures state == S.Running(2461,prefix+[ret,args,count,arrayBase,index+1],S.Store(mem,arrayBase+32+index*32,result))
    ensures E.Trace(code,V.Destinations(ret),value,data,states)
    ensures states[0] == S.Running(2530,prefix+[ret,args,count,arrayBase,index,result],mem) && states[|states|-1] == state
    ensures forall j {:trigger states[j]} :: 0 <= j < |states|-1 ==> states[j].Running? && states[j].pc < |code| && |states[j].stack| <= 1000
  {
    ArrayOffsets(arrayBase,count,index);
    StoreImage(ret,args,arrayBase,count,index,result,prefix,mem);
    state,states := V.Run(code,ret,args,0,0,result,count,index,arrayBase,prefix,mem,value,data);
  }

}
