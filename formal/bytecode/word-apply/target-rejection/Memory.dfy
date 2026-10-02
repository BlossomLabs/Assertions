// SPDX-License-Identifier: MIT
include "../allocation-header/Memory.dfy"
include "../../scans/ErrorBytes.dfy"
module BytecodeApplyTargetErrorMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  function Header(): S.Word { 0x54b3288a00000000000000000000000000000000000000000000000000000000 }
  function First(n: nat): seq<S.Byte>
    requires n < 0x800000000000000
  { S.Store(A.Heap(n),O.Extent(n),Header()) }
  function Complete(n: nat,target: S.Word): seq<S.Byte>
    requires n < 0x800000000000000
  { S.Store(First(n),O.Extent(n)+4,target) }
  lemma Rounding(n: nat)
    ensures S.Round32(O.Extent(n)+32) == O.Extent(n)+32
    ensures S.Round32(O.Extent(n)+36) == O.Extent(n)+64
  {}
  lemma Frames(n: nat,target: S.Word)
    requires n < 0x800000000000000
    ensures S.Load(A.Heap(n),64) == O.Extent(n)
    ensures S.Load(First(n),64) == O.Extent(n)
    ensures S.Load(Complete(n,target),64) == O.Extent(n)
    ensures |A.Heap(n)| == O.Extent(n) && |A.Heap(n)|%32 == 0
    ensures |First(n)| == O.Extent(n)+32 && |Complete(n,target)| == O.Extent(n)+64
    ensures |Complete(n,target)|%32 == 0 && |Complete(n,target)| < 0x40000000000000000
    ensures Complete(n,target)[O.Extent(n)..O.Extent(n)+36] == G.Encode(0x54b3288a,4)+G.Encode(target,32)
  {
    hide G.BitAnd();
    O.Header(n,0);O.Aligned(n);Rounding(n);
    R.StoredWord(A.Heap(n),O.Extent(n),Header());
    R.StoredFrame(A.Heap(n),O.Extent(n),Header(),64);
    R.StoredWord(First(n),O.Extent(n)+4,target);
    assert |First(n)| == O.Extent(n)+32;
    assert |Complete(n,target)| == O.Extent(n)+64;
    R.StoredFrame(First(n),O.Extent(n)+4,target,64);
    ER.PhysicalError(A.Heap(n),O.Extent(n),0x54b3288a,Header(),target);
  }
}
