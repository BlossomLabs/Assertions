// SPDX-License-Identifier: MIT
include "Frame.dfy"
module AssertionsNavigationCompose {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import H = AssertionsNavigationFrame
  lemma Join(code: seq<S.Byte>,destinations: set<nat>,self: S.Word,value: S.Word,
             data: seq<S.Byte>,observations: seq<M.Observation>,left: seq<E.Frame>,right: seq<E.Frame>)
    requires H.Trace(code,destinations,self,value,data,observations,left)
    requires H.Trace(code,destinations,self,value,data,observations,right)
    requires left[|left|-1] == right[0]
    ensures H.Trace(code,destinations,self,value,data,observations,left+right[1..])
    ensures (left+right[1..])[0] == left[0]
    ensures (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    var joined := left+right[1..];
    forall i {:trigger joined[i]} | 0 <= i < |joined|-1
      ensures M.Step(code,destinations,joined[i],self,value,data,observations) == joined[i+1] && joined[i+1].state != S.Bad
    {
      if i < |left|-1 {
        assert joined[i] == left[i] && joined[i+1] == left[i+1];
      } else {
        var j := i-(|left|-1);
        assert 0 <= j < |right|-1;
        assert joined[i] == right[j] && joined[i+1] == right[j+1];
      }
    }
    if |right| == 1 { assert right[0] == left[|left|-1]; }
  }
}
