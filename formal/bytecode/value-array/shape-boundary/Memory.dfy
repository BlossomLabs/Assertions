// SPDX-License-Identifier: MIT
include "../encoded-copy/Boundary.dfy"
module BytecodeCollectionsUnpackCopiedFrame {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import H = BytecodeApplyTemplateMemory
  import D = BytecodeCollectionsUnpackDecoder
  import B = BytecodeCollectionsUnpackCopyBoundary
  lemma CopiedWord(data: seq<Byte>,slot: Word)
    requires D.Admitted(data) && slot in {64,128}
    ensures Load(H.Copied(Store([],64,128),128,D.OffsetB(data),D.LengthB(data),data),slot) ==
            Load(H.Head(Store([],64,128),128,D.LengthB(data)),slot)
  {
    hide DataWord();
    D.Bounds(data);
    var head := H.Head(Store([],64,128),128,D.LengthB(data));
    var copied := H.Copied(Store([],64,128),128,D.OffsetB(data),D.LengthB(data),data);
    R.StoredWord([],64,128);H.Arithmetic(128,D.LengthB(data));
    R.StoredWord(Store([],64,128),64,H.Free(128,D.LengthB(data)));
    R.StoredWord(H.Pointer(Store([],64,128),128,D.LengthB(data)),128,D.LengthB(data));
    C.Frame(head,160,Window(data,D.OffsetB(data),D.LengthB(data)));
    C.Size(head,160,Window(data,D.OffsetB(data),D.LengthB(data)));
    assert slot+32 <= |head| && slot+32 <= |copied|;
    forall i {:trigger copied[slot+i]} | 0 <= i < 32
      ensures copied[slot+i] == head[slot+i]
    { assert slot+i < 160; }
    assert copied[slot..slot+32] == head[slot..slot+32];
    assert G.Grow(copied,slot+32) == copied && G.Grow(head,slot+32) == head;
  }
  lemma Frame(data: seq<Byte>)
    requires D.Admitted(data)
    ensures 160+D.LengthB(data) <= |B.CopiedMemory(data)| < 0x80000000000000000
    ensures |B.CopiedMemory(data)|%32 == 0
    ensures Load(B.CopiedMemory(data),64) == H.Free(128,D.LengthB(data)) < 0x40000000000000000
    ensures Load(B.CopiedMemory(data),128) == D.LengthB(data)
  {
    hide DataWord();D.Bounds(data);
    var mem := Store([],64,128);var length := D.LengthB(data);
    R.StoredWord([],64,128);H.Arithmetic(128,length);
    R.StoredWord(mem,64,H.Free(128,length));
    R.StoredWord(H.Pointer(mem,128,length),128,length);
    C.Size(H.Head(mem,128,length),160,Window(data,D.OffsetB(data),length));
    C.Rounded(160+length);
    R.StoredWord(H.Copied(mem,128,D.OffsetB(data),length,data),160+length,0);
    R.StoredFrame(H.Pointer(mem,128,length),128,length,64);
    CopiedWord(data,64);CopiedWord(data,128);
    R.StoredFrame(H.Copied(mem,128,D.OffsetB(data),length,data),160+length,0,64);
    R.StoredFrame(H.Copied(mem,128,D.OffsetB(data),length,data),160+length,0,128);
  }
}
