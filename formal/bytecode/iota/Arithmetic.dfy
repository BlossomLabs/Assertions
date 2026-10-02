// SPDX-License-Identifier: MIT
include "../scans/Execution.dfy"
module BytecodeIotaArithmetic {
  import G = BytecodeGetterMachine
  function Limit(): nat { (G.Modulus()-1)/32 }
  function Product(n: G.Word): G.Word { ((n as nat)*32)%G.Modulus() }
  lemma Fit(n: G.Word)
    requires n <= Limit()
    ensures Product(n) == (n as nat)*32
    ensures Product(n)/32 == n
  {}
  lemma Overflow(n: G.Word)
    requires n > Limit()
    ensures Product(n)/32 < n
  {
    assert Product(n) < G.Modulus();
    assert Product(n)/32 <= Limit();
  }
}
