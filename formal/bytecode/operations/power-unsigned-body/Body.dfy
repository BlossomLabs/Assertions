// SPDX-License-Identifier: MIT
// Entire compiled integer-power body; native and public retention pending.
include "../power-unsigned-shortcut-controls/Connection.dfy"
include "../power-unsigned-loop-controls/Engine.dfy"
include "../power-unsigned-final-controls/Connection.dfy"
module OperationsPowerUnsignedBody {
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import P = OperationsCheckedPowerModel
  import K = OperationsPowerWordKernel
  import S = OperationsPowerUnsignedShortcutConnection
  import U = OperationsPowerUnsignedLoopEngine
  import F = OperationsPowerUnsignedFinalConnection
  opaque predicate Matches(code:seq<Byte>) { S.Matches(code) && U.Matches(code) && F.Matches(code) }
  function Destinations():set<nat> { S.Destinations()+U.Destinations()+F.Destinations() }
  ghost method Run(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                   a:Word,b:Word,value:Word,size:Word,word:Word,
                   headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=985
    ensures P.Unsigned(a,b).Value? ==>
              state==Running(1329,prefix+[K.Encode(P.Unsigned(a,b).result)],Store([],64,128))
    ensures P.Unsigned(a,b).Panic? ==> state==Reverted(Panic(17))
    ensures U.Continuous(code,destinations,trace,value,size,word,headA,headB)
    ensures trace[0]==Running(9089,prefix+[1329,a,b],Store([],64,128)) && trace[|trace|-1]==state
  {
    reveal Matches();
    K.PowWordMeaning(a,b); P.PowerNonnegative(a,b);
    state,trace:=S.Run(code,destinations,prefix,a,b,value,size,word,headA,headB);
    if !S.Shortcut(a,b) {
      assert a>=3 && b>0;
      var tail:seq<State>;
      state,tail:=U.Run(code,destinations,S.GenericPrefix(prefix,a,b),a,b,value,size,word,headA,headB);
      U.Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
      if state.Running? {
        var acc:=state.stack[|S.GenericPrefix(prefix,a,b)|];
        var factor:=state.stack[|S.GenericPrefix(prefix,a,b)|+1];
        assert 1<=acc<factor && acc*factor==P.Power(a,b);
        state,tail:=F.Run(code,destinations,prefix,factor,b,acc,a,value,size,word,headA,headB);
        U.Join(code,destinations,trace,tail,value,size,word,headA,headB);trace:=trace+tail[1..];
      }
    }
  }
}
