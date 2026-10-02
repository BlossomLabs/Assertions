// SPDX-License-Identifier: MIT
// Fitting raw sortWords boundary: exact dispatcher and complete decoder classification.
include "Admission.dfy"
include "../decoder/Decoder.generated.dfy"
include "../prefix/Prefix.generated.dfy"
module BytecodeSortRawBoundary {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import A = BytecodeSortRawAdmission
  import P = BytecodeWordSortPrefix
  import C = BytecodeWordSortDecoder
  import H = BytecodeSortRawHeadShort
  import O = BytecodeSortRawOffsetLarge
  import S = BytecodeSortRawHeaderShort
  import N = BytecodeSortRawLengthLarge
  import T = BytecodeSortRawTailShort
  predicate Matches(code: seq<Byte>) {
    P.Matches(code) && C.Matches(code) && H.Matches(code) && O.Matches(code) &&
    S.Matches(code) && N.Matches(code) && T.Matches(code)
  }
  function Destinations(): set<nat> {
    P.Destinations()+C.Destinations()+H.Destinations()+O.Destinations()+
    S.Destinations()+N.Destinations()+T.Destinations()
  }
  function Expected(data: seq<Byte>): State {
    if A.Classify(data) == A.Accepted then Running(3422,[785862473,518,C.Offset(data),C.Length(data)],Store([],64,128)) else Reverted([])
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
        state,part := C.Run(code,data,mem,value);
        small := C.Destinations();
    }
    E.WidenTrace(code,small,Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..];
  }
}
