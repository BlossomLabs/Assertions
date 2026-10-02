// SPDX-License-Identifier: MIT
// Selective shared natural multiplication facts from Operations log2-repair-v4/Math.dfy.
// No machine/datatype assumptions or unrelated arithmetic dependencies imported.
module SharedFoundationProductOrderV5 {
  lemma ProductNonnegative(a: nat,b: nat)
    ensures a*b >= 0
  { }
  lemma ProductMonotone(a: nat,b: nat,c: nat)
    requires a <= b
    ensures a*c <= b*c
  { ProductNonnegative(b-a,c); assert b*c == a*c+(b-a)*c; }
}
