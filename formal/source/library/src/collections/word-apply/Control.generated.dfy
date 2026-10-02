// SPDX-License-Identifier: MIT
// Generated controls from the complete structurally gated _applyWords and wrappers.
include "../word-memory/Model.dfy"
module CollectionsWordApplyControl {
  import opened AbiFrames
  import Mem = CollectionsWordMemoryModel
  function Unaligned(length: nat): bool { ((length % 32) != 0) }
  function Count(length: nat): nat { (length / 32) }
  function Nonempty(count: nat): bool { (count != 0) }
  function Loop(i: nat,count: nat): bool { (i < count) }
  function Filter(mode: bool): bool { mode }
  function Invalid(word: nat): bool { (word > 1) }
  function Keep(word: nat): bool { (word != 0) }
  function FilterIndex(kept: nat): nat { kept }
  function FilterValue(elem: nat): nat { elem }
  function MapIndex(i: nat): nat { i }
  function MapValue(word: nat,elem: nat): nat { word }
  function ShrinkMode(mode: bool): bool { mode }
  function ShrinkBytes(kept: nat): nat { Mem.Mul(kept,32) }
  function MapMode(): bool { false }
  function FilterMode(): bool { true }
  function UnalignedSelector(): seq<Byte> { [169, 73, 210, 133] }
  function MapSelector(): seq<Byte> { [237, 109, 195, 190] }
  function FilterSelector(): seq<Byte> { [119, 135, 235, 72] }
}
