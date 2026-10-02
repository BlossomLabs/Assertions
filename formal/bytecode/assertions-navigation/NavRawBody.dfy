// SPDX-License-Identifier: MIT
// Full body connection for the raw operand / no constraints / empty path case.
// Public ABI decoder and the other nav cases remain separate obligations.
include "Compose.dfy"
include "development/setup-v1/Connection.dfy"
include "development/passthrough-v3/Connection.dfy"
include "../assertions-resolution/raw/Connection.dfy"
module AssertionsNavigationRawBody {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import H = AssertionsNavigationFrame
  import J = AssertionsNavigationCompose
  import A = AssertionsNavigationSetup
  import AC = AssertionsNavigationSetupConnection
  import B = AssertionsNavigationPassthrough
  import BC = AssertionsNavigationPassthroughConnection
  import R = AssertionsRawResolve
  import RC = AssertionsRawResolveConnection
  import RM = AssertionsRawResolveMemory
  import RH = AssertionsRawResolveFrame
  lemma Boundary(prefix: seq<S.Word>,ret: S.Word,param: S.Word,typeOffset: S.Word,typeLength: S.Word,pathOffset: S.Word,free: S.Word,mem: seq<S.Byte>,returned: seq<S.Byte>,cursor: nat,left: E.Frame,right: E.Frame)
    requires left == E.Frame(S.Running(3393,prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0,1081,param,free,0,0],mem),returned,cursor)
    requires right == E.Frame(S.Running(3393,(prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0])+[1081,param,free,0,0],mem),returned,cursor)
    ensures left == right
  {
    calc {
      prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0,1081,param,free,0,0];
      prefix+([ret,param,typeOffset,typeLength,pathOffset,0,0]+[1081,param,free,0,0]);
      (prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0])+[1081,param,free,0,0];
    }
  }
  lemma Stitch(code: seq<S.Byte>,destinations: set<nat>,self: S.Word,value: S.Word,data: seq<S.Byte>,observations: seq<M.Observation>,prefix: seq<S.Word>,ret: S.Word,param: S.Word,typeOffset: S.Word,typeLength: S.Word,pathOffset: S.Word,free: S.Word,mem: seq<S.Byte>,returned: seq<S.Byte>,cursor: nat,left: seq<E.Frame>,right: seq<E.Frame>)
    requires H.Trace(code,destinations,self,value,data,observations,left)
    requires H.Trace(code,destinations,self,value,data,observations,right)
    requires left[|left|-1] == E.Frame(S.Running(3393,prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0,1081,param,free,0,0],mem),returned,cursor)
    requires right[0] == E.Frame(S.Running(3393,(prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0])+[1081,param,free,0,0],mem),returned,cursor)
    ensures H.Trace(code,destinations,self,value,data,observations,left+right[1..])
    ensures (left+right[1..])[0] == left[0]
    ensures (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    Boundary(prefix,ret,param,typeOffset,typeLength,pathOffset,free,mem,returned,cursor,left[|left|-1],right[0]);
    J.Join(code,destinations,self,value,data,observations,left,right);
  }
  ghost method Execute(code: seq<S.Byte>,destinations: set<nat>,free: S.Word,ret: S.Word,param: S.Word,typeOffset: S.Word,typeLength: S.Word,pathOffset: S.Word,bytesRelative: S.Word,constraintsRelative: S.Word,length: S.Word,prefix: seq<S.Word>,mem: seq<S.Byte>,returned: seq<S.Byte>,cursor: nat,self: S.Word,value: S.Word,data: seq<S.Byte>,observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires A.Matches(code) && B.Matches(code) && R.Matches(code,1081)
    requires A.Admitted(free,ret,param,typeOffset,typeLength,pathOffset,prefix,mem)
    requires R.Admitted(1081,param,free,0,0,bytesRelative,constraintsRelative,length,free+32,prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0],A.Prepared(mem,free),data)
    requires 3393 in destinations && R.Destinations(1081) <= destinations
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(1054,prefix+[ret,param,typeOffset,typeLength,pathOffset,0],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Returned(data[R.PayloadOffset(param,bytesRelative)..R.PayloadOffset(param,bytesRelative)+length]),returned,cursor)
  {
    var first := AC.Execute(code,destinations,free,ret,param,typeOffset,typeLength,pathOffset,prefix,mem,returned,cursor,self,value,data,observations);
    var middleState,middle := RC.Run(code,destinations,1081,param,free,0,0,bytesRelative,constraintsRelative,length,free+32,prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0],A.Prepared(mem,free),data,returned,cursor,self,value,observations);
    var built := RM.Construct(A.Prepared(mem,free),free+32,R.PayloadOffset(param,bytesRelative),length,data);
    RM.Built(A.Prepared(mem,free),free+32,R.PayloadOffset(param,bytesRelative),length,data);
    assert |built| < G.Modulus();
    assert B.Admitted(free+32,length,ret,param,typeOffset,typeLength,pathOffset,prefix,built);
    var last := BC.Execute(code,destinations,free+32,length,ret,param,typeOffset,typeLength,pathOffset,prefix,built,returned,cursor,self,value,data,observations);
    assert H.Trace(code,destinations,self,value,data,observations,middle) by { reveal H.Trace(); reveal RH.Trace(); }
    Stitch(code,destinations,self,value,data,observations,prefix,ret,param,typeOffset,typeLength,pathOffset,free,A.Prepared(mem,free),returned,cursor,first,middle);
    var earlier := first+middle[1..];
    J.Join(code,destinations,self,value,data,observations,earlier,last);
    frames := earlier+last[1..];
  }
}
