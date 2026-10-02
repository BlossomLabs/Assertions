// SPDX-License-Identifier: MIT
include "../callback-exhaustion/Connection.dfy"
include "../../word-apply/callback-failed-admission-repair-v4/Memory.dfy"
include "Engine.dfy"
module BytecodeFoldOrdinaryFailedCallbackConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeFoldFailedCallbackGuardConnection
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import K = BytecodeApplyCallbackExhaustionEngine
  import HS = BytecodeApplyCallbackExhaustionScalar
  import A = BytecodeApplyCallbackFailedReceiptAdmission
  import H = BytecodeApplyCallbackFailedMemory
  import D = BytecodeApplyDynamicBytesCopyMemory
  import S = BytecodeFoldCallbackFailedSerializerEngine
  import V = BytecodeFoldCallbackExhaustionInvoke
  import P = BytecodeApplyCallbackCopyMemory
  import AM = BytecodeApplyAddressMask
  import CL = BytecodeFoldCallbackLengthScalar
  predicate Matches(code: seq<Byte>) { C.Matches(code) && S.Matches(code) }
  function Destinations(): set<nat> { C.Destinations()+S.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,domain: nat,target: Word,ptr: Word,index: Word,free: Word,length: Word,payload: seq<Byte>,self: Word,value: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,gasAfter: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires domain < 3 && Matches(code) && CM.Fits(mem,ptr,free,length,returned)
    requires |payload| == length && mem[ptr+32..ptr+32+length] == payload
    requires Load(CM.Final(mem,ptr,free,length,returned),64)+|payload|+|returned|+512 < D.Bound()
    requires X.Context(self) && target < AM.Bound() && |prefix| <= 997
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(domain)
    requires var after := CM.Final(mem,ptr,free,length,returned);var receipt := CM.Receipt(free,returned);
                                                                 !K.Refused(|returned|,Load(after,receipt+32),gasBefore,gasAfter)
    requires cursor+3 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas) && observations[cursor+3] == X.Gas(gasAfter)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,mem[ptr+32..ptr+32+length],false,returned)
    ensures frame == X.Frame(Reverted(H.Packet(CL.Operation(domain),index,target,payload,returned)),returned,cursor+4)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(16908,prefix+[16553,target,ptr,index,0,0],mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide CM.Final();hide P.Packed();hide K.Refused();hide HS.Masked();hide H.Packet();hide E.Trace();
    var after := CM.Final(mem,ptr,free,length,returned);var receipt := CM.Receipt(free,returned);var nextFree := Load(after,64);
    frame,trace := C.Run(code,data,mem,prefix,target,ptr,index,free,length,self,value,oldReturn,returned,cursor,observations,gasBefore,requestedGas,gasAfter);
    E.WidenTrace(code,C.Destinations(),Destinations(),self,value,data,observations,trace);
    A.Admission(mem,ptr,free,length,payload,returned);
    assert V.Tail(target,ptr,index,gasBefore,receipt) == S.Tail(target,ptr,index,gasBefore,receipt) by { reveal V.Tail();reveal S.Tail(); }
    var part: seq<X.Frame>;
    frame,part := S.ExternalRun(code,data,after,prefix,domain,target,ptr,index,gasBefore,receipt,nextFree,payload,returned,value,self,returned,cursor+4,observations);
    E.WidenTrace(code,S.Destinations(),Destinations(),self,value,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
  }
}
