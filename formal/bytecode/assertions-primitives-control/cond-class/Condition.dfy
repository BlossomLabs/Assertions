// SPDX-License-Identifier: MIT
// Exact public body prefix, RAW condition resolve, and first-word choice/rejection.
include "RawSpec.dfy"
include "Memory.dfy"
include "FirstWord.dfy"
module AssertionsCondRawCondition {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import C = AssertionsControlCondStart
  import N = AssertionsControlCondFirstWord
  import P = AssertionsPrimitivePreparation
  import D = AssertionsCondRawSpec
  import R = AssertionsRawResolve
  import RR = AssertionsRawResolveConnection
  import M = AssertionsRawResolveMemory
  import Q = AssertionsCondMemory
  import W = AssertionsCondFirstWord
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { C.Matches(code) && N.Matches(code) && R.Matches(code,1770) && W.Matches(code) && 1783 < |code| && code[1783] == 0x5b }
  function Destinations(ret: Word): set<nat> { C.Destinations(ret)+N.Destinations(ret)+R.Destinations(1770)+W.Destinations(1783) }
  function Free(free: Word, operand: D.Operand): Word
    requires free+S.Round32(operand.length)+64 < G.Modulus()
  { free+64+S.Round32(operand.length) }
  function Image(mem: seq<Byte>, free: Word, operand: D.Operand, data: seq<Byte>): seq<Byte>
    requires D.Heap(mem,free,operand) && D.Span(data,operand)
  { M.Construct(P.EmptyAssertion(mem,free),free+32,D.Offset(operand),operand.length,data) }
  function First(data: seq<Byte>, operand: D.Operand): Word
    requires D.Span(data,operand)
  { if operand.length < 32 then 0 else S.DataWord(data,D.Offset(operand)) }
  ghost method Run(code: seq<Byte>, ret: Word, condition: D.Operand, then_: Word, else_: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word, observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code) && D.Span(data,condition) && D.Heap(mem,free,condition) && |prefix| <= 940
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(1743,prefix+[ret,condition.pointer,then_,else_],mem),returned,cursor) && frames[|frames|-1] == frame
    ensures if condition.length < 32 then frame == E.Frame(S.Reverted(W.Error(condition.length)),returned,cursor)
            else frame == E.Frame(S.Running(1783,prefix+[ret,condition.pointer,then_,else_,free+32,0,0,First(data,condition)],Image(mem,free,condition,data)),returned,cursor)
    ensures S.Load(Image(mem,free,condition,data),64) == Free(free,condition)
    ensures |Image(mem,free,condition,data)|%32 == 0 && 96 <= |Image(mem,free,condition,data)| <= Free(free,condition)+32
  {
    hide S.DataWord(); hide S.Window(); hide G.Decode(); hide M.Construct();
    D.Prepared(mem,free,condition,data); D.Admitted(1770,0,0,condition,free,prefix+[ret,condition.pointer,then_,else_,0],mem,data);
    var state,states := C.Run(code,ret,condition.pointer,then_,else_,0,0,0,free,prefix,mem,value,data);
    assert C.Memory2(ret,condition.pointer,then_,else_,0,0,0,free,prefix,mem) == P.EmptyAssertion(mem,free);
    frames := F.Lift(code,C.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    var part: seq<E.Frame>;
    frame,part := RR.Run(code,Destinations(ret),1770,condition.pointer,free,0,0,condition.bytesRelative,condition.constraintsRelative,condition.length,free+32,prefix+[ret,condition.pointer,then_,else_,0],P.EmptyAssertion(mem,free),data,returned,cursor,self,value,observations);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    M.Built(P.EmptyAssertion(mem,free),free+32,D.Offset(condition),condition.length,data);
    var image := Image(mem,free,condition,data);
    assert image == M.Construct(P.EmptyAssertion(mem,free),free+32,D.Offset(condition),condition.length,data);
    state,states := N.Run(code,ret,condition.pointer,then_,else_,free+32,condition.length,First(data,condition),Free(free,condition),prefix,image,value,data);
    part := F.Lift(code,N.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    if condition.length >= 32 { Q.First(P.EmptyAssertion(mem,free),free+32,D.Offset(condition),condition.length,data); }
    D.Labels();
    frame,part := W.Run(code,1783,prefix+[ret,condition.pointer,then_,else_,free+32,0,0],image,free+32,condition.length,First(data,condition),Free(free,condition),data,returned,cursor,self,value,observations);
    F.Widen(code,W.Destinations(1783),Destinations(ret),self,value,data,observations,part);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
  }
}
