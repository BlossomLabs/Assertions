// SPDX-License-Identifier: MIT
include "../../scans/Representation.dfy"
module BytecodeCollectionsArrayStateMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  function Pointer(mem: seq<S.Byte>,fp: S.Word): seq<S.Byte>
    requires fp < 0x40000000000000000
  { S.Store(mem,64,fp+192) }
  function Zero(mem: seq<S.Byte>,fp: S.Word,count: nat): seq<S.Byte>
    requires fp < 0x40000000000000000 && count <= 6
    decreases count
  { if count == 0 then Pointer(mem,fp) else S.Store(Zero(mem,fp,count-1),fp+32*(count-1),0) }
  lemma Arithmetic(mem: seq<S.Byte>,fp: S.Word)
    requires 96 <= |mem| && LoadAt64(mem,fp) && fp < 0x40000000000000000
    ensures fp+192 < G.Modulus() && S.Expand(mem,96) == mem
  {}
  predicate LoadAt64(mem: seq<S.Byte>,fp: S.Word) { S.Load(mem,64) == fp }
}
