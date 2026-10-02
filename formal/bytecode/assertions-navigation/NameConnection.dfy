// SPDX-License-Identifier: MIT
// Descriptor-name scanner retains the external observation cursor and returndata.
include "NameLoop.dfy"
module AssertionsNavigationNameConnection {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import H = AssertionsNavigationFrame
  import T = AssertionsNavigationNameTrace
  import N = AssertionsNavigationName
  import L = AssertionsNavigationNameLoop
  import I = AssertionsNavigationNameInit
  import C = AssertionsNavigationNameCharacter
  import X = AssertionsNavigationNameExit
  import B = AssertionsNavigationNameLimit
  ghost method Run(code: seq<S.Byte>,destinations: set<nat>,ret: S.Word,offset: S.Word,length: S.Word,p: S.Word,limit: S.Word,prefix: seq<S.Word>,mem: seq<S.Byte>,data: seq<S.Byte>,value: S.Word,self: S.Word,returned: seq<S.Byte>,cursor: nat,observations: seq<M.Observation>) returns (q: S.Word,frames: seq<E.Frame>)
    requires L.Admitted(data,offset,length,p,limit,prefix)
    requires I.Matches(code) && C.Matches(code) && X.Matches(code) && B.Matches(code)
    requires {3967,12522,12565} <= destinations
    requires ret in destinations && ret < |code| && code[ret] == 91
    ensures p <= q <= limit
    ensures offset+q == N.End(data,offset+p,offset+limit)
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(12520,prefix+[ret,offset,length,p,limit],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Running(ret,prefix+[q],mem),returned,cursor)
  {
    var states: seq<S.State>;
    q,states := L.Run(code,destinations,ret,offset,length,p,limit,prefix,mem,data,value);
    T.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,states);
    frames := H.Lift(states,returned,cursor);
  }
}
