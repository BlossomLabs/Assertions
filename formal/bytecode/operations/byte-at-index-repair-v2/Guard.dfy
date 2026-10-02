// SPDX-License-Identifier: MIT
// Checked candidates for the reached negative-index compiler addition guard.
include "../byte-at-body-support/Kernel.dfy"
module OperationsByteAtNegativeGuard {
  import opened OperationsByteAtMachine
  import N = OperationsByteAtIndices
  import S = OperationsByteAtBodyKernel
  lemma NegativeAddition(c:Word,b:Word)
    requires N.FitsIndex(c,b) && N.Signed(c)<0
    ensures N.Signed(((c+b)%M) as Word)==b+N.Signed(c)
    ensures Bool(N.Signed(b)<N.Signed(0))==0
    ensures Bool(N.Signed(((c+b)%M) as Word)<N.Signed(c))==0
    ensures BitAnd(0,1)==0 && BitAnd(0,0)==0 && BitOr(0,0)==0
  {
    N.NegativePosition(c,b);
    S.BooleanBits(0,1);S.BooleanBits(0,0);
  }
}
