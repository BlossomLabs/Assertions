// SPDX-License-Identifier: MIT
// Raw four-head decoder fields and ordered admission, without canonical ABI premises.
include "../../scans/Execution.dfy"
include "../array-stride/Stride.dfy"
include "Scalar.dfy"
module BytecodeApplyRawInputs {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import AS = BytecodeApplyArrayStride
  function U64(): nat { 0x10000000000000000 }
  function AddressBound(): nat { 0x10000000000000000000000000000000000000000 }
  function SourceHead(data: seq<S.Byte>): S.Word { S.DataWord(data,4) }
  function Target(data: seq<S.Byte>): S.Word { S.DataWord(data,36) }
  function TemplateHead(data: seq<S.Byte>): S.Word { S.DataWord(data,68) }
  function ArrayHead(data: seq<S.Byte>): S.Word { S.DataWord(data,100) }
  function Header(head: S.Word): S.Word { ((head as nat)+4)%G.Modulus() }
  function Offset(head: S.Word): S.Word { ((head as nat)+36)%G.Modulus() }
  function SourceLength(data: seq<S.Byte>): S.Word { S.DataWord(data,Header(SourceHead(data))) }
  function TemplateLength(data: seq<S.Byte>): S.Word { S.DataWord(data,Header(TemplateHead(data))) }
  function Count(data: seq<S.Byte>): S.Word { S.DataWord(data,Header(ArrayHead(data))) }
  function Span(data: seq<S.Byte>): S.Word { ((Count(data) as nat)*32)%G.Modulus() }
  opaque function MaskedTarget(data: seq<S.Byte>): S.Word { G.BitAnd(Target(data),0xffffffffffffffffffffffffffffffffffffffff) }
  lemma MaskDefinition(data: seq<S.Byte>)
    ensures MaskedTarget(data) == G.BitAnd(Target(data),0xffffffffffffffffffffffffffffffffffffffff)
  { reveal MaskedTarget(); }
  predicate SourceFits(data: seq<S.Byte>) {
    132 <= |data| < U64() && SourceHead(data) < U64() &&
    (SourceHead(data) as nat)+36 <= |data| && SourceLength(data) < U64() &&
    (SourceHead(data) as nat)+36+(SourceLength(data) as nat) <= |data|
  }
  predicate TargetFits(data: seq<S.Byte>) { SourceFits(data) && Target(data) < AddressBound() }
  predicate TemplateFits(data: seq<S.Byte>) {
    TargetFits(data) && TemplateHead(data) < U64() &&
    (TemplateHead(data) as nat)+36 <= |data| && TemplateLength(data) < U64() &&
    (TemplateHead(data) as nat)+36+(TemplateLength(data) as nat) <= |data|
  }
  predicate ArrayHeaderFits(data: seq<S.Byte>) {
    TemplateFits(data) && ArrayHead(data) < U64() && (ArrayHead(data) as nat)+36 <= |data|
  }
  predicate Fits(data: seq<S.Byte>) {
    ArrayHeaderFits(data) && Count(data) < U64() &&
    (ArrayHead(data) as nat)+36+32*(Count(data) as nat) <= |data|
  }
  predicate ValidReturn(returnPc: S.Word) { returnPc == 784 || returnPc == 1050 }
  lemma Pointer(head: S.Word)
    requires head < U64()
    ensures Header(head) == (head as nat)+4 && Offset(head) == (head as nat)+36
    ensures (Header(head) as nat)+32 == Offset(head)
  {}
  lemma ArrayArithmetic(data: seq<S.Byte>)
    requires ArrayHead(data) < U64() && Count(data) < U64()
    ensures Span(data) == 32*(Count(data) as nat)
    ensures (Offset(ArrayHead(data)) as nat)+(Span(data) as nat) < G.Modulus()
  { Pointer(ArrayHead(data)); }
  lemma AcceptedCount(data: seq<S.Byte>)
    requires Fits(data)
    ensures Count(data) < 0x800000000000000
    ensures (Offset(ArrayHead(data)) as nat)+32*(Count(data) as nat) <= |data|
  {
    Pointer(ArrayHead(data));
    AS.Scalar(Count(data));
    AS.FittingCount(Count(data),Offset(ArrayHead(data)),|data|);
  }
}
