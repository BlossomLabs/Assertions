// SPDX-License-Identifier: MIT
// Candidate finite physical byte-copy model. No opcode or public evidence yet.
include "Indices.dfy"
module OperationsByteAtMemory {
  import I = OperationsByteAtIndices
  type Byte = n: nat | n < 256 witness 0
  function Max(a: nat,b: nat): nat { if a < b then b else a }
  function Round(n: nat): nat { ((n+31)/32)*32 }
  lemma Rounded(n: nat)
    ensures n <= Round(n) < n+32
    ensures Round(n)%32 == 0
    ensures n%32 == 0 ==> Round(n) == n
  {}
  lemma RoundMonotone(a: nat,b: nat)
    requires a <= b
    ensures Round(a) <= Round(b)
  {}
  function Cell(bytes: seq<Byte>,offset: nat): Byte {
    if offset < |bytes| then bytes[offset] else 0
  }
  function Grow(memory: seq<Byte>,extent: nat): seq<Byte> {
    seq(Max(|memory|,Round(extent)),i requires 0 <= i < Max(|memory|,Round(extent)) => Cell(memory,i))
  }
  lemma Growth(memory: seq<Byte>,extent: nat)
    ensures |Grow(memory,extent)| == Max(|memory|,Round(extent))
    ensures |Grow(memory,extent)| >= |memory| && |Grow(memory,extent)| >= extent
    ensures Grow(memory,extent)[..|memory|] == memory
    ensures forall i: nat | |memory| <= i < |Grow(memory,extent)| :: Grow(memory,extent)[i] == 0
  {
    Rounded(extent);
    forall i: nat | i < |memory|
      ensures Grow(memory,extent)[..|memory|][i] == memory[i]
    {}
  }
  function CopyCell(memory: seq<Byte>,input: seq<Byte>,source: nat,destination: nat,count: nat,index: nat): Byte {
    if destination <= index < destination+count then Cell(input,source+index-destination) else Cell(memory,index)
  }
  function Copy(memory: seq<Byte>,input: seq<Byte>,source: nat,destination: nat,count: nat): seq<Byte> {
    if count == 0 then memory
    else var size := Max(|memory|,Round(destination+count));
         seq(size,(i: nat) requires i < size => CopyCell(memory,input,source,destination,count,i))
  }
  lemma CopyLength(memory: seq<Byte>,input: seq<Byte>,source: nat,destination: nat,count: nat)
    ensures |Copy(memory,input,source,destination,count)| ==
            (if count == 0 then |memory| else Max(|memory|,Round(destination+count)))
    ensures |Copy(memory,input,source,destination,count)| >= |memory|
    ensures count > 0 ==> |Copy(memory,input,source,destination,count)| >= destination+count
  { Rounded(destination+count); }
  lemma CopiedByte(memory: seq<Byte>,input: seq<Byte>,source: nat,destination: nat,count: nat,position: nat)
    requires position < count
    ensures Copy(memory,input,source,destination,count)[destination+position] == Cell(input,source+position)
  { CopyLength(memory,input,source,destination,count); }
  lemma CopyFrame(memory: seq<Byte>,input: seq<Byte>,source: nat,destination: nat,count: nat,index: nat)
    requires index < |Copy(memory,input,source,destination,count)|
    requires index < destination || index >= destination+count
    ensures Copy(memory,input,source,destination,count)[index] == Cell(memory,index)
  {}
  lemma CopiedWindow(memory: seq<Byte>,input: seq<Byte>,source: nat,destination: nat,count: nat)
    requires source+count <= |input| && count > 0
    ensures Copy(memory,input,source,destination,count)[destination..destination+count] == input[source..source+count]
  {
    CopyLength(memory,input,source,destination,count);
    forall i: nat | destination <= i < destination+count
      ensures Copy(memory,input,source,destination,count)[i] == input[source+i-destination]
    { CopiedByte(memory,input,source,destination,count,i-destination); }
  }
  function Move(memory: seq<Byte>,source: nat,destination: nat,count: nat): seq<Byte> {
    if count == 0 then memory
    else Copy(Grow(memory,Max(source+count,destination+count)),memory,source,destination,count)
  }
  lemma MovedByte(memory: seq<Byte>,source: nat,destination: nat,count: nat,position: nat)
    requires position < count
    ensures Move(memory,source,destination,count)[destination+position] == Cell(memory,source+position)
  { CopiedByte(Grow(memory,Max(source+count,destination+count)),memory,source,destination,count,position); }
  lemma MoveLength(memory: seq<Byte>,source: nat,destination: nat,count: nat)
    ensures |Move(memory,source,destination,count)| ==
            (if count == 0 then |memory| else Max(|memory|,Round(Max(source+count,destination+count))))
  {
    if count > 0 {
      RoundMonotone(destination+count,Max(source+count,destination+count));
      Growth(memory,Max(source+count,destination+count));
      CopyLength(Grow(memory,Max(source+count,destination+count)),memory,source,destination,count);
    }
  }
  lemma MoveFrame(memory: seq<Byte>,source: nat,destination: nat,count: nat,index: nat)
    requires index < |memory|
    requires index < destination || index >= destination+count
    ensures Move(memory,source,destination,count)[index] == memory[index]
  {
    if count > 0 {
      Growth(memory,Max(source+count,destination+count));
      CopyLength(Grow(memory,Max(source+count,destination+count)),memory,source,destination,count);
      CopyFrame(Grow(memory,Max(source+count,destination+count)),memory,source,destination,count,index);
    }
  }
  lemma OriginalByteThroughCopies(memory: seq<Byte>,input: seq<Byte>,source: nat,first: nat,second: nat)
    requires source < |input|
    ensures Move(Copy(memory,input,source,first,1),first,second,1)[second] == input[source]
  {
    CopiedByte(memory,input,source,first,1,0);
    CopyLength(memory,input,source,first,1);
    MovedByte(Copy(memory,input,source,first,1),first,second,1,0);
  }
}
