// SPDX-License-Identifier: MIT
// Exact whole bytes[] serializer through the shared physical public RETURN.
include "Start.generated.dfy"
include "CanonicalLoop.dfy"
include "Return.generated.dfy"
include "Result.dfy"
module AssertionsGatherArrayEncoder {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import L = AssertionsPrimitiveExternalLift
  import F = AssertionsGatherLoopFrame
  import D = AssertionsGatherArraySpec
  import M = AssertionsGatherArrayMemory
  import W = AssertionsGatherArrayWork
  import P = AssertionsGatherArrayEncoded
  import Z = AssertionsGatherArrayResult
  import H = AssertionsGatherArrayStart
  import C = AssertionsGatherArrayCanonicalLoop
  import I = AssertionsGatherArrayIteration
  import Q = AssertionsGatherArrayDone
  import R = AssertionsGatherSerializerReturn
  import DS = AssertionsGatherCallerSpec
  import SR = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { H.Matches(code,381) && I.Matches(code,381) && Q.Matches(code,381) && R.Matches(code) }
  function Destinations(): set<nat> { H.Destinations(381)+C.Destinations(381)+R.Destinations() }
  lemma Label()
    ensures 381 in DS.RuntimeDestinations()
  { reveal DS.RuntimeDestinations(); reveal DS.Chunk0(); }
  lemma Header(mem: seq<Byte>, arrayBase: Word, base: Word, count: Word)
    requires D.StartHeap(mem,arrayBase,base,count) && S.Load(mem,64) == base
    ensures H.Memory2(mem,base,0,0,count) == D.Header2(mem,base,count)
    ensures S.Load(D.Header2(mem,base,count),64) == base
    ensures ((base as nat)+(S.ShiftLeft(count,5) as nat))%G.Modulus()+64 == base+count*32+64
    ensures (((base as nat)+(S.ShiftLeft(count,5) as nat))%G.Modulus()+64)%G.Modulus() == base+count*32+64
    ensures ((base as nat)+64)%G.Modulus() == base+64 && ((arrayBase as nat)+32)%G.Modulus() == arrayBase+32
  {
    D.StartWords(mem,arrayBase,base,count);
    SR.StoredFrame(mem,base,32,64);
    SR.StoredFrame(D.Header1(mem,base),base+32,count,64);
  }
  ghost method Run(code: seq<Byte>, arrayBase: Word, base: Word, values: seq<seq<Byte>>, pointers: seq<Word>,
                   prefix: seq<Word>, initial: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   self: Word, value: Word, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>, output: seq<Byte>)
    requires Matches(code) && |prefix| <= 940
    requires W.Budget(base,values) && W.Sources(initial,arrayBase,base,values,pointers)
    requires D.StartHeap(initial,arrayBase,base,|values|) && S.Load(initial,64) == base
    ensures L.Trace(code,Destinations(),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(17316,prefix+[381,arrayBase,base],initial),returned,cursor)
    ensures frames[|frames|-1] == frame && frame == E.Frame(S.Returned(output),returned,cursor)
    ensures Z.Result(output,values)
  {
    Label(); Header(initial,arrayBase,base,|values|); M.Start(initial,arrayBase,base,|values|); W.Positions(base,values,0);
    reveal H.Admitted();
    var count: Word := |values|;
    var state,states := H.Run(code,381,arrayBase,base,0,0,count,0,0,0,0,prefix,initial,data,value);
    frames := F.Lift(code,H.Destinations(381),Destinations(),self,value,data,observations,states,returned,cursor);
    var header := D.Header2(initial,base,count);
    W.Preserved(initial,header,arrayBase,base,values,pointers);
    var firstTail: Word := base+64+count*32;
    var part: seq<E.Frame>; var tail: Word;
    frame,part,tail := C.Run(code,381,arrayBase,base,firstTail,values,pointers,prefix,header,data,returned,cursor,self,value,observations);
    F.Widen(code,C.Destinations(381),Destinations(),self,value,data,observations,part);
    F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
    var mem := frame.state.memory;
    W.Positions(base,values,|values|);
    if count > 0 {
      reveal P.Done(); assert P.Cell(mem,base,values,count-1); reveal P.Cell();
    }
    assert tail <= |mem|;
    assert mem[base..base+32] == G.Encode(32,32) && mem[base+32..base+64] == G.Encode(count,32);
    M.LoadEqual(header,mem,64);
    Z.Materialized(mem,base,tail,values); output := mem[base..tail];
    reveal R.Admitted();
    state,states := R.Run(code,arrayBase,base,tail,prefix,mem,value,data);
    part := F.Lift(code,R.Destinations(),Destinations(),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
    frame := E.Frame(state,returned,cursor);
  }
}
