// SPDX-License-Identifier: MIT
// Physical call input snapshots, partial output writes and bounded returndata copies.
include "../copy/Memory.dfy"
module BytecodeExternalMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  type Byte = S.Byte
  type Word = S.Word
  function Footprint(offset: Word, size: Word): nat { if size == 0 then 0 else (offset as nat)+size }
  function Maximum(a: nat, b: nat): nat { if a >= b then a else b }
  predicate Fits(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word) {
    |mem| < G.Modulus() && S.Round32(Maximum(Footprint(inputOffset,inputSize),Footprint(outputOffset,outputSize))) < G.Modulus()
  }
  function Expanded(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word): seq<Byte> {
    S.Expand(mem,Maximum(Footprint(inputOffset,inputSize),Footprint(outputOffset,outputSize)))
  }
  // Snapshot the input before the external call can overwrite its output region.
  function Input(mem: seq<Byte>, offset: Word, size: Word): seq<Byte> { S.Window(mem,offset,size) }
  function Copied(outputSize: Word, returned: seq<Byte>): nat { if outputSize <= |returned| then outputSize else |returned| }
  function Output(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word, returned: seq<Byte>): seq<Byte> {
    C.Write(Expanded(mem,inputOffset,inputSize,outputOffset,outputSize),outputOffset,returned[..Copied(outputSize,returned)])
  }
  function ReturnCopy(mem: seq<Byte>, destination: Word, source: Word, size: Word, returned: seq<Byte>): seq<Byte>
    requires (source as nat)+size <= |returned|
  { C.Write(mem,destination,returned[source..source+size]) }
  lemma ExpandedSize(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word)
    ensures |Expanded(mem,inputOffset,inputSize,outputOffset,outputSize)| >= |mem|
    ensures |Expanded(mem,inputOffset,inputSize,outputOffset,outputSize)| >= Footprint(inputOffset,inputSize)
    ensures |Expanded(mem,inputOffset,inputSize,outputOffset,outputSize)| >= Footprint(outputOffset,outputSize)
    ensures Fits(mem,inputOffset,inputSize,outputOffset,outputSize) ==> |Expanded(mem,inputOffset,inputSize,outputOffset,outputSize)| < G.Modulus()
  { C.Rounded(Maximum(Footprint(inputOffset,inputSize),Footprint(outputOffset,outputSize))); }
  lemma InputSnapshot(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word)
    ensures |Input(mem,inputOffset,inputSize)| == inputSize
    ensures inputSize > 0 ==> Input(mem,inputOffset,inputSize) == Expanded(mem,inputOffset,inputSize,outputOffset,outputSize)[inputOffset..inputOffset+inputSize]
  {
    ExpandedSize(mem,inputOffset,inputSize,outputOffset,outputSize);
    if inputSize > 0 {
      var expanded := Expanded(mem,inputOffset,inputSize,outputOffset,outputSize);
      forall i: nat | i < inputSize
        ensures Input(mem,inputOffset,inputSize)[i] == expanded[inputOffset+i]
      { assert inputOffset+i < |expanded|; }
    }
  }
  lemma OutputSize(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word, returned: seq<Byte>)
    ensures |Output(mem,inputOffset,inputSize,outputOffset,outputSize,returned)| == |Expanded(mem,inputOffset,inputSize,outputOffset,outputSize)|
    ensures Fits(mem,inputOffset,inputSize,outputOffset,outputSize) ==> |Output(mem,inputOffset,inputSize,outputOffset,outputSize,returned)| < G.Modulus()
  {
    ExpandedSize(mem,inputOffset,inputSize,outputOffset,outputSize);
    var expanded := Expanded(mem,inputOffset,inputSize,outputOffset,outputSize);
    var count := Copied(outputSize,returned);
    if count > 0 {
      assert outputSize > 0 && outputOffset+count <= |expanded|;
      C.RoundedMonotone(outputOffset+count,Maximum(Footprint(inputOffset,inputSize),Footprint(outputOffset,outputSize)));
    }
    C.Size(expanded,outputOffset,returned[..count]);
  }
  lemma OutputByte(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word, returned: seq<Byte>, index: nat)
    requires index < Copied(outputSize,returned)
    ensures Output(mem,inputOffset,inputSize,outputOffset,outputSize,returned)[outputOffset+index] == returned[index]
  { C.Span(Expanded(mem,inputOffset,inputSize,outputOffset,outputSize),outputOffset,returned[..Copied(outputSize,returned)]); }
  lemma OutputFrame(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word, returned: seq<Byte>, index: nat)
    requires index < |mem| && (index < outputOffset || outputOffset+Copied(outputSize,returned) <= index)
    ensures Output(mem,inputOffset,inputSize,outputOffset,outputSize,returned)[index] == mem[index]
  {
    ExpandedSize(mem,inputOffset,inputSize,outputOffset,outputSize);
    var expanded := Expanded(mem,inputOffset,inputSize,outputOffset,outputSize);
    C.Frame(expanded,outputOffset,returned[..Copied(outputSize,returned)]);
    assert expanded[index] == mem[index];
  }
  lemma ZeroOutput(mem: seq<Byte>, inputOffset: Word, inputSize: Word, outputOffset: Word, returned: seq<Byte>)
    ensures Output(mem,inputOffset,inputSize,outputOffset,0,returned) == Expanded(mem,inputOffset,inputSize,outputOffset,0)
  {}
  lemma CopyByte(mem: seq<Byte>, destination: Word, source: Word, size: Word, returned: seq<Byte>, index: nat)
    requires (source as nat)+size <= |returned| && index < size
    ensures ReturnCopy(mem,destination,source,size,returned)[destination+index] == returned[source+index]
  { C.Span(mem,destination,returned[source..source+size]); }
  lemma CopyFrame(mem: seq<Byte>, destination: Word, source: Word, size: Word, returned: seq<Byte>, index: nat)
    requires (source as nat)+size <= |returned| && index < |mem| && (index < destination || destination+size <= index)
    ensures ReturnCopy(mem,destination,source,size,returned)[index] == mem[index]
  { C.Frame(mem,destination,returned[source..source+size]); }
  lemma EmptyCopy(mem: seq<Byte>, destination: Word, source: Word, returned: seq<Byte>)
    requires source <= |returned|
    ensures ReturnCopy(mem,destination,source,0,returned) == mem
  {}
}
