// SPDX-License-Identifier: MIT
include "../callback-receipt-engine/Memory.dfy"
include "../callback-exhaustion-controls/Scalar.dfy"
module BytecodeApplyCallbackExhaustionMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeApplyFullCallbackReceiptMemory
  import R = BytecodeApplyCallbackReceiptMemory
  import P = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackExhaustionScalar
  lemma Admission(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>)
    requires F.Fits(mem,ptr,free,length,returned)
    ensures H.Fits(F.Final(mem,ptr,free,length,returned),F.Receipt(free,returned),|returned|,S.Load(F.Final(mem,ptr,free,length,returned),F.Receipt(free,returned)+32))
  {
    hide G.BitAnd(); hide S.BitNot(); hide F.Final(); hide P.Packed();
    F.Header(mem,ptr,free,length,returned);
    F.Admission(mem,ptr,free,length,returned);
    if |returned| == 4 {
      R.Bounds(P.Packed(mem,ptr,free,length),free,returned);
      reveal F.Final();
      assert free+36 <= |F.Final(mem,ptr,free,length,returned)|;
      assert free+64 <= |F.Final(mem,ptr,free,length,returned)|;
    }
  }
}
