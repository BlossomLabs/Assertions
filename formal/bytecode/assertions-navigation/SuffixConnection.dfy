// SPDX-License-Identifier: MIT
// Full external-machine frame for the arbitrary-length successful suffix scanner.
include "SuffixLoop.dfy"
module AssertionsNavigationSuffixConnection {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import H = AssertionsNavigationFrame
  import L = AssertionsNavigationSuffixLoop
  import A = AssertionsNavigationSuffixInit
  import D = AssertionsNavigationSuffixDigit
  import X = AssertionsNavigationSuffixExit
  ghost method Run(code: seq<S.Byte>,destinations: set<nat>,ret: S.Word,offset: S.Word,length: S.Word,ts: S.Word,te: S.Word,opening: S.Word,prefix: seq<S.Word>,mem: seq<S.Byte>,data: seq<S.Byte>,value: S.Word,self: S.Word,returned: seq<S.Byte>,cursor: nat,observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires L.Admitted(data,offset,length,ts,te,opening,prefix)
    requires A.Matches(code) && D.Matches(code) && X.Matches(code)
    requires {3175,8231,17922,8234,8267,8290,8320,8343,8358,8366,19880,19894,8384,3967} <= destinations
    requires ret in destinations && ret < |code| && code[ret] == 91
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(8219,prefix+[ret,offset,length,ts,te],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Running(ret,prefix+[opening],mem),returned,cursor)
  {
    var state,trace := L.Run(code,destinations,ret,offset,length,ts,te,opening,prefix,mem,data,value);
    H.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,trace);
    frames := H.Lift(trace,returned,cursor);
  }
}
