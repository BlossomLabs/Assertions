// SPDX-License-Identifier: MIT
// Complete helper partition, not a public entry or whole-loop proof.
include "Fit.generated.dfy"
include "Overflow.generated.dfy"
include "Minimum.generated.dfy"
module OperationsPowerSignedMultiplyConnection {
  import opened OperationsSignedMultiplyMachine
  import Fit = OperationsPowerSignedMultiplyFit
  import Overflow = OperationsPowerSignedMultiplyOverflow
  import Minimum = OperationsPowerSignedMultiplyMinimum
  import P = OperationsCheckedPowerModel
  import K = OperationsPowerWordKernel
  import E = OperationsPowerExecution

  predicate Fitting(a:Word,b:Word) {
    -Modulus()/2<=Signed(a)*Signed(b)<Modulus()/2
  }
  opaque predicate Matches(code:seq<Byte>) {
    Fit.Matches(code) && Overflow.Matches(code) && Minimum.Matches(code)
  }
  function Destinations():set<nat> {
    Fit.Destinations()+Overflow.Destinations()+Minimum.Destinations()
  }

  lemma MinimumOverflow(a:Word,b:Word)
    requires Signed(b)<0 && a==Modulus()/2
    ensures !Fitting(a,b)
  {
    assert Signed(a)==-Modulus()/2 && Signed(b)<=-1;
    assert Signed(a)*Signed(b)>=Modulus()/2;
  }

  lemma MathematicalProduct(a:Word,b:Word)
    ensures Fitting(a,b)==P.Signed(K.Signed(a)*K.Signed(b))
    ensures SignedProduct(a,b)==K.Encode(K.Signed(a)*K.Signed(b))
  {}

  ghost method Run(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                   returnPc:Word,a:Word,b:Word,value:Word,size:Word,
                   word:Word,headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations
    requires |prefix|<=1000 && returnPc in {3275,3301}
    ensures Fitting(a,b) ==>
              state==Running(returnPc,prefix+[SignedProduct(a,b)],Store([],64,128))
    ensures !Fitting(a,b) ==> state==Reverted(Panic(17))
    ensures |trace|>0 && trace[0]==Running(20145,prefix+[returnPc,a,b],Store([],64,128)) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  {
    reveal Matches();
    if Fitting(a,b) {
      state,trace:=Fit.Run(code,destinations,prefix,returnPc,a,b,value,size,word,headA,headB);
    } else if Signed(b)<0 && a==Modulus()/2 {
      MinimumOverflow(a,b);
      state,trace:=Minimum.Run(code,destinations,prefix,returnPc,a,b,value,size,word,headA,headB);
    } else {
      state,trace:=Overflow.Run(code,destinations,prefix,returnPc,a,b,value,size,word,headA,headB);
    }
  }
}
