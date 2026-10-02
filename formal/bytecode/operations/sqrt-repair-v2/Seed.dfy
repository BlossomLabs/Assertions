// SPDX-License-Identifier: MIT
// Independent radix-four seed classification candidate, no opcode/public credit.
include "Math.dfy"
module OperationsSquareRootSeed {
  function Power2(exponent: nat): nat
    ensures Power2(exponent)>0
    decreases exponent
  { if exponent==0 then 1 else 2*Power2(exponent-1) }
  function Power4(exponent: nat): nat
    ensures Power4(exponent)>0
    decreases exponent
  { if exponent==0 then 1 else 4*Power4(exponent-1) }
  function Class(n: nat): nat
    requires n>0
    ensures Power4(Class(n))<=n<Power4(Class(n)+1)
    decreases n
  { if n<4 then 0 else 1+Class(n/4) }
  function Initial(n: nat): nat
    requires n>0
  { Power2(Class(n)) }
  lemma Powers(exponent: nat)
    ensures Power2(exponent)*Power2(exponent)==Power4(exponent)
    decreases exponent
  { if exponent>0 { Powers(exponent-1); } }
  lemma Bounds(n: nat)
    requires n>0
    ensures Initial(n)*Initial(n)<=n<4*Initial(n)*Initial(n)
  { Powers(Class(n)); }
  lemma Monotone(left: nat,right: nat)
    requires left<=right
    ensures Power4(left)<=Power4(right)
    decreases right
  { if left<right { Monotone(left,right-1); } }
  lemma Power2Monotone(left: nat,right: nat)
    requires left<=right
    ensures Power2(left)<=Power2(right)
    decreases right
  { if left<right { Power2Monotone(left,right-1); } }

  lemma Parity(exponent: nat)
    ensures Power2(exponent)==1 || Power2(exponent)%2==0
  {
    if exponent>0 { assert Power2(exponent)==2*Power2(exponent-1); }
  }

}
