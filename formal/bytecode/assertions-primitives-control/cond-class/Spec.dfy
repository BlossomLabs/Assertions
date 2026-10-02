// SPDX-License-Identifier: MIT
// Independent three-pointer calldata admission for public cond.
include "../../scans/Representation.dfy"
include "../gather-public/Spec.dfy"
module AssertionsCondPublicSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = AssertionsGatherPublicSpec
  type Word = S.Word
  type Byte = S.Byte
  function Selector(): Word { 0x5fe917dc }
  function Initial(): seq<Byte> { S.Store([],64,128) }
  predicate Calldata(data: seq<Byte>, conditionRelative: Word, thenRelative: Word, elseRelative: Word) {
    100 <= |data| < 0x10000000000000000 &&
    conditionRelative < 0x10000000000000000 && thenRelative < 0x10000000000000000 && elseRelative < 0x10000000000000000 &&
    4+conditionRelative+128 <= |data| && 4+thenRelative+128 <= |data| && 4+elseRelative+128 <= |data| &&
    S.DataWord(data,4) == conditionRelative && S.DataWord(data,36) == thenRelative && S.DataWord(data,68) == elseRelative
  }
  lemma Constant64()
    ensures S.ShiftLeft(1,64) == 0x10000000000000000
  { Q.Constant64(); }
  lemma Pointers(data: seq<Byte>, conditionRelative: Word, thenRelative: Word, elseRelative: Word)
    requires Calldata(data,conditionRelative,thenRelative,elseRelative)
    ensures ((4 as nat)+conditionRelative)%G.Modulus() == 4+conditionRelative
    ensures ((4 as nat)+thenRelative)%G.Modulus() == 4+thenRelative
    ensures ((4 as nat)+elseRelative)%G.Modulus() == 4+elseRelative
  {}
}
