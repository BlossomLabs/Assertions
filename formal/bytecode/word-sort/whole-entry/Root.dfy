// SPDX-License-Identifier: MIT
// Complete fitting zero-value raw sortWords frame from PC zero to its physical terminal.
include "Body.dfy"
include "../raw-decoder/Boundary.dfy"
module BytecodeSortPublicBytecodeRoot {
  import opened BytecodeScanMachine
  import E = BytecodeCopyExecution
  import L = BytecodeCopyTraceLift
  import P = BytecodeWordSortPrefix
  import D = BytecodeWordSortDecoder
  import A = BytecodeSortRawAdmission
  import Raw = BytecodeSortRawBoundary
  import B = BytecodeSortBodyExecutionConnection
  import G = BytecodeGetterMachine
  predicate Matches(code: seq<Byte>) { Raw.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { Raw.Destinations()+B.Destinations() }
  lemma Geometry(data: seq<Byte>)
    requires D.Admitted(data)
    ensures B.Fits(data,D.Offset(data),D.Length(data))
  {}
  predicate Verdict(data: seq<Byte>, ids: seq<nat>, state: State)
    requires 4 <= |data| < 0x10000000000000000
  {
    A.Exhaustive(data);
    if A.Classify(data) != A.Accepted then ids == [] && state == Reverted([])
    else
      Geometry(data);
      if D.Length(data)%32 != 0 then ids == [] && state == Reverted(G.Encode(0xa949d285,4)+G.Encode(D.Length(data),32))
      else B.Success(data,D.Offset(data),D.Length(data),ids,state)
  }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>, ids: seq<nat>)
    requires Matches(code) && P.Admitted(value,data)
    ensures Verdict(data,ids,state)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    ids := [];
    state,trace := Raw.Run(code,value,data);
    L.Trace(code,Raw.Destinations(),value,data,trace);
    E.WidenTrace(code,Raw.Destinations(),Destinations(),value,data,trace);
    A.Exhaustive(data);
    if A.Classify(data) == A.Accepted {
      Geometry(data);
      var part: seq<State>;
      state,part,ids := B.Run(code,data,D.Offset(data),D.Length(data),value);
      E.WidenTrace(code,B.Destinations(),Destinations(),value,data,part);
      E.Join(code,Destinations(),value,data,trace,part);
      trace := trace+part[1..];
    }
  }
}
