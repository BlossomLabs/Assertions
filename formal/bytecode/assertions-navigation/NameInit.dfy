// SPDX-License-Identifier: MIT
include "NameTrace.dfy"
module AssertionsNavigationNameInit {
  import opened BytecodeScanMachine
  import B = AssertionsByteMachine
  import A = AssertionsSignedMachine
  import H = AssertionsNavigationNameFrame
  import Q = AssertionsNavigationFrame
  import E = AssertionsNavigationNameTrace
  predicate Matches(code: seq<Byte>) {
    12522 < |code| && code[12520] == 91 && code[12521] == 129 && code[12522] == 91
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word) returns (trace: seq<State>)
    requires Matches(code) && |prefix| <= 980
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(12520,prefix+[ret,offset,length,p,limit],mem)
    ensures trace[|trace|-1] == Running(12522,prefix+[ret,offset,length,p,limit,p],mem)
    ensures forall k {:trigger trace[k]} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
  {
    var first := Running(12520,prefix+[ret,offset,length,p,limit],mem);
    var second := Running(12521,prefix+[ret,offset,length,p,limit],mem);
    var last := Running(12522,prefix+[ret,offset,length,p,limit,p],mem);
    B.Delegate(code,destinations,first,value,data);
    A.Delegate(code,destinations,first,value,data);
    B.Delegate(code,destinations,second,value,data);
    A.Delegate(code,destinations,second,value,data);
    reveal Step();
    assert Fetch(code,12520) == Op(91,12521,0);
    assert Fetch(code,12521) == Op(129,12522,0);
    assert B.Step(code,destinations,first,value,data) == second;
    assert B.Step(code,destinations,second,value,data) == last;
    trace := [first,second,last];
    reveal H.Local(); reveal Q.Local();
    forall k {:trigger trace[k]} | 0 <= k < 2
      ensures H.Local(code,trace[k])
    { if k == 0 { assert trace[k] == first; } else { assert trace[k] == second; } }
  }
}
