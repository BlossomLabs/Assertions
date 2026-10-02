// SPDX-License-Identifier: MIT
include "../scans/Scalar.dfy"
module ExpressionsAddressFacts {
  import S = BytecodeScanMachine
  import Q = BytecodeScanScalar
  lemma Shifts()
    ensures S.ShiftLeft(1,160) == 0x10000000000000000000000000000000000000000
    ensures S.ShiftLeft(0x64a42493,224) == 0x64a4249300000000000000000000000000000000000000000000000000000000
  {
    reveal S.ShiftLeft();
    Q.Narrow(1); Q.Narrow(0x64a42493);
    Q.ShiftDefinition(1,160); Q.ShiftDefinition(0x64a42493,224);
  }
  lemma ExpansionIdentity(mem: seq<S.Byte>, end: nat)
    requires |mem| % 32 == 0 && end <= |mem|
    ensures S.Expand(mem,end) == mem
  {
    assert S.Round32(end) <= |mem|;
  }
}
