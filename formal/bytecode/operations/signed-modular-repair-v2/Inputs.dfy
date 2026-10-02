// SPDX-License-Identifier: MIT
// Candidate mathematical partition; binding to all physical paths remains open.
include "Math.dfy"
module OperationsSignedModularInputs {
  import opened OperationsSignedModularMath

  function AddClass(a: Word,b: Word,m: Word): nat {
    if a<Half && b<Half then (if m==0 then 0 else if m<Half then 1 else 2)
    else if a>=Half && b>=Half then (if m==0 then 15 else if m<Half then 16 else 17)
    else if a<Half then
      (if Magnitude(a)>=Magnitude(b)
       then (if m==0 then 5 else if m<Half then 6 else 8)
       else (if m==0 then 3 else if m<Half then 4 else 7))
    else
      (if Magnitude(a)>=Magnitude(b)
       then (if m==0 then 11 else if m<Half then 12 else 14)
       else (if m==0 then 9 else if m<Half then 10 else 13))
  }
  function MulClass(a: Word,b: Word,m: Word): nat {
    if m==0 then 0
    else (if m<Half then 1 else 5)+(if a>=Half then 1 else 0)+(if b>=Half then 2 else 0)
  }
  predicate AddCase(id: nat,a: Word,b: Word,m: Word) { id==AddClass(a,b,m) }
  predicate MulCase(id: nat,a: Word,b: Word,m: Word) { id==MulClass(a,b,m) }

  lemma AddPartition(a: Word,b: Word,m: Word)
    ensures AddClass(a,b,m)<18
    ensures exists id: nat :: id<18 && AddCase(id,a,b,m)
    ensures forall i: nat,j: nat :: AddCase(i,a,b,m) && AddCase(j,a,b,m) ==> i==j
  { assert AddCase(AddClass(a,b,m),a,b,m); }
  lemma MulPartition(a: Word,b: Word,m: Word)
    ensures MulClass(a,b,m)<9
    ensures exists id: nat :: id<9 && MulCase(id,a,b,m)
    ensures forall i: nat,j: nat :: MulCase(i,a,b,m) && MulCase(j,a,b,m) ==> i==j
  { assert MulCase(MulClass(a,b,m),a,b,m); }
  lemma AddZeroPartition(a: Word,b: Word,m: Word)
    ensures (m==0)==(AddClass(a,b,m) in {0,3,5,9,11,15})
  {}
  lemma MulZeroPartition(a: Word,b: Word,m: Word)
    ensures (m==0)==(MulClass(a,b,m)==0)
  {}
}
