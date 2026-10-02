// SPDX-License-Identifier: MIT
// Generated from fresh solc AST and interface method identifiers.
include "../../abi/Frames.dfy"

module CollectionsCodecErrorSignatures {
  import opened AbiFrames
  datatype Tag = U | Address | Four | Word
  function ComponentCountMismatch(): seq<Byte>
    ensures |ComponentCountMismatch()| == 4
  { [0x1e,0xc6,0xa9,0x56] }
  function ComponentCountMismatchTypes(): seq<Tag> { [U,U] }
  function InvalidCallbackResult(): seq<Byte>
    ensures |InvalidCallbackResult()| == 4
  { [0x24,0x44,0x8a,0x11] }
  function InvalidCallbackResultTypes(): seq<Tag> { [Four,U,U,Address] }
  function InvalidComponentEnvelope(): seq<Byte>
    ensures |InvalidComponentEnvelope()| == 4
  { [0xdc,0x5d,0x12,0x62] }
  function InvalidComponentEnvelopeTypes(): seq<Tag> { [U,U,Word] }
  function InvalidComponentLength(): seq<Byte>
    ensures |InvalidComponentLength()| == 4
  { [0x30,0x62,0x0a,0x1b] }
  function InvalidComponentLengthTypes(): seq<Tag> { [U,U,U] }
  function InvalidComponentValue(): seq<Byte>
    ensures |InvalidComponentValue()| == 4
  { [0xdf,0x06,0xc5,0x1e] }
  function InvalidComponentValueTypes(): seq<Tag> { [U,U] }
  function InvalidTypeDescriptor(): seq<Byte>
    ensures |InvalidTypeDescriptor()| == 4
  { [0x9a,0x67,0xd1,0x26] }
  function InvalidTypeDescriptorTypes(): seq<Tag> { [U] }
  function InvalidValue(): seq<Byte>
    ensures |InvalidValue()| == 4
  { [0x60,0x72,0x74,0x2c] }
  function InvalidValueTypes(): seq<Tag> { [U] }
  function Panic(): seq<Byte>
    ensures |Panic()| == 4
  { [0x4e,0x48,0x7b,0x71] }
  function PanicTypes(): seq<Tag> { [U] }
}
