// SPDX-License-Identifier: MIT
include "Bindings.dfy"
include "../raw-success/Bindings.dfy"
module BytecodeApplyRawRefusedGuardReached {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import C = BytecodeApplyRawLoopPrefixCompletion
  import L = BytecodeApplyRawLoopState
  import F = BytecodeApplyRawRefusedGuardBindings
  import W = BytecodeApplyRefusedGuardIteration
  import WI = BytecodeApplyWrongSizeIterationEngine
  import WM = BytecodeApplyWrongSizeIterationMemory
  import D = BytecodeApplyRawLoopBindings
  import Z = BytecodeApplyRawSuccessfulBindings
  import B = BytecodeApplyRawIterationBounds
  import H = BytecodeApplyCallbackOutOfGasReturnMemory
  import HS = BytecodeApplyCallbackExhaustionScalar
  import K = BytecodeApplyCallbackExhaustionEngine
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import M = BytecodeApplyRepeatedIterationMemory
  import O = BytecodeIotaOutput
  import RH = BytecodeApplyCallbackReceiptMemory
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,gasAfter: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires W.Matches(code) && C.Successful(data,filter,actual) && |actual| < L.N(data) && X.Context(self)
    requires B.Free(L.N(data),I.TemplateLength(data),|actual|)+|returned|+256 < RH.Bound()
    requires F.BadTape(data,filter,actual,self,cursor,observations,gasBefore,requestedGas,gasAfter,returned)
    ensures frame == X.Frame(Reverted(H.Packet()),returned,cursor+4)
    ensures E.Trace(code,W.Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == WI.Initial(L.Heap(data,filter,F.Completed(data,filter,actual),|actual|),Z.Prefix(data,filter),5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),L.N(data),L.Kept(data,filter,F.Completed(data,filter,actual),|actual|),|actual|,filter,oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide B.Free();hide L.Kept();hide M.Stamped();hide C.Complete();hide L.Heap();hide L.Initial();hide L.Original();hide CM.Final();hide K.Refused();hide HS.Masked();hide H.Packet();
    reveal F.BadTape();
    var receipts := F.Completed(data,filter,actual);var index: Word := |actual|;
    var n := L.N(data);var prefix := Z.Prefix(data,filter);
    Z.Initial(data,filter,receipts);Z.Stack(data,filter,receipts,0);Z.Stack(data,filter,receipts,index);
    WM.RawAdmission(data,filter,receipts,index,returned);
    D.ReadAdmission(data,index);B.RawSource(data,index);
    var mem := L.Heap(data,filter,receipts,index);var ptr: Word := O.Extent(n);var free := B.Free(n,I.TemplateLength(data),index);
    var word := L.Original(data,index);
    assert word == DataWord(data,I.Offset(I.SourceHead(data))+index*32);
    assert Load(mem,64) == free;
    var stamped := M.Stamped(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,word);
    assert CM.Fits(stamped,ptr,free,I.TemplateLength(data),returned);
    var after := CM.Final(stamped,ptr,free,I.TemplateLength(data),returned);var receipt := CM.Receipt(free,returned);
    assert cursor+3 < |observations|;
    assert observations[cursor+2] == X.StaticCall(self,requestedGas,I.Target(data),stamped[ptr+32..ptr+32+I.TemplateLength(data)],false,returned);
    assert K.Refused(|returned|,Load(after,receipt+32),gasBefore,gasAfter);
    frame,trace := W.Run(code,data,mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),n,L.Kept(data,filter,receipts,index),index,filter,self,oldReturn,returned,cursor,observations,gasBefore,requestedGas,gasAfter);
  }
}
