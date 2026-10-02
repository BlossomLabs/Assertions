// SPDX-License-Identifier: MIT
// Successful ABI decoder composed with the RAW/no-constraints/empty-path body.
// Dispatcher admission and all other operand/path cases remain obligations.
include "NavRawBody.dfy"
include "development/decoder-v7/FrameConnection.dfy"
module AssertionsNavigationDecodedRawBody {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import H = AssertionsNavigationFrame
  import J = AssertionsNavigationCompose
  import D = AssertionsNavigationDecoder
  import DC = AssertionsNavigationDecoderFrame
  import I = AssertionsNavigationDecoderAdmission
  import A = AssertionsNavigationSetup
  import B = AssertionsNavigationPassthrough
  import R = AssertionsRawResolve
  import N = AssertionsNavigationRawBody
  lemma Boundary(prefix: seq<S.Word>,param: S.Word,typeOffset: S.Word,typeLength: S.Word,pathOffset: S.Word,pathLength: S.Word,mem: seq<S.Byte>,returned: seq<S.Byte>,cursor: nat,left: E.Frame,right: E.Frame)
    requires pathLength == 0
    requires left == E.Frame(S.Running(1054,prefix+[531649507,285,param,typeOffset,typeLength,pathOffset,pathLength],mem),returned,cursor)
    requires right == E.Frame(S.Running(1054,(prefix+[531649507])+[285,param,typeOffset,typeLength,pathOffset,0],mem),returned,cursor)
    ensures left == right
  {
    calc {
      prefix+[531649507,285,param,typeOffset,typeLength,pathOffset,pathLength];
      prefix+([531649507]+[285,param,typeOffset,typeLength,pathOffset,0]);
      (prefix+[531649507])+[285,param,typeOffset,typeLength,pathOffset,0];
    }
  }
  lemma Stitch(code: seq<S.Byte>,destinations: set<nat>,self: S.Word,value: S.Word,data: seq<S.Byte>,observations: seq<M.Observation>,prefix: seq<S.Word>,param: S.Word,typeOffset: S.Word,typeLength: S.Word,pathOffset: S.Word,pathLength: S.Word,mem: seq<S.Byte>,returned: seq<S.Byte>,cursor: nat,left: seq<E.Frame>,right: seq<E.Frame>)
    requires H.Trace(code,destinations,self,value,data,observations,left)
    requires H.Trace(code,destinations,self,value,data,observations,right)
    requires pathLength == 0
    requires left[|left|-1] == E.Frame(S.Running(1054,prefix+[531649507,285,param,typeOffset,typeLength,pathOffset,pathLength],mem),returned,cursor)
    requires right[0] == E.Frame(S.Running(1054,(prefix+[531649507])+[285,param,typeOffset,typeLength,pathOffset,0],mem),returned,cursor)
    ensures H.Trace(code,destinations,self,value,data,observations,left+right[1..])
    ensures (left+right[1..])[0] == left[0]
    ensures (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    Boundary(prefix,param,typeOffset,typeLength,pathOffset,pathLength,mem,returned,cursor,left[|left|-1],right[0]);
    J.Join(code,destinations,self,value,data,observations,left,right);
  }
  ghost method Execute(code: seq<S.Byte>,destinations: set<nat>,free: S.Word,bytesRelative: S.Word,constraintsRelative: S.Word,length: S.Word,prefix: seq<S.Word>,mem: seq<S.Byte>,returned: seq<S.Byte>,cursor: nat,self: S.Word,value: S.Word,data: seq<S.Byte>,observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires D.Matches(code) && D.Targets() <= destinations && D.Admitted(data,prefix,mem)
    requires I.PathLength(data) == 0
    requires A.Matches(code) && B.Matches(code) && R.Matches(code,1081)
    requires A.Admitted(free,285,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),prefix+[531649507],mem)
    requires R.Admitted(1081,I.Param(data),free,0,0,bytesRelative,constraintsRelative,length,free+32,prefix+[531649507,285,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),0,0],A.Prepared(mem,free),data)
    requires 3393 in destinations && R.Destinations(1081) <= destinations
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(344,prefix+[531649507],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Returned(data[R.PayloadOffset(I.Param(data),bytesRelative)..R.PayloadOffset(I.Param(data),bytesRelative)+length]),returned,cursor)
  {
    var first := DC.Execute(code,destinations,data,prefix,mem,returned,cursor,self,value,observations);
    var body := N.Execute(code,destinations,free,285,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),bytesRelative,constraintsRelative,length,prefix+[531649507],mem,returned,cursor,self,value,data,observations);
    Stitch(code,destinations,self,value,data,observations,prefix,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),I.PathLength(data),mem,returned,cursor,first,body);
    frames := first+body[1..];
  }
}
