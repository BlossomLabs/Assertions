// SPDX-License-Identifier: MIT
// Fresh PC0 through exact decoder, condition and selected RAW operand or short-condition rejection.
include "Admission.dfy"
module AssertionsCondConstrainedPublicConnection {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsCondPublicSpec
  import Q = AssertionsCondConstrainedAdmission
  import R = AssertionsCondConstrainedSpec
  import P = AssertionsCondPublicDispatch
  import N = AssertionsCondPublicDecoder
  import C = AssertionsCondConstrainedBody
  import W = AssertionsCondFirstWord
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { P.Matches(code) && N.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+N.Destinations()+C.Destinations(285) }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, conditionRelative: Word, thenRelative: Word, elseRelative: Word, condition: R.Operand, selected: R.Operand, self: Word, observations: seq<A.Observation>) returns (frames: seq<E.Frame>, output: seq<Byte>)
    requires Matches(code) && Q.Calldata(data,conditionRelative,thenRelative,elseRelative,condition,selected)
    ensures L.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures if condition.length < 32 then frames[|frames|-1] == E.Frame(S.Reverted(output),[],0) && output == W.Error(condition.length)
            else R.Span(data,selected) && frames[|frames|-1] == E.Frame(S.Returned(output),[],0) && output == R.Payload(data,selected)
  {
    Q.Caller(data,conditionRelative,thenRelative,elseRelative,condition,selected);
    D.Pointers(data,conditionRelative,thenRelative,elseRelative);
    hide S.DataWord(); hide S.Window(); hide S.ShiftRight();
    var state,states := P.Run(code,conditionRelative,thenRelative,elseRelative,[],[],data,0);
    frames := F.Lift(code,P.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    state,states := N.Run(code,conditionRelative,thenRelative,elseRelative,[],D.Initial(),data,0);
    var part := F.Lift(code,N.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    var frame: E.Frame;
    frame,part := C.Run(code,285,condition,4+thenRelative,4+elseRelative,selected,128,
                        [D.Selector()],D.Initial(),data,[],0,self,0,observations);
    F.Widen(code,C.Destinations(285),Destinations(),self,0,data,observations,part);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    if condition.length < 32 { output := W.Error(condition.length); }
    else { output := R.Payload(data,selected); }
  }
}
