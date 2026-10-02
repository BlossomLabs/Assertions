// SPDX-License-Identifier: MIT
module SourceNaturalProductV8 {
  lemma Nonnegative(a: nat, b: nat)
    ensures a*b >= 0
    decreases b
  {
    if b > 0 {
      Nonnegative(a,b-1);
      assert a*b == a*(b-1)+a;
    } else {
      assert a*b == 0;
    }
  }
}
