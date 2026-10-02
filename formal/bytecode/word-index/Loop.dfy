// SPDX-License-Identifier: MIT
// Unbounded least-match loop composed from actual helper and instruction traces.
include "Guard.generated.dfy"
include "AfterMulFirst.generated.dfy"
include "AfterMulSecond.generated.dfy"
include "AfterEnd.generated.dfy"
include "AfterSlice.generated.dfy"
include "Hit.generated.dfy"
include "Miss.generated.dfy"
include "Exit.generated.dfy"
include "Mul32.generated.dfy"
include "Add.generated.dfy"
include "Slice.generated.dfy"
include "Read32.generated.dfy"
module BytecodeIndexLoop {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import L = BytecodeIndexGuard
  import M1 = BytecodeIndexAfterMulFirst
  import M2 = BytecodeIndexAfterMulSecond
  import N = BytecodeIndexAfterEnd
  import S = BytecodeIndexAfterSlice
  import H = BytecodeIndexHit
  import T = BytecodeIndexMiss
  import X = BytecodeIndexExit
  import HP = BytecodeIndexMul32
  import HA = BytecodeIndexAdd
  import HS = BytecodeIndexSlice
  import HR = BytecodeIndexRead32
  predicate Matches(code: seq<Byte>) {
    L.Matches(code) && M1.Matches(code) && M2.Matches(code) && N.Matches(code) &&
    S.Matches(code) && H.Matches(code) && T.Matches(code) && X.Matches(code) &&
    HP.Matches(code) && HA.Matches(code) && HS.Matches(code) && HR.Matches(code)
  }
  function Destinations(): set<nat> {
    L.Destinations()+M1.Destinations()+M2.Destinations()+N.Destinations()+
    S.Destinations()+H.Destinations()+T.Destinations()+X.Destinations()+
    HP.Destinations()+HA.Destinations()+HS.Destinations()+HR.Destinations()
  }
  function At(data: seq<Byte>, offset: Word, index: nat): Word {
    DataWord(data,((offset as nat)+index*32)%G.Modulus())
  }
  predicate Fits(data: seq<Byte>, offset: Word, length: Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data| && length%32 == 0
  }
  predicate Least(data: seq<Byte>, offset: Word, count: nat, needle: Word, result: nat) {
    result <= count && (forall j: nat | j < result :: At(data,offset,j) != needle) &&
    (result < count ==> At(data,offset,result) == needle)
  }
  lemma Geometry(data: seq<Byte>, offset: Word, length: Word, index: Word)
    requires Fits(data,offset,length) && index < length/32
    ensures N.Position(index) == (index as nat)*32
    ensures N.NextPosition(index) == ((index as nat)+1)*32
    ensures S.WordOffset(offset,index) == (offset as nat)+(index as nat)*32
    ensures (N.NextPosition(index) as nat)-(N.Position(index) as nat) == 32
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
  ghost method Run(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word, needle: Word, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>, result: Word)
    requires Matches(code) && Fits(data,offset,length)
    ensures Least(data,offset,length/32,needle,result)
    ensures state == Running(604,[3904669827,result],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(8296,[3904669827,604,offset,length,needle,0,length/32,0],mem) && trace[|trace|-1] == state
  {
    var count: Word := length/32;
    var index: Word := 0;
    state := Running(8296,[3904669827,604,offset,length,needle,0,count,index],mem);
    trace := [state];
    while index < count
      invariant index <= count && count == length/32
      invariant forall j: nat | j < index :: At(data,offset,j) != needle
      invariant state == Running(8296,[3904669827,604,offset,length,needle,0,count,index],mem)
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(8296,[3904669827,604,offset,length,needle,0,count,0],mem)
      decreases count-index
    {
      Geometry(data,offset,length,index);
      var saved: seq<Word> := [3904669827,604,offset,length,needle,0,count,index];
      var part: seq<State>;
      state,part := L.Run(code,offset,length,needle,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,L.Destinations());
      state,part := HP.Run(code,saved+[needle,offset,length],index,8318,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := M1.Run(code,offset,length,needle,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,M1.Destinations());
      state,part := HP.Run(code,saved+[needle,offset,M1.Position(index),length],index,8330,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := M2.Run(code,offset,length,needle,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,M2.Destinations());
      state,part := HA.Run(code,saved+[needle,offset,M2.Position(index),length],M2.Position(index),32,8341,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := N.Run(code,offset,length,needle,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,N.Destinations());
      state,part := HS.Run(code,saved+[needle],offset,length,N.Position(index),N.NextPosition(index),mem,value,data);
      trace := Append(code,value,data,trace,part,HS.Destinations());
      assert trace[|trace|-1] == Running(8354,saved+[needle,S.WordOffset(offset,index),32],mem);
      state,part := S.Run(code,offset,length,needle,index,0,mem,value,data);
      assert part[0] == trace[|trace|-1];
      trace := Append(code,value,data,trace,part,S.Destinations());
      state,part := HR.Run(code,saved+[needle],S.WordOffset(offset,index),mem,value,data);
      trace := Append(code,value,data,trace,part,HR.Destinations());
      var item := At(data,offset,index);
      if item == needle {
        state,part := H.Run(code,offset,length,needle,index,item,mem,value,data);
        trace := Append(code,value,data,trace,part,H.Destinations());
        result := index;
        return;
      }
      state,part := T.Run(code,offset,length,needle,index,item,mem,value,data);
      trace := Append(code,value,data,trace,part,T.Destinations());
      index := index+1;
    }
    var part: seq<State>;
    state,part := X.Run(code,offset,length,needle,index,0,mem,value,data);
    trace := Append(code,value,data,trace,part,X.Destinations());
    result := count;
  }
}
