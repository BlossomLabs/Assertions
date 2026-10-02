// SPDX-License-Identifier: MIT
// Successful unbounded finite sum loop, composed from actual instruction traces.
include "BodyStart.generated.dfy"
include "Aligned.generated.dfy"
include "Count.generated.dfy"
include "Guard.generated.dfy"
include "AfterMulFirst.generated.dfy"
include "AfterMulSecond.generated.dfy"
include "AfterEnd.generated.dfy"
include "AfterSlice.generated.dfy"
include "AfterRead.generated.dfy"
include "AfterSum.generated.dfy"
include "Exit.generated.dfy"
include "Mod.generated.dfy"
include "Div.generated.dfy"
include "Mul32.generated.dfy"
include "Add.generated.dfy"
include "Slice.generated.dfy"
include "Read32.generated.dfy"
include "Overflow.generated.dfy"
module BytecodeSumCheckedLoop {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import B = BytecodeSumBodyStart
  import A = BytecodeSumAligned
  import C = BytecodeSumCount
  import L = BytecodeSumGuard
  import M1 = BytecodeSumAfterMulFirst
  import M2 = BytecodeSumAfterMulSecond
  import N = BytecodeSumAfterEnd
  import S = BytecodeSumAfterSlice
  import R = BytecodeSumAfterRead
  import T = BytecodeSumAfterSum
  import X = BytecodeSumExit
  import HM = BytecodeScanMod
  import HD = BytecodeScanDiv
  import HP = BytecodeScanMul32
  import HA = BytecodeScanAdd
  import HS = BytecodeScanSlice
  import HR = BytecodeScanRead32
  import U = BytecodeSumOverflow
  predicate Matches(code: seq<Byte>) {
    B.Matches(code) && A.Matches(code) && C.Matches(code) && L.Matches(code) &&
    M1.Matches(code) && M2.Matches(code) && N.Matches(code) && S.Matches(code) &&
    R.Matches(code) && T.Matches(code) && X.Matches(code) && HM.Matches(code) &&
    HD.Matches(code) && HP.Matches(code) && HA.Matches(code) && HS.Matches(code) && HR.Matches(code) && U.Matches(code)
  }
  function Destinations(): set<nat> {
    B.Destinations()+A.Destinations()+C.Destinations()+L.Destinations()+
    M1.Destinations()+M2.Destinations()+N.Destinations()+S.Destinations()+
    R.Destinations()+T.Destinations()+X.Destinations()+HM.Destinations()+
    HD.Destinations()+HP.Destinations()+HA.Destinations()+HS.Destinations()+HR.Destinations()+U.Destinations()
  }
  function At(data: seq<Byte>, offset: Word, index: nat): Word {
    DataWord(data,((offset as nat)+index*32)%G.Modulus())
  }
  function Prefix(data: seq<Byte>, offset: Word, count: nat): nat
    decreases count
  {
    if count == 0 then 0 else Prefix(data,offset,count-1)+(At(data,offset,count-1) as nat)
  }
  lemma PrefixMonotone(data: seq<Byte>, offset: Word, smaller: nat, larger: nat)
    requires smaller <= larger
    ensures Prefix(data,offset,smaller) <= Prefix(data,offset,larger)
    decreases larger
  {
    if smaller < larger {
      PrefixMonotone(data,offset,smaller,larger-1);
    }
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
  ghost method Run(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Fits(data,offset,length)
    requires mem == Store([],64,128)
    ensures state == (if Prefix(data,offset,length/32) < G.Modulus() then Running(604,[394725771,Prefix(data,offset,length/32)],mem) else Reverted(G.Encode(0x4e487b71,4)+G.Encode(17,32)))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(2828,[394725771,604,offset,length,0,length/32,0],mem) && trace[|trace|-1] == state
  {
    var count: Word := length/32;
    var index: Word := 0;
    var total: Word := 0;
    state := Running(2828,[394725771,604,offset,length,total,count,index],mem);
    trace := [state];
    while index < count
      invariant index <= count && count == length/32
      invariant total == Prefix(data,offset,index) && total < G.Modulus()
      invariant state == Running(2828,[394725771,604,offset,length,total,count,index],mem)
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(2828,[394725771,604,offset,length,0,count,0],mem)
      decreases count-index
    {
      Geometry(data,offset,length,index);
      var saved: seq<Word> := [394725771,604,offset,length,total,count,index];
      var part: seq<State>;
      state,part := L.Run(code,offset,length,total,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,L.Destinations());
      state,part := HP.Run(code,saved+[offset,length],index,2849,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := M1.Run(code,offset,length,total,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,M1.Destinations());
      state,part := HP.Run(code,saved+[offset,M1.Position(index),length],index,2861,mem,value,data);
      trace := Append(code,value,data,trace,part,HP.Destinations());
      state,part := M2.Run(code,offset,length,total,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,M2.Destinations());
      state,part := HA.Run(code,saved+[offset,M2.Position(index),length],M2.Position(index),32,2872,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      state,part := N.Run(code,offset,length,total,index,0,mem,value,data);
      trace := Append(code,value,data,trace,part,N.Destinations());
      state,part := HS.Run(code,saved,offset,length,N.Position(index),N.NextPosition(index),mem,value,data);
      trace := Append(code,value,data,trace,part,HS.Destinations());
      assert trace[|trace|-1] == Running(2885,saved+[S.WordOffset(offset,index),32],mem);
      state,part := S.Run(code,offset,length,total,index,0,mem,value,data);
      assert part[0] == trace[|trace|-1];
      trace := Append(code,value,data,trace,part,S.Destinations());
      state,part := HR.Run(code,saved,S.WordOffset(offset,index),mem,value,data);
      trace := Append(code,value,data,trace,part,HR.Destinations());
      var item := At(data,offset,index);
      state,part := R.Run(code,offset,length,total,index,item,mem,value,data);
      trace := Append(code,value,data,trace,part,R.Destinations());
      PrefixMonotone(data,offset,index+1,count);
      assert (total as nat)+(item as nat) == Prefix(data,offset,index+1);
      if (total as nat)+(item as nat) >= G.Modulus() {
        state,part := U.Run(code,saved,item,total,value,data);
        trace := Append(code,value,data,trace,part,U.Destinations());
        return;
      }
      state,part := HA.Run(code,saved,item,total,2904,mem,value,data);
      trace := Append(code,value,data,trace,part,HA.Destinations());
      var nextTotal: Word := (total as nat)+(item as nat);
      state,part := T.Run(code,offset,length,total,index,nextTotal,mem,value,data);
      trace := Append(code,value,data,trace,part,T.Destinations());
      total := nextTotal;
      index := index+1;
    }
    var part: seq<State>;
    state,part := X.Run(code,offset,length,total,index,0,mem,value,data);
    trace := Append(code,value,data,trace,part,X.Destinations());
  }
}
