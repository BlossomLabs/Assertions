// SPDX-License-Identifier: MIT
// Generated controls from the complete structurally gated _applyWords and wrappers.
include "../word-memory/Model.dfy"
module CollectionsWordApplyControl {
  import opened AbiFrames
  import Mem = CollectionsWordMemoryModel
  function Unaligned(length: nat): bool { $ALIGNMENT$ }
  function Count(length: nat): nat { $COUNT$ }
  function Nonempty(count: nat): bool { $NONEMPTY$ }
  function Loop(i: nat,count: nat): bool { $LOOP$ }
  function Filter(mode: bool): bool { $FILTER$ }
  function Invalid(word: nat): bool { $INVALID$ }
  function Keep(word: nat): bool { $KEEP$ }
  function FilterIndex(kept: nat): nat { $FILTER_INDEX$ }
  function FilterValue(elem: nat): nat { $FILTER_VALUE$ }
  function MapIndex(i: nat): nat { $MAP_INDEX$ }
  function MapValue(word: nat,elem: nat): nat { $MAP_VALUE$ }
  function ShrinkMode(mode: bool): bool { $SHRINK_MODE$ }
  function ShrinkBytes(kept: nat): nat { $SHRINK_BYTES$ }
  function MapMode(): bool { $MAP_MODE$ }
  function FilterMode(): bool { $FILTER_MODE$ }
  function UnalignedSelector(): seq<Byte> { $UnalignedWords$ }
  function MapSelector(): seq<Byte> { $mapWords$ }
  function FilterSelector(): seq<Byte> { $filterWords$ }
}
