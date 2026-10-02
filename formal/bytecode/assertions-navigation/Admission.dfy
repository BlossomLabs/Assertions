// SPDX-License-Identifier: MIT
// Independent structural calldata specification for the public nav wrapper.
include "../scans/Machine.dfy"
module AssertionsNavigationAdmission {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Byte = S.Byte
  type Word = S.Word
  function Relative(data: seq<Byte>, slot: Word): Word { S.DataWord(data,slot) }
  predicate Head(data: seq<Byte>) {
    100 <= |data| < 0x10000000000000000 &&
    Relative(data,4) <= 0xffffffffffffffff &&
    Relative(data,36) <= 0xffffffffffffffff &&
    Relative(data,68) <= 0xffffffffffffffff
  }
  predicate Admitted(data: seq<Byte>) {
    Head(data) &&
    4+(Relative(data,4) as nat)+128 <= |data| &&
    4+(Relative(data,36) as nat)+32 <= |data| &&
    4+(Relative(data,68) as nat)+32 <= |data| &&
    S.DataWord(data,4+Relative(data,36)) <= 0xffffffffffffffff &&
    S.DataWord(data,4+Relative(data,68)) <= 0xffffffffffffffff &&
    4+(Relative(data,36) as nat)+32+(S.DataWord(data,4+Relative(data,36)) as nat) <= |data| &&
    4+(Relative(data,68) as nat)+32+32*(S.DataWord(data,4+Relative(data,68)) as nat) <= |data|
  }
  function Param(data: seq<Byte>): Word requires Head(data) { 4+Relative(data,4) }
  function TypeOffset(data: seq<Byte>): Word requires Head(data) { 36+Relative(data,36) }
  function TypeLength(data: seq<Byte>): Word requires Head(data) { S.DataWord(data,4+Relative(data,36)) }
  function PathOffset(data: seq<Byte>): Word requires Head(data) { 36+Relative(data,68) }
  function PathLength(data: seq<Byte>): Word requires Head(data) { S.DataWord(data,4+Relative(data,68)) }
  lemma Bounds(data: seq<Byte>)
    requires Admitted(data)
    ensures (Param(data) as nat)+128 <= |data|
    ensures (TypeOffset(data) as nat)+TypeLength(data) <= |data|
    ensures (PathOffset(data) as nat)+32*PathLength(data) <= |data|
    ensures TypeLength(data) < 0x10000000000000000 && PathLength(data) < 0x10000000000000000
  {}
}
