// SPDX-License-Identifier: MIT
// Unverified candidate for the exact reached byteAt byte-memory write sequence.
// Compiler-bound control/actual MLOAD bridges and complete retention remain open.
include "AdmissionKernel.dfy"
module OperationsByteAtOutput {
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import B = OperationsByteAtMemory
  import K = OperationsByteAtAdmissionKernel
  function InitialHeap(): seq<Byte> { K.StoreWord([],64,128) }
  function Allocated(): seq<Byte> { K.StoreWord(InitialHeap(),64,192) }
  function TemporaryHeader(): seq<Byte> { K.StoreWord(Allocated(),128,1) }
  function Selected(data: seq<Byte>,source: nat): seq<Byte> { B.Copy(TemporaryHeader(),data,source,160,1) }
  function Temporary(data: seq<Byte>,source: nat): seq<Byte> { K.StoreWord(Selected(data,source),161,0) }
  function OffsetHeader(data: seq<Byte>,source: nat): seq<Byte> { K.StoreWord(Temporary(data,source),192,32) }
  function LengthHeader(data: seq<Byte>,source: nat): seq<Byte> { K.StoreWord(OffsetHeader(data,source),224,1) }
  function Copied(data: seq<Byte>,source: nat): seq<Byte> { B.Move(LengthHeader(data,source),160,256,1) }
  function Finished(data: seq<Byte>,source: nat): seq<Byte> { K.StoreWord(Copied(data,source),257,0) }
  lemma Sizes(data: seq<Byte>,source: nat)
    ensures |InitialHeap()| == 96 && |Allocated()| == 96
    ensures |TemporaryHeader()| == 160 && |Selected(data,source)| == 192
    ensures |Temporary(data,source)| == 224 && |OffsetHeader(data,source)| == 224
    ensures |LengthHeader(data,source)| == 256 && |Copied(data,source)| == 288
    ensures |Finished(data,source)| == 320
  {
    B.CopyLength([],I.Encode(128,32),0,64,32);
    B.CopyLength(InitialHeap(),I.Encode(192,32),0,64,32);
    B.CopyLength(Allocated(),I.Encode(1,32),0,128,32);
    B.CopyLength(TemporaryHeader(),data,source,160,1);
    B.CopyLength(Selected(data,source),I.Encode(0,32),0,161,32);
    B.CopyLength(Temporary(data,source),I.Encode(32,32),0,192,32);
    B.CopyLength(OffsetHeader(data,source),I.Encode(1,32),0,224,32);
    B.MoveLength(LengthHeader(data,source),160,256,1);
    B.CopyLength(Copied(data,source),I.Encode(0,32),0,257,32);
  }
  lemma OriginalByte(data: seq<Byte>,source: nat)
    requires source < |data|
    ensures LengthHeader(data,source)[160] == data[source]
    ensures Finished(data,source)[256] == data[source]
  {
    Sizes(data,source);
    B.CopiedByte(TemporaryHeader(),data,source,160,1,0);
    B.CopyFrame(Selected(data,source),I.Encode(0,32),0,161,32,160);
    B.CopyFrame(Temporary(data,source),I.Encode(32,32),0,192,32,160);
    B.CopyFrame(OffsetHeader(data,source),I.Encode(1,32),0,224,32,160);
    B.MovedByte(LengthHeader(data,source),160,256,1,0);
    B.CopyFrame(Copied(data,source),I.Encode(0,32),0,257,32,256);
  }
  lemma ZeroByte(width: nat,index: nat)
    requires index < width
    ensures I.Encode(0,width)[index] == 0
    decreases width
  {
    if index < width-1 { ZeroByte(width-1,index); }
  }
  lemma OffsetSpan(data: seq<Byte>,source: nat,index: nat)
    requires 192 <= index < 224
    ensures Finished(data,source)[index] == I.Encode(32,32)[index-192]
  {
    Sizes(data,source);
    B.CopiedByte(Temporary(data,source),I.Encode(32,32),0,192,32,index-192);
    B.CopyFrame(OffsetHeader(data,source),I.Encode(1,32),0,224,32,index);
    B.MoveFrame(LengthHeader(data,source),160,256,1,index);
    B.CopyFrame(Copied(data,source),I.Encode(0,32),0,257,32,index);
  }
  lemma LengthSpan(data: seq<Byte>,source: nat,index: nat)
    requires 224 <= index < 256
    ensures Finished(data,source)[index] == I.Encode(1,32)[index-224]
  {
    Sizes(data,source);
    B.CopiedByte(OffsetHeader(data,source),I.Encode(1,32),0,224,32,index-224);
    B.MoveFrame(LengthHeader(data,source),160,256,1,index);
    B.CopyFrame(Copied(data,source),I.Encode(0,32),0,257,32,index);
  }
  lemma ZeroTail(data: seq<Byte>,source: nat,index: nat)
    requires 257 <= index < 288
    ensures Finished(data,source)[index] == 0
  {
    Sizes(data,source);
    B.CopiedByte(Copied(data,source),I.Encode(0,32),0,257,32,index-257);
    ZeroByte(32,index-257);
  }
  lemma Receipt(data: seq<Byte>,source: nat)
    requires source < |data|
    ensures ReturnedBytes(Finished(data,source),192,96) == I.ByteEnvelope(data[source])
  {
    Sizes(data,source); OriginalByte(data,source); I.ByteEnvelopeWidth(data[source]);
    forall index: nat | index < 96
      ensures ReturnedBytes(Finished(data,source),192,96)[index] == I.ByteEnvelope(data[source])[index]
    {
      if index < 32 { OffsetSpan(data,source,192+index); }
      else if index < 64 { LengthSpan(data,source,192+index); }
      else if index == 64 {}
      else { ZeroTail(data,source,192+index); }
    }
  }
}
