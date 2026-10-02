// SPDX-License-Identifier: MIT
include "../raw-callback-memory/Memory.dfy"
include "../iteration-memory/Memory.dfy"
include "../raw-decoder/Inputs.dfy"
module BytecodeApplyRawIterationBounds {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import I = BytecodeApplyRawInputs
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import M = BytecodeApplyRepeatedIterationMemory
  function Free(n: S.Word,length: S.Word,index: S.Word): S.Word
    requires n < 0x800000000000000 && length < I.U64() && index <= n
    ensures Free(n,length,index) == H.Free(O.Extent(n),length)+64*index
    ensures O.Extent(n)+32+length <= Free(n,length,index)
    ensures (Free(n,length,index) as nat)+length+160 < M.Bound()
  {
    Allocation(n,length,index);
    H.Free(O.Extent(n),length)+64*index
  }
  lemma Allocation(n: S.Word,length: S.Word,index: S.Word)
    requires n < 0x800000000000000 && length < I.U64() && index <= n
    ensures H.Free(O.Extent(n),length)+64*index < G.Modulus()
    ensures O.Extent(n)+32+length <= H.Free(O.Extent(n),length)+64*index
    ensures (H.Free(O.Extent(n),length) as nat)+64*index+length+160 < M.Bound()
    ensures O.Extent(n) < 0x20000000000000000
  {
    H.Arithmetic(O.Extent(n),length);
    assert O.Extent(n) == 160+32*n;
    assert 96*n < 3*I.U64();
    assert (H.Free(O.Extent(n),length) as nat)+64*index+length+160 < 5*I.U64()+384;
    assert 5*I.U64()+384 < M.Bound();
  }
  lemma Advance(n: S.Word,length: S.Word,index: S.Word)
    requires n < 0x800000000000000 && length < I.U64() && index < n
    ensures Free(n,length,index+1) == Free(n,length,index)+64
    ensures (Free(n,length,index+1) as nat)+length+160 < M.Bound()
  { Allocation(n,length,index);Allocation(n,length,index+1); }
  lemma RawSource(data: seq<S.Byte>,index: S.Word)
    requires I.Fits(data) && I.SourceLength(data)%32 == 0 && index < I.SourceLength(data)/32
    ensures 0 < I.SourceLength(data)/32 < 0x800000000000000
    ensures (I.Offset(I.SourceHead(data)) as nat)+32*index+32 <= |data|
    ensures S.DataWord(data,I.Offset(I.SourceHead(data))+32*index) == G.Decode(data[I.Offset(I.SourceHead(data))+32*index..I.Offset(I.SourceHead(data))+32*index+32])
  {
    I.Pointer(I.SourceHead(data));
    assert I.SourceLength(data) < I.U64();
    assert 32*(index+1) <= I.SourceLength(data);
    R.WordProjection(data,I.Offset(I.SourceHead(data))+32*index);
  }
}
