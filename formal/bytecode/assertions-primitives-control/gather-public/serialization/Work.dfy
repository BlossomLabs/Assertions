// SPDX-License-Identifier: MIT
// Arbitrary-count serializer rank, allocation positions, and resolved source objects.
include "ArrayMemory.dfy"
module AssertionsGatherArrayWork {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import D = AssertionsGatherArraySpec
  import B = AssertionsGatherBytesSpec
  import M = AssertionsGatherArrayMemory
  import C = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  function Used(values: seq<seq<Byte>>, index: nat): nat
    requires index <= |values|
    decreases index
  { if index == 0 then 0 else Used(values,index-1)+32+S.Round32(|values[index-1]|) }
  opaque function Position(base: Word, values: seq<seq<Byte>>, index: nat): nat
    requires index <= |values|
  { base+64+|values|*32+Used(values,index) }
  predicate Budget(base: Word, values: seq<seq<Byte>>) {
    128 <= base && base%32 == 0 && |values| < 0x10000000000000000 &&
    base+192+|values|*32+Used(values,|values|) < 0x10000000000000000
  }
  lemma Zero(values: seq<seq<Byte>>)
    ensures Used(values,0) == 0
  {}
  lemma Next(values: seq<seq<Byte>>, index: nat)
    requires index < |values|
    ensures Used(values,index+1) == Used(values,index)+32+S.Round32(|values[index]|)
  {}
  lemma Monotone(values: seq<seq<Byte>>, index: nat, end: nat)
    requires index <= end <= |values|
    ensures Used(values,index) <= Used(values,end)
    decreases end-index
  { if index < end { Monotone(values,index,end-1); } }
  lemma Aligned(values: seq<seq<Byte>>, index: nat)
    requires index <= |values|
    ensures Used(values,index)%32 == 0
    decreases index
  { if index > 0 { Aligned(values,index-1); C.Rounded(|values[index-1]|); } }
  lemma Positions(base: Word, values: seq<seq<Byte>>, index: nat)
    requires Budget(base,values) && index <= |values|
    ensures base+64+|values|*32 <= Position(base,values,index)
    ensures Position(base,values,index)+64 < 0x10000000000000000
    ensures Position(base,values,index)%32 == 0
    ensures index == 0 ==> Position(base,values,index) == base+64+|values|*32
    ensures index < |values| ==> Position(base,values,index)+96+S.Round32(|values[index]|) < 0x10000000000000000
    ensures index < |values| ==> Position(base,values,index+1) == Position(base,values,index)+32+S.Round32(|values[index]|)
  {
    Zero(values); hide Used(); reveal Position();
    Monotone(values,index,|values|); Aligned(values,index);
    if index == 0 { assert Used(values,index) == 0; }
    if index < |values| { Next(values,index); Monotone(values,index+1,|values|); }
  }
  predicate Sources(mem: seq<Byte>, arrayBase: Word, base: Word, values: seq<seq<Byte>>, pointers: seq<Word>)
    requires Budget(base,values)
  {
    |pointers| == |values| && arrayBase+32+|values|*32 <= |mem| && arrayBase+32+|values|*32 <= base &&
    S.Load(mem,arrayBase) == |values| &&
    forall j: nat {:trigger pointers[j]} :: j < |values| ==>
                                              pointers[j]+32+|values[j]| <= |mem| && pointers[j]+32+|values[j]| <= base &&
                                              S.Load(mem,arrayBase+32+j*32) == pointers[j] && S.Load(mem,pointers[j]) == |values[j]| &&
                                              mem[pointers[j]+32..pointers[j]+32+|values[j]|] == values[j]
  }
  lemma Source(mem: seq<Byte>, arrayBase: Word, base: Word, values: seq<seq<Byte>>, pointers: seq<Word>, index: nat)
    requires Budget(base,values) && Sources(mem,arrayBase,base,values,pointers) && index < |values|
    ensures M.Object(mem,base,pointers[index],|values[index]|)
    ensures S.Load(mem,arrayBase+32+index*32) == pointers[index]
    ensures |values[index]| < G.Modulus()
  { Positions(base,values,index); C.Rounded(|values[index]|); }
  lemma Preserved(before: seq<Byte>, after: seq<Byte>, arrayBase: Word, base: Word,
                  values: seq<seq<Byte>>, pointers: seq<Word>)
    requires Budget(base,values) && Sources(before,arrayBase,base,values,pointers) && |before| <= |after|
    requires forall p: nat {:trigger after[p]} :: p < |before| && p < base ==> after[p] == before[p]
    ensures Sources(after,arrayBase,base,values,pointers)
  {
    forall p: nat {:trigger after[p]} | arrayBase <= p < arrayBase+32
      ensures after[p] == before[p]
    {}
    M.LoadEqual(before,after,arrayBase);
    forall j: nat {:trigger pointers[j]} | j < |values|
      ensures pointers[j]+32+|values[j]| <= |after| && pointers[j]+32+|values[j]| <= base &&
              S.Load(after,arrayBase+32+j*32) == pointers[j] && S.Load(after,pointers[j]) == |values[j]| &&
              after[pointers[j]+32..pointers[j]+32+|values[j]|] == values[j]
    {
      var slot := arrayBase+32+j*32;
      forall p: nat {:trigger after[p]} | slot <= p < slot+32
        ensures after[p] == before[p]
      {}
      M.LoadEqual(before,after,slot);
      var ptr := pointers[j];
      forall p: nat {:trigger after[p]} | ptr <= p < ptr+32
        ensures after[p] == before[p]
      {}
      M.LoadEqual(before,after,ptr);
      forall p: nat {:trigger after[ptr+32+p]} | p < |values[j]|
        ensures after[ptr+32+p] == before[ptr+32+p]
      {}
      assert after[ptr+32..ptr+32+|values[j]|] == before[ptr+32..ptr+32+|values[j]|];
    }
  }
}
