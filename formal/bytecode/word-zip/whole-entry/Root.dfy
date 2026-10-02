// SPDX-License-Identifier: MIT
// Complete fitting zero-value raw zipWords frame from PC 0 to physical terminal.
include "Body.dfy"
include "../raw-decoder/Boundary.dfy"
module BytecodeZipPublicBytecodeRoot {
  import S = BytecodeScanMachine
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  import P = BytecodeWordZipPrefix
  import D = BytecodeWordZipDecoder
  import A = BytecodeZipRawAdmission
  import Raw = BytecodeZipRawBoundary
  import B = BytecodeZipBodyExecutionConnection
  predicate Matches(code: seq<S.Byte>) { Raw.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { Raw.Destinations()+B.Destinations() }
  lemma Geometry(data: seq<S.Byte>)
    requires D.Admitted(data)
    ensures B.Fits(data,D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data))
  {}
  function Expected(data: seq<S.Byte>): S.State
    requires 4 <= |data| < 0x10000000000000000
  {
    if A.Classify(data) == A.Accepted then B.Expected(data,D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data))
    else S.Reverted([])
  }
  ghost method Run(code: seq<S.Byte>, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && P.Admitted(value,data)
    ensures state == Expected(data)
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(0,[],[]) && trace[|trace|-1] == state
  {
    state,trace := Raw.Run(code,value,data);
    Lift.Trace(code,Raw.Destinations(),value,data,trace);
    C.WidenTrace(code,Raw.Destinations(),Destinations(),value,data,trace);
    A.Exhaustive(data);
    if A.Classify(data) == A.Accepted {
      Geometry(data);
      var terminal,part := B.Run(code,data,D.OffsetA(data),D.LengthA(data),D.OffsetB(data),D.LengthB(data),value);
      C.WidenTrace(code,B.Destinations(),Destinations(),value,data,part);
      C.Join(code,Destinations(),value,data,trace,part);
      trace := trace+part[1..]; state := terminal;
    }
  }
}
