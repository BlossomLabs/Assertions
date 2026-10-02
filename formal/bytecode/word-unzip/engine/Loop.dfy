// SPDX-License-Identifier: MIT
// Arbitrary finite actual lane loop, with original bytes and decreasing remaining count.
include "../loop/Guard.generated.dfy"
include "../loop/AfterMulTwiceA.generated.dfy"
include "../loop/AfterLaneA.generated.dfy"
include "../loop/AfterPositionA.generated.dfy"
include "../loop/AfterMulTwiceB.generated.dfy"
include "../loop/AfterLaneB.generated.dfy"
include "../loop/AfterPositionB.generated.dfy"
include "../loop/AfterEnd.generated.dfy"
include "../loop/AfterSlice.generated.dfy"
include "../loop/Tail.generated.dfy"
include "../loop/Exit.generated.dfy"
include "../loop/Mul32.generated.dfy"
include "../loop/Mul2.generated.dfy"
include "../loop/Add.generated.dfy"
include "../loop/Slice.generated.dfy"
include "../loop/Read32.generated.dfy"
include "../Memory.dfy"
module BytecodeUnzipExecutionConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import R = BytecodeWordUnzipMemory
  import L = BytecodeUnzipSegmentGuard
  import M1 = BytecodeUnzipSegmentAfterMulTwiceA
  import LA = BytecodeUnzipSegmentAfterLaneA
  import PA = BytecodeUnzipSegmentAfterPositionA
  import M2 = BytecodeUnzipSegmentAfterMulTwiceB
  import LB = BytecodeUnzipSegmentAfterLaneB
  import PB = BytecodeUnzipSegmentAfterPositionB
  import N = BytecodeUnzipSegmentAfterEnd
  import S = BytecodeUnzipSegmentAfterSlice
  import T = BytecodeUnzipSegmentTail
  import X = BytecodeUnzipSegmentExit
  import HP = BytecodeUnzipHelperMul32
  import H2 = BytecodeUnzipHelperMul2
  import HA = BytecodeUnzipHelperAdd
  import HS = BytecodeUnzipHelperSlice
  import HR = BytecodeUnzipHelperRead32
  predicate Matches(code: seq<Byte>) {
    L.Matches(code) && M1.Matches(code) && LA.Matches(code) && PA.Matches(code) && M2.Matches(code) && LB.Matches(code) && PB.Matches(code) && N.Matches(code) && S.Matches(code) && T.Matches(code) && X.Matches(code) && HP.Matches(code) && H2.Matches(code) && HA.Matches(code) && HS.Matches(code) && HR.Matches(code)
  }
  function Destinations(): set<nat> {
    L.Destinations()+M1.Destinations()+LA.Destinations()+PA.Destinations()+M2.Destinations()+LB.Destinations()+PB.Destinations()+N.Destinations()+S.Destinations()+T.Destinations()+X.Destinations()+HP.Destinations()+H2.Destinations()+HA.Destinations()+HS.Destinations()+HR.Destinations()
  }
  predicate Fits(data: seq<Byte>, offset: Word, length: Word, lane: Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data| && length%32 == 0 && lane <= 1
  }
  lemma Geometry(data: seq<Byte>, offset: Word, length: Word, lane: Word, index: Word)
    requires Fits(data,offset,length,lane) && index < L.Count(length,lane)
    ensures N.Position(index,lane) == (2*(index as nat)+(lane as nat))*32
    ensures N.NextPosition(index,lane) == (2*(index as nat)+(lane as nat)+1)*32
    ensures S.WordOffset(offset,index,lane) == (offset as nat)+(2*(index as nat)+(lane as nat))*32
    ensures N.NextPosition(index,lane) <= length
    ensures (N.NextPosition(index,lane) as nat)-(N.Position(index,lane) as nat) == 32
    ensures T.Target(index) == 160+(index as nat)*32
    ensures R.Admitted(length/32,index,lane,offset,data)
    ensures L.Count(length,lane) == R.Count(length/32,lane)
  {
    R.Geometry(length/32,lane,index);
  }
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
  ghost method Run(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word, lane: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Fits(data,offset,length,lane)
    ensures state == Running(518,[2989505972,128],R.Heap(length/32,R.Count(length/32,lane),lane,offset,data))
    ensures state.memory[160..] == R.Payload(length/32,lane,offset,data)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,R.Count(length/32,lane),0],R.Heap(length/32,0,lane,offset,data)) && trace[|trace|-1] == state
  {
    var count: Word := length/32;
    var laneCount: Word := R.Count(count,lane);
    assert count < 0x800000000000000 && count*32 == length;
    assert laneCount == L.Count(length,lane) && laneCount <= count;
    var index: Word := 0;
    var mem := R.Heap(count,index,lane,offset,data);
    state := Running(6162,[2989505972,518,offset,length,lane,128,count,laneCount,index],mem);
    trace := [state];
    while index < laneCount
      invariant index <= laneCount && count == length/32 && count*32 == length
      invariant laneCount == R.Count(count,lane) && laneCount == L.Count(length,lane)
      invariant mem == R.Heap(count,index,lane,offset,data)
      invariant state == Running(6162,[2989505972,518,offset,length,lane,128,count,laneCount,index],mem)
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,count,laneCount,0],R.Heap(count,0,lane,offset,data))
      decreases laneCount-index
    {
      Geometry(data,offset,length,lane,index);
      var saved: seq<Word> := [2989505972,518,offset,length,lane,128,count,laneCount,index];
      var part: seq<State>;
      state,part := L.Run(code,offset,length,lane,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,L.Destinations());
      state,part := H2.Run(code,saved+[0,offset,length,lane],index,6185,mem,value,data);
      trace := Append(code,value,data,trace,part,H2.Destinations());
      state,part := M1.Run(code,offset,length,lane,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,M1.Destinations());
      state,part := HA.Run(code,saved+[0,offset,length],lane,M1.Twice(index),6195,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := LA.Run(code,offset,length,lane,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,LA.Destinations());
      state,part := HP.Run(code,saved+[0,offset,length],LA.SourceIndex(index,lane),6206,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := PA.Run(code,offset,length,lane,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,PA.Destinations());
      state,part := H2.Run(code,saved+[0,offset,PA.Position(index,lane),length,lane],index,6219,mem,value,data);
      trace := Append(code,value,data,trace,part,H2.Destinations());
      assert PA.Twice(index) == (index as nat)*2;
      assert trace[|trace|-1] == Running(6219,saved+[0,offset,PA.Position(index,lane),length,lane,PA.Twice(index)],mem);
      state,part := M2.Run(code,offset,length,lane,index,0,mem,value,data);
      assert M2.Position(index,lane) == PA.Position(index,lane);
      assert M2.Twice(index) == PA.Twice(index);
      assert part[0] == Running(6219,saved+[0,offset,PA.Position(index,lane),length,lane,PA.Twice(index)],mem);
      assert trace[|trace|-1] == part[0];
      assert M2.Destinations() <= Destinations();
      trace := Append(code,value,data,trace,part,M2.Destinations());
      state,part := HA.Run(code,saved+[0,offset,M2.Position(index,lane),length],lane,M2.Twice(index),6229,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := LB.Run(code,offset,length,lane,index,0,mem,value,data);
      assert trace[|trace|-1] == part[0];
      assert LB.Destinations() <= Destinations();
      trace := Append(code,value,data,trace,part,LB.Destinations());
      state,part := HP.Run(code,saved+[0,offset,LB.Position(index,lane),length],LB.SourceIndex(index,lane),6240,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := PB.Run(code,offset,length,lane,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,PB.Destinations());
      state,part := HA.Run(code,saved+[0,offset,PB.Position(index,lane),length],PB.Position(index,lane),32,6251,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := N.Run(code,offset,length,lane,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,N.Destinations());
      state,part := HS.Run(code,saved+[0],offset,length,N.Position(index,lane),N.NextPosition(index,lane),mem,value,data);
      trace := Append(code,value,data,trace,part,HS.Destinations());
      state,part := S.Run(code,offset,length,lane,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,S.Destinations());
      state,part := HR.Run(code,saved+[0],S.WordOffset(offset,index,lane),mem,value,data);
      trace := Append(code,value,data,trace,part,HR.Destinations());
      var word := DataWord(data,offset+(2*index+lane)*32);
      R.Advance(count,index,lane,offset,data);
      state,part := T.Run(code,offset,length,lane,index,word,mem,value,data);
      trace := Append(code,value,data,trace,part,T.Destinations());
      mem := R.Heap(count,index+1,lane,offset,data);
      index := index+1;
    }
    var part: seq<State>;
    state,part := X.Run(code,offset,length,lane,index,0,mem,value,data);
    trace := Append(code,value,data,trace,part,X.Destinations());
    R.OriginalBytes(count,lane,offset,data);
  }
}
