// SPDX-License-Identifier: MIT
include "Bindings.dfy"
module BytecodeApplyCallbackFailedControlScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  import H = BytecodeApplyCallbackFailedMemory
  import WC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  import CL = BytecodeApplyCallbackLengthScalar
  lemma HeaderLiteral()
    ensures S.ShiftLeft(0x08be7b7b,225) == H.Header()
  {
    hide G.BitAnd();hide S.BitNot();hide G.Shift();
    reveal S.ShiftLeft();SC.ShiftDefinition(0x08be7b7b,225);SC.Narrow(0x08be7b7b);
    var bits: bv256 := 0x117cf6f600000000000000000000000000000000000000000000000000000000;
    assert (0x08be7b7b as bv256) << 225 == bits;
    assert (bits as nat) == H.Header();
  }
  lemma OperationMask(filter: bool,data: seq<S.Byte>)
    requires S.ShiftRight(S.DataWord(data,0),224) == CL.Selector(filter)
    ensures G.BitAnd(WC.HighMask(),S.DataWord(data,0)) == CL.Operation(filter)
    ensures G.BitAnd(CL.Operation(filter),WC.HighMask()) == CL.Operation(filter)
  {
    hide G.BitAnd();hide S.DataWord();hide S.ShiftRight();
    CL.Mask(filter,data);
    A.Definition(WC.HighMask(),CL.Operation(filter));A.Definition(CL.Operation(filter),WC.HighMask());
    assert (WC.HighMask() as bv256) & (CL.Operation(filter) as bv256) == (CL.Operation(filter) as bv256) & (WC.HighMask() as bv256);
  }
  lemma TargetMask(target: S.Word)
    requires target < A.Bound()
    ensures G.BitAnd(0xffffffffffffffffffffffffffffffffffffffff,target) == target
    ensures G.BitAnd(target,0xffffffffffffffffffffffffffffffffffffffff) == target
  {
    hide G.BitAnd();
    A.Canonical(target);
    A.Definition(0xffffffffffffffffffffffffffffffffffffffff,target);
    A.Definition(target,0xffffffffffffffffffffffffffffffffffffffff);
    assert (target as bv256) & (0xffffffffffffffffffffffffffffffffffffffff as bv256) == (0xffffffffffffffffffffffffffffffffffffffff as bv256) & (target as bv256);
  }
}
