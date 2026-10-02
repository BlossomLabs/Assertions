// SPDX-License-Identifier: MIT
// Compose the empty OR decoder and exact InvalidOrConstraint physical REVERT.
include "EmptyDecoder.generated.dfy"
include "EmptyAbort.generated.dfy"
include "../../raw/public/Execution.dfy"
module AssertionsConstraintOrEmptyConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import D = AssertionsConstraintOrEmptyDecoder
  import B = AssertionsConstraintOrEmptyAbort
  import V = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  function Prefix(prefix: seq<Word>, ret: Word, constraints: Word, count: Word, ptr: Word,
                  assertion: Word, entry: Word, param: Word, words: Word, index: Word,
                  actual: Word, record: Word): seq<Word> {
    prefix+[ret,constraints,count,ptr,assertion,entry,param,count,words,index,actual,record,0,0]
  }
  opaque predicate Matches(code: seq<Byte>) { D.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { D.Destinations()+B.Destinations() }
  lemma Join(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>,
             first: seq<S.State>, second: seq<S.State>)
    requires R.Trace(code,destinations,value,data,first) && R.Trace(code,destinations,value,data,second)
    requires first[|first|-1] == second[0]
    requires forall i {:trigger first[i]} :: 0 <= i < |first| ==> Q.Local(code,first[i])
    requires forall i {:trigger second[i]} :: 0 <= i < |second|-1 ==> Q.Local(code,second[i])
    ensures R.Trace(code,destinations,value,data,first+second[1..])
    ensures forall i {:trigger (first+second[1..])[i]} :: 0 <= i < |first+second[1..]|-1 ==> Q.Local(code,(first+second[1..])[i])
    ensures (first+second[1..])[0] == first[0]
    ensures (first+second[1..])[|first+second[1..]|-1] == second[|second|-1]
  {
    forall i {:trigger (first+second[1..])[i]} | 0 <= i < |first+second[1..]|-1
      ensures R.Step(code,destinations,(first+second[1..])[i],value,data) == (first+second[1..])[i+1]
      ensures (first+second[1..])[i+1] != S.Bad
      ensures Q.Local(code,(first+second[1..])[i])
    {
      if i < |first|-1 {} else {
        var j := i-(|first|-1);
        assert (first+second[1..])[i] == second[j];
        assert (first+second[1..])[i+1] == second[j+1];
      }
    }
  }
  ghost method Run(code: seq<Byte>, destinations: set<nat>, ret: Word, constraints: Word, count: Word,
                   ptr: Word, assertion: Word, entry: Word, param: Word, words: Word, index: Word,
                   actual: Word, record: Word, end: Word, start: Word, relative: Word, free: Word,
                   prefix: seq<Word>, mem: seq<Byte>, self: Word, value: Word, data: seq<Byte>,
                   returned: seq<Byte>, cursor: nat, observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires Matches(code) && Destinations() <= destinations && |prefix| <= 960
    requires D.Admitted(end,start,relative,free,Prefix(prefix,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record),mem)
    requires (free as nat)+192 < 0x10000000000000000
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(19462,Prefix(prefix,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record)+[7777,end,start],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Reverted(B.Error(entry,param,index)),returned,cursor)
  {
    reveal Matches();
    var before := Prefix(prefix,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record);
    var first := D.Run(code,end,start,relative,free,before,mem,value,data);
    var image := D.Construct(mem,free);
    assert B.Admitted(ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,free,free+32,prefix,image) by {
      reveal D.Admitted();
      V.StoredWord(mem,64,free+32);
      V.StoredWord(S.Store(mem,64,free+32),free,0);
      V.StoredFrame(S.Store(mem,64,free+32),free,0,64);
      assert |S.Store(mem,64,free+32)| <= free+32;
      assert |image| == free+32;
      assert S.Load(image,free) == 0;
      assert S.Load(image,64) == free+32;
    }
    var second := B.Run(code,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,free,free+32,prefix,image,value,data);
    R.WidenTrace(code,D.Destinations(),destinations,value,data,first);
    R.WidenTrace(code,B.Destinations(),destinations,value,data,second);
    Join(code,destinations,value,data,first,second);
    var states := first+second[1..];
    U.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,states);
    frames := Q.Lift(states,returned,cursor);
  }
}
