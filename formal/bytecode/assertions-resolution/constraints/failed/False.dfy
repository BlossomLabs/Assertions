// SPDX-License-Identifier: MIT
// False non-OR validator caller through canonical ConstraintFailed physical REVERT.
include "CallerHeap.dfy"
include "Canonical.dfy"
include "../LoopFrames.dfy"
module AssertionsConstraintFailedFalse {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import W = AssertionsConstraintLoopFrames
  import C = AssertionsConstraintFailedCaller
  import H = AssertionsConstraintFailedCallerHeap
  import F = AssertionsConstraintFailedSerialization
  import K = AssertionsConstraintFailedCanonical
  import P = AssertionsConstraintFailedSpec
  type Word = S.Word
  type Byte = S.Byte
  function Base(ret: Word, constraints: Word, count: Word, ptr: Word, assertion: Word, entry: Word,
                param: Word, words: Word, index: Word, actual: Word, record: Word): seq<Word>
  { [ret,constraints,count,ptr,assertion,entry,param,count,words,index,actual,record] }
  opaque predicate Matches(code: seq<Byte>) { C.Matches(code) && F.Matches(code) }
  function Destinations(): set<nat> { C.Destinations()+F.Destinations() }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, destinations: set<nat>, ret: Word, constraints: Word,
                count: Word, ptr: Word, assertion: Word, entry: Word, param: Word, words: Word, index: Word,
                actual: Word, record: Word, kind: Word, reference: Word, free: Word,
                assertionLength: Word, referenceLength: Word, prefix: seq<Word>, mem: seq<Byte>,
                self: Word, value: Word, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                observations: seq<A.Observation>) returns (frames: seq<E.Frame>)
    requires Matches(code) && Destinations() <= destinations
    requires C.Admitted(ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,kind,reference,free,assertionLength,referenceLength,prefix,mem)
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(8035,prefix+Base(ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record)+[0,0],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Reverted(P.Error(mem[assertion+32..assertion+32+assertionLength],entry,param,index,kind,actual,
      mem[reference+32..reference+32+referenceLength])),returned,cursor)
  {
    reveal Matches();
    var caller := C.Run(code,ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record,kind,reference,free,assertionLength,referenceLength,prefix,mem,value,data);
    R.WidenTrace(code,C.Destinations(),destinations,value,data,caller);
    var bodyPrefix := prefix+Base(ret,constraints,count,ptr,assertion,entry,param,words,index,actual,record)+[0];
    assert |bodyPrefix| <= 940;
    U.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,caller);
    frames := Q.Lift(caller,returned,cursor);
    var prepared := C.Image(mem,free);
    H.Prepared(mem,free,assertion,assertionLength,reference,referenceLength);
    var body := F.Run(code,destinations,assertion,entry,param,index,kind,actual,reference,free,assertionLength,referenceLength,bodyPrefix,prepared,self,value,data,returned,cursor,observations);
    assert frames[|frames|-1] == body[0];
    W.Join(code,destinations,self,value,data,observations,frames,body);
    frames := frames+body[1..];
    K.Image(prepared,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
  }
}
