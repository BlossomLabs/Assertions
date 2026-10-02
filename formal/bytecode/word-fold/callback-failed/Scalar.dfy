// SPDX-License-Identifier: MIT
include "Bindings.dfy"
module BytecodeFoldCallbackFailedControlScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  import H = BytecodeApplyCallbackFailedMemory
  import WC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  import CL = BytecodeFoldCallbackLengthScalar
  lemma HeaderLiteral()
    ensures S.ShiftLeft(0x08be7b7b,225) == H.Header()
  {
    hide G.BitAnd();hide S.BitNot();hide G.Shift();
    reveal S.ShiftLeft();SC.ShiftDefinition(0x08be7b7b,225);SC.Narrow(0x08be7b7b);
    var bits: bv256 := 0x117cf6f600000000000000000000000000000000000000000000000000000000;
    assert (0x08be7b7b as bv256) << 225 == bits;
    assert (bits as nat) == H.Header();
  }
  lemma OperationMask(domain: nat,data: seq<S.Byte>)
    requires domain < 3 && S.ShiftRight(S.DataWord(data,0),224) == CL.Selector(domain)
    ensures G.BitAnd(WC.HighMask(),S.DataWord(data,0)) == CL.Operation(domain)
    ensures G.BitAnd(CL.Operation(domain),WC.HighMask()) == CL.Operation(domain)
  {
    hide G.BitAnd();hide S.DataWord();hide S.ShiftRight();
    CL.Mask(domain,data);
    A.Definition(WC.HighMask(),CL.Operation(domain));A.Definition(CL.Operation(domain),WC.HighMask());
    assert (WC.HighMask() as bv256) & (CL.Operation(domain) as bv256) == (CL.Operation(domain) as bv256) & (WC.HighMask() as bv256);
  }
}
