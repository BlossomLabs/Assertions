// SPDX-License-Identifier: MIT
// Generated from fresh solc AST and interface method identifiers.
include "../../abi/Frames.dfy"

module CollectionsAdmissionSignatures {
  import opened AbiFrames
  function InvalidCallback(): seq<Byte>
    ensures |InvalidCallback()| == 4
  { [0xf7,0xa6,0x32,0xf5] }
  function InvalidTypeDescriptor(): seq<Byte>
    ensures |InvalidTypeDescriptor()| == 4
  { [0x9a,0x67,0xd1,0x26] }
  function Panic(): seq<Byte>
    ensures |Panic()| == 4
  { [0x4e,0x48,0x7b,0x71] }
}
