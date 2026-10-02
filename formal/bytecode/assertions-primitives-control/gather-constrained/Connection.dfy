// SPDX-License-Identifier: MIT
// Fresh PC0 through exact decoder, all constrained RAW iterations, and canonical bytes[] RETURN.
include "Spec.dfy"
module AssertionsGatherConstrainedPublicConnection {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsGatherPublicSpec
  import P = AssertionsGatherPublicDispatch
  import C = AssertionsGatherPublicDecoder
  import B = AssertionsGatherConstrainedBody
  import V = AssertionsGatherConstrainedValues
  import Q = AssertionsGatherConstrainedPublicSpec
  import H = AssertionsGatherConstrainedLoopSpec
  import Z = AssertionsGatherSerializerWrapper
  import R = AssertionsGatherArrayResult
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { P.Matches(code) && C.Matches(code) && B.Matches(code) && Z.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+C.Destinations()+B.Destinations(477)+Z.Destinations() }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, relative: Word, items: seq<H.Item>, self: Word, observations: seq<A.Observation>)
    returns (frames: seq<E.Frame>, output: seq<Byte>)
    requires Matches(code) && Q.Calldata(data,relative,items)
    ensures L.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures frames[|frames|-1] == E.Frame(S.Returned(output),[],0)
    ensures V.Layout(data,items)
    ensures R.Result(output,V.Values(data,items))
  {
    Q.Caller(code,data,relative,items); D.Layout(data,relative,|items|);
    hide S.DataWord(); hide S.Window(); hide S.ShiftRight(); hide D.Calldata();
    var state,states := P.Run(code,relative,|items|,[],[],data,0);
    frames := F.Lift(code,P.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    state,states := C.Run(code,relative,|items|,[],D.Initial(),data,0);
    var part := F.Lift(code,C.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    var frame: E.Frame;
    var mem: seq<Byte>;
    frame,part,mem := B.Run(code,477,D.Args(relative),128,items,[D.Selector()],D.Initial(),data,[],0,self,0,observations);
    F.Widen(code,B.Destinations(477),Destinations(),self,0,data,observations,part);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    V.Sources(data,mem,128,Q.Start(items),Q.Base(items),items);
    frame,part,output := Z.Run(code,128,Q.Base(items),V.Values(data,items),V.Pointers(Q.Start(items),items),[D.Selector()],mem,data,[],0,self,0,observations);
    F.Widen(code,Z.Destinations(),Destinations(),self,0,data,observations,part);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
  }
}
