// SPDX-License-Identifier: MIT
// Complete fitting-size raw wordIndexOf entry: physical routing, decode, body and errors.
include "Admission.dfy"
include "../Connection.dfy"
include "../Prefix.generated.dfy"
module BytecodeIndexRawConnection {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import A = BytecodeIndexRawAdmission
  import P = BytecodeIndexPrefix
  import C = BytecodeIndexConnection
  import H = BytecodeIndexRawHeadShort
  import O = BytecodeIndexRawOffsetLarge
  import S = BytecodeIndexRawHeaderShort
  import N = BytecodeIndexRawLengthLarge
  import T = BytecodeIndexRawTailShort
  predicate Matches(code: seq<Byte>) {
    P.Matches(code) && C.Matches(code) && H.Matches(code) && O.Matches(code) &&
    S.Matches(code) && N.Matches(code) && T.Matches(code)
  }
  function Destinations(): set<nat> {
    P.Destinations()+C.Destinations()+H.Destinations()+O.Destinations()+
    S.Destinations()+N.Destinations()+T.Destinations()
  }
  function Expected(data: seq<Byte>): State {
    if A.Classify(data) == A.Accepted then C.Expected(data) else Reverted([])
  }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && P.Admitted(value,data)
    ensures state == Expected(data)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    var part: seq<State>;
    var small: set<nat>;
    state,trace := P.Run(code,value,data);
    E.WidenTrace(code,P.Destinations(),Destinations(),value,data,trace);
    A.Exhaustive(data);
    var mem := Store([],64,128);
    match A.Classify(data) {
      case HeadShort =>
        state,part := H.Run(code,data,mem,value);
        small := H.Destinations();
      case OffsetLarge =>
        state,part := O.Run(code,data,mem,value);
        small := O.Destinations();
      case HeaderShort =>
        state,part := S.Run(code,data,mem,value);
        small := S.Destinations();
      case LengthLarge =>
        state,part := N.Run(code,data,mem,value);
        small := N.Destinations();
      case TailShort =>
        state,part := T.Run(code,data,mem,value);
        small := T.Destinations();
      case Accepted =>
        state,part := C.Run(code,data,value);
        small := C.Destinations();
    }
    E.WidenTrace(code,small,Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..];
  }
}
