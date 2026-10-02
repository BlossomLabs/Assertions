// SPDX-License-Identifier: MIT
// Complete finite compiled signed-power loop. Native verification pending.
include "Initial.generated.dfy"
include "Exit.generated.dfy"
include "Even.generated.dfy"
include "OddInvoke.generated.dfy"
include "AccumulatorReturn.generated.dfy"
include "LastHalf.generated.dfy"
include "SquareInvoke.generated.dfy"
include "SquareReturn.generated.dfy"
include "../power-signed-multiply-controls/Connection.dfy"
module OperationsPowerSignedLoopEngine {
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import K = OperationsPowerWordKernel
  import P = OperationsCheckedPowerModel
  import C = OperationsPowerSignedMultiplyConnection
  import I = OperationsPowerSignedLoopInitial
  import X = OperationsPowerSignedLoopExit
  import V = OperationsPowerSignedLoopEven
  import O = OperationsPowerSignedLoopOddInvoke
  import A = OperationsPowerSignedLoopAccumulatorReturn
  import L = OperationsPowerSignedLoopLastHalf
  import S = OperationsPowerSignedLoopSquareInvoke
  import R = OperationsPowerSignedLoopSquareReturn

  opaque predicate Matches(code:seq<Byte>) {
    I.Matches(code) && X.Matches(code) && V.Matches(code) &&
    O.Matches(code) && A.Matches(code) && L.Matches(code) &&
    S.Matches(code) && R.Matches(code) && C.Matches(code)
  }
  function Destinations():set<nat> {
    I.Destinations()+X.Destinations()+V.Destinations()+O.Destinations()+
    A.Destinations()+L.Destinations()+S.Destinations()+R.Destinations()+C.Destinations()
  }
  predicate Continuous(code:seq<Byte>,destinations:set<nat>,trace:seq<State>,
                       value:Word,size:Word,word:Word,headA:Word,headB:Word) {
    |trace|>0 && forall j:nat :: j+1<|trace| ==>
                                   trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  }
  lemma Join(code:seq<Byte>,destinations:set<nat>,left:seq<State>,right:seq<State>,
             value:Word,size:Word,word:Word,headA:Word,headB:Word)
    requires Continuous(code,destinations,left,value,size,word,headA,headB)
    requires Continuous(code,destinations,right,value,size,word,headA,headB)
    requires left[|left|-1]==right[0]
    ensures Continuous(code,destinations,left+right[1..],value,size,word,headA,headB)
    ensures (left+right[1..])[0]==left[0]
    ensures (left+right[1..])[|left+right[1..]|-1]==right[|right|-1]
  {
    forall j:nat | j+1<|left+right[1..]|
      ensures (left+right[1..])[j+1]==E.Execute(code,destinations,(left+right[1..])[j],value,size,word,headA,headB)
    {
      if j+1<|left| {}
      else if j+1==|left| { assert (left+right[1..])[j]==right[0]; }
      else { assert (left+right[1..])[j]==right[j-|left|+1]; }
    }
  }
  predicate Result(state:State,prefix:seq<Word>,outcome:P.Outcome) {
    if outcome.Panic? then state==Reverted(Panic(17))
    else state.Running? && state.pc==2984 &&
         |state.stack|==|prefix|+3 && state.stack[..|prefix|]==prefix &&
         state.stack[|state.stack|-1]==K.Encode(outcome.result) &&
         state.memory==Store([],64,128)
  }

  ghost method Loop(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                    a:Word,b:Word,c:Word,value:Word,size:Word,
                    word:Word,headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=997
    ensures Result(state,prefix,P.Trace(K.Signed(a),b,K.Signed(c)))
    ensures Continuous(code,destinations,trace,value,size,word,headA,headB)
    ensures trace[0]==Running(3250,prefix+[a,b,c],Store([],64,128)) && trace[|trace|-1]==state
    decreases b
  {
    reveal Matches();
    K.SignedEncoding(a); K.SignedEncoding(c);
    assert Signed(a)==K.Signed(a) && Signed(c)==K.Signed(c);
    if b==0 {
      state,trace:=X.Run(code,destinations,prefix,a,b,c,0,value,size,word,headA,headB);
    } else {
      var acc:=c;
      var tail:seq<State>;
      if b%2==1 {
        state,trace:=O.Run(code,destinations,prefix,a,b,c,0,value,size,word,headA,headB);
        C.MathematicalProduct(a,c);
        var product:=K.Signed(a)*K.Signed(c);
        state,tail:=C.Run(code,destinations,prefix+[a,b,c],3275,a,c,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
        if !P.Signed(product) { return; }
        acc:=SignedProduct(a,c);
        SignedResidue(product);
        assert K.Signed(acc)==product;
        state,tail:=A.Run(code,destinations,prefix,a,b,c,acc,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
      } else {
        state,trace:=V.Run(code,destinations,prefix,a,b,c,0,value,size,word,headA,headB);
      }
      assert state==Running(3278,prefix+[a,b,acc],Store([],64,128));
      assert P.Signed(K.Signed(acc));
      if b==1 {
        state,tail:=L.Run(code,destinations,prefix,a,b,acc,0,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
        state,tail:=Loop(code,destinations,prefix,a,0,acc,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
      } else {
        assert b>=2;
        state,tail:=S.Run(code,destinations,prefix,a,b,acc,0,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
        C.MathematicalProduct(a,a);
        var square:=K.Signed(a)*K.Signed(a);
        state,tail:=C.Run(code,destinations,prefix+[a,b/2,acc],3301,a,a,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
        if !P.Signed(square) { return; }
        var squared:=SignedProduct(a,a);
        SignedResidue(square);
        assert K.Signed(squared)==square;
        state,tail:=R.Run(code,destinations,prefix,a,b/2,acc,squared,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
        state,tail:=Loop(code,destinations,prefix,squared,b/2,acc,value,size,word,headA,headB);
        Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
      }
    }
  }

  ghost method Run(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                   a:Word,b:Word,value:Word,size:Word,word:Word,
                   headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=997
    ensures Result(state,prefix,P.SignedSpec(K.Signed(a),b))
    ensures Continuous(code,destinations,trace,value,size,word,headA,headB)
    ensures trace[0]==Running(3247,prefix+[a,b],Store([],64,128)) && trace[|trace|-1]==state
  {
    reveal Matches();
    state,trace:=I.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
    var tail:seq<State>;
    state,tail:=Loop(code,destinations,prefix,a,b,1,value,size,word,headA,headB);
    Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
  }
}
