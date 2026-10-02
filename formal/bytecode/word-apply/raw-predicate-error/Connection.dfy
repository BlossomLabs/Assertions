// SPDX-License-Identifier: MIT
// PC-zero raw filter entry to first successful noncanonical predicate result.
include "Bindings.dfy"
include "Reached.dfy"
include "../raw-template/Connection.dfy"
include "../raw-success/Bindings.dfy"
include "../predicate-error-iteration-repair-v2/Engine.dfy"
module BytecodeApplyRawNoncanonicalPredicateEntry {
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
  import W = BytecodeApplyNoncanonicalPredicateIteration
  import WI = BytecodeApplyWrongSizeIterationEngine
  import A = BytecodeApplyRawNoncanonicalPredicateReached
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import H = BytecodeApplyWrongCallbackMemory
  import CH = BytecodeApplyCallbackSuccessMemory
  import SC = BytecodeApplyWrongCallbackScalar
  import CL = BytecodeApplyCallbackLengthScalar
  import RH = BytecodeApplyCallbackReceiptMemory
  import F = BytecodeApplyRawNoncanonicalPredicateBindings
  predicate Matches(code: seq<Byte>) { T.Matches(code) && V.Matches(code) && W.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+V.Destinations()+W.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,actual: seq<seq<Byte>>,returned: seq<Byte>,self: Word,oldReturn: seq<Byte>,cursor: nat,codeSize: Word,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && C.Successful(data,true,actual) && |actual| < L.N(data)
    requires FP.Admitted(0,data)
    requires |returned| == 32 && CH.Result(returned) > 1
    requires X.Context(self) && codeSize > 0 && cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    requires V.Tape(data,true,F.Completed(data,actual),self,|actual|,cursor+1,before,requested,observations)
    requires F.BadTape(data,actual,self,cursor+1+3*|actual|,observations,gasBefore,requestedGas,returned)
    ensures frame == X.Frame(Reverted(H.Packet(SC.Operation(),|actual|,I.Target(data))),returned,cursor+1+3*|actual|+3)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide B.Free(); hide L.Kept(); hide M.Stamped(); hide C.Complete(); hide E.Trace(); hide L.Heap(); hide L.Initial(); hide L.Original();
    hide CM.Final();hide H.Packet();
    hide F.BadTape();hide C.Successful();hide W.Matches();hide V.Last();
    var receipts := F.Completed(data,actual); var index: Word := |actual|;
    var n := L.N(data); var prefix := Z.Prefix(data,true);
    Z.Initial(data,true,receipts); Z.Stack(data,true,receipts,0);
    var part: seq<X.Frame>;
    frame,trace := T.Run(code,data,true,self,oldReturn,cursor,codeSize,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    frame,part := V.Run(code,data,true,receipts,prefix,5526,self,index,oldReturn,cursor+1,before,requested,observations);
    D.StackShape(data,true,receipts,prefix,5526,0);
    D.StackShape(data,true,receipts,prefix,5526,index);
    E.WidenTrace(code,V.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
    var mem := L.Heap(data,true,receipts,index);
    var callCursor: nat := cursor+1+3*|actual|;
    assert W.Matches(code);
    assert C.Successful(data,true,actual);
    assert |actual| < L.N(data);
    assert X.Context(self);
    assert |returned| == 32 && CH.Result(returned) > 1;
    assert F.BadTape(data,actual,self,callCursor,observations,gasBefore,requestedGas,returned);
    frame,part := A.Run(code,data,actual,self,V.Last(oldReturn,receipts,index),returned,callCursor,observations,gasBefore,requestedGas);
    WI.InitialDefinition(mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),n,L.Kept(data,true,receipts,index),index,true,V.Last(oldReturn,receipts,index),cursor+1+3*index);
    E.WidenTrace(code,W.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
  }
}
