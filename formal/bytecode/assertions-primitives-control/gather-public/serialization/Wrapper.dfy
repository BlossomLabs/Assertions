// SPDX-License-Identifier: MIT
// Full physical public gather serializer suffix PC477 -> canonical bytes[] RETURN.
include "Before.generated.dfy"
include "Encoder.dfy"
module AssertionsGatherSerializerWrapper {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsGatherArraySpec
  import W = AssertionsGatherArrayWork
  import Z = AssertionsGatherArrayResult
  import B = AssertionsGatherSerializerBefore
  import C = AssertionsGatherArrayEncoder
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { B.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { B.Destinations()+C.Destinations() }
  ghost method Run(code: seq<Byte>, arrayBase: Word, base: Word, values: seq<seq<Byte>>, pointers: seq<Word>,
                   prefix: seq<Word>, initial: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   self: Word, value: Word, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>, output: seq<Byte>)
    requires Matches(code) && |prefix| <= 940
    requires W.Budget(base,values) && W.Sources(initial,arrayBase,base,values,pointers)
    requires D.StartHeap(initial,arrayBase,base,|values|) && S.Load(initial,64) == base
    ensures L.Trace(code,Destinations(),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(477,prefix+[arrayBase],initial),returned,cursor)
    ensures frames[|frames|-1] == frame && frame == E.Frame(S.Returned(output),returned,cursor)
    ensures Z.Result(output,values)
  {
    reveal B.Admitted();
    var state,states := B.Run(code,arrayBase,base,0,prefix,initial,value,data);
    frames := F.Lift(code,B.Destinations(),Destinations(),self,value,data,observations,states,returned,cursor);
    var part: seq<E.Frame>;
    frame,part,output := C.Run(code,arrayBase,base,values,pointers,prefix,initial,data,returned,cursor,self,value,observations);
    F.Widen(code,C.Destinations(),Destinations(),self,value,data,observations,part);
    F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
  }
}
