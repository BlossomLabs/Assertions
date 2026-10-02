// SPDX-License-Identifier: MIT
// Independent public InputParam/int256 head spans for pick.
include "../cond-class/RawSpec.dfy"
module AssertionsPickPublicSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = AssertionsGatherPublicSpec
  type Word = S.Word
  type Byte = S.Byte
  function Selector(): Word { 0xbf50f520 }
  function Initial(): seq<Byte> { S.Store([],64,128) }
  predicate Calldata(data: seq<Byte>,relative: Word,index: Word) {
    68 <= |data| < 0x10000000000000000 && relative < 0x10000000000000000 &&
    4+relative+128 <= |data| && S.DataWord(data,4) == relative && S.DataWord(data,36) == index
  }
  lemma Constant64()
    ensures S.ShiftLeft(1,64) == 0x10000000000000000
  { Q.Constant64(); }
  lemma Pointers(data: seq<Byte>,relative: Word,index: Word)
    requires Calldata(data,relative,index)
    ensures ((4 as nat)+relative)%G.Modulus() == 4+relative
  {}
}
