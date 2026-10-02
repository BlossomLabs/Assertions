// SPDX-License-Identifier: MIT
// Arbitrary finite charset loop over original bytes; native verification pending.
include "../charset-controls/Start.generated.dfy"
include "../charset-controls/Done.generated.dfy"
include "../charset-controls/Next.generated.dfy"
include "../charset-controls/Reject.generated.dfy"
module OperationsCharsetEngine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = OperationsCharsetInputs
  import K = OperationsCharsetKernel
  import Start = OperationsCharsetStart
  import Done = OperationsCharsetDone
  import Next = OperationsCharsetNext
  import Reject = OperationsCharsetReject
  function Destinations():set<nat> { Start.Destinations()+Done.Destinations()+Next.Destinations()+Reject.Destinations() }
  predicate Matches(code:seq<S.Byte>) { Start.Matches(code) && Done.Matches(code) && Next.Matches(code) && Reject.Matches(code) }
  lemma Tail(data:seq<S.Byte>,offset:S.Word,length:S.Word,index:S.Word,mask:S.Word)
    requires (offset as nat)+length<=|data|<I.U64 && index<length
    requires I.Member(mask,data[offset+index])
    ensures I.All(data,offset+index,length-index,mask) <==> I.All(data,offset+index+1,length-index-1,mask)
  {
    if I.All(data,offset+index,length-index,mask) {
      forall j:nat {:trigger data[offset+index+1+j]} | j<length-index-1
        ensures I.Member(mask,data[offset+index+1+j])
      { assert j+1<length-index; }
    } else if I.All(data,offset+index+1,length-index-1,mask) {
      forall j:nat {:trigger data[offset+index+j]} | j<length-index
        ensures I.Member(mask,data[offset+index+j])
      { if j>0 { assert j-1<length-index-1; } }
    }
  }
  ghost method Loop(code:seq<S.Byte>,destinations:set<nat>,offset:S.Word,length:S.Word,mask:S.Word,index:S.Word,
                    mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && K.Memory(mem)
    requires (offset as nat)+length<=|data|<I.U64 && index<=length
    ensures state==M.Frame(S.Returned(G.Encode(if I.All(data,offset+index,length-index,mask) then 1 else 0,32)),[],0)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(4124,[0x3e8c97e3,1289,offset,length,mask,0,index],mem),[],0)
    ensures trace[|trace|-1]==state && E.Trace(code,destinations,self,value,data,observations,trace)
    decreases length-index
  {
    if index==length {
      state,trace:=Done.Run(code,destinations,offset,length,mask,index,mem,self,value,data,observations);
    } else if I.Member(mask,data[offset+index]) {
      state,trace:=Next.Run(code,destinations,offset,length,mask,index,mem,self,value,data,observations);
      var tail:seq<M.Frame>;
      state,tail:=Loop(code,destinations,offset,length,mask,index+1,mem,self,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      Tail(data,offset,length,index,mask);
    } else {
      state,trace:=Reject.Run(code,destinations,offset,length,mask,index,mem,self,value,data,observations);
      assert 0<length-index;
      assert !I.All(data,offset+index,length-index,mask);
    }
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,offset:S.Word,length:S.Word,mask:S.Word,
                   mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && K.Memory(mem)
    requires (offset as nat)+length<=|data|<I.U64
    ensures state==M.Frame(S.Returned(G.Encode(if I.All(data,offset,length,mask) then 1 else 0,32)),[],0)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(4121,[0x3e8c97e3,1289,offset,length,mask],mem),[],0)
    ensures trace[|trace|-1]==state && E.Trace(code,destinations,self,value,data,observations,trace)
  {
    state,trace:=Start.Run(code,destinations,offset,length,mask,0,mem,self,value,data,observations);
    var tail:seq<M.Frame>;
    state,tail:=Loop(code,destinations,offset,length,mask,0,mem,self,value,data,observations);
    assert trace[|trace|-1]==tail[0];
    E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
  }
}
