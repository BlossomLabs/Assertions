// SPDX-License-Identifier: MIT
// Complete successful non-tuple typeShape: arbitrary names and array suffix chains.
include "BaseHead.dfy"
include "ArrayChain.dfy"
include "development/shape-byte-return-v1/Character.dfy"
include "development/shape-limit-return-v1/Character.dfy"
module AssertionsNavigationBaseArrays {
  import opened BytecodeScanMachine
  import A = AssertionsNavigationBaseHead
  import N = AssertionsNavigationName
  import K = AssertionsNavigationNameClass
  import Q = AssertionsNavigationArrayChainSpec
  import C = AssertionsNavigationArrayChain
  import S = AssertionsNavigationArraySuffix
  import B = AssertionsNavigationShapeByteReturn
  import L = AssertionsNavigationShapeLimitReturn
  import T = AssertionsNavigationNameTrace
  import H = AssertionsNavigationFrame
  import J = AssertionsNavigationCompose
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  predicate Admitted(data: seq<Byte>,offset: Word,length: Word,p: Word,limit: Word,closings: seq<nat>,prefix: seq<Word>) {
    A.Admitted(data,offset,length,p,limit,prefix) &&
    Q.Valid(data,offset,N.End(data,offset+p,offset+limit)-offset,limit,
            K.Dynamic(data[offset+p..N.End(data,offset+p,offset+limit)]),1,closings)
  }
  predicate Matches(code: seq<Byte>) {
    A.Matches(code) && S.Matches(code) && B.Matches(code) && L.Matches(code)
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,closings: seq<nat>,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<M.Observation>) returns (nameEnd: Word,end: Word,dyn: bool,words: Word,frames: seq<E.Frame>)
    requires Admitted(data,offset,length,p,limit,closings,prefix) && Matches(code)
    requires {3175,3967,8481,8516,8747,8760,8797,8808,8825,8863,8870,8874,8882,8902,8919,8923,8955,8969,8980,8991,9005,9015,9027,9036,9047,9066,9081,9084,9105,9121,9147,9151,9184,9195,9204,12520,12522,12565,17853,17922,18062,19262,19279,19901} <= destinations
    requires ret in destinations && ret < |code| && code[ret] == 91
    ensures p < nameEnd <= end <= limit
    ensures offset+nameEnd == N.End(data,offset+p,offset+limit)
    ensures Q.Result(data,offset,nameEnd,limit,K.Dynamic(data[offset+p..offset+nameEnd]),1,closings) == Q.Shape(end,dyn,words)
    ensures 1 <= words <= 4294967295 && (dyn ==> words == 1)
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(Running(8442,prefix+[ret,offset,length,p,limit],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(Running(ret,prefix+[end,if dyn then 1 else 0,words],mem),returned,cursor)
  {
    var initialDyn: bool;
    nameEnd,initialDyn,frames := A.Run(code,destinations,ret,offset,length,p,limit,prefix,mem,data,value,self,returned,cursor,observations);
    var chain: seq<State>;
    end,dyn,words,chain := C.Run(code,destinations,ret,offset,length,p,limit,nameEnd,initialDyn,1,closings,prefix,mem,data,value);
    T.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,chain);
    var middle := H.Lift(chain,returned,cursor);
    J.Join(code,destinations,self,value,data,observations,frames,middle);
    frames := frames+middle[1..];
    var flag: Word := if dyn then 1 else 0;
    var last: seq<State>;
    if end == limit {
      assert L.Admitted(ret,offset,length,p,limit,end,flag,words,prefix,mem,data);
      last := L.Run(code,destinations,ret,offset,length,p,limit,end,flag,words,prefix,mem,data,value);
    } else {
      assert B.Admitted(ret,offset,length,p,limit,end,flag,words,prefix,mem,data);
      last := B.Run(code,destinations,ret,offset,length,p,limit,end,flag,words,prefix,mem,data,value);
    }
    T.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,last);
    var tail := H.Lift(last,returned,cursor);
    J.Join(code,destinations,self,value,data,observations,frames,tail);
    frames := frames+tail[1..];
  }
}
