// SPDX-License-Identifier: MIT
// Candidate support for actual byteAt body guards and physical word loads.
// Native correspondence and retained public evidence remain open.
include "../byte-at-repair-v3/Error.dfy"
module OperationsByteAtBodyKernel {
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import N = OperationsByteAtIndices
  import B = OperationsByteAtMemory
  import K = OperationsByteAtAdmissionKernel
  import E = OperationsByteAtError
  import O = OperationsByteAtOutput
  import C = OperationsByteAtWordConversion

  lemma {:autoRevealDependencies false} HalfWordShift()
    ensures Left(1,255)==N.H
  {
    var input:bv256:=1;
    var output:bv256:=0x8000000000000000000000000000000000000000000000000000000000000000;
    C.Inverse256(input);C.Inverse256(output);
    assert input<<255==output;
    assert (input as nat)==1 && (output as nat)==N.H;
    E.ShiftProjection(1,255,input,N.H);
  }
  lemma {:autoRevealDependencies false} ActualErrorSelectorShift()
    ensures Left(0x6fbae5d7,225)==E.Header
  {
    var input:bv256:=0x6fbae5d7;
    var output:bv256:=0xdf75cbae00000000000000000000000000000000000000000000000000000000;
    C.Inverse256(input);C.Inverse256(output);
    assert input<<225==output;
    assert (input as nat)==0x6fbae5d7 && (output as nat)==E.Header;
    E.ShiftProjection(0x6fbae5d7,225,input,E.Header);
  }
  lemma BooleanBits(a:Word,b:Word)
    requires a<=1 && b<=1
    ensures BitAnd(a,b)==Bool(a==1 && b==1)
    ensures BitOr(a,b)==Bool(a==1 || b==1)
  { reveal BitAnd();reveal BitOr(); }
  lemma StrictGuards(c:Word,length:Word)
    requires length<U64
    ensures N.Signed(length)==length
    ensures N.Signed(((M-length)%M) as Word)==-(length as int)
    ensures N.FitsIndex(c,length) <==> N.Signed(c)<N.Signed(length) && N.Signed(((M-length)%M) as Word)<=N.Signed(c)
  { N.NegativeLength(length); }
  lemma LoadStored(memory:seq<Byte>,offset:nat,value:Word)
    ensures I.DataWord(K.StoreWord(memory,offset,value),offset)==value
  {
    K.StoreWindow(memory,offset,value);I.WordPower();K.EncodeRoundTrip(value,32);
    forall at:nat | offset<=at<offset+32
      ensures I.Cell(K.StoreWord(memory,offset,value),at)==I.Cell(I.Encode(value,32),at-offset)
    {}
    K.EqualLoads(K.StoreWord(memory,offset,value),offset,I.Encode(value,32),0,32);
  }
  lemma LoadFrame(memory:seq<Byte>,input:seq<Byte>,source:nat,destination:nat,count:nat,offset:nat)
    requires offset+32<=|memory|
    requires destination+count<=offset || offset+32<=destination
    ensures I.DataWord(B.Copy(memory,input,source,destination,count),offset)==I.DataWord(memory,offset)
  {
    B.CopyLength(memory,input,source,destination,count);
    forall at:nat | offset<=at<offset+32
      ensures I.Cell(B.Copy(memory,input,source,destination,count),at)==I.Cell(memory,at)
    { B.CopyFrame(memory,input,source,destination,count,at); }
    K.EqualLoads(B.Copy(memory,input,source,destination,count),offset,memory,offset,32);
  }
  lemma LoadMovedFrame(memory:seq<Byte>,source:nat,destination:nat,count:nat,offset:nat)
    requires offset+32<=|memory|
    requires destination+count<=offset || offset+32<=destination
    ensures I.DataWord(B.Move(memory,source,destination,count),offset)==I.DataWord(memory,offset)
  {
    B.MoveLength(memory,source,destination,count);
    forall at:nat | offset<=at<offset+32
      ensures I.Cell(B.Move(memory,source,destination,count),at)==I.Cell(memory,at)
    { B.MoveFrame(memory,source,destination,count,at); }
    K.EqualLoads(B.Move(memory,source,destination,count),offset,memory,offset,32);
  }
  lemma {:autoRevealDependencies false} AlignOne()
    ensures BitAnd(32,M-32)==32
  {
    C.Nat256(32);C.Nat256(M-32);
    C.Inverse256(32 as bv256);
    assert ((32 as bv256)&((M-32) as bv256))==(32 as bv256);
    reveal BitAnd();
  }
  lemma HeapLoads(data:seq<Byte>,source:nat)
    ensures I.DataWord(O.InitialHeap(),64)==128
    ensures I.DataWord(O.Allocated(),64)==192
    ensures I.DataWord(O.TemporaryHeader(),64)==192
    ensures I.DataWord(O.Selected(data,source),64)==192
    ensures I.DataWord(O.Temporary(data,source),64)==192
    ensures I.DataWord(O.OffsetHeader(data,source),64)==192
    ensures I.DataWord(O.LengthHeader(data,source),64)==192
    ensures I.DataWord(O.Copied(data,source),64)==192
    ensures I.DataWord(O.Finished(data,source),64)==192
  {
    O.Sizes(data,source);LoadStored([],64,128);LoadStored(O.InitialHeap(),64,192);
    LoadFrame(O.Allocated(),I.Encode(1,32),0,128,32,64);
    LoadFrame(O.TemporaryHeader(),data,source,160,1,64);
    LoadFrame(O.Selected(data,source),I.Encode(0,32),0,161,32,64);
    LoadFrame(O.Temporary(data,source),I.Encode(32,32),0,192,32,64);
    LoadFrame(O.OffsetHeader(data,source),I.Encode(1,32),0,224,32,64);
    LoadMovedFrame(O.LengthHeader(data,source),160,256,1,64);
    LoadFrame(O.Copied(data,source),I.Encode(0,32),0,257,32,64);
  }
  lemma TemporaryLength(data:seq<Byte>,source:nat)
    ensures I.DataWord(O.Temporary(data,source),128)==1
    ensures I.DataWord(O.OffsetHeader(data,source),128)==1
    ensures I.DataWord(O.LengthHeader(data,source),128)==1
  {
    O.Sizes(data,source);LoadStored(O.Allocated(),128,1);
    LoadFrame(O.TemporaryHeader(),data,source,160,1,128);
    LoadFrame(O.Selected(data,source),I.Encode(0,32),0,161,32,128);
    LoadFrame(O.Temporary(data,source),I.Encode(32,32),0,192,32,128);
    LoadFrame(O.OffsetHeader(data,source),I.Encode(1,32),0,224,32,128);
  }
}
