// SPDX-License-Identifier: MIT
// Independent canonical bytes[] offsets, length words, payload bytes and zero padding.
include "Work.dfy"
module AssertionsGatherArrayEncoded {
  import W = AssertionsGatherArrayWork
  import M = AssertionsGatherArrayMemory
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Cell(mem: seq<Byte>, base: Word, values: seq<seq<Byte>>, index: nat)
    requires W.Budget(base,values) && index < |values|
  {
    var pos := W.Position(base,values,index);
    var end := W.Position(base,values,index+1);
    var head := base+64+index*32;
    head+32 <= |mem| && end <= |mem| && pos+32+|values[index]| <= end &&
    S.Load(mem,head) == pos-base-64 &&
    mem[pos..pos+32] == G.Encode(|values[index]|,32) &&
    mem[pos+32..pos+32+|values[index]|] == values[index] &&
    forall p: nat {:trigger mem[p]} :: pos+32+|values[index]| <= p < end ==> mem[p] == 0
  }
  opaque predicate Done(mem: seq<Byte>, base: Word, values: seq<seq<Byte>>, index: nat)
    requires W.Budget(base,values) && index <= |values|
  {
    forall j: nat {:trigger Cell(mem,base,values,j)} :: j < index ==> Cell(mem,base,values,j)
  }
  lemma Empty(mem: seq<Byte>, base: Word, values: seq<seq<Byte>>)
    requires W.Budget(base,values)
    ensures Done(mem,base,values,0)
  { reveal Done(); }
  lemma Produced(mem: seq<Byte>, base: Word, values: seq<seq<Byte>>, index: nat, tail: Word, end: Word)
    requires W.Budget(base,values) && index < |values| && tail == W.Position(base,values,index) && end == W.Position(base,values,index+1)
    requires end <= |mem| && tail+32+|values[index]| <= end && base+64+index*32+32 <= |mem|
    requires S.Load(mem,base+64+index*32) == tail-base-64
    requires mem[tail..tail+32] == G.Encode(|values[index]|,32) && mem[tail+32..tail+32+|values[index]|] == values[index]
    requires forall p: nat {:trigger mem[p]} :: tail+32+|values[index]| <= p < end ==> mem[p] == 0
    ensures Cell(mem,base,values,index)
  { W.Positions(base,values,index); reveal Cell(); }
  lemma Range(before: seq<Byte>, after: seq<Byte>, start: nat, length: nat)
    requires start+length <= |before| && start+length <= |after|
    requires forall p: nat {:trigger after[p]} :: start <= p < start+length ==> after[p] == before[p]
    ensures after[start..start+length] == before[start..start+length]
  { assert after[start..start+length] == before[start..start+length]; }
  lemma EarlierPosition(base: Word, values: seq<seq<Byte>>, previousIndex: nat, index: nat)
    requires W.Budget(base,values) && previousIndex < index < |values|
    ensures W.Position(base,values,previousIndex+1) <= W.Position(base,values,index)
    ensures base+64+index*32+32 <= W.Position(base,values,previousIndex)
    ensures base+64+previousIndex*32+32 <= base+64+index*32
  {
    hide W.Used(); reveal W.Position();
    W.Monotone(values,previousIndex+1,index);
  }
  lemma Earlier(before: seq<Byte>, after: seq<Byte>, base: Word, values: seq<seq<Byte>>, previousIndex: nat, index: nat,
                tail: Word, head: Word)
    requires W.Budget(base,values) && previousIndex < index < |values| && Cell(before,base,values,previousIndex)
    requires tail == W.Position(base,values,index) && head == base+64+index*32 && |before| <= |after|
    requires forall p: nat {:trigger after[p]} :: p < |before| && p < tail && (p < head || head+32 <= p) ==> after[p] == before[p]
    ensures Cell(after,base,values,previousIndex)
  {
    EarlierPosition(base,values,previousIndex,index); W.Positions(base,values,previousIndex); reveal Cell();
    var oldHead: Word := base+64+previousIndex*32;
    var pos := W.Position(base,values,previousIndex);
    var end := W.Position(base,values,previousIndex+1);
    forall p: nat {:trigger after[p]} | oldHead <= p < oldHead+32
      ensures after[p] == before[p]
    {}
    M.LoadEqual(before,after,oldHead);
    forall p: nat {:trigger after[p]} | pos <= p < end
      ensures after[p] == before[p]
    {}
    Range(before,after,pos,32); Range(before,after,pos+32,|values[previousIndex]|);
    forall p: nat {:trigger after[p]} | pos+32+|values[previousIndex]| <= p < end
      ensures after[p] == 0
    {}
  }
  lemma Advance(before: seq<Byte>, after: seq<Byte>, base: Word, values: seq<seq<Byte>>, index: nat,
                tail: Word, head: Word)
    requires W.Budget(base,values) && index < |values| && Done(before,base,values,index) && Cell(after,base,values,index)
    requires tail == W.Position(base,values,index) && head == base+64+index*32 && |before| <= |after|
    requires forall p: nat {:trigger after[p]} :: p < |before| && p < tail && (p < head || head+32 <= p) ==> after[p] == before[p]
    ensures Done(after,base,values,index+1)
  {
    reveal Done();
    forall j: nat {:trigger Cell(after,base,values,j)} | j < index+1
      ensures Cell(after,base,values,j)
    { if j < index { Earlier(before,after,base,values,j,index,tail,head); } }
  }
}
