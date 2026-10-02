// SPDX-License-Identifier: MIT
// Generated from the complete uniqueWords compiler AST.
include "Model.dfy"
module CollectionsWordUniqueControl {
  import opened AbiFrames
  import M = CollectionsWordMemoryModel
  function Unaligned(length: nat): bool { $ALIGNMENT$ }
  function Loop(i: nat,length: nat): bool { $LOOP$ }
  function Ordered(ordered: bool): bool { $ORDERED$ }
  function Nonempty(kept: nat): bool { $NONEMPTY$ }
  function Equal(previous: nat,word: nat): bool { $EQUAL$ }
  function Scan(j: nat,kept: nat): bool { $SCAN$ }
  function Unseen(seen: bool): bool { $UNSEEN$ }
  function ShrinkBytes(kept: nat): nat { $SHRINK$ }
  function UnalignedSelector(): seq<Byte> { $UnalignedWords$ }
}
