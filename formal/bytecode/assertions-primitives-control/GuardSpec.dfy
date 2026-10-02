// SPDX-License-Identifier: MIT
// Independent boolean outcomes and fallback operand routing at physical bodies.
include "IsValidFinishTrue.generated.dfy"
include "IsValidFinishFalse.generated.dfy"
include "OrElseFallback.generated.dfy"
include "OrElseReturn.generated.dfy"
include "ChainEmpty.generated.dfy"
include "GatherTooLarge.generated.dfy"
include "GatherValueStore.generated.dfy"
include "Preparation.dfy"
module AssertionsPrimitiveGuardSpec {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import M = BytecodeScanRepresentation
  import T = AssertionsControlIsValidFinishTrue
  import F = AssertionsControlIsValidFinishFalse
  import B = AssertionsControlOrElseFallback
  import V = AssertionsControlOrElseReturn
  import C = AssertionsControlChainEmpty
  import N = AssertionsControlGatherTooLarge
  import A = AssertionsControlGatherValueStore
  import Err = BytecodeScanErrorBytes
  import P = AssertionsPrimitivePreparation
  predicate Frame(code: seq<Byte>, ret: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>) {
    |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 128 <= free &&
    free+64 < G.Modulus() && |prefix| <= 980 && ret in T.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b
  }
  ghost method IsValidFinish(code: seq<Byte>, ret: Word, operand: Word, gasBefore: Word, success: Word, reason: Word,
                             free: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires T.Matches(code) && F.Matches(code) && Frame(code,ret,free,prefix,mem)
    ensures state == Running(ret,prefix+[if success == 0 then 0 else 1],mem)
    ensures E.Trace(code,T.Destinations(ret)+F.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(3367,prefix+[ret,operand,0,gasBefore,success,reason],mem) && trace[|trace|-1] == state
  {
    if success == 0 {
      state,trace := F.Run(code,ret,operand,gasBefore,0,reason,0,success,free,prefix,mem,value,data);
      E.WidenTrace(code,F.Destinations(ret),T.Destinations(ret)+F.Destinations(ret),value,data,trace);
    } else {
      state,trace := T.Run(code,ret,operand,gasBefore,0,reason,0,success,free,prefix,mem,value,data);
      E.WidenTrace(code,T.Destinations(ret),T.Destinations(ret)+F.Destinations(ret),value,data,trace);
    }
  }
  ghost method Fallback(code: seq<Byte>, ret: Word, attempt: Word, fallback: Word, gasBefore: Word, reason: Word,
                        free: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires B.Matches(code) && B.Admitted(code,ret,attempt,fallback,gasBefore,reason,0,0,free,prefix,mem)
    ensures state == Running(3393,prefix+[ret,attempt,fallback,gasBefore,0,reason,1017,fallback,free,0,1],P.EmptyAssertion(mem,free))
    ensures E.Trace(code,B.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(1820,prefix+[ret,attempt,fallback,gasBefore,0,reason],mem) && trace[|trace|-1] == state
  {
    state,trace := B.Run(code,ret,attempt,fallback,gasBefore,reason,0,0,free,prefix,mem,value,data);
    assert B.Memory1(ret,attempt,fallback,gasBefore,reason,0,0,free,prefix,mem) == Store(mem,64,free+32);
    assert B.Memory2(ret,attempt,fallback,gasBefore,reason,0,0,free,prefix,mem) == P.EmptyAssertion(mem,free);
  }
  ghost method AttemptReturn(code: seq<Byte>, ret: Word, attempt: Word, fallback: Word, gasBefore: Word, ptr: Word,
                             length: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires V.Matches(code) && V.Admitted(code,ret,attempt,fallback,gasBefore,ptr,length,1,free,prefix,mem)
    ensures state == Returned(mem[ptr+32..ptr+32+length])
    ensures E.Trace(code,V.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(3078,prefix+[ret,attempt,fallback,gasBefore,1,ptr],mem) && trace[|trace|-1] == state
  {
    state,trace := V.Run(code,ret,attempt,fallback,gasBefore,ptr,length,1,free,prefix,mem,value,data);
    assert G.Grow(mem,ptr+32+length) == mem;
  }
  lemma SelectorPrefix(mem: seq<Byte>, free: Word)
    requires |mem|%32 == 0 && free+32 < G.Modulus()
    ensures Store(mem,free,0x3955afaa00000000000000000000000000000000000000000000000000000000)[free..free+4] == G.Encode(0x3955afaa,4)
  {
    G.WordPower();
    Err.ShiftedPrefix(0x3955afaa,28);
    M.StoredWord(mem,free,0x3955afaa00000000000000000000000000000000000000000000000000000000);
  }
  ghost method EmptyChain(code: seq<Byte>, ret: Word, operand: Word, calls: Word, free: Word,
                          prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires C.Matches(code) && C.Admitted(code,ret,operand,calls,0,0,0,0,free,prefix,mem)
    ensures state == Reverted(G.Encode(0x3955afaa,4))
    ensures E.Trace(code,C.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(2638,prefix+[ret,operand,calls,0],mem) && trace[|trace|-1] == state
  {
    state,trace := C.Run(code,ret,operand,calls,0,0,0,0,free,prefix,mem,value,data);
    SelectorPrefix(mem,free);
    assert C.Memory1(ret,operand,calls,0,0,0,0,free,prefix,mem) == Store(mem,free,0x3955afaa00000000000000000000000000000000000000000000000000000000);
    M.StoredWord(mem,free,0x3955afaa00000000000000000000000000000000000000000000000000000000);
  }
  ghost method GatherTooLarge(code: seq<Byte>, ret: Word, args: Word, count: Word, free: Word,
                              prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires N.Matches(code) && N.Admitted(code,ret,args,0,0,0,count,0,free,prefix,mem)
    ensures state == Reverted(G.Encode(0x4e487b71,4)+G.Encode(0x41,32))
    ensures E.Trace(code,N.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(2379,prefix+[ret,args,count],mem) && trace[|trace|-1] == state
  {
    state,trace := N.Run(code,ret,args,0,0,0,count,0,free,prefix,mem,value,data);
    Err.PhysicalError(mem,0,0x4e487b71,0x4e487b7100000000000000000000000000000000000000000000000000000000,0x41);
    assert N.Memory1(ret,args,0,0,0,count,0,free,prefix,mem) == Store(mem,0,0x4e487b7100000000000000000000000000000000000000000000000000000000);
    assert N.Memory2(ret,args,0,0,0,count,0,free,prefix,mem) == Store(N.Memory1(ret,args,0,0,0,count,0,free,prefix,mem),4,0x41);
  }
  lemma ArrayOffset(free: Word, count: Word, index: Word, mem: seq<Byte>)
    requires free+32+count*32 <= |mem| < G.Modulus() && index < count
    ensures free+32+index*32 < G.Modulus() && index+1 < G.Modulus()
    ensures (32*(index as nat))%G.Modulus() == 32*index
    ensures (32+32*(index as nat))%G.Modulus() == 32+32*index
    ensures ((free as nat)+32+32*(index as nat))%G.Modulus() == free+32+32*index
  {}
  ghost method GatherStore(code: seq<Byte>, ret: Word, args: Word, count: Word, index: Word, arrayBase: Word, result: Word,
                           prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires A.Matches(code) && A.Admitted(code,ret,args,0,0,result,count,index,arrayBase,prefix,mem)
    ensures state == Running(2461,prefix+[ret,args,count,arrayBase,index+1],Store(mem,arrayBase+32+index*32,result))
    ensures E.Trace(code,A.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(2530,prefix+[ret,args,count,arrayBase,index,result],mem) && trace[|trace|-1] == state
  {
    ArrayOffset(arrayBase,count,index,mem);
    state,trace := A.Run(code,ret,args,0,0,result,count,index,arrayBase,prefix,mem,value,data);
    assert A.Memory1(ret,args,0,0,result,count,index,arrayBase,prefix,mem) == Store(mem,arrayBase+32+index*32,result);
  }
}
