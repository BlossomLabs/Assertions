// SPDX-License-Identifier: MIT
// Generated from fresh solc AST and interface method identifiers.
include "../../abi/Frames.dfy"

module CollectionsWireSignatures {
  import opened AbiFrames
  function CallbackFailed(): seq<Byte>
    ensures |CallbackFailed()| == 4
  { [0x11,0x7c,0xf6,0xf6] }
  function InvalidCallback(): seq<Byte>
    ensures |InvalidCallback()| == 4
  { [0xf7,0xa6,0x32,0xf5] }
  function InvalidCallbackResult(): seq<Byte>
    ensures |InvalidCallbackResult()| == 4
  { [0x24,0x44,0x8a,0x11] }
  function InvalidCallbackTarget(): seq<Byte>
    ensures |InvalidCallbackTarget()| == 4
  { [0x54,0xb3,0x28,0x8a] }
  function SubcallOutOfGas(): seq<Byte>
    ensures |SubcallOutOfGas()| == 4
  { [0xd2,0x71,0x06,0x0e] }
  function Evaluate(): seq<Byte>
    ensures |Evaluate()| == 4
  { [0x8f,0x1e,0xa4,0xef] }
}
