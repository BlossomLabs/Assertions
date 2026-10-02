// SPDX-License-Identifier: MIT
// Unverified candidate arithmetic for raw byteAt indices. This file does not
// establish opcode, ABI, resource, bytecode or public-source correspondence.
module OperationsByteAtIndices {
  const M: nat := 0x10000000000000000000000000000000000000000000000000000000000000000
  const H: nat := 0x8000000000000000000000000000000000000000000000000000000000000000
  const U64: nat := 0x10000000000000000
  type Word = n: nat | n < M witness 0
  function Signed(c: Word): int { if c < H then c else c-M }
  predicate FitsIndex(c: Word,b: nat) { b < U64 && -(b as int) <= Signed(c) < b }
  function Position(c: Word,b: nat): nat
    requires FitsIndex(c,b)
    ensures Position(c,b) < b
    ensures Position(c,b) < U64
  { if c < H then c else b+c-M }
  lemma SignedBounds(c: Word)
    ensures -(H as int) <= Signed(c) < H
  {}
  lemma NegativeLength(b: nat)
    requires b < U64
    ensures (M-(b as int))%M < M
    ensures Signed(((M-(b as int))%M) as Word) == -(b as int)
  {}
  lemma EmptyInvalid(c: Word)
    ensures !FitsIndex(c,0)
  {}
  lemma PositivePosition(c: Word,b: nat)
    requires b < U64 && 0 <= Signed(c) < b
    ensures c < H && FitsIndex(c,b) && Position(c,b) == c
  {}
  lemma NegativePosition(c: Word,b: nat)
    requires b < U64 && -(b as int) <= Signed(c) < 0
    ensures c >= H && FitsIndex(c,b)
    ensures Position(c,b) == (b+c)%M == b+Signed(c)
    ensures Signed(((b+c)%M) as Word) == b+Signed(c)
    ensures -(H as int) <= b+Signed(c) < H
  {}
  lemma OriginalByteWindow(a: nat,b: nat,c: Word,size: nat)
    requires a < U64 && size < U64 && a+36+b <= size
    requires FitsIndex(c,b)
    ensures a+36+Position(c,b) < size
    ensures a+36+Position(c,b)+1 <= size
    ensures Position(c,b)+1 <= b
  {}
  lemma FittingGuards(c: Word,b: nat)
    requires b < U64
    ensures FitsIndex(c,b) || Signed(c) >= b || Signed(c) < -(b as int)
    ensures !(FitsIndex(c,b) && Signed(c) >= b)
    ensures !(FitsIndex(c,b) && Signed(c) < -(b as int))
    ensures !(Signed(c) >= b && Signed(c) < -(b as int))
  {}
}
