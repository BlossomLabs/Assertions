// SPDX-License-Identifier: MIT
// Seven raw fold ABI heads; dynamic tails may be loose, shared or overlap heads.
include "../../scans/Execution.dfy"
include "../../word-apply/array-stride/Stride.dfy"
module BytecodeFoldRawInputs {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import AS = BytecodeApplyArrayStride
  function U64(): nat { 0x10000000000000000 }
  function AddressBound(): nat { 0x10000000000000000000000000000000000000000 }
  function SourceHead(data: seq<S.Byte>): S.Word { S.DataWord(data,4) }
  function RangeCount(data: seq<S.Byte>): S.Word { S.DataWord(data,4) }
  function Target(data: seq<S.Byte>): S.Word { S.DataWord(data,36) }
  function TemplateHead(data: seq<S.Byte>): S.Word { S.DataWord(data,68) }
  function AccOffset(data: seq<S.Byte>): S.Word { S.DataWord(data,100) }
  function ArrayHead(data: seq<S.Byte>): S.Word { S.DataWord(data,132) }
  function Initial(data: seq<S.Byte>): S.Word { S.DataWord(data,164) }
  function Exit(data: seq<S.Byte>): S.Word { S.DataWord(data,196) }
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
  predicate Heads(data: seq<S.Byte>) { 228 <= |data| < U64() }
  predicate SourceFits(data: seq<S.Byte>, range: bool) {
    Heads(data) && (range || (SourceHead(data) < U64() &&
                              (SourceHead(data) as nat)+36 <= |data| && SourceLength(data) < U64() &&
                              (SourceHead(data) as nat)+36+(SourceLength(data) as nat) <= |data|))
  }
  predicate TargetFits(data: seq<S.Byte>, range: bool) { SourceFits(data,range) && Target(data) < AddressBound() }
  predicate TemplateFits(data: seq<S.Byte>, range: bool) {
    TargetFits(data,range) && TemplateHead(data) < U64() &&
    (TemplateHead(data) as nat)+36 <= |data| && TemplateLength(data) < U64() &&
    (TemplateHead(data) as nat)+36+(TemplateLength(data) as nat) <= |data|
  }
  predicate ArrayHeaderFits(data: seq<S.Byte>, range: bool) {
    TemplateFits(data,range) && ArrayHead(data) < U64() && (ArrayHead(data) as nat)+36 <= |data|
  }
  predicate ArrayFits(data: seq<S.Byte>, range: bool) {
    ArrayHeaderFits(data,range) && Count(data) < U64() &&
    (ArrayHead(data) as nat)+36+32*(Count(data) as nat) <= |data|
  }
  predicate Fits(data: seq<S.Byte>, range: bool) { ArrayFits(data,range) && Exit(data) < 3 }
  predicate ValidReturn(returnPc: S.Word, range: bool) { if range then returnPc == 1069 else returnPc == 727 || returnPc == 746 }
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
  lemma AcceptedCount(data: seq<S.Byte>, range: bool)
    requires ArrayFits(data,range)
    ensures Count(data) < 0x800000000000000
    ensures (Offset(ArrayHead(data)) as nat)+32*(Count(data) as nat) <= |data|
    ensures S.ShiftLeft(Count(data),5) == 32*(Count(data) as nat)
  {
    Pointer(ArrayHead(data));
    AS.Scalar(Count(data));
    AS.FittingCount(Count(data),Offset(ArrayHead(data)),|data|);
  }
  lemma RangeDomain(data: seq<S.Byte>)
    requires SourceFits(data,true)
    ensures RangeCount(data) < G.Modulus()
    ensures RangeCount(data) == SourceHead(data)
  {}
}
