// SPDX-License-Identifier: MIT
// Independent array predicate and allocation specification for a validator run.
include "../Spec.dfy"
include "DecoderMemory.dfy"
include "Sequences.dfy"
module AssertionsConstraintLoopSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import L = AssertionsConstraintSpec
  import Q = AssertionsConstraintSequences
  type Word = S.Word
  type Byte = S.Byte
  datatype Constraint = Leaf(kind: Word, position: Word, referenceRelative: Word, length: Word)
  function Position(base: Word, c: Constraint): Word { ((base as nat)+c.position)%G.Modulus() }
  function Payload(base: Word, c: Constraint): Word { ((base as nat)+c.position+c.referenceRelative+32)%G.Modulus() }
  predicate Layout(data: seq<Byte>, base: Word, cs: seq<Constraint>) {
    |data| < 0x10000000000000000 && (base as nat)+|cs|*32 <= |data| &&
    forall i {:trigger cs[i]} :: 0 <= i < |cs| ==>
                                   cs[i].kind <= 8 && cs[i].kind != 6 &&
                                   (base as nat)+cs[i].position+64 <= |data| &&
                                   (base as nat)+cs[i].position+cs[i].referenceRelative+32+cs[i].length <= |data| &&
                                   S.DataWord(data,base+i*32) == cs[i].position &&
                                   S.DataWord(data,Position(base,cs[i])) == cs[i].kind &&
                                   S.DataWord(data,Position(base,cs[i])+32) == cs[i].referenceRelative &&
                                   S.DataWord(data,Position(base,cs[i])+cs[i].referenceRelative) == cs[i].length
  }
  function Actual(bytes: seq<Byte>, index: nat): Word
    requires (index+1)*32 <= |bytes|
  { G.Decode(bytes[index*32..(index+1)*32])%G.Modulus() }
  predicate Passes(bytes: seq<Byte>, data: seq<Byte>, base: Word, cs: seq<Constraint>)
    requires Layout(data,base,cs) && |cs|*32 <= |bytes|
  {
    forall i {:trigger cs[i]} :: 0 <= i < |cs| ==>
                                   L.Judge(cs[i].kind,cs[i].length,Actual(bytes,i),
                                           S.DataWord(data,Payload(base,cs[i])),S.DataWord(data,Payload(base,cs[i])+32)) == L.Holds
  }
  function Cost(cs: seq<Constraint>): nat
    decreases |cs|
  { if |cs| == 0 then 0 else Cost(cs[..|cs|-1])+96+S.Round32(cs[|cs|-1].length) }
  lemma PrefixCost(cs: seq<Constraint>, index: nat)
    requires index <= |cs|
    ensures Cost(cs[..index]) <= Cost(cs)
    decreases |cs|-index
  {
    if index < |cs| {
      PrefixCost(cs[..|cs|-1],index);
      assert cs[..|cs|-1][..index] == cs[..index];
      assert Cost(cs) == Cost(cs[..|cs|-1])+96+S.Round32(cs[|cs|-1].length);
    } else { assert cs[..index] == cs; }
  }
  lemma NextCost(cs: seq<Constraint>, index: nat)
    requires index < |cs|
    ensures Cost(cs[..index+1]) == Cost(cs[..index])+96+S.Round32(cs[index].length)
    ensures Cost(cs[..index])+96+S.Round32(cs[index].length) <= Cost(cs)
  {
    assert cs[..index+1][..index] == cs[..index];
    assert cs[..index+1][index] == cs[index];
    assert Cost(cs[..index+1]) == Cost(cs[..index])+96+S.Round32(cs[index].length);
    PrefixCost(cs,index+1);
  }
  function Free(initial: Word, cs: seq<Constraint>, index: nat): Word
    requires index <= |cs| && (initial as nat)+Cost(cs) < 0x10000000000000000
  { PrefixCost(cs,index); initial+Cost(cs[..index]) }
  lemma FreeStep(initial: Word, cs: seq<Constraint>, index: nat)
    requires index < |cs| && (initial as nat)+Cost(cs)+160 < 0x10000000000000000
    ensures Free(initial,cs,index+1) == Free(initial,cs,index)+96+S.Round32(cs[index].length)
    ensures (Free(initial,cs,index) as nat)+S.Round32(cs[index].length)+256 < 0x10000000000000000
  { NextCost(cs,index); }
  predicate Heap(mem: seq<Byte>, pointer: Word, bytes: seq<Byte>, free: Word) {
    |mem|%32 == 0 && 96 <= |mem| < 0x10000000000000000 && |mem| <= (free as nat)+32 &&
    free%32 == 0 && free >= 128 && pointer >= 96 &&
    (pointer as nat)+32+|bytes| <= |mem| && (pointer as nat)+32+|bytes| <= free &&
    S.Load(mem,pointer) == |bytes| && S.Load(mem,64) == free &&
    mem[pointer+32..pointer+32+|bytes|] == bytes
  }
  lemma PhysicalWord(mem: seq<Byte>, pointer: Word, bytes: seq<Byte>, free: Word, index: nat)
    requires Heap(mem,pointer,bytes,free) && (index+1)*32 <= |bytes|
    ensures S.Load(mem,pointer+32+index*32) == Actual(bytes,index)
  {
    assert mem[pointer+32..pointer+32+|bytes|] == bytes;
    forall j {:trigger mem[pointer+32+index*32+j]} | 0 <= j < 32
      ensures mem[pointer+32+index*32+j] == bytes[index*32+j]
    {
      assert mem[pointer+32..pointer+32+|bytes|][index*32+j] == mem[pointer+32+index*32+j];
    }
    Q.Span(mem,bytes,pointer+32+index*32,index*32,32);
    assert pointer+32+index*32+32 == pointer+32+(index+1)*32;
    assert mem[pointer+32+index*32..pointer+32+(index+1)*32] == bytes[index*32..(index+1)*32];
    assert G.Grow(mem,(pointer as nat)+64+index*32) == mem;
  }
}
