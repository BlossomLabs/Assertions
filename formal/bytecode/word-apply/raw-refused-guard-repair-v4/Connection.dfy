// SPDX-License-Identifier: MIT
// PC-zero raw public map/filter entry to first failed callback with refused guard.
include "Bindings.dfy"
include "Reached.dfy"
include "../raw-template/Connection.dfy"
include "../raw-success/Bindings.dfy"
include "../failed-guard-iteration/Engine.dfy"
module BytecodeApplyRawRefusedGuardEntry {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import T = BytecodeApplyRawTemplateCopy
  import L = BytecodeApplyRawLoopState
  import C = BytecodeApplyRawLoopPrefixCompletion
  import V = BytecodeApplySuccessfulRawLoopPrefixEngine
  import D = BytecodeApplyRawLoopBindings
  import Z = BytecodeApplyRawSuccessfulBindings
  import B = BytecodeApplyRawIterationBounds
  import O = BytecodeIotaOutput
  import WM = BytecodeApplyWrongSizeIterationMemory
  import M = BytecodeApplyRepeatedIterationMemory
  import W = BytecodeApplyRefusedGuardIteration
  import WI = BytecodeApplyWrongSizeIterationEngine
  import A = BytecodeApplyRawRefusedGuardReached
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import K = BytecodeApplyCallbackExhaustionEngine
  import HS = BytecodeApplyCallbackExhaustionScalar
  import H = BytecodeApplyCallbackOutOfGasReturnMemory
  import CL = BytecodeApplyCallbackLengthScalar
  import RH = BytecodeApplyCallbackReceiptMemory
  import F = BytecodeApplyRawRefusedGuardBindings
  predicate Matches(code: seq<Byte>) { T.Matches(code) && V.Matches(code) && W.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+V.Destinations()+W.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>,returned: seq<Byte>,self: Word,oldReturn: seq<Byte>,cursor: nat,codeSize: Word,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,gasAfter: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && C.Successful(data,filter,actual) && |actual| < L.N(data)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires B.Free(L.N(data),I.TemplateLength(data),|actual|)+|returned|+256 < RH.Bound()
    requires X.Context(self) && codeSize > 0 && cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    requires V.Tape(data,filter,F.Completed(data,filter,actual),self,|actual|,cursor+1,before,requested,observations)
    requires F.BadTape(data,filter,actual,self,cursor+1+3*|actual|,observations,gasBefore,requestedGas,gasAfter,returned)
    ensures frame == X.Frame(Reverted(H.Packet()),returned,cursor+1+3*|actual|+4)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide B.Free(); hide L.Kept(); hide M.Stamped(); hide C.Complete(); hide E.Trace(); hide L.Heap(); hide L.Initial(); hide L.Original();
    hide CM.Final();hide K.Refused();hide HS.Masked();hide H.Packet();
    hide F.BadTape();hide C.Successful();
    var receipts := F.Completed(data,filter,actual); var index: Word := |actual|;
    var n := L.N(data); var prefix := Z.Prefix(data,filter);
    Z.Initial(data,filter,receipts); Z.Stack(data,filter,receipts,0);
    var part: seq<X.Frame>;
    frame,trace := T.Run(code,data,filter,self,oldReturn,cursor,codeSize,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    frame,part := V.Run(code,data,filter,receipts,prefix,5526,self,index,oldReturn,cursor+1,before,requested,observations);
    D.StackShape(data,filter,receipts,prefix,5526,0);
    D.StackShape(data,filter,receipts,prefix,5526,index);
    E.WidenTrace(code,V.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
    var mem := L.Heap(data,filter,receipts,index);
    var callCursor := cursor+1+3*index;
    frame,part := A.Run(code,data,filter,actual,self,V.Last(oldReturn,receipts,index),returned,callCursor,observations,gasBefore,requestedGas,gasAfter);
    WI.InitialDefinition(mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),n,L.Kept(data,filter,receipts,index),index,filter,V.Last(oldReturn,receipts,index),cursor+1+3*index);
    E.WidenTrace(code,W.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
  }
}
