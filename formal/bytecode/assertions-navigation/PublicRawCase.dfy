// SPDX-License-Identifier: MIT
// Public physical nav execution for RAW bytes, no constraints, and an empty path.
// Other accepted/rejected nav classes remain open; this is not whole-entry coverage.
include "DecodedRawBody.dfy"
include "RawCaseAdmission.dfy"
include "development/dispatch-v5/Connection.dfy"
module AssertionsNavigationPublicRawCase {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import H = AssertionsNavigationFrame
  import J = AssertionsNavigationCompose
  import P = AssertionsNavigationDispatch
  import PC = AssertionsNavigationDispatchFrame
  import D = AssertionsNavigationDecoder
  import I = AssertionsNavigationDecoderAdmission
  import A = AssertionsNavigationSetup
  import B = AssertionsNavigationPassthrough
  import R = AssertionsRawResolve
  import N = AssertionsNavigationDecodedRawBody
  import C = AssertionsNavigationRawCaseAdmission
  lemma Stitch(code: seq<S.Byte>,destinations: set<nat>,self: S.Word,value: S.Word,data: seq<S.Byte>,observations: seq<M.Observation>,left: seq<E.Frame>,right: seq<E.Frame>)
    requires H.Trace(code,destinations,self,value,data,observations,left)
    requires H.Trace(code,destinations,self,value,data,observations,right)
    requires left[|left|-1] == E.Frame(S.Running(344,[531649507],P.Prepared()),[],0)
    requires right[0] == E.Frame(S.Running(344,[]+[531649507],P.Prepared()),[],0)
    ensures H.Trace(code,destinations,self,value,data,observations,left+right[1..])
    ensures (left+right[1..])[0] == left[0]
    ensures (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    assert []+[531649507] == [531649507];
    J.Join(code,destinations,self,value,data,observations,left,right);
  }
  ghost method Execute(code: seq<S.Byte>,destinations: set<nat>,bytesRelative: S.Word,constraintsRelative: S.Word,length: S.Word,self: S.Word,value: S.Word,data: seq<S.Byte>,observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires P.Matches(code) && P.Targets() <= destinations && P.Admitted(data,value)
    requires D.Matches(code) && D.Targets() <= destinations && D.Admitted(data,[],P.Prepared())
    requires I.PathLength(data) == 0
    requires A.Matches(code) && B.Matches(code) && R.Matches(code,1081)
    requires A.Admitted(128,285,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),[531649507],P.Prepared())
    requires R.Admitted(1081,I.Param(data),128,0,0,bytesRelative,constraintsRelative,length,160,[531649507,285,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),0,0],A.Prepared(P.Prepared(),128),data)
    requires 3393 in destinations && R.Destinations(1081) <= destinations
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures frames[|frames|-1] == E.Frame(S.Returned(data[R.PayloadOffset(I.Param(data),bytesRelative)..R.PayloadOffset(I.Param(data),bytesRelative)+length]),[],0)
  {
    var first := PC.Execute(code,destinations,data,[],0,self,value,observations);
    var body := N.Execute(code,destinations,128,bytesRelative,constraintsRelative,length,[],P.Prepared(),[],0,self,value,data,observations);
    Stitch(code,destinations,self,value,data,observations,first,body);
    frames := first+body[1..];
  }
  ghost method AdmittedExecute(code: seq<S.Byte>,destinations: set<nat>,bytesRelative: S.Word,constraintsRelative: S.Word,length: S.Word,self: S.Word,value: S.Word,data: seq<S.Byte>,observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires C.Calldata(data,value,bytesRelative,constraintsRelative,length)
    requires P.Matches(code) && P.Targets() <= destinations
    requires D.Matches(code) && D.Targets() <= destinations
    requires A.Matches(code) && B.Matches(code) && R.Matches(code,1081)
    requires 3393 in destinations && R.Destinations(1081) <= destinations
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures frames[|frames|-1] == E.Frame(S.Returned(data[R.PayloadOffset(I.Param(data),bytesRelative)..R.PayloadOffset(I.Param(data),bytesRelative)+length]),[],0)
  {
    C.Caller(data,value,bytesRelative,constraintsRelative,length);
    frames := Execute(code,destinations,bytesRelative,constraintsRelative,length,self,value,data,observations);
  }

}
