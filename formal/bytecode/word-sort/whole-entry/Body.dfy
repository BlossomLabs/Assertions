// SPDX-License-Identifier: MIT
// Accepted raw byte frame: actual remainder check, error branch, stable sort and physical RETURN.
include "../whole-body/WholeBody.dfy"
include "../entry/BodyStart.generated.dfy"
include "../entry/Aligned.generated.dfy"
include "../entry/Unaligned.generated.dfy"
include "../kernels/Mod.generated.dfy"
include "../../copy/Lift.dfy"
module BytecodeSortBodyExecutionConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCopyExecution
  import L = BytecodeCopyTraceLift
  import Start = BytecodeSortAdmissionBodyStart
  import Align = BytecodeSortAdmissionAligned
  import Error = BytecodeSortErrorUnaligned
  import Mod = BytecodeSortHelperMod
  import B = BytecodeSortWholeBody
  import O = BytecodeWordSortOriginalSpec
  import S = CollectionsSortModel
  import R = BytecodeSortBytesReturnMemory
  predicate Fits(data: seq<Byte>, offset: Word, length: Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data|
  }
  predicate Matches(code: seq<Byte>) { Start.Matches(code) && Align.Matches(code) && Error.Matches(code) && Mod.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { Start.Destinations()+Align.Destinations()+Error.Destinations()+Mod.Destinations()+B.Destinations() }
  predicate Success(data: seq<Byte>, offset: Word, length: Word, ids: seq<nat>, state: State)
    requires Fits(data,offset,length) && length%32 == 0
  {
    var n := length/32;
    |ids| == n && multiset(ids) == multiset(S.Range(0,n)) && O.Bounds(n,ids) &&
    O.Sorted(O.Values(data,offset,n),ids) && state == Returned(R.Bytes(n,O.Payload(data,offset,n,ids)))
  }
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, trace: seq<State>, part: seq<State>, small: set<nat>) returns (combined: seq<State>)
    requires E.Trace(code,Destinations(),value,data,trace) && E.Trace(code,small,value,data,part)
    requires small <= Destinations() && trace[|trace|-1] == part[0]
    ensures E.Trace(code,Destinations(),value,data,combined)
    ensures combined == trace+part[1..] && combined[0] == trace[0] && combined[|combined|-1] == part[|part|-1]
  { E.WidenTrace(code,small,Destinations(),value,data,part); E.Join(code,Destinations(),value,data,trace,part); combined := trace+part[1..]; }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word, value: Word)
    returns (state: State, trace: seq<State>, ids: seq<nat>)
    requires Matches(code) && Fits(data,offset,length)
    ensures if length%32 != 0 then ids == [] && state == Reverted(G.Encode(0xa949d285,4)+G.Encode(length,32)) else Success(data,offset,length,ids,state)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3422,[785862473,518,offset,length],Store([],64,128)) && trace[|trace|-1] == state
  {
    ids := [];
    var mem := Store([],64,128);
    state,trace := Start.Run(code,offset,length,mem,value,data);
    L.Trace(code,Start.Destinations(),value,data,trace);
    E.WidenTrace(code,Start.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>;
    state,part := Mod.Run(code,[785862473,518,offset,length,96],length,mem,value,data);
    L.Trace(code,Mod.Destinations(),value,data,part);
    trace := Append(code,value,data,trace,part,Mod.Destinations());
    if length%32 != 0 {
      state,part := Error.Run(code,offset,length,value,data);
      L.Trace(code,Error.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Error.Destinations());
    } else {
      state,part := Align.Run(code,offset,length,mem,value,data);
      L.Trace(code,Align.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Align.Destinations());
      var n: Word := length/32;
      assert n*32 == length && O.Fits(data,offset,n);
      state,part,ids := B.Run(code,n,offset,data,value);
      trace := Append(code,value,data,trace,part,B.Destinations());
    }
  }
}
