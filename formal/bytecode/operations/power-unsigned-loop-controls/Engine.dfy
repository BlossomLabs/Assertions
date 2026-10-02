// SPDX-License-Identifier: MIT
// Exact generic loop connection candidate. Native verification pending.
include "Initial.generated.dfy"
include "Exit.generated.dfy"
include "Even.generated.dfy"
include "Odd.generated.dfy"
include "Overflow.generated.dfy"
module OperationsPowerUnsignedLoopEngine {
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import P = OperationsCheckedPowerModel
  import K = OperationsPowerWordKernel
  import F = OperationsPowerUnsignedLoopKernel
  import I = OperationsPowerUnsignedLoopInitial
  import X = OperationsPowerUnsignedLoopExit
  import V = OperationsPowerUnsignedLoopEven
  import O = OperationsPowerUnsignedLoopOdd
  import B = OperationsPowerUnsignedLoopOverflow
  opaque predicate Matches(code:seq<Byte>) {
    I.Matches(code) && X.Matches(code) && V.Matches(code) && O.Matches(code) && B.Matches(code)
  }
  function Destinations():set<nat> {
    I.Destinations()+X.Destinations()+V.Destinations()+O.Destinations()+B.Destinations()
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
  predicate Pair(state:State,prefix:seq<Word>,ideal:int) {
    state.Running? && state.pc==21132 &&
    |state.stack|==|prefix|+2 && state.stack[..|prefix|]==prefix &&
    1<=state.stack[|prefix|]<state.stack[|prefix|+1] &&
    state.stack[|prefix|]*state.stack[|prefix|+1]==ideal &&
    state.memory==Store([],64,128)
  }
  ghost method Loop(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                    a:Word,b:Word,acc:Word,original:Word,value:Word,size:Word,
                    word:Word,headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=997
    requires a>=2 && b>0 && 1<=acc<a
    ensures state==Reverted(Panic(17)) || Pair(state,prefix,acc*P.Power(a,b))
    ensures state.Reverted? ==> acc*P.Power(a,b)>=Modulus()
    ensures Continuous(code,destinations,trace,value,size,word,headA,headB)
    ensures trace[0]==Running(20936,prefix+[21132,Modulus()-1,b,original,acc,a],Store([],64,128)) && trace[|trace|-1]==state
    decreases b
  {
    reveal Matches();
    if b==1 {
      state,trace:=X.Run(code,destinations,prefix,a,b,acc,original,value,size,word,headA,headB);
    } else if a*a>=Modulus() {
      K.PowerMonotoneExponent(a,2,b);
      assert acc*P.Power(a,b)>=a*a;
      state,trace:=B.Run(code,destinations,prefix,a,b,acc,original,value,size,word,headA,headB);
    } else {
      F.WordProducts(a,acc);
      var next:Word:=if b%2==1 then acc*a else acc;
      var square:Word:=a*a;
      if b%2==1 {
        state,trace:=O.Run(code,destinations,prefix,a,b,acc,original,value,size,word,headA,headB);
      } else {
        state,trace:=V.Run(code,destinations,prefix,a,b,acc,original,value,size,word,headA,headB);
      }
      P.PowerBinary(a,b);
      assert acc*P.Power(a,b)==next*P.Power(square,b/2);
      var tail:seq<State>;
      state,tail:=Loop(code,destinations,prefix,square,b/2,next,original,value,size,word,headA,headB);
      Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
    }
  }
  ghost method Run(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                   a:Word,b:Word,value:Word,size:Word,word:Word,
                   headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=997
    requires a>=2 && b>0
    ensures state==Reverted(Panic(17)) || Pair(state,prefix,P.Power(a,b))
    ensures state.Reverted? ==> P.Unsigned(a,b)==P.Panic(17)
    ensures Continuous(code,destinations,trace,value,size,word,headA,headB)
    ensures trace[0]==Running(20932,prefix+[21132,Modulus()-1,b,a],Store([],64,128)) && trace[|trace|-1]==state
  {
    reveal Matches();
    state,trace:=I.Run(code,destinations,prefix,a,b,0,a,value,size,word,headA,headB);
    var tail:seq<State>;
    state,tail:=Loop(code,destinations,prefix,a,b,1,a,value,size,word,headA,headB);
    Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
  }
}
