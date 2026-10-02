// SPDX-License-Identifier: MIT
include "Memory.dfy"
include "../shape-invocation/Invocation.generated.dfy"
module BytecodeCollectionsUnpackShapeBoundary {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import R = BytecodeCollectionsUnpackCopyBoundary
  import A = BytecodeCollectionsUnpackRawAdmission
  import P = BytecodeCollectionsUnpackPrefix
  import D = BytecodeCollectionsUnpackDecoder
  import B = BytecodeCollectionsUnpackShapeInvocation
  import H = BytecodeApplyTemplateMemory
  import M = BytecodeCollectionsArrayStateMemory
  import F = BytecodeCollectionsUnpackCopiedFrame
  predicate Matches(code: seq<Byte>) { R.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+B.Destinations() }
  function StateMemory(data: seq<Byte>): seq<Byte>
    requires D.Admitted(data)
  { M.Zero(R.CopiedMemory(data),H.Free(128,D.LengthB(data)),6) }
  lemma LiftScan(code: seq<Byte>,value: Word,data: seq<Byte>,states: seq<State>)
    requires S.Trace(code,Destinations(),value,data,states)
    ensures C.Trace(code,Destinations(),value,data,states)
  {
    hide DataWord();hide G.BitAnd();hide ShiftRight();
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    {
      reveal S.Trace();
      assert Step(code,Destinations(),states[i],value,data) == states[i+1];
      assert states[i+1] != Bad;
      reveal Step();
    }
    C.Lift(code,Destinations(),value,data,states);
  }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && P.Admitted(value,data)
    ensures if A.Classify(data) == A.Accepted then
              D.Admitted(data) && state == Running(9893,[3411229406,477,D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data),96,5704,D.OffsetA(data),D.LengthA(data),128,96,H.Free(128,D.LengthB(data)),12879,D.OffsetA(data),D.LengthA(data)],StateMemory(data))
            else state == Reverted([])
    ensures C.Trace(code,Destinations(),value,data,trace) && |trace| > 0
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    hide DataWord();hide G.BitAnd();hide ShiftRight();hide S.Trace();hide C.Trace();
    state,trace := R.Run(code,value,data);
    C.WidenTrace(code,R.Destinations(),Destinations(),value,data,trace);
    if A.Classify(data) == A.Accepted {
      A.Exhaustive(data);D.Bounds(data);F.Frame(data);
      var mem := R.CopiedMemory(data);var fp := H.Free(128,D.LengthB(data));
      var prefix := [3411229406,477,D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data),96];
      assert B.Admitted(data,mem,prefix,5704,D.OffsetA(data),D.LengthA(data),128,fp);
      var initial := state;var part: seq<State>;
      state,part := B.Run(code,data,mem,prefix,5704,D.OffsetA(data),D.LengthA(data),128,fp,value);
      assert part[0] == initial;
      S.WidenTrace(code,B.Destinations(),Destinations(),value,data,part);
      LiftScan(code,value,data,part);
      assert trace[|trace|-1] == part[0];
      C.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    }
  }
}
