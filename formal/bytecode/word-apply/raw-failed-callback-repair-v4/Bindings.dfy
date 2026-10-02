// SPDX-License-Identifier: MIT
include "../raw-wrong-size-repair-v4/Bindings.dfy"
include "../failed-callback-iteration-repair-v3/Engine.dfy"
module BytecodeApplyRawOrdinaryFailedCallbackBindings {
  import opened BytecodeScanMachine
  import X = BytecodeExternalMachine
  import C = BytecodeApplyRawLoopPrefixCompletion
  import L = BytecodeApplyRawLoopState
  import I = BytecodeApplyRawInputs
  import B = BytecodeApplyRawIterationBounds
  import O = BytecodeIotaOutput
  import M = BytecodeApplyRepeatedIterationMemory
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import WM = BytecodeApplyWrongSizeIterationMemory
  import D = BytecodeApplyCallbackExhaustionEngine
  import F = BytecodeApplyRawWrongSizeBindings
  import RH = BytecodeApplyCallbackReceiptMemory
  import DM = BytecodeApplyDynamicBytesCopyMemory
  function Completed(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>): seq<seq<Byte>>
    requires C.Successful(data,filter,actual)
    ensures L.Receipts(data,filter,Completed(data,filter,actual))
    ensures Completed(data,filter,actual) == F.Completed(data,filter,actual)
  { F.Completed(data,filter,actual) }
  predicate Resource(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>,returned: seq<Byte>)
    requires C.Successful(data,filter,actual) && |actual| < L.N(data)
    requires B.Free(L.N(data),I.TemplateLength(data),|actual|)+|returned|+256 < RH.Bound()
  {
    var receipts := Completed(data,filter,actual);var index: Word := |actual|;
                                                  WM.RawAdmission(data,filter,receipts,index,returned);
                                                  var mem := L.Heap(data,filter,receipts,index);var ptr: Word := O.Extent(L.N(data));
                                                                                                var free := B.Free(L.N(data),I.TemplateLength(data),index);
                                                                                                var stamped := M.Stamped(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index));
                                                                                                Load(CM.Final(stamped,ptr,free,I.TemplateLength(data),returned),64)+I.TemplateLength(data)+|returned|+512 < DM.Bound()
  }
  opaque predicate BadTape(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>,self: Word,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,gasAfter: Word,returned: seq<Byte>)
    requires C.Successful(data,filter,actual) && |actual| < L.N(data)
    requires B.Free(L.N(data),I.TemplateLength(data),|actual|)+|returned|+256 < RH.Bound()
  {
    var receipts := Completed(data,filter,actual);var index: Word := |actual|;
                                                  WM.RawAdmission(data,filter,receipts,index,returned);
                                                  var mem := L.Heap(data,filter,receipts,index);var ptr: Word := O.Extent(L.N(data));
                                                                                                var free := B.Free(L.N(data),I.TemplateLength(data),index);
                                                                                                var stamped := M.Stamped(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index));
                                                                                                var after := CM.Final(stamped,ptr,free,I.TemplateLength(data),returned);var receipt := CM.Receipt(free,returned);
                                                                                                                                                                        cursor+3 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
                                                                                                                                                                        && observations[cursor+2] == X.StaticCall(self,requestedGas,I.Target(data),stamped[ptr+32..ptr+32+I.TemplateLength(data)],false,returned)
                                                                                                                                                                        && observations[cursor+3] == X.Gas(gasAfter) && !D.Refused(|returned|,Load(after,receipt+32),gasBefore,gasAfter)
  }
}
