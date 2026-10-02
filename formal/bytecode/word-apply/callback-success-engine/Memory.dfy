// SPDX-License-Identifier: MIT
// Derived admission for the actual exact32 receipt after zero-output STATICCALL.
include "../callback-copy/Memory.dfy"
include "../callback-success/Memory.dfy"
module BytecodeApplySuccessfulCallMemory {
  import S = BytecodeScanMachine
  import C = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackSuccessMemory
  lemma Fits(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word)
    requires C.Fits(mem,ptr,free,length) && S.Load(mem,64) == free
    requires (free as nat)+96 < 0x10000000000000000000000000000000000000000000000000000000000000000
    ensures H.Fits(C.Packed(mem,ptr,free,length),free)
  {
    C.Bounds(mem,ptr,free,length);
    C.FreePointer(mem,ptr,free,length);
    assert 96 <= free;
  }
}
