// SPDX-License-Identifier: MIT
// Exact arbitrary finite decimal suffix scan, including the uint32 stop guard.
include "Iteration.dfy"
include "../decimal-guards/End.generated.dfy"
include "../decimal-guards/Low.generated.dfy"
include "../decimal-guards/High.generated.dfy"
include "../decimal-guards/Large.generated.dfy"
include "../byte-machine/Scalar.dfy"
module BytecodeCollectionsDecimalLoop {
  import opened BytecodeScanMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import I = BytecodeCollectionsDecimalIteration
  import End = BytecodeCollectionsDecimalEnd
  import Low = BytecodeCollectionsDecimalLow
  import High = BytecodeCollectionsDecimalHigh
  import Large = BytecodeCollectionsDecimalLarge
  predicate Digit(b: Byte) { 48 <= b <= 57 }
  function DataByte(data: seq<Byte>,offset: Word,q: nat): Byte {
    if offset+q < |data| then data[offset+q] else 0
  }
  function Number(data: seq<Byte>,offset: Word,start: nat,stop: nat): int
    requires start <= stop
    decreases stop-start
  { if start == stop then 0 else Number(data,offset,start,stop-1)*10+(DataByte(data,offset,stop-1) as int)-48 }
  lemma NumberExtend(data: seq<Byte>,offset: Word,start: nat,q: nat)
    requires start <= q
    ensures Number(data,offset,start,q+1) == Number(data,offset,start,q)*10+(DataByte(data,offset,q) as int)-48
  {}
  predicate Matches(code: seq<Byte>) {
    I.Matches(code) && End.Matches(code) && Low.Matches(code) && High.Matches(code) && Large.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    I.Destinations(returnPc)+End.Destinations(returnPc)+Low.Destinations(returnPc)+High.Destinations(returnPc)+Large.Destinations(returnPc)
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,value: Word) returns (q: Word,k: Word,state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1005 && descriptorOffset < 0x10000000000000000 && end < limit <= descriptorLength < 0x10000000000000000
    ensures end+1 <= q <= limit && k <= 0xffffffff*10+9 && k == Number(data,descriptorOffset,end+1,q)
    ensures forall i {:trigger DataByte(data,descriptorOffset,i)} :: end+1 <= i < q ==> Digit(DataByte(data,descriptorOffset,i))
    ensures q == limit || !Digit(DataByte(data,descriptorOffset,q)) || k > 0xffffffff
    ensures state == Running(14433,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k],mem)
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14320,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,end+1,0],mem) && trace[|trace|-1] == state
  {
    q := end+1;k := 0;state := Running(14320,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k],mem);trace := [state];
    var part: seq<State>;
    while q < limit && Digit(DataByte(data,descriptorOffset,q)) && k <= 0xffffffff
      invariant end+1 <= q <= limit && k <= 0xffffffff*10+9 && k == Number(data,descriptorOffset,end+1,q)
      invariant forall i {:trigger DataByte(data,descriptorOffset,i)} :: end+1 <= i < q ==> Digit(DataByte(data,descriptorOffset,i))
      invariant state == Running(14320,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k],mem)
      invariant E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14320,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,end+1,0],mem) && trace[|trace|-1] == state
      decreases limit-q
    {
      var b := DataByte(data,descriptorOffset,q);Z.FirstByte(data,descriptorOffset+q);
      var before := state;
      state,part := I.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
      assert part[0] == before;
      X.WidenTrace(code,I.Destinations(returnPc),Destinations(returnPc),value,data,part);
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
      NumberExtend(data,descriptorOffset,end+1,q);
      forall i {:trigger DataByte(data,descriptorOffset,i)} | end+1 <= i < q+1
        ensures Digit(DataByte(data,descriptorOffset,i))
      { if i == q { assert DataByte(data,descriptorOffset,i) == b; } }
      k := k*10+b-48;q := q+1;
    }
    var before := state;
    if q == limit {
      state,part := End.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,0,value);
      X.WidenTrace(code,End.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else {
      var b := DataByte(data,descriptorOffset,q);Z.FirstByte(data,descriptorOffset+q);
      if b < 48 {
        state,part := Low.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
        X.WidenTrace(code,Low.Destinations(returnPc),Destinations(returnPc),value,data,part);
      } else if b > 57 {
        state,part := High.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
        X.WidenTrace(code,High.Destinations(returnPc),Destinations(returnPc),value,data,part);
      } else {
        state,part := Large.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
        X.WidenTrace(code,Large.Destinations(returnPc),Destinations(returnPc),value,data,part);
      }
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
