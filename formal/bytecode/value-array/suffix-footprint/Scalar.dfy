// SPDX-License-Identifier: MIT
// Descriptor span and decimal-stop bounds imply exact checked product fitting.
include "../../scans/Machine.dfy"
include "../../../foundations/v5/ProductOrder.dfy"
module BytecodeCollectionsSuffixFootprintScalar {
  import G = BytecodeGetterMachine
  import O = SharedFoundationProductOrderV5
  lemma ProductFits(words: G.Word,k: G.Word,p: G.Word,end: G.Word)
    requires p < end < 0x10000000000000000
    requires words <= 0xffffffff*(end-p) && k <= 0xffffffff*10+9
    ensures 0 <= words*k < G.Modulus()
  {
    assert words <= 0xffffffff*end;
    assert words < 0x1000000000000000000000000;
    assert k < 0x1000000000;
    O.ProductNonnegative(words,k);
    O.ProductMonotone(k,0x1000000000,words);
    assert words*k == k*words && words*0x1000000000 == 0x1000000000*words;
    assert words*k <= words*0x1000000000;
    assert words*0x1000000000 < 0x1000000000000000000000000000000000;
    assert 0x1000000000000000000000000000000000 < G.Modulus();
  }
}
