// SPDX-License-Identifier: MIT
// Actual typeShape entry through bounds/ASCII guards and arbitrary name scanning.
include "development/base-prefix-v1/Character.dfy"
include "NameConnection.dfy"
module AssertionsNavigationBaseName {
  import opened BytecodeScanMachine
  import P = AssertionsNavigationBasePrefix
  import N = AssertionsNavigationName
  import L = AssertionsNavigationNameLoop
  import I = AssertionsNavigationNameInit
  import C = AssertionsNavigationNameCharacter
  import X = AssertionsNavigationNameExit
  import B = AssertionsNavigationNameLimit
  import T = AssertionsNavigationNameTrace
  import H = AssertionsNavigationNameFrame
  import Q = AssertionsNavigationFrame
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  predicate Admitted(data: seq<Byte>,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>) {
    p < limit <= length && (offset as nat)+length <= |data| < 0x10000000000000000 &&
    |prefix| <= 960 && N.Character(data[offset+p])
  }
  predicate Matches(code: seq<Byte>) {
    P.Matches(code) && I.Matches(code) && C.Matches(code) && X.Matches(code) && B.Matches(code) &&
    8760 < |code| && code[8760] == 91
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<M.Observation>) returns (q: Word,frames: seq<E.Frame>)
    requires Admitted(data,offset,length,p,limit,prefix) && Matches(code)
    requires {8481,8516,8747,12520,3967,12522,12565,8760} <= destinations
    ensures p < q <= limit
    ensures offset+q == N.End(data,offset+p,offset+limit)
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(Running(8442,prefix+[ret,offset,length,p,limit],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(Running(8760,prefix+[ret,offset,length,p,limit,0,0,0,0,q],mem),returned,cursor)
  {
    assert P.Admitted(ret,offset,length,p,limit,p,prefix,mem,data);
    var first := P.Run(code,destinations,ret,offset,length,p,limit,p,prefix,mem,data,value);
    var extended := prefix+[ret,offset,length,p,limit,0,0,0,0];
    assert L.Admitted(data,offset,length,p,limit,extended);
    var second: seq<State>;
    q,second := L.Run(code,destinations,8760,offset,length,p,limit,extended,mem,data,value);
    assert first[|first|-1] == second[0];
    T.Join(code,destinations,value,data,first,second);
    L.JoinLocal(first,second,code);
    var states := first+second[1..];
    assert N.End(data,offset+p,offset+limit) > offset+p;
    T.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,states);
    frames := Q.Lift(states,returned,cursor);
  }
}
