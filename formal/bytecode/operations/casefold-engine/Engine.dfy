// SPDX-License-Identifier: MIT
// Arbitrary finite original-byte case-fold loop; native verification pending.
include "../casefold-controls/Done.generated.dfy"
include "../casefold-controls/Below.generated.dfy"
include "../casefold-controls/Above.generated.dfy"
include "../casefold-controls/Fold.generated.dfy"
include "../casefold-controls/Start.generated.dfy"
module OperationsCaseFoldEngine {
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import F = OperationsCaseFoldMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsCaseFoldInputs
  import K = OperationsCaseFoldKernel
  import B = OperationsCaseFoldBinary
  import Done = OperationsCaseFoldDone
  import Below = OperationsCaseFoldBelow
  import Above = OperationsCaseFoldAbove
  import Fold = OperationsCaseFoldFold
  import Start = OperationsCaseFoldStart
  function Stack(offset:S.Word,length:S.Word,index:S.Word,lower:bool):seq<S.Word> {
    [I.Selector(lower),1362,offset,length,96,3085,offset,length,B.Cell(I.Low(lower)),B.Cell(I.High(lower)),128,index]
  }
  function Destinations():set<nat> { Start.Destinations()+Done.Destinations()+Below.Destinations()+Above.Destinations()+Fold.Destinations() }
  predicate Matches(code:seq<S.Byte>) { Start.Matches(code) && Done.Matches(code) && Below.Matches(code) && Above.Matches(code) && Fold.Matches(code) }
  ghost method Loop(code:seq<S.Byte>,destinations:set<nat>,offset:S.Word,length:S.Word,index:S.Word,lower:bool,
                    mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && K.Inv(mem,data,offset,length,index,lower)
    ensures state.state.Running? && state.state.pc==10129 && state.state.stack==Stack(offset,length,length,lower)
    ensures state.returned==[] && state.cursor==0 && K.Inv(state.state.memory,data,offset,length,length,lower)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(12208,Stack(offset,length,index,lower),mem),[],0)
    ensures trace[|trace|-1]==state && E.Trace(code,destinations,self,value,data,observations,trace)
    decreases length-index
  {
    if index==length {
      state,trace:=Done.Run(code,destinations,offset,length,index,lower,mem,self,value,data,observations);
    } else {
      if data[offset+index]<I.Low(lower) {
        state,trace:=Below.Run(code,destinations,offset,length,index,lower,mem,self,value,data,observations);
      } else if data[offset+index]>I.High(lower) {
        state,trace:=Above.Run(code,destinations,offset,length,index,lower,mem,self,value,data,observations);
      } else {
        state,trace:=Fold.Run(code,destinations,offset,length,index,lower,mem,self,value,data,observations);
      }
      var newmem:=state.state.memory;var tail:seq<M.Frame>;
      state,tail:=Loop(code,destinations,offset,length,index+1,lower,newmem,self,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
    }
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,offset:S.Word,length:S.Word,lower:bool,
                   self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && K.Input(data,offset,length)
    ensures state.state.Running? && state.state.pc==10129 && state.state.stack==Stack(offset,length,length,lower)
    ensures state.returned==[] && state.cursor==0 && K.Inv(state.state.memory,data,offset,length,length,lower)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(12150,Stack(offset,length,0,lower)[..10],K.Base()),[],0)
    ensures trace[|trace|-1]==state && E.Trace(code,destinations,self,value,data,observations,trace)
  {
    state,trace:=Start.Run(code,destinations,offset,length,0,lower,K.Base(),self,value,data,observations);
    var tail:seq<M.Frame>;
    state,tail:=Loop(code,destinations,offset,length,0,lower,K.Initial(data,offset,length),self,value,data,observations);
    assert trace[|trace|-1]==tail[0];
    E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
  }
}
