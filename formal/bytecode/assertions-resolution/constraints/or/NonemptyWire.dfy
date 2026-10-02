// SPDX-License-Identifier: MIT
// Independent successful in-memory ABI child-array layout, allowing loose bounded offsets.
include "../../../scans/Machine.dfy"
module AssertionsConstraintOrNonemptyWire {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Word = S.Word
  type Byte = S.Byte
  datatype Child = Child(kind: Word, position: Word, referenceRelative: Word, length: Word)
  function Body(start: Word, relative: Word): Word { ((start as nat)+relative)%G.Modulus() }
  function Offset(body: Word, child: Child): Word { ((body as nat)+child.position)%G.Modulus() }
  function Source(body: Word, child: Child): Word { ((body as nat)+child.position+child.referenceRelative+64)%G.Modulus() }
  predicate Layout(mem: seq<Byte>, start: Word, end: Word, relative: Word, children: seq<Child>) {
    0 < |children| && 96 <= start && (start as nat)+relative+32+|children|*32 <= end <= |mem| &&
    end < 0x10000000000000000 && S.Load(mem,start) == relative && S.Load(mem,Body(start,relative)) == |children| &&
    forall i {:trigger children[i]} :: 0 <= i < |children| ==>
      children[i].kind <= 8 &&
      (start as nat)+relative+children[i].position+96 <= end &&
      (start as nat)+relative+children[i].position+children[i].referenceRelative+64+children[i].length <= end &&
      S.Load(mem,Body(start,relative)+32+i*32) == children[i].position &&
      S.Load(mem,Offset(Body(start,relative),children[i])+32) == children[i].kind &&
      S.Load(mem,Offset(Body(start,relative),children[i])+64) == children[i].referenceRelative &&
      S.Load(mem,Offset(Body(start,relative),children[i])+children[i].referenceRelative+32) == children[i].length
  }
  function Cost(children: seq<Child>): nat
    decreases |children|
  { if |children| == 0 then 0 else Cost(children[..|children|-1])+96+S.Round32(children[|children|-1].length) }
  lemma Item(mem: seq<Byte>, start: Word, end: Word, relative: Word, children: seq<Child>, i: nat)
    requires Layout(mem,start,end,relative,children) && i < |children|
    ensures Body(start,relative) == start+relative
    ensures Offset(Body(start,relative),children[i]) == start+relative+children[i].position
    ensures Source(Body(start,relative),children[i]) == start+relative+children[i].position+children[i].referenceRelative+64
    ensures children[i].kind <= 8
    ensures Offset(Body(start,relative),children[i])+96 <= end
    ensures Source(Body(start,relative),children[i])+children[i].length <= end
    ensures S.Load(mem,Body(start,relative)+32+i*32) == children[i].position
    ensures S.Load(mem,Offset(Body(start,relative),children[i])+32) == children[i].kind
    ensures S.Load(mem,Offset(Body(start,relative),children[i])+64) == children[i].referenceRelative
    ensures S.Load(mem,Offset(Body(start,relative),children[i])+children[i].referenceRelative+32) == children[i].length
  {}
  lemma PrefixCost(children: seq<Child>, i: nat)
    requires i <= |children|
    ensures Cost(children[..i]) <= Cost(children)
    decreases |children|-i
  {
    if i < |children| {
      PrefixCost(children[..|children|-1],i);
      assert children[..|children|-1][..i] == children[..i];
      assert Cost(children) == Cost(children[..|children|-1])+96+S.Round32(children[|children|-1].length);
    } else { assert children[..i] == children; }
  }
  lemma NextCost(children: seq<Child>, i: nat)
    requires i < |children|
    ensures Cost(children[..i+1]) == Cost(children[..i])+96+S.Round32(children[i].length)
    ensures Cost(children[..i+1]) <= Cost(children)
  {
    assert children[..i+1][..i] == children[..i];
    assert children[..i+1][i] == children[i];
    PrefixCost(children,i+1);
  }
  function Free(initial: Word, children: seq<Child>, i: nat): Word
    requires i <= |children| && (initial as nat)+Cost(children) < G.Modulus()
  { PrefixCost(children,i); initial+Cost(children[..i]) }
  lemma FreeStep(initial: Word, children: seq<Child>, i: nat)
    requires i < |children| && (initial as nat)+Cost(children)+128 < 0x10000000000000000
    ensures Free(initial,children,i+1) == Free(initial,children,i)+96+S.Round32(children[i].length)
    ensures (Free(initial,children,i) as nat)+128+S.Round32(children[i].length) < 0x10000000000000000
  { NextCost(children,i); }
}
