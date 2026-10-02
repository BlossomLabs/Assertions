// SPDX-License-Identifier: MIT
// Exact fresh one-byte copy allocation and generic-return layout; native pending.
include "../string-at-kernel/Kernel.dfy"
include "../tostring-return/Kernel.dfy"
module OperationsStringAtBodyMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import K = OperationsStringAtKernel
  import U = OperationsUtf8Kernel
  import Q = OperationsToStringReturnKernel
  import T = OperationsSerializerMemoryTranslation
  predicate Input(data:seq<S.Byte>,offset:S.Word,length:S.Word,position:S.Word) {
    U.Span(data,offset,length,position) && position<length
  }
  function Cell(data:seq<S.Byte>,offset:S.Word,length:S.Word,position:S.Word):S.Byte
    requires Input(data,offset,length,position)
  { data[offset+position] }
  function FreeSet():seq<S.Byte> { S.Store(K.Initial(),64,192) }
  function Header():seq<S.Byte> { S.Store(FreeSet(),128,1) }
  function Copied(data:seq<S.Byte>,offset:S.Word,length:S.Word,position:S.Word):seq<S.Byte>
    requires Input(data,offset,length,position)
  { C.Calldata(Header(),160,offset+position,1,data) }
  function Finished(data:seq<S.Byte>,offset:S.Word,length:S.Word,position:S.Word):seq<S.Byte>
    requires Input(data,offset,length,position)
  { S.Store(Copied(data,offset,length,position),161,0) }
  lemma Bounds(data:seq<S.Byte>,offset:S.Word,length:S.Word,position:S.Word)
    requires Input(data,offset,length,position)
    ensures offset+position<|data|<U.U64() && position+1<=length<U.U64()
    ensures (offset+position)%G.Modulus()==offset+position && (position+1)%G.Modulus()==position+1
  {}
  lemma LoadSlice(mem:seq<S.Byte>,other:seq<S.Byte>,offset:S.Word)
    requires offset+32<=|mem| && offset+32<=|other| && mem[offset..offset+32]==other[offset..offset+32]
    ensures S.Load(mem,offset)==S.Load(other,offset)
  { G.LoadProjection(mem,offset);G.LoadProjection(other,offset); }
  lemma Stages(data:seq<S.Byte>,offset:S.Word,length:S.Word,position:S.Word)
    requires Input(data,offset,length,position)
    ensures |FreeSet()|==96 && |Header()|==160 && |Copied(data,offset,length,position)|==192 && |Finished(data,offset,length,position)|==224
    ensures S.Load(FreeSet(),64)==192 && S.Load(Header(),64)==192 && S.Load(Copied(data,offset,length,position),64)==192 && S.Load(Finished(data,offset,length,position),64)==192
    ensures S.Load(Header(),128)==1 && S.Load(Copied(data,offset,length,position),128)==1 && S.Load(Finished(data,offset,length,position),128)==1
    ensures S.Expand(K.Initial(),96)==K.Initial() && S.Expand(FreeSet(),96)==FreeSet() && S.Expand(Header(),96)==Header() && S.Expand(Copied(data,offset,length,position),96)==Copied(data,offset,length,position) && S.Expand(Finished(data,offset,length,position),96)==Finished(data,offset,length,position)
    ensures Copied(data,offset,length,position)[160]==Cell(data,offset,length,position) && Finished(data,offset,length,position)[160]==Cell(data,offset,length,position)
  {
    Bounds(data,offset,length,position);K.InitialFits();R.StoredWord(K.Initial(),64,192);R.StoredWord(FreeSet(),128,1);R.StoredFrame(FreeSet(),128,1,64);
    assert S.Window(data,offset+position,1)==[Cell(data,offset,length,position)];
    C.Size(Header(),160,[Cell(data,offset,length,position)]);C.Frame(Header(),160,[Cell(data,offset,length,position)]);C.Span(Header(),160,[Cell(data,offset,length,position)]);
    var copied:=Copied(data,offset,length,position);assert copied[64..96]==Header()[64..96];assert copied[128..160]==Header()[128..160];LoadSlice(copied,Header(),64);LoadSlice(copied,Header(),128);
    R.StoredWord(copied,161,0);R.StoredFrame(copied,161,0,64);R.StoredFrame(copied,161,0,128);
    assert Finished(data,offset,length,position)[160]==copied[160];
  }
  lemma ReturnLayout(data:seq<S.Byte>,offset:S.Word,length:S.Word,position:S.Word)
    requires Input(data,offset,length,position)
    ensures Q.Layout(Finished(data,offset,length,position),[Cell(data,offset,length,position)],128,192)
  {
    Stages(data,offset,length,position);var final:=Finished(data,offset,length,position);T.Load(final,64);T.Load(final,128);assert final[160..161]==[Cell(data,offset,length,position)];
  }
}
