// SPDX-License-Identifier: MIT
// Fold target rejection occurs before any FoldRun or template allocation.
include "../../scans/ErrorBytes.dfy"
module BytecodeFoldTargetErrorMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  function Header(): S.Word { 0x54b3288a00000000000000000000000000000000000000000000000000000000 }
  function Initial(): seq<S.Byte> { S.Store([],64,128) }
  function First(): seq<S.Byte> { S.Store(Initial(),128,Header()) }
  function Complete(target: S.Word): seq<S.Byte> { S.Store(First(),132,target) }
  lemma Frames(target: S.Word)
    ensures S.Load(Initial(),64) == 128 && S.Load(First(),64) == 128 && S.Load(Complete(target),64) == 128
    ensures |Initial()| == 96 && |First()| == 160 && |Complete(target)| == 192
    ensures |Initial()|%32 == 0 && |First()|%32 == 0 && |Complete(target)|%32 == 0
    ensures Complete(target)[128..164] == G.Encode(0x54b3288a,4)+G.Encode(target,32)
  {
    R.StoredWord([],64,128);
    R.StoredWord(Initial(),128,Header());
    R.StoredFrame(Initial(),128,Header(),64);
    R.StoredWord(First(),132,target);
    R.StoredFrame(First(),132,target,64);
    ER.PhysicalError(Initial(),128,0x54b3288a,Header(),target);
  }
}
