// SPDX-License-Identifier: MIT
// Unbounded original-word reversal composed from exact helper and instruction traces.
include "Guard.generated.dfy"
include "AfterMulFirst.generated.dfy"
include "AfterMulSecond.generated.dfy"
include "AfterEnd.generated.dfy"
include "AfterSlice.generated.dfy"
include "Tail.generated.dfy"
include "Exit.generated.dfy"
include "Mul32.generated.dfy"
include "Add.generated.dfy"
include "Slice.generated.dfy"
include "Read32.generated.dfy"
include "../Memory.dfy"
module BytecodeReverseLoopEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import R = BytecodeWordReverseMemory
  import L = BytecodeReverseSegmentGuard
  import M1 = BytecodeReverseSegmentAfterMulFirst
  import M2 = BytecodeReverseSegmentAfterMulSecond
  import N = BytecodeReverseSegmentAfterEnd
  import S = BytecodeReverseSegmentAfterSlice
  import T = BytecodeReverseSegmentTail
  import X = BytecodeReverseSegmentExit
  import HP = BytecodeReverseHelperMul32
  import HA = BytecodeReverseHelperAdd
  import HS = BytecodeReverseHelperSlice
  import HR = BytecodeReverseHelperRead32
  predicate Matches(code: seq<Byte>) {
    L.Matches(code) && M1.Matches(code) && M2.Matches(code) && N.Matches(code) &&
    S.Matches(code) && T.Matches(code) && X.Matches(code) &&
    HP.Matches(code) && HA.Matches(code) && HS.Matches(code) && HR.Matches(code)
  }
  function Destinations(): set<nat> {
    L.Destinations()+M1.Destinations()+M2.Destinations()+N.Destinations()+
    S.Destinations()+T.Destinations()+X.Destinations()+
    HP.Destinations()+HA.Destinations()+HS.Destinations()+HR.Destinations()
  }
  predicate Fits(data: seq<Byte>, offset: Word, length: Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data| && length%32 == 0
  }
  lemma Geometry(data: seq<Byte>, offset: Word, length: Word, index: Word)
    requires Fits(data,offset,length) && index < length/32
    ensures N.Position(index) == (index as nat)*32
    ensures N.NextPosition(index) == ((index as nat)+1)*32
    ensures S.WordOffset(offset,index) == (offset as nat)+(index as nat)*32
    ensures (N.NextPosition(index) as nat)-(N.Position(index) as nat) == 32
    ensures T.Target(length,index) == R.Offset(length/32,index)
    ensures R.Admitted(length/32,index,offset,data)
  {}
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, trace: seq<State>, part: seq<State>, small: set<nat>) returns (combined: seq<State>)
    requires E.Trace(code,Destinations(),value,data,trace) && E.Trace(code,small,value,data,part)
    requires small <= Destinations() && trace[|trace|-1] == part[0]
    ensures E.Trace(code,Destinations(),value,data,combined)
    ensures combined[0] == trace[0] && combined[|combined|-1] == part[|part|-1]
  {
    E.WidenTrace(code,small,Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    combined := trace+part[1..];
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Fits(data,offset,length)
    ensures state == Running(518,[2874738232,128],R.Heap(length/32,length/32,offset,data))
    ensures state.memory[160..] == R.Payload(length/32,offset,data)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,0],R.Heap(length/32,0,offset,data)) && trace[|trace|-1] == state
  {
    var count: Word := length/32;
    assert count < 0x800000000000000 && count*32 == length;
    var index: Word := 0;
    var mem := R.Heap(count,index,offset,data);
    state := Running(5846,[2874738232,518,offset,length,128,count,index],mem);
    trace := [state];
    while index < count
      invariant index <= count && count == length/32 && count*32 == length
      invariant mem == R.Heap(count,index,offset,data)
      invariant state == Running(5846,[2874738232,518,offset,length,128,count,index],mem)
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(5846,[2874738232,518,offset,length,128,count,0],R.Heap(count,0,offset,data))
      decreases count-index
    {
      Geometry(data,offset,length,index);
      var saved: seq<Word> := [2874738232,518,offset,length,128,count,index];
      var part: seq<State>;
      state,part := L.Run(code,offset,length,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,L.Destinations());
      state,part := HP.Run(code,saved+[0,offset,length],index,5868,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := M1.Run(code,offset,length,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,M1.Destinations());
      state,part := HP.Run(code,saved+[0,offset,M1.Position(index),length],index,5880,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := M2.Run(code,offset,length,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,M2.Destinations());
      state,part := HA.Run(code,saved+[0,offset,M2.Position(index),length],M2.Position(index),32,5891,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := N.Run(code,offset,length,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,N.Destinations());
      state,part := HS.Run(code,saved+[0],offset,length,N.Position(index),N.NextPosition(index),mem,value,data);
      trace := Append(code,value,data,trace,part,HS.Destinations());
      assert trace[|trace|-1] == Running(5904,saved+[0,S.WordOffset(offset,index),32],mem);
      state,part := S.Run(code,offset,length,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,S.Destinations());
      state,part := HR.Run(code,saved+[0],S.WordOffset(offset,index),mem,value,data);
      trace := Append(code,value,data,trace,part,HR.Destinations());
      var word := DataWord(data,offset+index*32);
      R.Advance(count,index,offset,data);
      state,part := T.Run(code,offset,length,index,word,mem,value,data);
      trace := Append(code,value,data,trace,part,T.Destinations());
      mem := R.Heap(count,index+1,offset,data);
      index := index+1;
    }
    var part: seq<State>;
    state,part := X.Run(code,offset,length,index,0,mem,value,data);
    trace := Append(code,value,data,trace,part,X.Destinations());
    R.OriginalBytes(count,offset,data);
  }
}
