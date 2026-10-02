// SPDX-License-Identifier: MIT
// Arbitrary finite actual pair loop, original bytes and decreasing remaining count.
include "../loop/Guard.generated.dfy"
include "../loop/AfterPositionAStart.generated.dfy"
include "../loop/AfterPositionAEnd.generated.dfy"
include "../loop/AfterEndA.generated.dfy"
include "../loop/AfterSliceA.generated.dfy"
include "../loop/AfterReadA.generated.dfy"
include "../loop/AfterPositionBStart.generated.dfy"
include "../loop/AfterPositionBEnd.generated.dfy"
include "../loop/AfterEndB.generated.dfy"
include "../loop/AfterSliceB.generated.dfy"
include "../loop/Tail.generated.dfy"
include "../loop/Exit.generated.dfy"
include "../loop/Mul32.generated.dfy"
include "../loop/Add.generated.dfy"
include "../loop/Slice.generated.dfy"
include "../loop/Read32.generated.dfy"
include "../Memory.dfy"
module BytecodeZipExecutionConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import R = BytecodeWordZipMemory
  import L = BytecodeZipSegmentGuard
  import AS = BytecodeZipSegmentAfterPositionAStart
  import AE = BytecodeZipSegmentAfterPositionAEnd
  import AN = BytecodeZipSegmentAfterEndA
  import AR = BytecodeZipSegmentAfterSliceA
  import BR = BytecodeZipSegmentAfterReadA
  import BS = BytecodeZipSegmentAfterPositionBStart
  import BE = BytecodeZipSegmentAfterPositionBEnd
  import BN = BytecodeZipSegmentAfterEndB
  import RR = BytecodeZipSegmentAfterSliceB
  import T = BytecodeZipSegmentTail
  import X = BytecodeZipSegmentExit
  import HP = BytecodeZipHelperMul32
  import HA = BytecodeZipHelperAdd
  import HS = BytecodeZipHelperSlice
  import HR = BytecodeZipHelperRead32
  predicate Matches(code: seq<Byte>) {
    L.Matches(code) && AS.Matches(code) && AE.Matches(code) && AN.Matches(code) && AR.Matches(code) && BR.Matches(code) && BS.Matches(code) && BE.Matches(code) && BN.Matches(code) && RR.Matches(code) && T.Matches(code) && X.Matches(code) && HP.Matches(code) && HA.Matches(code) && HS.Matches(code) && HR.Matches(code)
  }
  function Destinations(): set<nat> {
    L.Destinations()+AS.Destinations()+AE.Destinations()+AN.Destinations()+AR.Destinations()+BR.Destinations()+BS.Destinations()+BE.Destinations()+BN.Destinations()+RR.Destinations()+T.Destinations()+X.Destinations()+HP.Destinations()+HA.Destinations()+HS.Destinations()+HR.Destinations()
  }
  predicate Fits(data: seq<Byte>, a: Word, b: Word, length: Word) {
    |data| < 0x10000000000000000 && length < 0x8000000000000000 &&
    (a as nat)+(length as nat) <= |data| && (b as nat)+(length as nat) <= |data| && length%32 == 0
  }
  lemma Geometry(data: seq<Byte>, a: Word, b: Word, length: Word, index: Word)
    requires Fits(data,a,b,length) && index < length/32
    ensures L.Position(index) == (index as nat)*32
    ensures L.NextPosition(index) == (index as nat)*32+32
    ensures AR.WordOffset(a,index) == (a as nat)+(index as nat)*32
    ensures RR.WordOffset(b,index) == (b as nat)+(index as nat)*32
    ensures L.NextPosition(index) <= length
    ensures (L.NextPosition(index) as nat)-(L.Position(index) as nat) == 32
    ensures T.TargetA(index) == 160+(index as nat)*64 && T.TargetB(index) == 192+(index as nat)*64
    ensures R.Admitted(length/32,2*(index as nat),a,b,data)
    ensures R.Source(length/32,2*(index as nat),a,b,data) == DataWord(data,a+index*32)
    ensures R.Source(length/32,2*(index as nat)+1,a,b,data) == DataWord(data,b+index*32)
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
  ghost method Run(code: seq<Byte>, data: seq<Byte>, a: Word, b: Word, length: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Fits(data,a,b,length)
    ensures state == Running(518,[269019481,128],R.Heap(length/32,2*(length/32),a,b,data))
    ensures state.memory[160..] == R.Payload(length/32,a,b,data)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,0],R.Heap(length/32,0,a,b,data)) && trace[|trace|-1] == state
  {
    var count: Word := length/32;
    assert count < 0x400000000000000 && count*32 == length;
    var index: Word := 0;
    var mem := R.Heap(count,2*index,a,b,data);
    state := Running(2094,[269019481,518,a,length,b,length,128,count,index],mem);
    trace := [state];
    while index < count
      invariant index <= count && count == length/32 && count*32 == length
      invariant mem == R.Heap(count,2*index,a,b,data)
      invariant state == Running(2094,[269019481,518,a,length,b,length,128,count,index],mem)
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(2094,[269019481,518,a,length,b,length,128,count,0],R.Heap(count,0,a,b,data))
      decreases count-index
    {
      Geometry(data,a,b,length,index);
      var saved: seq<Word> := [269019481,518,a,length,b,length,128,count,index];
      var part: seq<State>;
      state,part := L.Run(code,a,b,length,index,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,L.Destinations());
      state,part := HP.Run(code,saved+[0,a,length],index,2116,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := AS.Run(code,a,b,length,index,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,AS.Destinations());
      state,part := HP.Run(code,saved+[0,a,AS.Position(index),length],index,2128,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := AE.Run(code,a,b,length,index,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,AE.Destinations());
      state,part := HA.Run(code,saved+[0,a,AE.Position(index),length],AE.Position(index),32,2139,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := AN.Run(code,a,b,length,index,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,AN.Destinations());
      state,part := HS.Run(code,saved+[0],a,length,AN.Position(index),AN.NextPosition(index),2152,mem,value,data);
      trace := Append(code,value,data,trace,part,HS.Destinations());
      state,part := AR.Run(code,a,b,length,index,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,AR.Destinations());
      state,part := HR.Run(code,saved+[0],AR.WordOffset(a,index),2161,mem,value,data);
      trace := Append(code,value,data,trace,part,HR.Destinations());
      var wordA := DataWord(data,a+index*32);
      state,part := BR.Run(code,a,b,length,index,wordA,0,mem,value,data);
      trace := Append(code,value,data,trace,part,BR.Destinations());
      state,part := HP.Run(code,saved+[wordA,0,b,length],index,2177,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := BS.Run(code,a,b,length,index,wordA,0,mem,value,data);
      trace := Append(code,value,data,trace,part,BS.Destinations());
      state,part := HP.Run(code,saved+[wordA,0,b,BS.Position(index),length],index,2189,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := BE.Run(code,a,b,length,index,wordA,0,mem,value,data);
      trace := Append(code,value,data,trace,part,BE.Destinations());
      state,part := HA.Run(code,saved+[wordA,0,b,BE.Position(index),length],BE.Position(index),32,2200,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := BN.Run(code,a,b,length,index,wordA,0,mem,value,data);
      trace := Append(code,value,data,trace,part,BN.Destinations());
      state,part := HS.Run(code,saved+[wordA,0],b,length,BN.Position(index),BN.NextPosition(index),2213,mem,value,data);
      trace := Append(code,value,data,trace,part,HS.Destinations());
      state,part := RR.Run(code,a,b,length,index,wordA,0,mem,value,data);
      trace := Append(code,value,data,trace,part,RR.Destinations());
      state,part := HR.Run(code,saved+[wordA,0],RR.WordOffset(b,index),2222,mem,value,data);
      trace := Append(code,value,data,trace,part,HR.Destinations());
      var wordB := DataWord(data,b+index*32);
      R.Advance(count,2*index,a,b,data);
      R.Advance(count,2*index+1,a,b,data);
      state,part := T.Run(code,a,b,length,index,wordA,wordB,mem,value,data);
      trace := Append(code,value,data,trace,part,T.Destinations());
      mem := R.Heap(count,2*(index+1),a,b,data);
      index := index+1;
    }
    var part: seq<State>;
    state,part := X.Run(code,a,b,length,index,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,X.Destinations());
    R.OriginalBytes(count,a,b,data);
  }
}
