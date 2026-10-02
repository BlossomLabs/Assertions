// SPDX-License-Identifier: MIT
// Complete physical typeShape base-name head, before the array-suffix loop.
include "BaseName.dfy"
include "Compose.dfy"
include "development/base-five-v2/Character.dfy"
include "development/base-six-v2/Character.dfy"
include "development/base-other-v1/Character.dfy"
module AssertionsNavigationBaseHead {
  import opened BytecodeScanMachine
  import A = AssertionsNavigationBaseName
  import N = AssertionsNavigationName
  import K = AssertionsNavigationNameClass
  import F = AssertionsNavigationBaseFive
  import G = AssertionsNavigationBaseSix
  import O = AssertionsNavigationBaseOther
  import T = AssertionsNavigationNameTrace
  import H = AssertionsNavigationFrame
  import J = AssertionsNavigationCompose
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  predicate Admitted(data: seq<Byte>,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>) {
    A.Admitted(data,offset,length,p,limit,prefix) && |prefix| <= 950
  }
  predicate Matches(code: seq<Byte>) {
    A.Matches(code) && F.Matches(code) && G.Matches(code) && O.Matches(code)
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<M.Observation>) returns (q: Word,dyn: bool,frames: seq<E.Frame>)
    requires Admitted(data,offset,length,p,limit,prefix) && Matches(code)
    requires {3175,3967,8481,8516,8747,8760,8797,8808,8825,8863,8870,8874,8902,9204,12520,12522,12565,17922} <= destinations
    requires ret in destinations && ret < |code| && code[ret] == 91
    ensures p < q <= limit
    ensures offset+q == N.End(data,offset+p,offset+limit)
    ensures dyn == K.Dynamic(data[offset+p..offset+q])
    ensures H.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(Running(8442,prefix+[ret,offset,length,p,limit],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(Running(8882,prefix+[ret,offset,length,p,limit,q,if dyn then 1 else 0,1],mem),returned,cursor)
  {
    var first: seq<E.Frame>;
    q,first := A.Run(code,destinations,ret,offset,length,p,limit,prefix,mem,data,value,self,returned,cursor,observations);
    dyn := K.Dynamic(data[offset+p..offset+q]);
    var flag: Word := if dyn then 1 else 0;
    var middle: seq<State>;
    if q-p == 5 {
      assert F.Admitted(ret,offset,length,p,limit,q,prefix,mem,data);
      middle := F.Run(code,destinations,ret,offset,length,p,limit,q,prefix,mem,data,value);
    } else if q-p == 6 {
      assert G.Admitted(ret,offset,length,p,limit,q,prefix,mem,data);
      middle := G.Run(code,destinations,ret,offset,length,p,limit,q,prefix,mem,data,value);
    } else {
      assert O.Admitted(ret,offset,length,p,limit,q,prefix,mem,data);
      middle := O.Run(code,destinations,ret,offset,length,p,limit,q,prefix,mem,data,value);
      K.Other(data[offset+p..offset+q]);
    }
    assert middle[0] == Running(8760,prefix+[ret,offset,length,p,limit,0,0,0,0,q],mem);
    assert middle[|middle|-1] == Running(8882,prefix+[ret,offset,length,p,limit,q,flag,1],mem);
    T.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,middle);
    var body := H.Lift(middle,returned,cursor);
    J.Join(code,destinations,self,value,data,observations,first,body);
    frames := first+body[1..];
  }
}
