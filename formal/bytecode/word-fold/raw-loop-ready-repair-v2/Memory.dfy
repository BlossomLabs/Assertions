// SPDX-License-Identifier: MIT
// Raw admitted allocation and copy imply actual finite-loop memory admission.
include "../raw-template/Connection.dfy"
include "../loop-model-repair-v2/Model.dfy"
module BytecodeFoldRawLoopReadyV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import I = BytecodeFoldRawInputs
  import T = BytecodeFoldRawTemplate
  import A = BytecodeFoldRunMemory
  import H = BytecodeApplyTemplateMemory
  import F = BytecodeFoldTemplateFrames
  import W = BytecodeFoldElementWindowInputs
  import V = BytecodeApplyWindowInputs
  import L = BytecodeFoldLoopModelV2
  import RT = BytecodeFoldRawTarget
  function Config(data: seq<Byte>,domain: nat): L.Configuration
    requires domain < 3
  { L.Configuration(T.SourceOffset(data,domain),T.SourceLength(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),0,320,domain,A.Count(data,domain),I.AccOffset(data),I.Exit(data),I.Target(data)) }
  lemma CopiedHeadWord(data: seq<Byte>,domain: nat,slot: Word)
    requires domain < 3 && I.Fits(data,domain == 0) && slot+32 <= 352
    ensures Load(H.Copied(A.Heap(data,domain),320,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data),slot) == Load(H.Head(A.Heap(data,domain),320,I.TemplateLength(data)),slot)
  {
    hide DataWord();
    A.Layout(data,domain);I.Pointer(I.TemplateHead(data));
    F.Geometry(A.Heap(data,domain),320,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
    var head := H.Head(A.Heap(data,domain),320,I.TemplateLength(data));
    var copied := H.Copied(A.Heap(data,domain),320,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
    C.Frame(head,352,Window(data,I.Offset(I.TemplateHead(data)),I.TemplateLength(data)));
    forall j: nat {:trigger copied[slot+j]} | j < 32
      ensures copied[slot+j] == head[slot+j]
    {}
    assert copied[slot..slot+32] == head[slot..slot+32];
    assert G.Grow(copied,slot+32) == copied && G.Grow(head,slot+32) == head;
  }
  lemma Memory(data: seq<Byte>,domain: nat)
    requires domain < 3 && I.Fits(data,domain == 0)
    ensures 352+I.TemplateLength(data) <= |T.LoopMemory(data,domain)| < 0x80000000000000000 && |T.LoopMemory(data,domain)|%32 == 0
    ensures Load(T.LoopMemory(data,domain),64) == H.Free(320,I.TemplateLength(data))
    ensures Load(T.LoopMemory(data,domain),320) == I.TemplateLength(data)
    ensures Load(T.LoopMemory(data,domain),256) == I.Initial(data)
  {
    hide DataWord();
    A.Layout(data,domain);I.Pointer(I.TemplateHead(data));
    var heap := A.Heap(data,domain);var length := I.TemplateLength(data);
    H.Arithmetic(320,length);F.Geometry(heap,320,I.Offset(I.TemplateHead(data)),length,data);
    R.StoredWord(heap,64,H.Free(320,length));
    R.StoredWord(H.Pointer(heap,320,length),320,length);
    C.Size(H.Head(heap,320,length),352,Window(data,I.Offset(I.TemplateHead(data)),length));
    C.Rounded(352+length);
    R.StoredWord(H.Copied(heap,320,I.Offset(I.TemplateHead(data)),length,data),352+length,0);
    R.StoredFrame(H.Pointer(heap,320,length),320,length,64);
    CopiedHeadWord(data,domain,64);CopiedHeadWord(data,domain,320);
    R.StoredFrame(H.Copied(heap,320,I.Offset(I.TemplateHead(data)),length,data),352+length,0,64);
    R.StoredFrame(H.Copied(heap,320,I.Offset(I.TemplateHead(data)),length,data),352+length,0,320);
    T.MemoryLayout(data,domain);
  }
  lemma Windows(length: Word,arrayOffset: Word,count: Word,data: seq<Byte>)
    requires W.Valid(length,arrayOffset,count,data)
    ensures V.Valid(length,arrayOffset,count,data)
  {
    hide DataWord();
    assert V.Represented(length,arrayOffset,count,data);
    forall j: nat | j < count
      ensures V.At(arrayOffset,j,data) <= length-32
    { assert V.At(arrayOffset,j,data) == W.At(arrayOffset,j,data); }
  }
  lemma Ready(data: seq<Byte>,domain: nat)
    requires RT.Admitted(data,domain)
    ensures L.Ready(data,T.LoopMemory(data,domain),Config(data,domain))
    ensures Load(T.LoopMemory(data,domain),256) == I.Initial(data)
  {
    hide DataWord();hide H.Copied();hide H.Complete();
    Memory(data,domain);T.MemoryLayout(data,domain);
    if domain > 0 { I.Pointer(I.SourceHead(data)); }
    I.Pointer(I.TemplateHead(data));I.Pointer(I.ArrayHead(data));
    H.Arithmetic(320,I.TemplateLength(data));
    Windows(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data);
  }
}
