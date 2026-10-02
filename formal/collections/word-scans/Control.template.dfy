// SPDX-License-Identifier: MIT
// Generated from complete gated wordIndexOf and sumWords compiler ASTs.
include "Model.dfy"
module CollectionsWordScansControl {
  import opened AbiFrames
  function Unaligned(length: nat): bool { $ALIGNMENT$ }
  function Count(length: nat): nat { $COUNT$ }
  function Loop(i: nat,count: nat): bool { $LOOP$ }
  function Equal(element: nat,needle: nat): bool { $EQUAL$ }
  function Next(total: nat,element: nat): nat { $SUM$ }
  function UnalignedSelector(): seq<Byte> { $UnalignedWords$ }
}
