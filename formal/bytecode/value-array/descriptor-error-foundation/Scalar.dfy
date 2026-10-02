// SPDX-License-Identifier: MIT
// Constructive exact literal SHL for the actual descriptor error selector.
include "Memory.dfy"
include "../../scans/Scalar.dfy"
module BytecodeCollectionsDescriptorErrorScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = BytecodeCollectionsDescriptorErrorMemory
  import SC = BytecodeScanScalar
  lemma Selector()
    ensures S.ShiftLeft(1295247507,225) == H.Header()
  {
    var input: G.Word := 1295247507;var amount: G.Word := 225;
    var bits: bv256 := 1295247507;var header: bv256 := 69839607418959649974994886373187129380178483871789262225004511567993345409024;
    SC.Narrow(input);assert (input as bv256) == bits;
    assert bits << 225 == header;
    SC.ShiftDefinition(input,amount);reveal S.ShiftLeft();
  }
}
