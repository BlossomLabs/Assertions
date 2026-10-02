// SPDX-License-Identifier: MIT
// Generated compiler selectors.
include "../../abi/Frames.dfy"
module CollectionsWordFoldEntrySelectors {
  import opened AbiFrames
  function RangeSelector(): seq<Byte> ensures |RangeSelector()| == 4 { [241,216,141,200] }
  function BytesSelector(): seq<Byte> ensures |BytesSelector()| == 4 { [109,36,231,156] }
  function WordsSelector(): seq<Byte> ensures |WordsSelector()| == 4 { [109,230,12,176] }
  function UnalignedSelector(): seq<Byte> ensures |UnalignedSelector()| == 4 { [169,73,210,133] }
}
