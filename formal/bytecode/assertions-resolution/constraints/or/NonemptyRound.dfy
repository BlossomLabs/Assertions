// SPDX-License-Identifier: MIT
// Isolated constant-stride arithmetic for in-memory OR allocation footprints.
include "../../../scans/Machine.dfy"
module AssertionsConstraintOrNonemptyRound {
  import S = BytecodeScanMachine
  lemma Aligned(base: nat)
    requires base%32 == 0
    ensures S.Round32(base) == base
  {
    assert base == (base/32)*32;
    assert (base+31)/32 == base/32;
  }
  lemma Add(base: nat, length: nat)
    requires base%32 == 0
    ensures S.Round32(base+length) == base+S.Round32(length)
  {
    assert base == (base/32)*32;
    assert (base+length+31)/32 == base/32+(length+31)/32;
  }
}
