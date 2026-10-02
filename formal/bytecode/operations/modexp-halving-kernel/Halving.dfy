// SPDX-License-Identifier: MIT
// Independent bit decomposition connects actual SHR/AND to binary-loop arithmetic.
include "../modexp-execution/Execution.dfy"
include "../../word-apply/word-conversion/Conversion.generated.dfy"
module OperationsModularPowerHalving {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeApplyWordConversion
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
  lemma OneShift(a:S.Word)
    ensures S.ShiftRight(a,1)==(((a as bv256)>>1) as nat)
  { Count9(1); }
  lemma Quotient(a:nat,q:nat,r:nat)
    requires a==2*q+r && r<2
    ensures a/2==q && a%2==r
  {
    assert a%2==r;
    assert a==2*(a/2)+a%2;
  }
  lemma Halve(a:S.Word)
    ensures S.ShiftRight(a,1)==a/2
    ensures G.BitAnd(a,1)==a%2 && G.BitAnd(1,a)==a%2
    ensures a==2*S.ShiftRight(a,1)+G.BitAnd(a,1)
  {
    var bits:=a as bv256;
    C.Nat256(a);Split(bits);
    var high:nat:=(bits>>1) as nat;
    var low:nat:=(bits&1) as nat;
    assert a==2*high+low && low<2;
    Quotient(a,high,low);OneShift(a);
    assert (bits&1)==(1&bits);
  }
}
