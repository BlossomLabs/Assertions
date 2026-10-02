// SPDX-License-Identifier: MIT
// Arbitrary child-fill physical loop, followed by the actual decoder exit.
include "NonemptyFillHeap.dfy"
include "NonemptyItem.generated.dfy"
include "NonemptyExit.generated.dfy"
include "NonemptyFillReady.dfy"
include "../../raw/public/Execution.dfy"
module AssertionsConstraintOrNonemptyFill {
  import S = BytecodeScanMachine
  import M = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import W = AssertionsConstraintOrNonemptyWire
  import H = AssertionsConstraintOrNonemptyFillHeap
  import R = AssertionsConstraintOrNonemptyWireFrame
  import I = AssertionsConstraintOrNonemptyItem
  import X = AssertionsConstraintOrNonemptyExit
  import Y = AssertionsConstraintOrNonemptyFillReady
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { I.Matches(code) && X.Matches(code) }
  function Destinations(): set<nat> { I.Destinations()+X.Destinations() }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, start: Word, end: Word, relative: Word, arrayptr: Word,
                                      initial: Word, children: seq<W.Child>, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>)
    returns (states: seq<S.State>)
    requires Matches(code) && |prefix| <= 949
    requires (initial as nat)+W.Cost(children)+160 < 0x10000000000000000
    requires H.Partial(mem,arrayptr,initial,children,0) && W.Layout(mem,start,end,relative,children) && end <= arrayptr
    ensures M.Trace(code,Destinations(),value,data,states)
    ensures forall j {:trigger states[j]} :: 0 <= j < |states| ==> Q.Local(code,states[j])
    ensures states[0] == S.Running(19590,prefix+[7777,end,start,0,W.Body(start,relative),W.Body(start,relative)+32+|children|*32,W.Body(start,relative)+32,arrayptr+32,arrayptr],mem)
    ensures states[|states|-1].Running? && states[|states|-1].pc == 7777 && states[|states|-1].stack == prefix+[arrayptr]
    ensures H.Partial(states[|states|-1].memory,arrayptr,initial,children,|children|)
    ensures W.Layout(states[|states|-1].memory,start,end,relative,children)
  {
    hide S.Store(); hide S.Load(); hide M.Step();
    var body := W.Body(start,relative);
    var headend := body+32+|children|*32;
    var image := mem;
    var i: nat := 0;
    states := [S.Running(19590,prefix+[7777,end,start,0,body,headend,body+32,arrayptr+32,arrayptr],mem)];
    assert M.Trace(code,Destinations(),value,data,states);
    hide M.Trace();
    while i < |children|
      invariant i <= |children|
      invariant 0 < |states|
      invariant H.Partial(image,arrayptr,initial,children,i) && W.Layout(image,start,end,relative,children)
      invariant M.Trace(code,Destinations(),value,data,states)
      invariant states[0] == S.Running(19590,prefix+[7777,end,start,0,body,headend,body+32,arrayptr+32,arrayptr],mem)
      invariant states[|states|-1] == S.Running(19590,prefix+[7777,end,start,0,body,headend,body+32+i*32,arrayptr+32+i*32,arrayptr],image)
      invariant forall j {:trigger states[j]} :: 0 <= j < |states|-1 ==> Q.Local(code,states[j])
      decreases |children|-i
    {
      W.Item(image,start,end,relative,children,i);
      W.FreeStep(initial,children,i);
      var c := children[i];
      var free := W.Free(initial,children,i);
      var source := W.Source(body,c);
      var slot := body+32+i*32;
      var dstslot := arrayptr+32+i*32;
      Y.Ready(start,end,relative,arrayptr,initial,children,i,prefix,image);
      var next := I.Run(code,end,start,body,headend,slot,dstslot,arrayptr,c.position,W.Offset(body,c),c.kind,c.referenceRelative,c.length,source,free,prefix+[7777],image,value,data);
      M.WidenTrace(code,I.Destinations(),Destinations(),value,data,next);
      H.Step(image,arrayptr,initial,children,i,source);
      R.Layout(image,start,end,relative,children,free,c.kind,source,c.length,dstslot);
      var after := H.Image(image,arrayptr,initial,children,i,source);
      assert next[|next|-1] == S.Running(19590,prefix+[7777,end,start,0,body,headend,body+32+(i+1)*32,arrayptr+32+(i+1)*32,arrayptr],after);
      U.Join(code,Destinations(),value,data,states,next);
      states := states+next[1..]; image := after; i := i+1;
    }
    var last := X.Run(code,end,start,body,headend,body+32+i*32,arrayptr+32+i*32,arrayptr,prefix,image,value,data);
    M.WidenTrace(code,X.Destinations(),Destinations(),value,data,last);
    U.Join(code,Destinations(),value,data,states,last);
    states := states+last[1..];
  }
}
