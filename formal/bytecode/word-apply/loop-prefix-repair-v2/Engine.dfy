// SPDX-License-Identifier: MIT
include "../iteration-engine/Engine.dfy"
include "../loop-state/Model.dfy"
include "Bindings.dfy"
module BytecodeApplySuccessfulRawLoopPrefixEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import O = BytecodeIotaOutput
  import L = BytecodeApplyRawLoopState
  import B = BytecodeApplyRawIterationBounds
  import M = BytecodeApplyRepeatedIterationMemory
  import H = BytecodeApplyCallbackSuccessMemory
  import V = BytecodeApplySuccessfulIterationEngine
  import D = BytecodeApplyRawLoopBindings
  import PB = BytecodeApplyRawLoopPrefixBindings
  import C = BytecodeApplyRawLoopPrefixCompletion
  predicate Matches(code: seq<Byte>) { V.Matches(code) }
  function Destinations(): set<nat> { V.Destinations() }
  function Last(oldReturn: seq<Byte>,receipts: seq<seq<Byte>>,index: nat): seq<Byte>
    requires index <= |receipts|
  { D.Last(oldReturn,receipts,index) }
  function Stack(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,prefix: seq<Word>,returnPc: Word,index: Word): seq<Word>
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
  { D.Stack(data,filter,receipts,prefix,returnPc,index) }
  predicate Tape(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,stop: Word,cursor: nat,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>)
  { PB.TapePrefix(data,filter,receipts,self,stop,cursor,before,requested,observations) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,prefix: seq<Word>,returnPc: Word,self: Word,stop: Word,oldReturn: seq<Byte>,cursor: nat,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Tape(data,filter,receipts,self,stop,cursor,before,requested,observations)
    requires X.Context(self) && |prefix| <= 984
    ensures frame == X.Frame(Running(12391,Stack(data,filter,receipts,prefix,returnPc,stop),L.Heap(data,filter,receipts,stop)),Last(oldReturn,receipts,stop),cursor+3*stop)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(12391,Stack(data,filter,receipts,prefix,returnPc,0),L.Initial(data)),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == 1+(if filter then 338 else 357)*(stop as nat)+40*(I.Count(data) as nat)*(stop as nat)+(if filter then 32*(L.Kept(data,filter,receipts,stop) as nat) else 0)
  {
    hide G.BitAnd();
    hide L.Heap();
    hide L.Update();
    hide M.After();
    hide V.Output();
    hide D.Stack();
    var n: Word := L.N(data); var index: Word := 0;
    frame := X.Frame(Running(12391,Stack(data,filter,receipts,prefix,returnPc,0),L.Initial(data)),oldReturn,cursor);trace := [frame];
    assert L.Heap(data,filter,receipts,0) == L.Initial(data) by { reveal L.Heap(); }
    while index < stop
      invariant index <= stop <= n
      invariant E.Trace(code,Destinations(),self,0,data,observations,trace)
      invariant trace[0] == X.Frame(Running(12391,Stack(data,filter,receipts,prefix,returnPc,0),L.Initial(data)),oldReturn,cursor) && trace[|trace|-1] == frame
      invariant frame == X.Frame(Running(12391,Stack(data,filter,receipts,prefix,returnPc,index),L.Heap(data,filter,receipts,index)),Last(oldReturn,receipts,index),cursor+3*index)
      invariant |trace| == 1+(if filter then 338 else 357)*(index as nat)+40*(I.Count(data) as nat)*(index as nat)+(if filter then 32*(L.Kept(data,filter,receipts,index) as nat) else 0)
      decreases stop-index
    {
      D.StackShape(data,filter,receipts,prefix,returnPc,index);
      D.ReadAdmission(data,index);
      PB.Slot(data,filter,receipts,self,stop,cursor,before,requested,observations,index);
      D.Step(data,filter,receipts,prefix,returnPc,oldReturn,index);
      D.LengthStep(data,filter,receipts,index);
      B.RawSource(data,index);
      I.Pointer(I.SourceHead(data));
      var mem := L.Heap(data,filter,receipts,index);
      var kept := L.Kept(data,filter,receipts,index);
      assert Load(mem,64) == B.Free(n,I.TemplateLength(data),index);
      var part: seq<X.Frame>;
      frame,part := V.Run(code,data,mem,prefix,returnPc,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),n,kept,index,filter,self,Last(oldReturn,receipts,index),receipts[index],cursor+3*index,observations,before[index],requested[index]);
      assert V.Output(mem,data,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),n,kept,index,filter,receipts[index]) == L.Heap(data,filter,receipts,index+1);
      assert frame == X.Frame(Running(12391,Stack(data,filter,receipts,prefix,returnPc,index+1),L.Heap(data,filter,receipts,index+1)),Last(oldReturn,receipts,index+1),cursor+3*(index+1));
      E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];index := index+1;
    }
  }
  ghost method RunActual(code: seq<Byte>,data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>,prefix: seq<Word>,returnPc: Word,self: Word,oldReturn: seq<Byte>,cursor: nat,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires C.Successful(data,filter,actual)
    requires Matches(code) && Tape(data,filter,C.Complete(data,filter,actual),self,|actual|,cursor,before,requested,observations)
    requires X.Context(self) && |prefix| <= 984
    ensures var receipts := C.Complete(data,filter,actual);
            frame == X.Frame(Running(12391,Stack(data,filter,receipts,prefix,returnPc,|actual|),L.Heap(data,filter,receipts,|actual|)),Last(oldReturn,receipts,|actual|),cursor+3*|actual|)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(12391,Stack(data,filter,C.Complete(data,filter,actual),prefix,returnPc,0),L.Initial(data)),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == 1+(if filter then 338 else 357)*|actual|+40*(I.Count(data) as nat)*|actual|+(if filter then 32*(L.Kept(data,filter,C.Complete(data,filter,actual),|actual|) as nat) else 0)
  {
    C.Admits(data,filter,actual);
    var receipts := C.Complete(data,filter,actual);
    frame,trace := Run(code,data,filter,receipts,prefix,returnPc,self,|actual|,oldReturn,cursor,before,requested,observations);
  }
}
