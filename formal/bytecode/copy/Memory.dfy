// SPDX-License-Identifier: MIT
// Development physical byte-copy foundations; adequate resources are premises.
include "../scans/Machine.dfy"
module BytecodeCopyMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Byte = S.Byte
  type Word = S.Word
  function Write(mem: seq<Byte>, dst: nat, bytes: seq<Byte>): seq<Byte> {
    if |bytes| == 0 then mem
    else var expanded := S.Expand(mem,dst+|bytes|);
         expanded[..dst]+bytes+expanded[dst+|bytes|..]
  }
  function Calldata(mem: seq<Byte>, dst: Word, src: Word, length: Word, data: seq<Byte>): seq<Byte> {
    Write(mem,dst,S.Window(data,src,length))
  }
  function Memory(mem: seq<Byte>, dst: Word, src: Word, length: Word): seq<Byte> {
    if length == 0 then mem
    else var end := if dst >= src then (dst as nat)+length else (src as nat)+length;
         var expanded := S.Expand(mem,end);
         Write(expanded,dst,S.Window(expanded,src,length))
  }
  lemma Rounded(n: nat)
    ensures n <= S.Round32(n) < n+32
    ensures S.Round32(n)%32 == 0
  {}
  lemma Size(mem: seq<Byte>, dst: nat, bytes: seq<Byte>)
    ensures |Write(mem,dst,bytes)| == (if |bytes| == 0 then |mem| else if |mem| >= S.Round32(dst+|bytes|) then |mem| else S.Round32(dst+|bytes|))
  { Rounded(dst+|bytes|); }
  lemma Span(mem: seq<Byte>, dst: nat, bytes: seq<Byte>)
    ensures forall i: nat | i < |bytes| :: Write(mem,dst,bytes)[dst+i] == bytes[i]
  {
    Rounded(dst+|bytes|);
    forall i: nat | i < |bytes|
      ensures Write(mem,dst,bytes)[dst+i] == bytes[i]
    { assert |bytes| > 0; }
  }
  lemma Frame(mem: seq<Byte>, dst: nat, bytes: seq<Byte>)
    ensures forall i: nat | i < |mem| && (i < dst || dst+|bytes| <= i) :: Write(mem,dst,bytes)[i] == mem[i]
  {
    Rounded(dst+|bytes|);
    forall i: nat | i < |mem| && (i < dst || dst+|bytes| <= i)
      ensures Write(mem,dst,bytes)[i] == mem[i]
    {
      if |bytes| > 0 {
        var expanded := S.Expand(mem,dst+|bytes|);
        assert expanded[i] == mem[i];
        if i < dst { assert Write(mem,dst,bytes)[i] == expanded[i]; }
        else { assert Write(mem,dst,bytes)[i] == expanded[i]; }
      }
    }
  }
  lemma ZeroLength(mem: seq<Byte>, dst: Word, src: Word, data: seq<Byte>)
    ensures Calldata(mem,dst,src,0,data) == mem && Memory(mem,dst,src,0) == mem
  { assert S.Window(data,src,0) == []; }
  lemma CalldataValue(mem: seq<Byte>, dst: Word, src: Word, length: Word, data: seq<Byte>, i: nat)
    requires i < length
    ensures Calldata(mem,dst,src,length,data)[dst+i] == (if src+i < |data| then data[src+i] else 0)
  {
    Span(mem,dst,S.Window(data,src,length));
    assert Write(mem,dst,S.Window(data,src,length))[dst+i] == S.Window(data,src,length)[i];
  }
  lemma MemoryValue(mem: seq<Byte>, dst: Word, src: Word, length: Word, i: nat)
    requires i < length
    ensures Memory(mem,dst,src,length)[dst+i] == (if src+i < |mem| then mem[src+i] else 0)
  {
    var end := if dst >= src then (dst as nat)+length else (src as nat)+length;
    Rounded(end);
    var expanded := S.Expand(mem,end);
    Span(expanded,dst,S.Window(expanded,src,length));
    assert src+i < end <= |expanded|;
    assert Write(expanded,dst,S.Window(expanded,src,length))[dst+i] == S.Window(expanded,src,length)[i];
  }
  lemma CopiedWord(mem: seq<Byte>, dst: Word, src: Word, data: seq<Byte>)
    ensures S.Load(Calldata(mem,dst,src,32,data),dst) == S.DataWord(data,src)
  {
    forall i: nat | i < 32
      ensures Calldata(mem,dst,src,32,data)[dst+i] == S.Window(data,src,32)[i]
    { CalldataValue(mem,dst,src,32,data,i); }
    Size(mem,dst,S.Window(data,src,32));
    assert |Calldata(mem,dst,src,32,data)| >= dst+32;
    assert Calldata(mem,dst,src,32,data)[dst..dst+32] == S.Window(data,src,32);
  }
  lemma RoundedMonotone(a: nat, b: nat)
    requires a <= b
    ensures S.Round32(a) <= S.Round32(b)
  {}
  lemma MemorySize(mem: seq<Byte>, dst: Word, src: Word, length: Word)
    ensures |Memory(mem,dst,src,length)| == (if length == 0 then |mem| else
                                             var end := if dst >= src then (dst as nat)+length else (src as nat)+length;
                                             if |mem| >= S.Round32(end) then |mem| else S.Round32(end))
  {
    if length > 0 {
      var end := if dst >= src then (dst as nat)+length else (src as nat)+length;
      var expanded := S.Expand(mem,end);
      RoundedMonotone((dst as nat)+length,end);
      Size(expanded,dst,S.Window(expanded,src,length));
    }
  }
  lemma MemoryFrame(mem: seq<Byte>, dst: Word, src: Word, length: Word, i: nat)
    requires i < |mem| && (i < dst || (dst as nat)+length <= i)
    ensures Memory(mem,dst,src,length)[i] == mem[i]
  {
    if length > 0 {
      var end := if dst >= src then (dst as nat)+length else (src as nat)+length;
      var expanded := S.Expand(mem,end);
      Frame(expanded,dst,S.Window(expanded,src,length));
      assert expanded[i] == mem[i];
    }
  }
  lemma MemoryCopiedWord(mem: seq<Byte>, dst: Word, src: Word)
    ensures S.Load(Memory(mem,dst,src,32),dst) == S.Load(mem,src)
  {
    MemorySize(mem,dst,src,32);
    Rounded((dst as nat)+32);
    assert |Memory(mem,dst,src,32)| >= dst+32;
    var original := G.Grow(mem,(src as nat)+32);
    forall i: nat {:trigger Memory(mem,dst,src,32)[dst+i]} | i < 32
      ensures Memory(mem,dst,src,32)[dst+i] == original[src+i]
    { MemoryValue(mem,dst,src,32,i); }
    assert Memory(mem,dst,src,32)[dst..dst+32] == original[src..src+32];
  }

}
