// SPDX-License-Identifier: MIT
module SourceTotalMemoryV1 {
  ghost predicate Total(mem: imap<int,bv8>) { forall a :: a in mem }
  ghost function Copy(mem: imap<int,bv8>, dest: int, src: seq<bv8>): imap<int,bv8>
    requires Total(mem)
    ensures Total(Copy(mem,dest,src))
  { imap a: int :: if dest <= a < dest+|src| then src[a-dest] else mem[a] }
  lemma Cell(mem: imap<int,bv8>, dest: int, src: seq<bv8>, a: int)
    requires Total(mem)
    ensures dest <= a < dest+|src| ==> Copy(mem,dest,src)[a] == src[a-dest]
    ensures a < dest || a >= dest+|src| ==> Copy(mem,dest,src)[a] == mem[a]
  { }
  lemma ReplacementCell(mem: imap<int,bv8>, ptr: int, dst: seq<bv8>, offset: int, src: seq<bv8>, i: int)
    requires Total(mem)
    requires forall j | 0 <= j < |dst| :: mem[ptr+32+j] == dst[j]
    requires 0 <= offset && offset+|src| <= |dst|
    requires 0 <= i < |dst|
    ensures Copy(mem,ptr+32+offset,src)[ptr+32+i] == (dst[..offset]+src+dst[offset+|src|..])[i]
  {
    Cell(mem,ptr+32+offset,src,ptr+32+i);
    if i < offset { } else if i < offset+|src| { } else { }
  }
  lemma OutsideObject(mem: imap<int,bv8>,ptr: int,dst: seq<bv8>,offset: int,src: seq<bv8>)
    requires Total(mem) && 0 <= offset && offset+|src| <= |dst|
    ensures forall a | a < ptr+32 || a >= ptr+32+|dst| :: Copy(mem,ptr+32+offset,src)[a] == mem[a]
  {
    forall a | a < ptr+32 || a >= ptr+32+|dst|
      ensures Copy(mem,ptr+32+offset,src)[a] == mem[a]
    { Cell(mem,ptr+32+offset,src,a); }
  }
}
