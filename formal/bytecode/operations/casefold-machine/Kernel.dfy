// SPDX-License-Identifier: MIT
// Physical original-byte prefix invariant; native verification pending.
include "Binary.generated.dfy"
include "Memory.dfy"
include "../../word-fold/byte-representation-repair-v9/Representation.dfy"
include "../../scans/Representation.dfy"
module OperationsCaseFoldKernel {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import F = OperationsCaseFoldMachine
  import P = OperationsCaseFoldMemory
  import I = OperationsCaseFoldInputs
  import B = OperationsCaseFoldBinary
  import V = BytecodeFoldByteRepresentationV9
  predicate Input(data:seq<S.Byte>,offset:S.Word,length:S.Word) {
    (offset as nat)+length<=|data|<I.U64
  }
  function Base():seq<S.Byte> { S.Store([],64,128) }
  lemma BaseFits()
    ensures |Base()|==96 && |Base()|%32==0 && S.Load(Base(),64)==128
  { R.StoredWord([],64,128); }
  function Free(length:S.Word):S.Word
    requires length<I.U64
  { 160+S.Round32(length) }
  function Allocated(length:S.Word):seq<S.Byte>
    requires length<I.U64
  { S.Store(Base(),64,Free(length)) }
  function Initial(data:seq<S.Byte>,offset:S.Word,length:S.Word):seq<S.Byte>
    requires Input(data,offset,length)
  {
    var mem:=S.Store(Allocated(length),128,length);
    S.Store(C.Calldata(mem,160,offset,length,data),160+length,0)
  }
  predicate Ready(mem:seq<S.Byte>,length:S.Word) {
    |mem|%32==0 && 192+(length as nat)<=|mem|<G.Modulus() && length<I.U64 && S.Load(mem,128)==length
  }
  predicate Inv(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,index:S.Word,lower:bool) {
    Input(data,offset,length) && Ready(mem,length) && index<=length && S.Load(mem,64)==Free(length) &&
    (forall j:nat {:trigger mem[160+j]} :: j<length ==>
                                             mem[160+j]==(if j<index then I.Fold(lower,data[offset+j]) else data[offset+j]))
  }
  lemma Load(mem:seq<S.Byte>,length:S.Word,at:S.Word)
    requires Ready(mem,length) && (at as nat)+32<=|mem|
    ensures S.Expand(mem,(at as nat)+32)==mem
    ensures S.Load(mem,at)==S.DataWord(mem,at)
  {
    C.RoundedMonotone((at as nat)+32,|mem|);
    assert S.Round32(|mem|)==|mem|;
    R.WordProjection(mem,at);R.WindowFits(mem,at,32);
    assert G.Grow(mem,(at as nat)+32)==mem;
  }
  lemma First(mem:seq<S.Byte>,length:S.Word,index:S.Word) returns(cell:S.Byte)
    requires Ready(mem,length) && index<length
    ensures cell==mem[160+index]
    ensures F.Byte(S.Load(mem,160+index),0)==cell
    ensures G.BitAnd(S.Load(mem,160+index),B.Mask())==B.Cell(cell)
  {
    Load(mem,length,160+index);V.First(mem,160+index);
    V.ShiftWord(S.Load(mem,160+index));B.PowerLiteral();
    var other:=B.First(S.Load(mem,160+index));cell:=mem[160+index];
  }
  lemma WordFrame(mem:seq<S.Byte>,length:S.Word,index:S.Word,value:S.Byte,at:S.Word)
    requires Ready(mem,length) && index<length && (at as nat)+32<=160
    ensures S.Load(F.Store8(mem,160+index,value),at)==S.Load(mem,at)
  {
    P.InBounds(mem,160+index,value);
    forall j:nat {:trigger F.Store8(mem,160+index,value)[at+j]} | j<32
      ensures F.Store8(mem,160+index,value)[at+j]==mem[at+j]
    { P.Frame(mem,160+index,value,at+j); }
    assert F.Store8(mem,160+index,value)[at..at+32]==mem[at..at+32];
    R.WordProjection(mem,at);R.WordProjection(F.Store8(mem,160+index,value),at);
  }
  lemma FoldStep(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,index:S.Word,lower:bool)
    requires Inv(mem,data,offset,length,index,lower) && index<length
    ensures Inv(F.Store8(mem,160+index,I.Fold(lower,data[offset+index])),data,offset,length,index+1,lower)
  {
    var value:=I.Fold(lower,data[offset+index]);P.InBounds(mem,160+index,value);
    WordFrame(mem,length,index,value,64);WordFrame(mem,length,index,value,128);
    forall j:nat {:trigger F.Store8(mem,160+index,value)[160+j]} | j<length
      ensures F.Store8(mem,160+index,value)[160+j]==(if j<index+1 then I.Fold(lower,data[offset+j]) else data[offset+j])
    { if j!=index { P.Frame(mem,160+index,value,160+j); } else { P.Write(mem,160+index,value); } }
  }
  lemma UnchangedStep(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,index:S.Word,lower:bool)
    requires Inv(mem,data,offset,length,index,lower) && index<length
    requires I.Fold(lower,data[offset+index])==data[offset+index]
    ensures Inv(mem,data,offset,length,index+1,lower)
  {
    forall j:nat {:trigger mem[160+j]} | j<length
      ensures mem[160+j]==(if j<index+1 then I.Fold(lower,data[offset+j]) else data[offset+j])
    { }
  }
  lemma InitialInv(data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool)
    requires Input(data,offset,length)
    ensures Inv(Initial(data,offset,length),data,offset,length,0,lower)
  {
    var first:=Allocated(length);BaseFits();R.StoredWord(Base(),64,Free(length));
    var header:=S.Store(first,128,length);R.StoredWord(first,128,length);R.StoredFrame(first,128,length,64);
    var copied:=C.Calldata(header,160,offset,length,data);C.Size(header,160,S.Window(data,offset,length));C.Rounded(160+(length as nat));
    forall j:nat {:trigger copied[j]} | j<160
      ensures copied[j]==header[j]
    { C.Frame(header,160,S.Window(data,offset,length)); }
    assert copied[64..96]==header[64..96];assert copied[128..160]==header[128..160];
    R.WordProjection(copied,64);R.WordProjection(copied,128);R.WordProjection(header,64);R.WordProjection(header,128);
    var mem:=S.Store(copied,160+length,0);R.StoredWord(copied,160+length,0);R.StoredFrame(copied,160+length,0,64);R.StoredFrame(copied,160+length,0,128);R.Expansion(copied,192+(length as nat));
    forall j:nat {:trigger mem[160+j]} | j<length
      ensures mem[160+j]==data[offset+j]
    { C.CalldataValue(header,160,offset,length,data,j);assert mem[160+j]==copied[160+j]; }
  }
}
