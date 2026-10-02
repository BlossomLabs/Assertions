// SPDX-License-Identifier: MIT
// Generated checked construction of fixed-width unsigned integer/bitvector round trips.
module OperationsShiftWordConversion {
  lemma Nat8(a: int)
    requires 0 <= a < 256
    ensures ((a as bv8) as int) == a
  {}
  lemma Join16(hi: bv8, lo: bv8)
    ensures ((((hi as bv16) << 8) | (lo as bv16)) as int) == 0x100*(hi as int)+(lo as int)
  {}
  lemma Inverse16(bits: bv16)
    ensures ((bits as int) as bv16) == bits
  {}
  lemma Nat16(a: int)
    requires 0 <= a < 0x10000
    ensures ((a as bv16) as int) == a
  {
    var quotient := a/0x100;
    var remainder := a%0x100;
    Nat8(quotient); Nat8(remainder);
    var bits := (((quotient as bv8) as bv16) << 8) | ((remainder as bv8) as bv16);
    Join16(quotient as bv8,remainder as bv8);
    assert (bits as int) == a;
    Inverse16(bits);
    assert (a as bv16) == bits;
  }
  lemma Join32(hi: bv16, lo: bv16)
    ensures ((((hi as bv32) << 16) | (lo as bv32)) as int) == 0x10000*(hi as int)+(lo as int)
  {}
  lemma Inverse32(bits: bv32)
    ensures ((bits as int) as bv32) == bits
  {}
  lemma Nat32(a: int)
    requires 0 <= a < 0x100000000
    ensures ((a as bv32) as int) == a
  {
    var quotient := a/0x10000;
    var remainder := a%0x10000;
    Nat16(quotient); Nat16(remainder);
    var bits := (((quotient as bv16) as bv32) << 16) | ((remainder as bv16) as bv32);
    Join32(quotient as bv16,remainder as bv16);
    assert (bits as int) == a;
    Inverse32(bits);
    assert (a as bv32) == bits;
  }
  lemma Join64(hi: bv32, lo: bv32)
    ensures ((((hi as bv64) << 32) | (lo as bv64)) as int) == 0x100000000*(hi as int)+(lo as int)
  {}
  lemma Inverse64(bits: bv64)
    ensures ((bits as int) as bv64) == bits
  {}
  lemma Nat64(a: int)
    requires 0 <= a < 0x10000000000000000
    ensures ((a as bv64) as int) == a
  {
    var quotient := a/0x100000000;
    var remainder := a%0x100000000;
    Nat32(quotient); Nat32(remainder);
    var bits := (((quotient as bv32) as bv64) << 32) | ((remainder as bv32) as bv64);
    Join64(quotient as bv32,remainder as bv32);
    assert (bits as int) == a;
    Inverse64(bits);
    assert (a as bv64) == bits;
  }
  lemma Join128(hi: bv64, lo: bv64)
    ensures ((((hi as bv128) << 64) | (lo as bv128)) as int) == 0x10000000000000000*(hi as int)+(lo as int)
  {}
  lemma Inverse128(bits: bv128)
    ensures ((bits as int) as bv128) == bits
  {}
  lemma Nat128(a: int)
    requires 0 <= a < 0x100000000000000000000000000000000
    ensures ((a as bv128) as int) == a
  {
    var quotient := a/0x10000000000000000;
    var remainder := a%0x10000000000000000;
    Nat64(quotient); Nat64(remainder);
    var bits := (((quotient as bv64) as bv128) << 64) | ((remainder as bv64) as bv128);
    Join128(quotient as bv64,remainder as bv64);
    assert (bits as int) == a;
    Inverse128(bits);
    assert (a as bv128) == bits;
  }
  lemma Join256(hi: bv128, lo: bv128)
    ensures ((((hi as bv256) << 128) | (lo as bv256)) as int) == 0x100000000000000000000000000000000*(hi as int)+(lo as int)
  {}
  lemma Inverse256(bits: bv256)
    ensures ((bits as int) as bv256) == bits
  {}
  lemma Nat256(a: int)
    requires 0 <= a < 0x10000000000000000000000000000000000000000000000000000000000000000
    ensures ((a as bv256) as int) == a
  {
    var quotient := a/0x100000000000000000000000000000000;
    var remainder := a%0x100000000000000000000000000000000;
    Nat128(quotient); Nat128(remainder);
    var bits := (((quotient as bv128) as bv256) << 128) | ((remainder as bv128) as bv256);
    Join256(quotient as bv128,remainder as bv128);
    assert (bits as int) == a;
    Inverse256(bits);
    assert (a as bv256) == bits;
  }
}
