// SPDX-License-Identifier: MIT
// Arbitrary-length physical structural OR scan before any alternative verdict is evaluated.
include "StructureStart.generated.dfy"
include "StructureIteration.generated.dfy"
include "StructureNested.generated.dfy"
include "StructureExit.generated.dfy"
include "../../raw/public/Execution.dfy"
module AssertionsConstraintOrStructure {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import P = AssertionsConstraintOrStructureStart
  import I = AssertionsConstraintOrStructureIteration
  import N = AssertionsConstraintOrStructureNested
  import X = AssertionsConstraintOrStructureExit
  type Word = S.Word
  type Byte = S.Byte
  datatype Child = Child(pointer: Word, kind: Word)
  predicate Table(mem: seq<Byte>, arrayptr: Word, free: Word, children: seq<Child>) {
    0 < |children| && |mem|%32 == 0 && 96 <= |mem| <= (free as nat)+32 && free >= 128 &&
    (free as nat)+160 < 0x10000000000000000 && arrayptr >= 96 &&
    (arrayptr as nat)+32+|children|*32 <= |mem| && S.Load(mem,arrayptr) == |children| && S.Load(mem,64) == free &&
    forall i: nat {:trigger children[i]} :: i < |children| ==>
                                              children[i].kind <= 8 && (children[i].pointer as nat)+32 <= |mem| &&
                                              S.Load(mem,arrayptr+32+i*32) == children[i].pointer && S.Load(mem,children[i].pointer) == children[i].kind
  }
  function Base(prefix: seq<Word>, ret: Word, constraints: Word, count: Word, ptr: Word,
                assertion: Word, entry: Word, param: Word, words: Word, index: Word, actual: Word, record: Word): seq<Word>
  { prefix+[ret,constraints,count,ptr,assertion,entry,param,count,words,index,actual,record] }
  opaque predicate Matches(code: seq<Byte>) { P.Matches(code) && I.Matches(code) && N.Matches(code) && X.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+I.Destinations()+N.Destinations()+X.Destinations() }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, destinations: set<nat>, ret: Word, constraints: Word,
                                         count: Word, ptr: Word, assertion: Word, entry: Word, param: Word, words: Word, index: Word,
                                         actual: Word, record: Word, arrayptr: Word, free: Word, children: seq<Child>, limit: nat,
                                         prefix: seq<Word>, mem: seq<Byte>, self: Word, value: Word, data: seq<Byte>,
                                         returned: seq<Byte>, cursor: nat, observations: seq<A.Observation>) returns (frames: seq<E.Frame>)
    requires Matches(code) && Destinations() <= destinations && |prefix| <= 960
    requires Table(mem,arrayptr,free,children) && limit <= |children|
    requires forall i: nat {:trigger children[i]} :: i < limit ==> children[i].kind != 6
    requires limit < |children| ==> children[limit].kind == 6
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(7777,Base(prefix,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record)+[0,0,arrayptr],mem),returned,cursor)
    ensures limit == |children| ==> frames[|frames|-1] == E.Frame(S.Running(7943,Base(prefix,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record)+[0,arrayptr,|children|],mem),returned,cursor)
    ensures limit < |children| ==> frames[|frames|-1] == E.Frame(S.Reverted(N.Error(entry,param,index)),returned,cursor)
  {
    reveal Matches();
    var first := children[0];
    assert |children| < G.Modulus();
    var trace := P.Run(code,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,arrayptr,free,|children|,0,first.pointer,first.kind,prefix,mem,value,data);
    R.WidenTrace(code,P.Destinations(),destinations,value,data,trace);
    var base := Base(prefix,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record);
    var position: nat := 0;
    assert trace[|trace|-1] == S.Running(7831,base+[0,arrayptr,position],mem);
    while position < limit
      invariant position <= limit <= |children|
      invariant R.Trace(code,destinations,value,data,trace)
      invariant trace[0] == S.Running(7777,base+[0,0,arrayptr],mem)
      invariant trace[|trace|-1] == S.Running(7831,base+[0,arrayptr,position],mem)
      invariant forall j {:trigger trace[j]} :: 0 <= j < |trace|-1 ==> Q.Local(code,trace[j])
      decreases limit-position
    {
      var child := children[position];
      var next := I.Run(code,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,arrayptr,free,|children|,position,child.pointer,child.kind,prefix,mem,value,data);
      R.WidenTrace(code,I.Destinations(),destinations,value,data,next);
      assert position+1 < G.Modulus();
      assert next[|next|-1] == S.Running(7831,base+[0,arrayptr,position+1],mem);
      assert trace[|trace|-1] == next[0];
      U.Join(code,destinations,value,data,trace,next);
      trace := trace+next[1..]; position := position+1;
    }
    var last: seq<S.State>;
    if limit == |children| {
      last := X.Run(code,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,arrayptr,free,|children|,limit,first.pointer,first.kind,prefix,mem,value,data);
      R.WidenTrace(code,X.Destinations(),destinations,value,data,last);
    } else {
      var child := children[limit];
      last := N.Run(code,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,arrayptr,free,|children|,limit,child.pointer,child.kind,prefix,mem,value,data);
      R.WidenTrace(code,N.Destinations(),destinations,value,data,last);
    }
    assert trace[|trace|-1] == last[0];
    U.Join(code,destinations,value,data,trace,last); trace := trace+last[1..];
    U.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,trace); frames := Q.Lift(trace,returned,cursor);
  }
}
