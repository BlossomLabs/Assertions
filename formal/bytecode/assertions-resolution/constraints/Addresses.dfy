// SPDX-License-Identifier: MIT
// Normalize admitted address arithmetic before exposing memory and opcode states.
include "../../getters/Machine.dfy"
module AssertionsConstraintAddresses {
  import G = BytecodeGetterMachine
  lemma Normalize(free: G.Word, length: G.Word, offset: G.Word, relative: G.Word)
    requires (free as nat)+length+256 < 0x10000000000000000
    requires (offset as nat)+relative+32+length < 0x10000000000000000
    ensures ((free+64 as nat)+32)%G.Modulus() == free+96
    ensures ((((offset as nat)+(relative as nat))%G.Modulus() as nat)+32)%G.Modulus() == offset+relative+32
    ensures ((free+64 as nat)+(length as nat))%G.Modulus() == free+64+length
    ensures (32+(((free+64 as nat)+(length as nat))%G.Modulus()))%G.Modulus() == free+96+length
    ensures ((offset as nat)+relative)%G.Modulus() == offset+relative
    ensures ((offset+relative as nat)+length)%G.Modulus() == offset+relative+length
    ensures (32+(offset+relative+length as nat))%G.Modulus() == offset+relative+length+32
  {}
}
