// SPDX-License-Identifier: MIT
// Exact PC-zero two-input decoder boundary.
include "Admission.dfy"
include "../prefix-pack/Prefix.generated.dfy"
module BytecodeCollectionsPackRawBoundary {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import A = BytecodeCollectionsPackRawAdmission
  import P = BytecodeCollectionsPackPrefix
  import C = BytecodeCollectionsPackDecoder
  import R0 = BytecodeCollectionsPackRawHeadShort
  import R1 = BytecodeCollectionsPackRawFirstOffsetLarge
  import R2 = BytecodeCollectionsPackRawFirstHeaderShort
  import R3 = BytecodeCollectionsPackRawFirstLengthLarge
  import R4 = BytecodeCollectionsPackRawFirstTailShort
  import R5 = BytecodeCollectionsPackRawSecondOffsetLarge
  import R6 = BytecodeCollectionsPackRawSecondHeaderShort
  import R7 = BytecodeCollectionsPackRawSecondLengthLarge
  import R8 = BytecodeCollectionsPackRawSecondTailShort
  predicate Matches(code: seq<Byte>) { P.Matches(code) && C.Matches(code) && R0.Matches(code) && R1.Matches(code) && R2.Matches(code) && R3.Matches(code) && R4.Matches(code) && R5.Matches(code) && R6.Matches(code) && R7.Matches(code) && R8.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+C.Destinations()+R0.Destinations()+R1.Destinations()+R2.Destinations()+R3.Destinations()+R4.Destinations()+R5.Destinations()+R6.Destinations()+R7.Destinations()+R8.Destinations() }
  function Expected(data: seq<Byte>): State {
    if A.Classify(data) == A.Accepted then Running(5682,[2625112747,518,C.OffsetA(data),C.LengthA(data),C.OffsetB(data),C.LengthB(data)],Store([],64,128)) else Reverted([])
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
        state,part := R0.Run(code,data,mem,value);
        small := R0.Destinations();
      case FirstOffsetLarge =>
        state,part := R1.Run(code,data,mem,value);
        small := R1.Destinations();
      case FirstHeaderShort =>
        state,part := R2.Run(code,data,mem,value);
        small := R2.Destinations();
      case FirstLengthLarge =>
        state,part := R3.Run(code,data,mem,value);
        small := R3.Destinations();
      case FirstTailShort =>
        state,part := R4.Run(code,data,mem,value);
        small := R4.Destinations();
      case SecondOffsetLarge =>
        state,part := R5.Run(code,data,mem,value);
        small := R5.Destinations();
      case SecondHeaderShort =>
        state,part := R6.Run(code,data,mem,value);
        small := R6.Destinations();
      case SecondLengthLarge =>
        state,part := R7.Run(code,data,mem,value);
        small := R7.Destinations();
      case SecondTailShort =>
        state,part := R8.Run(code,data,mem,value);
        small := R8.Destinations();
      case Accepted =>
        state,part := C.Run(code,data,mem,value);
        small := C.Destinations();
    }
    E.WidenTrace(code,small,Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..];
  }
}
