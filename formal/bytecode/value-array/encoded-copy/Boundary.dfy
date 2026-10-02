// SPDX-License-Identifier: MIT
// PC-zero raw unpack decoder and its actual encoded-value memory copy.
include "../raw-unpack/Boundary.dfy"
include "Copy.generated.dfy"
module BytecodeCollectionsUnpackCopyBoundary {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import R = BytecodeCollectionsUnpackRawBoundary
  import A = BytecodeCollectionsUnpackRawAdmission
  import P = BytecodeCollectionsUnpackPrefix
  import D = BytecodeCollectionsUnpackDecoder
  import B = BytecodeCollectionsUnpackCopy
  import H = BytecodeApplyTemplateMemory
  import MR = BytecodeScanRepresentation
  predicate Matches(code: seq<Byte>) { R.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+B.Destinations() }
  function CopiedMemory(data: seq<Byte>): seq<Byte>
    requires D.Admitted(data)
  { H.Complete(Store([],64,128),128,D.OffsetB(data),D.LengthB(data),data) }
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
              D.Admitted(data) && state == Running(12814,[3411229406,477,D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data),96,5704,D.OffsetA(data),D.LengthA(data),128],CopiedMemory(data))
            else state == Reverted([])
    ensures C.Trace(code,Destinations(),value,data,trace) && |trace| > 0
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    hide DataWord();hide G.BitAnd();hide ShiftRight();hide S.Trace();hide C.Trace();
    state,trace := R.Run(code,value,data);
    S.WidenTrace(code,R.Destinations(),Destinations(),value,data,trace);
    LiftScan(code,value,data,trace);
    if A.Classify(data) == A.Accepted {
      A.Exhaustive(data);D.Bounds(data);
      var mem := Store([],64,128);
      MR.StoredWord([],64,128);
      assert |mem| == 96 && |mem|%32 == 0 && Load(mem,64) == 128;
      assert B.Admitted(data,mem,[3411229406,477],D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data),128);
      var initial := state;
      var part: seq<State>;
      state,part := B.Run(code,data,mem,[3411229406,477],D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data),128,value);
      assert part[0] == initial;
      assert trace[|trace|-1] == part[0];
      C.WidenTrace(code,B.Destinations(),Destinations(),value,data,part);
      C.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    }
  }
}
