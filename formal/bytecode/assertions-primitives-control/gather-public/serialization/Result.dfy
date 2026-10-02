// SPDX-License-Identifier: MIT
// Independent canonical ABI bytes[] result, projected directly into returned bytes.
include "Encoded.dfy"
module AssertionsGatherArrayResult {
  import W = AssertionsGatherArrayWork
  import P = AssertionsGatherArrayEncoded
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Byte = S.Byte
  type Word = S.Word
  opaque predicate Item(bytes: seq<Byte>, values: seq<seq<Byte>>, j: nat)
    requires j < |values|
  {
    var pos := 64+|values|*32+W.Used(values,j);
    var end := 64+|values|*32+W.Used(values,j+1);
    64+j*32+32 <= |bytes| && pos+32+|values[j]| <= end <= |bytes| &&
    G.Decode(bytes[64+j*32..96+j*32]) == |values|*32+W.Used(values,j) &&
    bytes[pos..pos+32] == G.Encode(|values[j]|,32) &&
    bytes[pos+32..pos+32+|values[j]|] == values[j] &&
    (forall p: nat {:trigger bytes[p]} :: pos+32+|values[j]| <= p < end ==> bytes[p] == 0)
  }
  opaque predicate Result(bytes: seq<Byte>, values: seq<seq<Byte>>) {
    |bytes| == 64+|values|*32+W.Used(values,|values|) &&
    bytes[..32] == G.Encode(32,32) && bytes[32..64] == G.Encode(|values|,32) &&
    forall j: nat {:trigger Item(bytes,values,j)} :: j < |values| ==> Item(bytes,values,j)
  }
  lemma Position(base: Word, values: seq<seq<Byte>>, index: nat)
    requires index <= |values|
    ensures W.Position(base,values,index) == base+64+|values|*32+W.Used(values,index)
  { reveal W.Position(); }
  lemma Slice(mem: seq<Byte>, start: nat, end: nat, offset: nat, length: nat)
    requires start <= end <= |mem| && offset+length <= end-start
    ensures mem[start..end][offset..offset+length] == mem[start+offset..start+offset+length]
  {
    var left := mem[start..end][offset..offset+length];
    var right := mem[start+offset..start+offset+length];
    forall j: nat {:trigger left[j]} | j < length
      ensures left[j] == right[j]
    { assert left[j] == mem[start+offset+j]; assert right[j] == mem[start+offset+j]; }
  }
  lemma Read(mem: seq<Byte>, offset: Word)
    requires offset+32 <= |mem|
    ensures S.Load(mem,offset) == G.Decode(mem[offset..offset+32])
  { G.LoadProjection(mem,offset); assert G.Grow(mem,offset+32) == mem; }
  lemma CellFields(mem: seq<Byte>, base: Word, values: seq<seq<Byte>>, index: nat)
    requires W.Budget(base,values) && index < |values| && P.Cell(mem,base,values,index)
    ensures W.Position(base,values,index)+32+|values[index]| <= W.Position(base,values,index+1) <= |mem|
    ensures base+64+index*32+32 <= |mem|
    ensures S.Load(mem,base+64+index*32) == W.Position(base,values,index)-base-64
    ensures mem[W.Position(base,values,index)..W.Position(base,values,index)+32] == G.Encode(|values[index]|,32)
    ensures mem[W.Position(base,values,index)+32..W.Position(base,values,index)+32+|values[index]|] == values[index]
    ensures forall p: nat {:trigger mem[p]} :: W.Position(base,values,index)+32+|values[index]| <= p < W.Position(base,values,index+1) ==> mem[p] == 0
  { reveal P.Cell(); }
  lemma Materialized(mem: seq<Byte>, base: Word, end: Word, values: seq<seq<Byte>>)
    requires W.Budget(base,values) && P.Done(mem,base,values,|values|)
    requires end == W.Position(base,values,|values|) && base+64 <= end <= |mem|
    requires mem[base..base+32] == G.Encode(32,32) && mem[base+32..base+64] == G.Encode(|values|,32)
    ensures Result(mem[base..end],values)
  {
    hide S.Load(); hide G.Decode();
    Position(base,values,|values|); reveal P.Done();
    forall j: nat {:trigger Item(mem[base..end],values,j)} | j < |values|
      ensures Item(mem[base..end],values,j)
    {
      assert P.Cell(mem,base,values,j); CellFields(mem,base,values,j);
      Position(base,values,j); Position(base,values,j+1); W.Monotone(values,j+1,|values|);
      var head: Word := base+64+j*32;
      Read(mem,head);
      var pos := 64+|values|*32+W.Used(values,j);
      var last := 64+|values|*32+W.Used(values,j+1);
      Slice(mem,base,end,64+j*32,32);
      Slice(mem,base,end,pos,32);
      Slice(mem,base,end,pos+32,|values[j]|);
      forall p: nat {:trigger mem[base..end][p]} | pos+32+|values[j]| <= p < last
        ensures mem[base..end][p] == 0
      { assert mem[base..end][p] == mem[base+p]; }
      reveal Item();
    }
    Slice(mem,base,end,0,32);
    Slice(mem,base,end,32,32);
    assert mem[base..end][..32] == G.Encode(32,32);
    assert mem[base..end][32..64] == G.Encode(|values|,32);
    assert |mem[base..end]| == 64+|values|*32+W.Used(values,|values|);
    reveal Result();
  }
}
