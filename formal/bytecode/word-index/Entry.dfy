// SPDX-License-Identifier: MIT
include "Connection.dfy"
include "Prefix.generated.dfy"
module BytecodeIndexEntry {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import P = BytecodeIndexPrefix
  import C = BytecodeIndexConnection
  import D = BytecodeScanIndexDecoder
  predicate Matches(code: seq<Byte>) { P.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+C.Destinations() }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && P.Admitted(value,data) && D.Admitted(data)
    ensures state == C.Expected(data)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    state,trace := P.Run(code,value,data);
    E.WidenTrace(code,P.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>;
    state,part := C.Run(code,data,value);
    E.WidenTrace(code,C.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..];
  }
}
