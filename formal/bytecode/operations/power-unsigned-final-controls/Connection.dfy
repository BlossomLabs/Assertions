// SPDX-License-Identifier: MIT
// Complete final product and caller cleanup candidate; native checks pending.
include "Fit.generated.dfy"
include "Overflow.generated.dfy"
module OperationsPowerUnsignedFinalConnection {
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import F = OperationsPowerUnsignedFinalFit
  import O = OperationsPowerUnsignedFinalOverflow
  opaque predicate Matches(code:seq<Byte>) { F.Matches(code) && O.Matches(code) }
  function Destinations():set<nat> { F.Destinations()+O.Destinations() }
  ghost method Run(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                   a:Word,b:Word,acc:Word,original:Word,value:Word,size:Word,
                   word:Word,headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=997
    requires a>=2 && 1<=acc<a
    ensures acc*a<Modulus() ==> state==Running(1329,prefix+[(acc*a) as Word],Store([],64,128))
    ensures acc*a>=Modulus() ==> state==Reverted(Panic(17))
    ensures |trace|>0 && trace[0]==Running(21132,prefix+[1329,original,b,0,3085,b,original,0,3085,b,original,0,acc,a],Store([],64,128)) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==>
                              trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  {
    reveal Matches();
    if acc*a<Modulus() {
      ProductSymmetric(a,acc);
      assert Product(a,acc)==acc*a;
      state,trace:=F.Run(code,destinations,prefix,a,b,acc,original,value,size,word,headA,headB);
    } else {
      state,trace:=O.Run(code,destinations,prefix,a,b,acc,original,value,size,word,headA,headB);
    }
  }
}
