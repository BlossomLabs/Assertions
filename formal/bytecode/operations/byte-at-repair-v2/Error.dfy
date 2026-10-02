// SPDX-License-Identifier: MIT
// Unverified exact overlapping InvalidByteIndex physical error writes.
include "Output.dfy"
module OperationsByteAtError {
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import B = OperationsByteAtMemory
  import K = OperationsByteAtAdmissionKernel
  import O = OperationsByteAtOutput
  import C = OperationsByteAtWordConversion
  const Header: Word := 0xdf75cbae00000000000000000000000000000000000000000000000000000000
  function SelectorStored(): seq<Byte> { K.StoreWord(O.InitialHeap(),128,Header) }
  function IndexStored(index: Word): seq<Byte> { K.StoreWord(SelectorStored(),132,index) }
  function Finished(index: Word,length: Word): seq<Byte> { K.StoreWord(IndexStored(index),164,length) }
  lemma ErrorBits()
    ensures (0xdf75cbae as bv256)<<224 == (Header as bv256)
  {}
  lemma ErrorProjection()
    ensures (((0xdf75cbae as bv256)<<224) as nat)==Header
  {
    ErrorBits();
    C.Inverse256(Header as bv256);
  }
  lemma LeftDefinition(input: Word,amount: Word)
    ensures Left(input,amount)==(if amount>=256 then 0 else ((input as bv256)<<(amount as nat)) as nat)
  { reveal Left(); }
  lemma ShiftProjection(input: Word,amount: Word,bits: bv256,result: Word)
    requires amount<256 && (input as bv256)==bits
    requires result==((bits<<(amount as nat)) as nat)
    ensures Left(input,amount)==result
  { LeftDefinition(input,amount); }
  lemma ErrorShift()
    ensures Left(0xdf75cbae,224) == Header
  {
    ErrorProjection();
    ShiftProjection(0xdf75cbae,224,0xdf75cbae as bv256,Header);
  }
  lemma HeaderEncoding()
    ensures I.Encode(Header,32)[..4] == I.Encode(0xdf75cbae,4)
  {
    K.PaddedEncode(0xdf75cbae,4,28);
    I.WordPower();
    assert I.Power(32) == 256*I.Power(31);
    assert I.Power(31) == 256*I.Power(30);
    assert I.Power(30) == 256*I.Power(29);
    assert I.Power(29) == 256*I.Power(28);
    assert Header == 0xdf75cbae*I.Power(28);
  }
  lemma Sizes(index: Word,length: Word)
    ensures |SelectorStored()| == 160 && |IndexStored(index)| == 192
    ensures |Finished(index,length)| == 224
  {
    B.CopyLength(O.InitialHeap(),I.Encode(Header,32),0,128,32);
    B.CopyLength(SelectorStored(),I.Encode(index,32),0,132,32);
    B.CopyLength(IndexStored(index),I.Encode(length,32),0,164,32);
  }
  lemma SelectorSpan(index: Word,length: Word,at: nat)
    requires 128 <= at < 132
    ensures Finished(index,length)[at] == I.Encode(0xdf75cbae,4)[at-128]
  {
    Sizes(index,length); HeaderEncoding();
    B.CopiedByte(O.InitialHeap(),I.Encode(Header,32),0,128,32,at-128);
    B.CopyFrame(SelectorStored(),I.Encode(index,32),0,132,32,at);
    B.CopyFrame(IndexStored(index),I.Encode(length,32),0,164,32,at);
  }
  lemma IndexSpan(index: Word,length: Word,at: nat)
    requires 132 <= at < 164
    ensures Finished(index,length)[at] == I.Encode(index,32)[at-132]
  {
    Sizes(index,length);
    B.CopiedByte(SelectorStored(),I.Encode(index,32),0,132,32,at-132);
    B.CopyFrame(IndexStored(index),I.Encode(length,32),0,164,32,at);
  }
  lemma LengthSpan(index: Word,length: Word,at: nat)
    requires 164 <= at < 196
    ensures Finished(index,length)[at] == I.Encode(length,32)[at-164]
  {
    Sizes(index,length);
    B.CopiedByte(IndexStored(index),I.Encode(length,32),0,164,32,at-164);
  }
  lemma Receipt(index: Word,length: Word)
    ensures ReturnedBytes(Finished(index,length),128,68) == I.InvalidIndex(index,length)
  {
    Sizes(index,length); I.InvalidReceiptWidth(index,length);
    forall at: nat | at < 68
      ensures ReturnedBytes(Finished(index,length),128,68)[at] == I.InvalidIndex(index,length)[at]
    {
      if at < 4 { SelectorSpan(index,length,128+at); }
      else if at < 36 { IndexSpan(index,length,128+at); }
      else { LengthSpan(index,length,128+at); }
    }
  }
}
