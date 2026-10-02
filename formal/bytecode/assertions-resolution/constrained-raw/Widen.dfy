// SPDX-License-Identifier: MIT
// An accepted physical frame trace is unchanged by adding certified jump targets.
include "../raw/Frame.dfy"
module AssertionsConstrainedRawWiden {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import A = AssertionsSignedMachine
  import B = AssertionsByteMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import Q = AssertionsRawResolveFrame
  type Word = S.Word
  type Byte = S.Byte
  lemma Step(code: seq<Byte>, small: set<nat>, large: set<nat>, frame: E.Frame,
             self: Word, value: Word, data: seq<Byte>, observations: seq<M.Observation>)
    requires small <= large && M.Step(code,small,frame,self,value,data,observations).state != S.Bad
    ensures M.Step(code,small,frame,self,value,data,observations) == M.Step(code,large,frame,self,value,data,observations)
  {
    reveal M.Step(); reveal E.Step(); reveal B.Step(); reveal A.Step(); reveal C.Step(); reveal S.Step(); reveal G.Step();
  }
  lemma Trace(code: seq<Byte>, small: set<nat>, large: set<nat>, self: Word, value: Word,
              data: seq<Byte>, observations: seq<M.Observation>, frames: seq<E.Frame>)
    requires small <= large && Q.Trace(code,small,self,value,data,observations,frames)
    ensures Q.Trace(code,large,self,value,data,observations,frames)
  {
    forall i {:trigger frames[i]} | 0 <= i < |frames|-1
      ensures M.Step(code,large,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
    { Step(code,small,large,frames[i],self,value,data,observations); }
  }
}
