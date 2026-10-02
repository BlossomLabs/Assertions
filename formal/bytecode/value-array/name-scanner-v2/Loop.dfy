// SPDX-License-Identifier: MIT
// Exact arbitrary finite scanName execution; remaining descriptor grammar is open.
include "End.generated.dfy"
include "Digit.generated.dfy"
include "Lower.generated.dfy"
include "OtherLow.generated.dfy"
include "OtherMid.generated.dfy"
include "OtherHigh.generated.dfy"
module BytecodeCollectionsScanNameLoop {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCollectionsArrayByteMachine
  import Z = BytecodeCollectionsArrayByteScalar
  import E = BytecodeCollectionsArrayByteExecution
  import End = BytecodeCollectionsScanNameEnd
  import Digit = BytecodeCollectionsScanNameDigit
  import Lower = BytecodeCollectionsScanNameLower
  import OtherLow = BytecodeCollectionsScanNameOtherLow
  import OtherMid = BytecodeCollectionsScanNameOtherMid
  import OtherHigh = BytecodeCollectionsScanNameOtherHigh
  predicate Allowed(b: Byte) { 48 <= b < 58 || 97 <= b < 123 }
  function DataByte(data: seq<Byte>,offset: nat,q: nat): Byte {
    if offset+q < |data| then data[offset+q] else 0
  }
  predicate Matches(code: seq<Byte>) {
    |code| == 24560 &&
    End.Matches(code) && Digit.Matches(code) && Lower.Matches(code) && OtherLow.Matches(code) && OtherMid.Matches(code) && OtherHigh.Matches(code) && code[19245] == 0x5b && code[19246] == 0x81
  }
  function Destinations(): set<nat> { {5707,19247,19290} }
  lemma Entry(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,value: Word)
    requires Matches(code) && |prefix| <= 1013
    ensures E.Trace(code,Destinations(),value,data,[Running(19245,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem),Running(19246,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem),Running(19247,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,p],mem)])
  {
    var first := Running(19245,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem);
    var second := Running(19246,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem);
    var third := Running(19247,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,p],mem);
    B.Delegate(code,Destinations(),first,value,data);C.Delegate(code,Destinations(),first,value,data);
    B.Delegate(code,Destinations(),second,value,data);C.Delegate(code,Destinations(),second,value,data);reveal S.Step();
    assert B.Step(code,Destinations(),first,value,data) == second;
    assert B.Step(code,Destinations(),second,value,data) == third;
  }
  ghost method Loop(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,value: Word) returns (q: Word,state: State,trace: seq<State>)
    requires Matches(code) && descriptorOffset < 0x10000000000000000 && p <= limit <= descriptorLength < 0x10000000000000000 && |prefix| <= 1013
    ensures p <= q <= limit && (q == limit || !Allowed(DataByte(data,descriptorOffset,q)))
    ensures forall i {:trigger DataByte(data,descriptorOffset,i)} :: p <= i < q ==> Allowed(DataByte(data,descriptorOffset,i))
    ensures state == Running(5707,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,q],mem)
    ensures E.Trace(code,Destinations(),value,data,trace) && trace[0] == Running(19247,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,p],mem) && trace[|trace|-1] == state
  {
    q := p;state := Running(19247,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,q],mem);trace := [state];
    var part: seq<State>;
    while q < limit && Allowed(DataByte(data,descriptorOffset,q))
      invariant p <= q <= limit
      invariant state == Running(19247,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,q],mem)
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[0] == Running(19247,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,p],mem) && trace[|trace|-1] == state
      invariant forall i {:trigger DataByte(data,descriptorOffset,i)} :: p <= i < q ==> Allowed(DataByte(data,descriptorOffset,i))
      decreases limit-q
    {
      var b := DataByte(data,descriptorOffset,q);
      Z.FirstByte(data,descriptorOffset+q);
      var before := state;
      if 48 <= b < 58 {
        state,part := Digit.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,b,value);
      } else {
        state,part := Lower.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,b,value);
      }
      assert part[0] == before;
      Digit.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
      assert trace[|trace|-1] == state;
      forall i {:trigger DataByte(data,descriptorOffset,i)} | p <= i < q+1
        ensures Allowed(DataByte(data,descriptorOffset,i))
      { if i == q { assert DataByte(data,descriptorOffset,i) == b; } }
      q := q+1;
    }
    var before := state;
    if q == limit {
      state,part := End.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,0,value);
    } else {
      var b := DataByte(data,descriptorOffset,q);
      Z.FirstByte(data,descriptorOffset+q);
      if b < 48 {
        state,part := OtherLow.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,b,value);
      } else if b < 97 {
        state,part := OtherMid.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,b,value);
      } else {
        state,part := OtherHigh.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,b,value);
      }
    }
    assert part[0] == before;
    Digit.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,value: Word) returns (q: Word,state: State,trace: seq<State>)
    requires Matches(code) && descriptorOffset < 0x10000000000000000 && p <= limit <= descriptorLength < 0x10000000000000000 && |prefix| <= 1013
    ensures p <= q <= limit && (q == limit || !Allowed(DataByte(data,descriptorOffset,q)))
    ensures forall i {:trigger DataByte(data,descriptorOffset,i)} :: p <= i < q ==> Allowed(DataByte(data,descriptorOffset,i))
    ensures state == Running(5707,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,q],mem)
    ensures E.Trace(code,Destinations(),value,data,trace) && trace[0] == Running(19245,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem) && trace[|trace|-1] == state
  {
    Entry(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,value);
    trace := [Running(19245,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem),Running(19246,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem),Running(19247,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,p],mem)];
    var part: seq<State>;
    q,state,part := Loop(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,value);
    Digit.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
