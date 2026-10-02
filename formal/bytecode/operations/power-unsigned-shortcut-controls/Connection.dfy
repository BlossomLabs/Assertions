// SPDX-License-Identifier: MIT
// Complete compiler shortcut classification; native verification pending.
include "ZeroExponent.generated.dfy"
include "ZeroBase.generated.dfy"
include "OneBase.generated.dfy"
include "TwoFit.generated.dfy"
include "TwoOverflow.generated.dfy"
include "Small.generated.dfy"
include "GenericInvoke.generated.dfy"
module OperationsPowerUnsignedShortcutConnection {
  import opened OperationsSignedMultiplyMachine
  import P = OperationsCheckedPowerModel
  import K = OperationsPowerWordKernel
  import S = OperationsPowerShortcuts
  import E = OperationsPowerExecution
  import Z = OperationsPowerUnsignedShortcutZeroExponent
  import B = OperationsPowerUnsignedShortcutZeroBase
  import U = OperationsPowerUnsignedShortcutOneBase
  import T = OperationsPowerUnsignedShortcutTwoFit
  import F = OperationsPowerUnsignedShortcutTwoOverflow
  import V = OperationsPowerUnsignedShortcutSmall
  import G = OperationsPowerUnsignedShortcutGenericInvoke
  predicate Small(a:Word,b:Word) {
    (a<11 && b<78) || (a<307 && b<32)
  }
  predicate Shortcut(a:Word,b:Word) { b==0 || a<3 || Small(a,b) }
  opaque predicate Matches(code:seq<Byte>) {
    Z.Matches(code) && B.Matches(code) && U.Matches(code) &&
    T.Matches(code) && F.Matches(code) && V.Matches(code) && G.Matches(code)
  }
  function Destinations():set<nat> {
    Z.Destinations()+B.Destinations()+U.Destinations()+T.Destinations()+
    F.Destinations()+V.Destinations()+G.Destinations()
  }
  function GenericPrefix(prefix:seq<Word>,a:Word,b:Word):seq<Word> {
    prefix+[1329,a,b,0,3085,b,a,0,3085,b,a,0]
  }
  ghost method Run(code:seq<Byte>,destinations:set<nat>,prefix:seq<Word>,
                   a:Word,b:Word,value:Word,size:Word,word:Word,
                   headA:Word,headB:Word) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=985
    ensures Shortcut(a,b) && P.Unsigned(a,b).Value? ==>
              state==Running(1329,prefix+[K.Encode(P.Unsigned(a,b).result)],Store([],64,128))
    ensures Shortcut(a,b) && P.Unsigned(a,b).Panic? ==> state==Reverted(Panic(17))
    ensures !Shortcut(a,b) ==>
              state==Running(20932,GenericPrefix(prefix,a,b)+[21132,Modulus()-1,b,a],Store([],64,128))
    ensures |trace|>0 && trace[0]==Running(9089,prefix+[1329,a,b],Store([],64,128)) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==>
                              trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  {
    reveal Matches();
    if b==0 {
      S.ZeroExponent(a);
      state,trace:=Z.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
    } else if a==0 {
      S.UnsignedZero(b);
      state,trace:=B.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
    } else if a==1 {
      S.UnsignedOne(b);
      state,trace:=U.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
    } else if a==2 {
      S.TwoBase(b);
      if b<256 {
        state,trace:=T.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
      } else {
        state,trace:=F.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
      }
    } else if Small(a,b) {
      S.SmallShortcut(a,b);
      state,trace:=V.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
    } else {
      state,trace:=G.Run(code,destinations,prefix,a,b,0,0,value,size,word,headA,headB);
    }
  }
}
