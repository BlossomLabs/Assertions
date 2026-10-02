// SPDX-License-Identifier: MIT
// Same-domain arithmetic support for the actual one-byte SUB at PC20343.
include "../byte-at-body-support/Kernel.dfy"
module OperationsByteAtSerializationCount {
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import N = OperationsByteAtIndices
  lemma OneByte(position:Word)
    requires position<M-1
    ensures ((position+1)%M+M-position)%M==1
  {
    assert (position+1)%M==position+1;
    assert position+1+M-position==M+1;
  }
  lemma SelectedPosition(c:Word,length:Word)
    requires length<I.U64 && N.FitsIndex(c,length)
    ensures N.Position(c,length)<M-1
  { assert N.Position(c,length)<length; }
}
