// SPDX-License-Identifier: MIT
// Shared UTF-8 byte, mask, and exact custom-error memory bridges. Native pending.
include "Spec.dfy"
include "../../scans/Representation.dfy"
include "../../word-fold/byte-representation-repair-v9/Representation.dfy"
include "../casefold-machine/Binary.generated.dfy"
module OperationsUtf8Kernel {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import B = BytecodeFoldByteRepresentationV9
  import W = BytecodeApplyWordConversion
  import T = OperationsCaseFoldBinary
  import I = OperationsUtf8Inputs
  function U64():nat { 0x10000000000000000 }
  predicate Span(data:seq<S.Byte>,offset:S.Word,length:S.Word,cursor:S.Word) {
    (offset as nat)+length<=|data|<U64() && cursor<=length
  }
  function Payload(data:seq<S.Byte>,offset:S.Word,length:S.Word):seq<S.Byte>
    requires (offset as nat)+length<=|data|
  { data[offset..offset+length] }
  function Cell(data:seq<S.Byte>,offset:S.Word,length:S.Word,cursor:S.Word,j:nat):S.Byte
    requires Span(data,offset,length,cursor) && cursor+j<length
  { data[offset+cursor+j] }
  lemma First(data:seq<S.Byte>,offset:S.Word,length:S.Word,cursor:S.Word,j:nat)
    requires Span(data,offset,length,cursor) && cursor+j<length
    ensures S.ShiftRight(S.DataWord(data,offset+cursor+j),248)==Cell(data,offset,length,cursor,j)
  { B.Source(data,offset,length,cursor+j); }
  lemma Mask(cell:S.Byte)
    ensures G.BitAnd(cell,255)==cell
  {
    W.Nat8(cell);W.Nat256(cell);
    assert (cell as bv256)==((cell as bv8) as bv256);
    assert (cell as bv256)&(255 as bv256)==(cell as bv256);
  }
  function Mask192(cell:S.Byte):S.Byte { (((cell as bv8)&(192 as bv8)) as nat) }
  lemma ContinuationMask(cell:S.Byte)
    ensures G.BitAnd(cell,192)==Mask192(cell)
    ensures Mask192(cell)==128 <==> I.Continuation(cell)
  {
    W.Nat8(cell);W.Nat256(cell);W.Nat8(Mask192(cell));
    assert ((cell as bv256)&(192 as bv256))==(((cell as bv8)&(192 as bv8)) as bv256);
    assert (cell as bv8)&(192 as bv8)==(128 as bv8) <==> (128 as bv8)<=cell as bv8 && cell as bv8<=(191 as bv8);
  }
  lemma ShiftCell(cell:S.Byte)
    ensures S.ShiftRight(S.ShiftLeft(cell,248),248)==cell
  {
    T.CellWord(cell);
    assert (T.Top256(cell as bv8)>>248)==((cell as bv8) as bv256);
    W.Nat8(cell);W.Nat256(cell);
  }
  function Free(mem:seq<S.Byte>):S.Word { S.Load(mem,64) }
  predicate Memory(mem:seq<S.Byte>) {
    |mem|%32==0 && 96<=|mem|<=Free(mem) && (Free(mem) as nat)+64<G.Modulus()
  }
  predicate Common(prefix:seq<S.Word>,ret:S.Word,data:seq<S.Byte>,offset:S.Word,length:S.Word,cursor:S.Word,mem:seq<S.Byte>) {
    |prefix|<=980 && Span(data,offset,length,cursor) && Memory(mem)
  }
  function Head():S.Word { 0x4197203600000000000000000000000000000000000000000000000000000000 }
  function Packet(at:S.Word):seq<S.Byte> { [0x41,0x97,0x20,0x36]+G.Encode(at,32) }
  function FirstError(mem:seq<S.Byte>):seq<S.Byte> {
    S.Store(mem,Free(mem),Head())
  }
  function ErrorMemory(mem:seq<S.Byte>,at:S.Word):seq<S.Byte>
    requires Memory(mem)
  {
    S.Store(FirstError(mem),Free(mem)+4,at)
  }
  lemma HeadLiteral()
    ensures S.ShiftLeft(550211611,225)==Head()
    ensures G.Encode(Head(),32)[..4]==[0x41,0x97,0x20,0x36]
  { reveal S.ShiftLeft(); }
  lemma FreePreserved(mem:seq<S.Byte>,at:S.Word)
    requires Memory(mem)
    ensures S.Load(FirstError(mem),64)==Free(mem)
    ensures S.Load(ErrorMemory(mem,at),64)==Free(mem)
    ensures |FirstError(mem)|%32==0 && |ErrorMemory(mem,at)|%32==0
    ensures |FirstError(mem)|>=96 && |ErrorMemory(mem,at)|>=96
    ensures |FirstError(mem)|<G.Modulus() && |ErrorMemory(mem,at)|<G.Modulus()
    ensures S.Expand(mem,96)==mem
    ensures S.Expand(FirstError(mem),96)==FirstError(mem)
    ensures S.Expand(ErrorMemory(mem,at),96)==ErrorMemory(mem,at)
  {
    R.StoredWord(mem,Free(mem),Head());R.StoredFrame(mem,Free(mem),Head(),64);
    R.StoredWord(FirstError(mem),Free(mem)+4,at);R.StoredFrame(FirstError(mem),Free(mem)+4,at,64);
    assert S.Round32((Free(mem) as nat)+32)<G.Modulus();
    assert S.Round32((Free(mem) as nat)+36)<G.Modulus();
  }
  lemma ErrorPacket(mem:seq<S.Byte>,at:S.Word)
    requires Memory(mem)
    ensures G.Grow(ErrorMemory(mem,at),(Free(mem) as nat)+36)[Free(mem)..Free(mem)+36]==Packet(at)
  {
    HeadLiteral();FreePreserved(mem,at);
    R.StoredWord(mem,Free(mem),Head());R.StoredWord(FirstError(mem),Free(mem)+4,at);
    var first:=FirstError(mem);var last:=ErrorMemory(mem,at);var f:=Free(mem);
    assert first[f..f+4]==[0x41,0x97,0x20,0x36];
    assert last[f..f+4]==first[f..f+4];
    assert last[f+4..f+36]==G.Encode(at,32);
    assert G.Grow(last,(f as nat)+36)==last;
    assert last[f..f+36]==last[f..f+4]+last[f+4..f+36];
  }
}
