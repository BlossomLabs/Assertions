// SPDX-License-Identifier: MIT
// Actual wrapper/decoder/body/return connection for successful fitting word sums.
include "Loop.dfy"
include "SumDecoder.generated.dfy"
include "Return.generated.dfy"
module BytecodeSumConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import D = BytecodeScanSumDecoder
  import L = BytecodeSumLoop
  import B = BytecodeSumBodyStart
  import A = BytecodeSumAligned
  import C = BytecodeSumCount
  import HM = BytecodeScanMod
  import HD = BytecodeScanDiv
  import R = BytecodeSumReturn
  predicate Matches(code: seq<Byte>) { D.Matches(code) && L.Matches(code) && R.Matches(code) }
  function Destinations(): set<nat> { D.Destinations()+L.Destinations()+R.Destinations() }
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
    requires Matches(code) && D.Admitted(data) && D.Length(data)%32 == 0
    requires L.Prefix(data,D.Offset(data),D.Length(data)/32) < G.Modulus()
    ensures state == Returned(G.Encode(L.Prefix(data,D.Offset(data),D.Length(data)/32),32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(585,[394725771],Store([],64,128)) && trace[|trace|-1] == state
  {
    var offset := D.Offset(data);
    var length := D.Length(data);
    var mem := Store([],64,128);
    var part: seq<State>;
    state,trace := D.Run(code,data,mem,value);
    E.WidenTrace(code,D.Destinations(),Destinations(),value,data,trace);
    assert L.Fits(data,offset,length);
    state,part := B.Run(code,offset,length,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,B.Destinations());
    state,part := HM.Run(code,[394725771,604,offset,length,0],length,mem,value,data);
    trace := Append(code,value,data,trace,part,HM.Destinations());
    state,part := A.Run(code,offset,length,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,A.Destinations());
    state,part := HD.Run(code,[394725771,604,offset,length,0,0],length,mem,value,data);
    trace := Append(code,value,data,trace,part,HD.Destinations());
    state,part := C.Run(code,offset,length,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,C.Destinations());
    state,part := L.Run(code,data,offset,length,mem,value);
    trace := Append(code,value,data,trace,part,L.Destinations());
    var total: Word := L.Prefix(data,offset,length/32);
    state,part := R.Run(code,total,value,data);
    trace := Append(code,value,data,trace,part,R.Destinations());
  }
}
