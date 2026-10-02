// SPDX-License-Identifier: MIT
// Initial call memory and accepted decoder-to-UTF8 frame. Native pending.
include "../string-at-inputs/Inputs.dfy"
include "../utf8-shared/Kernel.dfy"
include "../casefold-machine/Execution.dfy"
module OperationsStringAtKernel {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import I = OperationsStringAtInputs
  import U = OperationsUtf8Kernel
  function Initial():seq<S.Byte> { S.Store([],64,128) }
  lemma InitialFits()
    ensures |Initial()|==96 && S.Load(Initial(),64)==128
    ensures U.Memory(Initial())
  { R.StoredWord([],64,128); }
  lemma DecoderSpan(data:seq<S.Byte>,value:S.Word)
    requires I.Frame(data) && I.Admission(data,value)==I.Accepted
    ensures I.Span(data) && I.PayloadOffset(data)<G.Modulus()
    ensures U.Common([0xa1bc2139,1362,I.PayloadOffset(data),I.Length(data),I.IndexWord(data),96],7291,data,I.PayloadOffset(data),I.Length(data),0,Initial())
  { I.AdmissionSpan(data,value);InitialFits(); }
}
