// SPDX-License-Identifier: MIT
// Bitvector-to-integer loop projection; native verification pending.
include "../power-opcode-kernel/Execution.dfy"
module OperationsPowerHalving {
  import M = OperationsSignedMultiplyMachine
  import C = OperationsSignedMultiplyWordConversion

  lemma JoinOne(high:bv255,low:bv1)
    ensures ((((high as bv256)<<1)|(low as bv256)) as int)==2*(high as int)+(low as int)
  {}

  lemma Split(bits:bv256)
    ensures (bits as int)==2*((bits>>1) as int)+((bits&1) as int)
    ensures ((bits&1) as int)<2
  {
    assert (bits>>1)<0x8000000000000000000000000000000000000000000000000000000000000000;
    assert (bits&1)<=1;
    var high:bv255:=(bits>>1) as bv255;
    var low:bv1:=(bits&1) as bv1;
    assert bits>>1==high as bv256;
    assert bits&1==low as bv256;
    assert bits==((high as bv256)<<1)|(low as bv256);
    JoinOne(high,low);
  }

  lemma Count9(count:int)
    requires 0<=count<512
    ensures ((count as bv9) as nat)==count
  {}

  lemma OneShift(a:M.Word)
    ensures M.Right(a,1)==(((a as bv256)>>1) as nat)
  { Count9(1); reveal M.Right(); }

  lemma Halve(a:M.Word)
    ensures M.Right(a,1)==a/2
    ensures M.BitAnd(a,1)==a%2
    ensures M.BitAnd(1,a)==a%2
    ensures a==2*M.Right(a,1)+M.BitAnd(a,1)
  {
    var bits:=a as bv256;
    C.Nat256(a); Split(bits);
    var high: nat:=(bits>>1) as nat;
    var low: nat:=(bits&1) as nat;
    assert a==2*high+low && low<2;
    M.DivisionUnique(a,2,high,low);
    assert a%2==low;
    OneShift(a); M.SymmetricBits(a,1);
  }
}
