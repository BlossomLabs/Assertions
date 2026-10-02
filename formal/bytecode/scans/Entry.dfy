// SPDX-License-Identifier: MIT
// Complete successful physical sum trace from PC zero; error classes separate.
include "Prefix.generated.dfy"
include "Connection.dfy"
module BytecodeSumEntry {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import P = BytecodeSumPrefix
  import D = BytecodeScanSumDecoder
  import L = BytecodeSumLoop
  import C = BytecodeSumConnection
  predicate Matches(code: seq<Byte>) { P.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+C.Destinations() }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && P.Admitted(value,data) && D.Admitted(data)
    requires D.Length(data)%32 == 0 && L.Prefix(data,D.Offset(data),D.Length(data)/32) < G.Modulus()
    ensures state == Returned(G.Encode(L.Prefix(data,D.Offset(data),D.Length(data)/32),32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    var part: seq<State>;
    state,trace := P.Run(code,value,data);
    E.WidenTrace(code,P.Destinations(),Destinations(),value,data,trace);
    state,part := C.Run(code,data,value);
    E.WidenTrace(code,C.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..];
  }
}
