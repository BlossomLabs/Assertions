// SPDX-License-Identifier: MIT
include "../../scans/Scalar.dfy"
module ExpressionsPublicCallGuardFacts {
  import S = BytecodeScanMachine
  import Q = BytecodeScanScalar
  import G = BytecodeGetterMachine
  lemma Shifts()
    ensures S.ShiftLeft(1,160) == 1461501637330902918203684832716283019655932542976
    ensures S.ShiftLeft(1,224) == 26959946667150639794667015087019630673637144422540572481103610249216
    ensures S.ShiftLeft(4260710243,224) == 114868520915462442597141167955500076753242771306388937253322076133114393919488
    ensures S.ShiftLeft(1480706717,225) == 79839548240023431189621900035380613298627509134309823755590942537928350367744
  {
    reveal S.ShiftLeft();
    Q.Narrow(1); Q.ShiftDefinition(1,160);
    Q.Narrow(1); Q.ShiftDefinition(1,224);
    Q.Narrow(4260710243); Q.ShiftDefinition(4260710243,224);
    Q.Narrow(1480706717); Q.ShiftDefinition(1480706717,225);
  }
  lemma ExpansionIdentity(mem: seq<S.Byte>, end: nat)
    requires |mem|%32 == 0 && end <= |mem|
    ensures S.Expand(mem,end) == mem
  { assert S.Round32(end) <= |mem|; }
  lemma TargetNarrow(target: G.Word)
    requires target < 0x10000000000000000000000000000000000000000
    ensures (target as bv256) == ((target as bv160) as bv256)
  {}
  lemma TargetMask(target: G.Word)
    requires target < 0x10000000000000000000000000000000000000000
    ensures S.BitAnd(target,0xffffffffffffffffffffffffffffffffffffffff) == target
  {
    TargetNarrow(target);
    reveal S.BitAnd();
    assert (((target as bv160) as bv256)&(0xffffffffffffffffffffffffffffffffffffffff as bv256)) == ((target as bv160) as bv256);
  }
}
