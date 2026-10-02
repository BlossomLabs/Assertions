// SPDX-License-Identifier: MIT
// Shared adapters to the current physical memory model; no upstream axioms or model replacement.
include "../../bytecode/copy/Memory.dfy"
include "../../bytecode/scans/Representation.dfy"
include "SequenceCopy.dfy"
module SharedFoundationMemoryFrames {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import P = SharedFoundationSequenceCopy
  type Byte = S.Byte
  type Word = S.Word
  function WriteViaCopy(mem: seq<Byte>, dst: nat, bytes: seq<Byte>): seq<Byte>
  {
    C.Rounded(dst+|bytes|);
    if |bytes| == 0 then mem else P.Copy(bytes,S.Expand(mem,dst+|bytes|),dst)
  }
  lemma CopyBridge(mem: seq<Byte>, dst: nat, bytes: seq<Byte>)
    ensures WriteViaCopy(mem,dst,bytes) == C.Write(mem,dst,bytes)
  {
    if |bytes| > 0 {
      reveal P.Copy();
      C.Rounded(dst+|bytes|);
      var expanded := S.Expand(mem,dst+|bytes|);
      forall i | 0 <= i < |expanded|
        ensures P.Copy(bytes,expanded,dst)[i] == C.Write(mem,dst,bytes)[i]
      {
        if i < dst { assert C.Write(mem,dst,bytes)[i] == expanded[i]; }
        else if i < dst+|bytes| { assert C.Write(mem,dst,bytes)[i] == bytes[i-dst]; }
        else { assert C.Write(mem,dst,bytes)[i] == expanded[i]; }
      }
    }
  }
  lemma StoreByteFrame(mem: seq<Byte>, dst: Word, value: Word, index: nat)
    requires index < |mem| && (index < dst || dst+32 <= index)
    ensures S.Store(mem,dst,value)[index] == mem[index]
    ensures |S.Store(mem,dst,value)| >= |mem|
  {
    var expanded := S.Expand(mem,dst+32);
    assert expanded[..|mem|] == mem;
    assert |G.Encode(value,32)| == 32;
    if index < dst { assert S.Store(mem,dst,value)[index] == expanded[index]; }
    else { assert S.Store(mem,dst,value)[index] == expanded[index]; }
  }
  lemma StoreSpanFrame(mem: seq<Byte>, dst: Word, value: Word, start: nat, length: nat)
    requires start+length <= |mem|
    requires length == 0 || start+length <= dst || dst+32 <= start
    ensures S.Store(mem,dst,value)[start..start+length] == mem[start..start+length]
  {
    forall i | 0 <= i < length
      ensures S.Store(mem,dst,value)[start+i] == mem[start+i]
    { StoreByteFrame(mem,dst,value,start+i); }
  }
  lemma CopySpanFrame(mem: seq<Byte>, dst: Word, src: Word, count: Word, start: nat, length: nat)
    requires start+length <= |mem|
    requires length == 0 || start+length <= dst || dst+count <= start
    ensures C.Memory(mem,dst,src,count)[start..start+length] == mem[start..start+length]
  {
    C.MemorySize(mem,dst,src,count);
    forall i | 0 <= i < length
      ensures C.Memory(mem,dst,src,count)[start+i] == mem[start+i]
    { C.MemoryFrame(mem,dst,src,count,start+i); }
  }
  lemma CopyWordFrame(mem: seq<Byte>, dst: Word, src: Word, count: Word, other: Word)
    requires other+32 <= |mem|
    requires other+32 <= dst || dst+count <= other
    ensures S.Load(C.Memory(mem,dst,src,count),other) == S.Load(mem,other)
  {
    CopySpanFrame(mem,dst,src,count,other,32);
    C.MemorySize(mem,dst,src,count);
    assert G.Grow(mem,other+32) == mem;
    assert G.Grow(C.Memory(mem,dst,src,count),other+32) == C.Memory(mem,dst,src,count);
  }
}
