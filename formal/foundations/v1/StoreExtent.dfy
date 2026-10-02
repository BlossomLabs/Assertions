// SPDX-License-Identifier: MIT
// Allocation-only store facts; no encoded bytes or load equations exported.
include "../../bytecode/copy/Memory.dfy"
module SharedFoundationStoreExtent {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  lemma Length(mem: seq<S.Byte>,dst: S.Word,value: S.Word)
    ensures |S.Store(mem,dst,value)| == (if |mem| >= S.Round32(dst+32) then |mem| else S.Round32(dst+32))
    ensures |S.Store(mem,dst,value)| >= |mem| && |S.Store(mem,dst,value)| >= dst+32
  {
    C.Rounded(dst+32);
    var expanded := S.Expand(mem,dst+32);
    assert |expanded| >= dst+32;
    assert G.Grow(expanded,dst+32) == expanded;
    assert |G.Encode(value,32)| == 32;
  }
  lemma Aligned(mem: seq<S.Byte>,dst: S.Word,value: S.Word)
    requires |mem|%32 == 0
    ensures |S.Store(mem,dst,value)|%32 == 0
  {
    Length(mem,dst,value);
    C.Rounded(dst+32);
  }
}
