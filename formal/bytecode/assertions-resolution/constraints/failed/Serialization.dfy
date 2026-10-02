// SPDX-License-Identifier: MIT
// Complete reached serializer orchestration, including both unaligned dynamic-byte encoders.
include "Heap.dfy"
include "BlobConnection.dfy"
include "End.generated.dfy"
include "../../raw/public/Execution.dfy"
module AssertionsConstraintFailedSerialization {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import D = AssertionsConstraintFailedBlobSpec
  import B = AssertionsConstraintFailedBlobEncoder
  import BC = AssertionsConstraintFailedBlobConnection
  import T = AssertionsConstraintFailedHeap
  import H = AssertionsConstraintFailedHeads
  import P = AssertionsConstraintFailedStart
  import Z = AssertionsConstraintFailedEnd
  import DS = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  ghost function First(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                       reference: Word, referenceLength: Word): seq<Byte>
    requires T.Heap(mem,free,assertion,assertionLength,reference,referenceLength)
  {
    T.Start(mem,free,assertion,assertionLength,reference,referenceLength);
    D.Image(S.Store(mem,free+4,224),free+228,assertion,assertionLength)
  }
  ghost function Heads(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                       reference: Word, referenceLength: Word, entry: Word, param: Word,
                       index: Word, kind: Word, actual: Word): seq<Byte>
    requires T.Heap(mem,free,assertion,assertionLength,reference,referenceLength)
  { H.Image(First(mem,free,assertion,assertionLength,reference,referenceLength),free,entry,param,index,kind,actual,assertionLength) }
  ghost function Image(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                       reference: Word, referenceLength: Word, entry: Word, param: Word,
                       index: Word, kind: Word, actual: Word): seq<Byte>
    requires T.Heap(mem,free,assertion,assertionLength,reference,referenceLength)
  {
    T.Heads(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
    D.Image(Heads(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual),free+260+S.Round32(assertionLength),reference,referenceLength)
  }
  function Prefix(prefix: seq<Word>, assertion: Word, entry: Word, param: Word, index: Word,
                  kind: Word, actual: Word, reference: Word, free: Word): seq<Word>
    requires free+4 < G.Modulus()
  { prefix+[1423,assertion,entry,param,index,kind,actual,reference,free+4,0] }
  opaque predicate Matches(code: seq<Byte>) {
    P.Matches(code) && H.Matches(code) && Z.Matches(code) && B.Matches(code,19811) && B.Matches(code,19866)
  }
  function Destinations(): set<nat> { P.Destinations()+H.Destinations()+Z.Destinations()+B.Destinations(19811)+B.Destinations(19866) }
  lemma ReturnsCertified()
    ensures 19811 in DS.RuntimeDestinations() && 19866 in DS.RuntimeDestinations()
  { reveal DS.RuntimeDestinations(); reveal DS.Chunk32(); }
  ghost method Run(code: seq<Byte>, destinations: set<nat>, assertion: Word, entry: Word, param: Word,
                   index: Word, kind: Word, actual: Word, reference: Word, free: Word,
                   assertionLength: Word, referenceLength: Word, prefix: seq<Word>, mem: seq<Byte>,
                   self: Word, value: Word, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   observations: seq<A.Observation>) returns (frames: seq<E.Frame>)
    requires Matches(code) && Destinations() <= destinations && |prefix| <= 940 && kind <= 8
    requires T.Heap(mem,free,assertion,assertionLength,reference,referenceLength)
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(19793,prefix+[1423,assertion,entry,param,index,kind,actual,reference,free+4],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Reverted(Image(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual)[free..free+292+S.Round32(assertionLength)+S.Round32(referenceLength)]),returned,cursor)
  {
    reveal Matches(); ReturnsCertified();
    T.Start(mem,free,assertion,assertionLength,reference,referenceLength);
    var t1 := P.Run(code,1423,assertion,entry,param,index,kind,actual,reference,free,assertionLength,referenceLength,prefix,mem,value,data);
    R.WidenTrace(code,P.Destinations(),destinations,value,data,t1);
    var m1 := S.Store(mem,free+4,224);
    var base := Prefix(prefix,assertion,entry,param,index,kind,actual,reference,free);
    assert B.Admitted(19811,free+228,assertion,assertionLength,base,m1,data,value) by { reveal B.Admitted(); }
    var state2,t2 := B.Run(code,19811,free+228,assertion,assertionLength,base,m1,data,value);
    BC.Normalize(m1,free+228,assertion,assertionLength);
    R.WidenTrace(code,B.Destinations(19811),destinations,value,data,t2);
    assert t1[|t1|-1] == t2[0];
    U.Join(code,destinations,value,data,t1,t2); var joined := t1+t2[1..];
    var m2 := First(mem,free,assertion,assertionLength,reference,referenceLength);
    T.First(mem,free,assertion,assertionLength,reference,referenceLength);
    var t3 := H.Run(code,1423,assertion,entry,param,index,kind,actual,reference,free,assertionLength,referenceLength,prefix,m2,value,data);
    R.WidenTrace(code,H.Destinations(),destinations,value,data,t3);
    assert joined[|joined|-1] == t3[0];
    U.Join(code,destinations,value,data,joined,t3); joined := joined+t3[1..];
    T.Heads(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
    var m3 := Heads(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
    var dst := free+260+S.Round32(assertionLength);
    assert B.Admitted(19866,dst,reference,referenceLength,base+[dst],m3,data,value) by { reveal B.Admitted(); }
    var state4,t4 := B.Run(code,19866,dst,reference,referenceLength,base+[dst],m3,data,value);
    BC.Normalize(m3,dst,reference,referenceLength);
    R.WidenTrace(code,B.Destinations(19866),destinations,value,data,t4);
    assert joined[|joined|-1] == t4[0];
    U.Join(code,destinations,value,data,joined,t4); joined := joined+t4[1..];
    T.Last(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
    var m4 := Image(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
    var t5 := Z.Run(code,1423,assertion,entry,param,index,kind,actual,reference,free,assertionLength,referenceLength,prefix,m4,value,data);
    R.WidenTrace(code,Z.Destinations(),destinations,value,data,t5);
    assert joined[|joined|-1] == t5[0];
    U.Join(code,destinations,value,data,joined,t5); joined := joined+t5[1..];
    U.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,joined);
    frames := Q.Lift(joined,returned,cursor);
  }
}
