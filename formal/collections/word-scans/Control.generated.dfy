// SPDX-License-Identifier: MIT
// Generated from complete gated wordIndexOf and sumWords compiler ASTs.
include "Model.dfy"
module CollectionsWordScansControl {
  import opened AbiFrames
  function Unaligned(length: nat): bool { ((length % 32) != 0) }
  function Count(length: nat): nat { (length / 32) }
  function Loop(i: nat,count: nat): bool { (i < count) }
  function Equal(element: nat,needle: nat): bool { (element == needle) }
  function Next(total: nat,element: nat): nat { (total + element) }
  function UnalignedSelector(): seq<Byte> { [169, 73, 210, 133] }
}
