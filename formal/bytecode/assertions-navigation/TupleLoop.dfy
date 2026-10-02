// SPDX-License-Identifier: MIT
// Arbitrary field-count physical tuple loop, parameterized by discharged child traces.
// Child parsing remains an explicit composition obligation, not an axiom or assumed lemma.
include "TupleSpec.dfy"
include "TupleField.dfy"
include "development/tuple-child-v1/Character.dfy"
module AssertionsNavigationTupleLoop {
  import opened BytecodeScanMachine
  import S = AssertionsNavigationTupleSpec
  import F = AssertionsNavigationTupleField
  import C = AssertionsNavigationTupleChild
  import E = AssertionsNavigationNameTrace
  import H = AssertionsNavigationNameFrame
  function Cursor(p: Word,fields: seq<S.Field>,index: nat): nat
    requires index <= |fields|
  { if index == 0 then p+1 else fields[index-1].end+1 }
  function Flag(fields: seq<S.Field>,index: nat): Word
    requires index <= |fields|
  { if S.Dynamic(fields,index) then 1 else 0 }
  predicate Admitted(data: seq<Byte>,offset: Word,length: Word,p: Word,limit: Word,fields: seq<S.Field>,prefix: seq<Word>) {
    (offset as nat)+length <= |data| < 0x10000000000000000 && p < limit <= length && |prefix| <= 930 &&
    |fields| > 0 && S.Positive(fields) && S.Sum(fields,|fields|) < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
    forall i :: 0 <= i < |fields| ==> (p < Cursor(p,fields,i) <= fields[i].end < limit &&
                                       S.Sum(fields,i) < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
                                       fields[i].words < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
                                       data[offset+fields[i].end] == (if i+1 == |fields| then 41 else 44))
  }
  // These explicit machine-word premises follow from the original tuple geometry.
  // In particular the sum is bounded by 256 bits, not by the uint32 suffix cap.
  predicate Geometry(data: seq<Byte>,offset: Word,length: Word,p: Word,limit: Word,fields: seq<S.Field>,prefix: seq<Word>) {
    (offset as nat)+length <= |data| < 0x10000000000000000 && p < limit <= length && |prefix| <= 930 &&
    |fields| > 0 && S.Positive(fields) && S.Sum(fields,|fields|) < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
    forall i :: 0 <= i < |fields| ==> (Cursor(p,fields,i) <= fields[i].end < limit &&
                                       data[offset+fields[i].end] == (if i+1 == |fields| then 41 else 44))
  }
  lemma CursorAfter(p: Word,fields: seq<S.Field>,index: nat)
    requires index < |fields|
    requires forall i :: 0 <= i < |fields| ==> Cursor(p,fields,i) <= fields[i].end
    ensures p < Cursor(p,fields,index)
    decreases index
  {
    if index > 0 { CursorAfter(p,fields,index-1); }
  }
  lemma GeometryBounds(data: seq<Byte>,offset: Word,length: Word,p: Word,limit: Word,fields: seq<S.Field>,prefix: seq<Word>)
    requires Geometry(data,offset,length,p,limit,fields,prefix)
    ensures Admitted(data,offset,length,p,limit,fields,prefix)
  {
    forall i | 0 <= i < |fields|
      ensures p < Cursor(p,fields,i) <= fields[i].end < limit
      ensures S.Sum(fields,i) < 0x10000000000000000000000000000000000000000000000000000000000000000
      ensures fields[i].words < 0x10000000000000000000000000000000000000000000000000000000000000000
    {
      CursorAfter(p,fields,i);
      S.SumMonotone(fields,i,|fields|);
      S.SumMonotone(fields,i+1,|fields|);
      S.Step(fields,i);
    }
  }
  predicate Children(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,fields: seq<S.Field>,prefix: seq<Word>,mem: seq<Byte>,children: seq<seq<State>>) {
    p < limit < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
    |children| == |fields| && S.Sum(fields,|fields|) < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
    forall i :: 0 <= i < |fields| ==>
                  Cursor(p,fields,i) <= fields[i].end < limit &&
                  S.Sum(fields,i) < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
                  fields[i].words < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
                  E.Trace(code,destinations,value,data,children[i]) &&
                  children[i][0] == Running(8442,prefix+[ret,offset,length,p,limit,0,Flag(fields,i),0,Cursor(p,fields,i),S.Sum(fields,i),0,0,0,8561,offset,length,Cursor(p,fields,i),limit],mem) &&
                  children[i][|children[i]|-1] == Running(8561,prefix+[ret,offset,length,p,limit,0,Flag(fields,i),0,Cursor(p,fields,i),S.Sum(fields,i),0,0,0,fields[i].end,(if fields[i].dynamic then 1 else 0),fields[i].words],mem) &&
                  forall j :: 0 <= j < |children[i]|-1 ==> H.Local(code,children[i][j])
  }
  lemma Join(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,left: seq<State>,right: seq<State>)
    requires E.Trace(code,destinations,value,data,left) && E.Trace(code,destinations,value,data,right)
    requires left[|left|-1] == right[0]
    requires forall i :: 0 <= i < |left|-1 ==> H.Local(code,left[i])
    requires forall i :: 0 <= i < |right|-1 ==> H.Local(code,right[i])
    ensures E.Trace(code,destinations,value,data,left+right[1..])
    ensures (left+right[1..])[0] == left[0]
    ensures (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
    ensures forall i :: 0 <= i < |left+right[1..]|-1 ==> H.Local(code,(left+right[1..])[i])
  {
    E.Join(code,destinations,value,data,left,right);
    forall i | 0 <= i < |left+right[1..]|-1
      ensures H.Local(code,(left+right[1..])[i])
    {
      if i < |left|-1 { assert (left+right[1..])[i] == left[i]; }
      else { var j := i-(|left|-1); assert 0 <= j < |right|-1; assert (left+right[1..])[i] == right[j]; }
    }
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,fields: seq<S.Field>,prefix: seq<Word>,mem: seq<Byte>,children: seq<seq<State>>,index: nat) returns (trace: seq<State>)
    requires Admitted(data,offset,length,p,limit,fields,prefix)
    requires Children(code,destinations,value,data,ret,offset,length,p,limit,fields,prefix,mem,children)
    requires F.Matches(code) && C.Matches(code)
    requires {3175,8442,8546,8578,8588,8625,8651,8662,8685,8696,8724,8735,8738,8882,17853} <= destinations
    requires index < |fields|
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8546,prefix+[ret,offset,length,p,limit,0,Flag(fields,index),0,Cursor(p,fields,index),S.Sum(fields,index)],mem)
    ensures trace[|trace|-1] == Running(8882,prefix+[ret,offset,length,p,limit,fields[|fields|-1].end+1,Flag(fields,|fields|),S.Footprint(fields)],mem)
    ensures forall i :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
    decreases |fields|-index
  {
    S.SumMonotone(fields,index+1,|fields|);
    S.Step(fields,index);
    var q: Word := Cursor(p,fields,index);
    var total: Word := S.Sum(fields,index);
    var ce: Word := fields[index].end;
    var cw: Word := fields[index].words;
    var cd: Word := if fields[index].dynamic then 1 else 0;
    var before := C.Run(code,destinations,ret,offset,length,p,limit,q,0,Flag(fields,index),0,total,prefix,mem,data,value);
    Join(code,destinations,value,data,before,children[index]);
    trace := before+children[index][1..];
    var after := F.Run(code,destinations,ret,offset,length,p,limit,q,0,Flag(fields,index),0,total,ce,cd,cw,prefix,mem,data,value);
    Join(code,destinations,value,data,trace,after);
    trace := trace+after[1..];
    if index+1 < |fields| {
      var tail := Run(code,destinations,value,data,ret,offset,length,p,limit,fields,prefix,mem,children,index+1);
      Join(code,destinations,value,data,trace,tail);
      trace := trace+tail[1..];
    }
  }
}
