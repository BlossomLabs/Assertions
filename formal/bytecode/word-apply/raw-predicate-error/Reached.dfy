// SPDX-License-Identifier: MIT
include "Bindings.dfy"
include "../raw-success/Bindings.dfy"
module BytecodeApplyRawNoncanonicalPredicateReached {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import FP = BytecodeWordFilterPrefix
  import C = BytecodeApplyRawLoopPrefixCompletion
  import L = BytecodeApplyRawLoopState
  import F = BytecodeApplyRawNoncanonicalPredicateBindings
  import W = BytecodeApplyNoncanonicalPredicateIteration
  import WI = BytecodeApplyWrongSizeIterationEngine
  import D = BytecodeApplyRawLoopBindings
  import Z = BytecodeApplyRawSuccessfulBindings
  import B = BytecodeApplyRawIterationBounds
  import H = BytecodeApplyCallbackSuccessMemory
  import WH = BytecodeApplyWrongCallbackMemory
  import SC = BytecodeApplyWrongCallbackScalar
  import WB = BytecodeApplyRawWrongSizeBindings
  ghost method Run(code: seq<Byte>,data: seq<Byte>,actual: seq<seq<Byte>>,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires W.Matches(code) && C.Successful(data,true,actual) && |actual| < L.N(data) && X.Context(self) && FP.Admitted(0,data)
    requires |returned| == 32 && H.Result(returned) > 1
    requires F.BadTape(data,actual,self,cursor,observations,gasBefore,requestedGas,returned)
    ensures frame == X.Frame(Reverted(WH.Packet(SC.Operation(),|actual|,I.Target(data))),returned,cursor+3)
    ensures E.Trace(code,W.Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == WI.Initial(L.Heap(data,true,F.Completed(data,actual),|actual|),Z.Prefix(data,true),5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),L.N(data),L.Kept(data,true,F.Completed(data,actual),|actual|),|actual|,true,oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide L.Heap();hide L.Kept();hide B.Free();hide WH.Packet();
    reveal F.BadTape();
    var receipts := F.Completed(data,actual);var index: Word := |actual|;
    Z.Initial(data,true,receipts);Z.Stack(data,true,receipts,0);Z.Stack(data,true,receipts,index);
    D.ReadAdmission(data,index);B.RawSource(data,index);WB.Selector(data,true);
    frame,trace := W.Run(code,data,L.Heap(data,true,receipts,index),Z.Prefix(data,true),5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),L.N(data),L.Kept(data,true,receipts,index),index,self,oldReturn,returned,cursor,observations,gasBefore,requestedGas);
  }
}
