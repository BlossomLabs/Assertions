// SPDX-License-Identifier: MIT
// Truthful GAS and exact copied STATICCALL input/full returndata binding.
include "../callback-copy/Memory.dfy"
include "../../external-calls/Execution.dfy"
include "Sequence.dfy"
module BytecodeApplyCallbackObservation {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import M = BytecodeExternalMemory
  import C = BytecodeCopyMemory
  import H = BytecodeApplyCallbackCopyMemory
  import Q = BytecodeApplyCallStackSequence
  lemma PackedInput(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>)
    requires H.Fits(mem,ptr,free,length)
    ensures M.Fits(H.Packed(mem,ptr,free,length),free,length,free,0)
    ensures M.Input(H.Packed(mem,ptr,free,length),free,length) == mem[ptr+32..ptr+32+length]
    ensures M.Output(H.Packed(mem,ptr,free,length),free,length,free,0,returned) == H.Packed(mem,ptr,free,length)
  {
    H.Bounds(mem,ptr,free,length);
    H.Input(mem,ptr,free,length);
    C.Rounded(free+length);
    M.InputSnapshot(H.Packed(mem,ptr,free,length),free,length,free,0);
    M.ZeroOutput(H.Packed(mem,ptr,free,length),free,length,free,returned);
    assert S.Expand(H.Packed(mem,ptr,free,length),M.Footprint(free,length)) == H.Packed(mem,ptr,free,length);
  }
  ghost method FirstGas(code: seq<S.Byte>,prefix: seq<S.Word>,mem: seq<S.Byte>,self: S.Word,value: S.Word,data: seq<S.Byte>,oldReturn: seq<S.Byte>,cursor: nat,observations: seq<X.Observation>,available: S.Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires |code| > 16908 && code[16908] == 0x5a && X.Context(self) && |prefix| < 1024
    requires cursor < |observations| && observations[cursor] == X.Gas(available)
    ensures frame == X.Frame(S.Running(16909,prefix+[available],mem),oldReturn,cursor+1)
    ensures E.Trace(code,{},self,value,data,observations,trace) && |trace| == 2
    ensures trace[0] == X.Frame(S.Running(16908,prefix,mem),oldReturn,cursor) && trace[1] == frame
  {
    var initial := X.Frame(S.Running(16908,prefix,mem),oldReturn,cursor);
    X.GasStep(code,16908,prefix,mem,self,oldReturn,cursor,observations,available,value,data);
    frame := X.Step(code,{},initial,self,value,data,observations);
    trace := [initial]; E.Extend(code,{},self,value,data,observations,trace,frame); trace := trace+[frame];
  }
  ghost method Call(code: seq<S.Byte>,prefix: seq<S.Word>,mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,target: S.Word,self: S.Word,value: S.Word,data: seq<S.Byte>,oldReturn: seq<S.Byte>,returned: seq<S.Byte>,success: bool,cursor: nat,observations: seq<X.Observation>,requestedGas: S.Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires |code| > 16947 && code[16946] == 0x5a && code[16947] == 0xfa
    requires H.Fits(mem,ptr,free,length) && X.Context(self) && |prefix| <= 1018 && |returned| < G.Modulus()
    requires cursor+1 < |observations| && observations[cursor] == X.Gas(requestedGas)
    requires observations[cursor+1] == X.StaticCall(self,requestedGas,X.Address(target),mem[ptr+32..ptr+32+length],success,returned)
    ensures frame == X.Frame(S.Running(16948,prefix+[if success then 1 else 0],H.Packed(mem,ptr,free,length)),returned,cursor+2)
    ensures E.Trace(code,{},self,value,data,observations,trace) && |trace| == 3
    ensures trace[0] == X.Frame(S.Running(16946,prefix+[0,free,length,free,target],H.Packed(mem,ptr,free,length)),oldReturn,cursor) && trace[2] == frame
  {
    PackedInput(mem,ptr,free,length,returned);
    var packed := H.Packed(mem,ptr,free,length);
    var initial := X.Frame(S.Running(16946,prefix+[0,free,length,free,target],packed),oldReturn,cursor);
    X.GasStep(code,16946,prefix+[0,free,length,free,target],packed,self,oldReturn,cursor,observations,requestedGas,value,data);
    var middle := X.Step(code,{},initial,self,value,data,observations);
    assert initial == X.Frame(S.Running(16946,prefix+[0,free,length,free,target],packed),oldReturn,cursor);
    assert middle == X.Frame(S.Running(16947,(prefix+[0,free,length,free,target])+[requestedGas],packed),oldReturn,cursor+1);
    Q.One(prefix,[0,free,length,free,target],requestedGas);
    Q.Six(prefix,0,free,length,free,target,requestedGas);
    assert (prefix+[0,free,length,free,target])+[requestedGas] == prefix+[0,free,length,free,target,requestedGas];
    assert middle == X.Frame(S.Running(16947,prefix+[0,free,length,free,target,requestedGas],packed),oldReturn,cursor+1);
    X.StaticStep(code,16947,prefix,packed,self,requestedGas,target,free,length,free,0,oldReturn,returned,success,cursor+1,observations,value,data);
    frame := X.Step(code,{},middle,self,value,data,observations);
    trace := [initial]; E.Extend(code,{},self,value,data,observations,trace,middle); trace := trace+[middle];
    E.Extend(code,{},self,value,data,observations,trace,frame); trace := trace+[frame];
  }
}
