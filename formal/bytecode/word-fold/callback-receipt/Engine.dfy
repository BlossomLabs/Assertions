// SPDX-License-Identifier: MIT
// Exact GAS/packing/STATICCALL, full receipt copy, then success flag dispatch.
include "../../word-apply/callback-receipt-engine/Memory.dfy"
include "../callback-engine/Engine.dfy"
include "Nonempty.generated.dfy"
include "Empty.generated.dfy"
include "Flag.dfy"
module BytecodeFoldFullCallbackReceiptEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import A = BytecodeApplyAddressMask
  import P = BytecodeApplyCallbackCopyMemory
  import M = BytecodeApplyFullCallbackReceiptMemory
  import C = BytecodeFoldCallbackEngine
  import N = BytecodeFoldNonemptyCallbackReceipt
  import Z = BytecodeFoldEmptyCallbackReceipt
  import F = BytecodeFoldCallbackFlagDispatch
  predicate Matches(code: seq<Byte>) { C.Matches(code) && N.Matches(code) && Z.Matches(code) && F.Matches(code) }
  function Destinations(): set<nat> { C.Destinations()+N.Destinations()+Z.Destinations()+F.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,self: Word,value: Word,oldReturn: seq<Byte>,returned: seq<Byte>,success: bool,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && M.Fits(mem,ptr,free,length,returned)
    requires X.Context(self) && target < A.Bound() && |prefix| <= 1000
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,mem[ptr+32..ptr+32+length],success,returned)
    ensures frame == X.Frame(Running(if success then 17065 else 17008,prefix+F.Tail(target,ptr,index,gasBefore,success,M.Receipt(free,returned)),M.Final(mem,ptr,free,length,returned)),returned,cursor+3)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures trace[0] == X.Frame(Running(16908,prefix+[16553,target,ptr,index,0,0],mem),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if |returned| == 0 then 91 else 112)
  {
    hide G.BitAnd(); hide BitNot(); hide E.Trace(); hide P.Packed(); hide M.Final();
    M.Admission(mem,ptr,free,length,returned);
    frame,trace := C.Run(code,data,mem,prefix,target,ptr,index,free,length,self,value,oldReturn,returned,success,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,C.Destinations(),Destinations(),self,value,data,observations,trace);
    var part: seq<X.Frame>;
    var packed := P.Packed(mem,ptr,free,length);
    if |returned| > 0 {
      frame,part := N.Run(code,data,packed,prefix,target,ptr,index,free+length,free,gasBefore,returned,cursor+3,observations,self,value,success);
      E.WidenTrace(code,N.Destinations(),Destinations(),self,value,data,observations,part);
    } else {
      frame,part := Z.Run(code,data,packed,prefix,target,ptr,index,free+length,free,gasBefore,returned,cursor+3,observations,self,value,success);
      E.WidenTrace(code,Z.Destinations(),Destinations(),self,value,data,observations,part);
    }
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
    reveal M.Final();
    assert frame == X.Frame(Running(17003,prefix+F.Tail(target,ptr,index,gasBefore,success,M.Receipt(free,returned)),M.Final(mem,ptr,free,length,returned)),returned,cursor+3);
    frame,part := F.Run(code,self,value,data,observations,prefix,M.Final(mem,ptr,free,length,returned),returned,cursor+3,target,ptr,index,gasBefore,success,M.Receipt(free,returned));
    E.WidenTrace(code,F.Destinations(),Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
  }
}
