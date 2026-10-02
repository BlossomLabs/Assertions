// SPDX-License-Identifier: MIT
// Fresh PC0 public pick, arbitrary signed index and RAW payload success/rejection.
include "Admission.dfy"
module AssertionsPickRawPublicConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsPickPublicSpec
  import Q = AssertionsPickRawAdmission
  import R = AssertionsCondRawSpec
  import P = AssertionsPickPublicDispatch
  import N = AssertionsPickPublicDecoder
  import B = AssertionsPickRawBody
  import W = AssertionsPickWord
  import X = AssertionsPrimitiveScalar
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { P.Matches(code) && N.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+N.Destinations()+B.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,relative: Word,index: Word,operand: R.Operand,self: Word,observations: seq<A.Observation>) returns (frames: seq<E.Frame>,output: seq<Byte>)
    requires Matches(code) && Q.Calldata(data,relative,index,operand)
    ensures L.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures R.Span(data,operand)
    ensures if X.Inside(operand.length,index) then output == G.Encode(B.WantedWord(data,operand,index),32) && frames[|frames|-1] == E.Frame(S.Returned(output),[],0)
            else output == W.Error(index,operand.length) && frames[|frames|-1] == E.Frame(S.Reverted(output),[],0)
  {
    Q.Caller(data,relative,index,operand); D.Pointers(data,relative,index);
    hide S.DataWord(); hide S.Window(); hide S.ShiftRight();
    var state,states := P.Run(code,relative,index,[],[],data,0);
    frames := F.Lift(code,P.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    state,states := N.Run(code,relative,index,[],D.Initial(),data,0);
    var part := F.Lift(code,N.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    var frame: E.Frame;
    frame,part := B.Run(code,operand,index,128,[D.Selector()],D.Initial(),data,[],0,self,0,observations);
    F.Widen(code,B.Destinations(),Destinations(),self,0,data,observations,part);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    output := if X.Inside(operand.length,index) then G.Encode(B.WantedWord(data,operand,index),32) else W.Error(index,operand.length);
  }
}
