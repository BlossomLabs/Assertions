// SPDX-License-Identifier: MIT
// Constructive positive-count allocation, arbitrary child fill, and table exit.
include "NonemptyAllocationFrame.dfy"
include "NonemptyFill.dfy"
include "Structure.dfy"
module AssertionsConstraintOrNonemptyDecoder {
  import S = BytecodeScanMachine
  import M = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import W = AssertionsConstraintOrNonemptyWire
  import H = AssertionsConstraintOrNonemptyFillHeap
  import A = AssertionsConstraintOrNonemptyAllocationHeap
  import B = AssertionsConstraintOrNonemptyAllocationFrame
  import P = AssertionsConstraintOrNonemptyStart
  import F = AssertionsConstraintOrNonemptyFill
  import T = AssertionsConstraintOrStructure
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { P.Matches(code) && F.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+F.Destinations() }
  function Children(initial: Word, children: seq<W.Child>): seq<T.Child>
    requires (initial as nat)+W.Cost(children)+160 < 0x10000000000000000
  { seq(|children|,j requires 0 <= j < |children| => T.Child(W.Free(initial,children,j),children[j].kind)) }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, start: Word, end: Word, relative: Word, free: Word,
                                      children: seq<W.Child>, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>)
    returns (states: seq<S.State>)
    requires Matches(code) && |prefix| <= 949
    requires W.Layout(mem,start,end,relative,children) && end <= free
    requires 128 <= free && free%32 == 0 && |mem|%32 == 0 && 96 <= |mem| <= free+32 && S.Load(mem,64) == free
    requires (free as nat)+32+|children|*32+W.Cost(children)+160 < 0x10000000000000000
    ensures M.Trace(code,Destinations(),value,data,states)
    ensures forall j {:trigger states[j]} :: 0 <= j < |states| ==> Q.Local(code,states[j])
    ensures states[0] == S.Running(19462,prefix+[7777,end,start],mem)
    ensures states[|states|-1].Running? && states[|states|-1].pc == 7777 && states[|states|-1].stack == prefix+[free]
    ensures T.Table(states[|states|-1].memory,free,W.Free(A.Reserved(free,children),children,|children|),Children(A.Reserved(free,children),children))
  {
    var initial := A.Reserved(free,children);
    var image := P.Construct(mem,free,|children|);
    var first := P.Run(code,end,start,relative,free,|children|,prefix,mem,value,data);
    M.WidenTrace(code,P.Destinations(),Destinations(),value,data,first);
    A.Allocate(mem,free,children);
    B.Layout(mem,start,end,relative,children,free);
    var last := F.Run(code,start,end,relative,free,initial,children,prefix,image,value,data);
    M.WidenTrace(code,F.Destinations(),Destinations(),value,data,last);
    U.Join(code,Destinations(),value,data,first,last);
    states := first+last[1..];
    var final := states[|states|-1].memory;
    var decoded := Children(initial,children);
    var finalFree := W.Free(initial,children,|children|);
    assert |decoded| == |children|;
    assert H.Partial(final,free,initial,children,|children|);
    forall j {:trigger decoded[j]} | 0 <= j < |decoded|
      ensures decoded[j].kind <= 8 && decoded[j].pointer+32 <= |final|
      ensures S.Load(final,free+32+j*32) == decoded[j].pointer
      ensures S.Load(final,decoded[j].pointer) == decoded[j].kind
    {
      assert decoded[j] == T.Child(W.Free(initial,children,j),children[j].kind);
    }
  }
}
