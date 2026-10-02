// SPDX-License-Identifier: MIT
// Accepted bytes/needle wrapper, actual body loop, and physical return/error.
include "IndexDecoder.generated.dfy"
include "BodyStart.generated.dfy"
include "Aligned.generated.dfy"
include "Count.generated.dfy"
include "Mod.generated.dfy"
include "Div.generated.dfy"
include "Unaligned.generated.dfy"
include "Return.generated.dfy"
include "Loop.dfy"
module BytecodeIndexConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import D = BytecodeScanIndexDecoder
  import B = BytecodeIndexBodyStart
  import A = BytecodeIndexAligned
  import C = BytecodeIndexCount
  import HM = BytecodeIndexMod
  import HD = BytecodeIndexDiv
  import U = BytecodeIndexUnaligned
  import R = BytecodeIndexReturn
  import L = BytecodeIndexLoop
  predicate Matches(code: seq<Byte>) {
    D.Matches(code) && B.Matches(code) && A.Matches(code) && C.Matches(code) &&
    HM.Matches(code) && HD.Matches(code) && U.Matches(code) && R.Matches(code) && L.Matches(code)
  }
  function Destinations(): set<nat> {
    D.Destinations()+B.Destinations()+A.Destinations()+C.Destinations()+
    HM.Destinations()+HD.Destinations()+U.Destinations()+R.Destinations()+L.Destinations()
  }
  function FindFrom(data: seq<Byte>, offset: Word, count: nat, needle: Word, index: nat): nat
    requires index <= count
    ensures index <= FindFrom(data,offset,count,needle,index) <= count
    ensures forall j: nat | index <= j < FindFrom(data,offset,count,needle,index) :: L.At(data,offset,j) != needle
    ensures FindFrom(data,offset,count,needle,index) < count ==> L.At(data,offset,FindFrom(data,offset,count,needle,index)) == needle
    decreases count-index
  {
    if index == count then count
    else if L.At(data,offset,index) == needle then index
    else FindFrom(data,offset,count,needle,index+1)
  }
  function First(data: seq<Byte>, offset: Word, count: nat, needle: Word): nat {
    FindFrom(data,offset,count,needle,0)
  }
  lemma LeastUnique(data: seq<Byte>, offset: Word, count: nat, needle: Word, a: nat, b: nat)
    requires L.Least(data,offset,count,needle,a) && L.Least(data,offset,count,needle,b)
    ensures a == b
  {
    if a < b { assert L.At(data,offset,a) != needle; }
    if b < a { assert L.At(data,offset,b) != needle; }
  }
  function Expected(data: seq<Byte>): State {
    if D.Length(data)%32 != 0 then Reverted(G.Encode(0xa949d285,4)+G.Encode(D.Length(data),32))
    else Returned(G.Encode(First(data,D.Offset(data),D.Length(data)/32,D.Needle(data)),32))
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
  ghost method Run(code: seq<Byte>, data: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && D.Admitted(data)
    ensures state == Expected(data)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(998,[3904669827],Store([],64,128)) && trace[|trace|-1] == state
  {
    var mem := Store([],64,128);
    var offset := D.Offset(data);
    var length := D.Length(data);
    var needle := D.Needle(data);
    var frame: seq<Word> := [3904669827,604,offset,length,needle];
    state,trace := D.Run(code,data,mem,value);
    E.WidenTrace(code,D.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>;
    state,part := B.Run(code,offset,length,needle,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,B.Destinations());
    state,part := HM.Run(code,frame+[0],length,mem,value,data);
    trace := Append(code,value,data,trace,part,HM.Destinations());
    if length%32 != 0 {
      state,part := U.Run(code,offset,length,needle,value,data);
      trace := Append(code,value,data,trace,part,U.Destinations());
      return;
    }
    state,part := A.Run(code,offset,length,needle,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,A.Destinations());
    state,part := HD.Run(code,frame+[0,0],length,mem,value,data);
    trace := Append(code,value,data,trace,part,HD.Destinations());
    state,part := C.Run(code,offset,length,needle,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,C.Destinations());
    var result: Word;
    state,part,result := L.Run(code,data,offset,length,needle,mem,value);
    trace := Append(code,value,data,trace,part,L.Destinations());
    assert L.Least(data,offset,length/32,needle,First(data,offset,length/32,needle));
    LeastUnique(data,offset,length/32,needle,result,First(data,offset,length/32,needle));
    state,part := R.Run(code,result,value,data);
    trace := Append(code,value,data,trace,part,R.Destinations());
  }
}
