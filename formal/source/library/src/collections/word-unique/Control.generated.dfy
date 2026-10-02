// SPDX-License-Identifier: MIT
// Generated from the complete uniqueWords compiler AST.
include "Model.dfy"
module CollectionsWordUniqueControl {
  import opened AbiFrames
  import M = CollectionsWordMemoryModel
  function Unaligned(length: nat): bool { ((length % 32) != 0) }
  function Loop(i: nat,length: nat): bool { (i < (length / 32)) }
  function Ordered(ordered: bool): bool { ordered }
  function Nonempty(kept: nat): bool { (kept != 0) }
  function Equal(previous: nat,word: nat): bool { (previous == word) }
  function Scan(j: nat,kept: nat): bool { (j < kept) }
  function Unseen(seen: bool): bool { !(seen) }
  function ShrinkBytes(kept: nat): nat { M.Mul(kept,32) }
  function UnalignedSelector(): seq<Byte> { [169, 73, 210, 133] }
}
