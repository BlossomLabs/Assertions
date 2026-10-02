// SPDX-License-Identifier: MIT
// Ordered raw calldata element windows admitted by the shared compiled check.
include "../../scans/Execution.dfy"
include "../raw-decoder/Inputs.dfy"
module BytecodeApplyWindowInputs {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeApplyRawInputs
  predicate Represented(templateLength: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>) {
    templateLength < I.U64() && |data| < I.U64() && count < 0x800000000000000 &&
    (arrayOffset as nat)+32*(count as nat) <= |data|
  }
  function At(arrayOffset: S.Word,index: nat,data: seq<S.Byte>): S.Word {
    S.DataWord(data,((arrayOffset as nat)+32*index)%G.Modulus())
  }
  predicate Valid(templateLength: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>) {
    Represented(templateLength,arrayOffset,count,data) && templateLength >= 32 &&
    forall j: nat :: j < count ==> At(arrayOffset,j,data) <= templateLength-32
  }
  lemma RawFrame(data: seq<S.Byte>)
    requires I.Fits(data)
    ensures Represented(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  {
    I.AcceptedCount(data);
  }
  lemma Index(templateLength: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,index: nat)
    requires Represented(templateLength,arrayOffset,count,data) && index < count
    ensures (arrayOffset as nat)+32*index+32 <= |data|
    ensures (arrayOffset as nat)+32*index < I.U64()
    ensures index+1 <= count && index < 0x800000000000000
    ensures ((arrayOffset as nat)+32*index)%G.Modulus() == (arrayOffset as nat)+32*index
  {}
  lemma Prefix(templateLength: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,index: nat)
    requires Valid(templateLength,arrayOffset,count,data) && index <= count
    ensures forall j: nat :: j < index ==> At(arrayOffset,j,data) <= templateLength-32
  {}
}
