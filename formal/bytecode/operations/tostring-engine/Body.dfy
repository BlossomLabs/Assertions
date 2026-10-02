// SPDX-License-Identifier: MIT
// Exact private unsigned decimal body, including zero and full finite loops.
// Native verification pending; fitting memory/call-return destinations are explicit.
include "Count.dfy"
include "Fill.dfy"
include "../tostring-controls/Allocate.generated.dfy"
include "../tostring-controls/Zero.generated.dfy"
include "../tostring-controls/Unwind.generated.dfy"
include "../tostring-return/Kernel.dfy"
module OperationsToStringBody {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsToStringInputs
  import D = OperationsToStringDecimal
  import K = OperationsToStringFillMemory
  import A = OperationsToStringAllocation
  import Q = OperationsToStringReturnKernel
  import T = OperationsSerializerMemoryTranslation
  import C = OperationsToStringCount
  import Alloc = OperationsToStringAllocate
  import Fill = OperationsToStringFill
  import Zero = OperationsToStringZero
  import Z = OperationsToStringZeroMemory
  import Unwind = OperationsToStringUnwind
  import H = OperationsToStringFrame
  function Length(original:S.Word):nat
    ensures 1<=Length(original)<=78
    ensures |I.Render(original,false)|==Length(original)
  { D.WordDigits(original);D.Length(original);if original==0 then 1 else D.Steps(original) }
  predicate Input(mem:seq<S.Byte>,data:seq<S.Byte>,base:S.Word) {
    I.Frame(data) && Z.Input(mem,base) && base+512<G.Modulus()
  }
  predicate Matches(code:seq<S.Byte>,ret:S.Word) {
    C.Matches(code) && Alloc.Matches(code) && Fill.Matches(code) && Zero.Matches(code,ret) && Unwind.Matches(code,ret)
  }
  function Destinations(ret:S.Word):set<nat> {
    C.Destinations()+Alloc.Destinations()+Fill.Destinations()+Zero.Destinations(ret)+Unwind.Destinations(ret)
  }
  lemma Layout(mem:seq<S.Byte>,base:S.Word,original:S.Word)
    requires K.Ready(mem,base,Length(original)) && K.Payload(mem,base,Length(original))==I.Render(original,false)
    requires base+512<G.Modulus()
    ensures Q.Layout(mem,I.Render(original,false),base,base+32+S.Round32(Length(original)))
  {
    D.WordDigits(original);T.Load(mem,base);T.Load(mem,64);T.Round(Length(original));
    assert |I.Render(original,false)|==Length(original);
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,prefix:seq<S.Word>,ret:S.Word,original:S.Word,base:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code,ret) && Destinations(ret)<=destinations && |prefix|<=999 && Input(mem,data,base)
    ensures state.state.Running? && state.state.pc==ret && state.state.stack==prefix+[base] && state.returned==[] && state.cursor==0
    ensures K.Ready(state.state.memory,base,Length(original)) && K.Payload(state.state.memory,base,Length(original))==I.Render(original,false)
    ensures Q.Layout(state.state.memory,I.Render(original,false),base,base+32+S.Round32(Length(original)))
    ensures H.Stable(mem,state.state.memory,|mem|)
    ensures |state.state.memory|==base+32+S.Round32(Length(original))
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
    ensures trace[0]==M.Frame(S.Running(5497,prefix+[ret,original],mem),[],0) && trace[|trace|-1]==state
  {
    D.WordDigits(original);D.Length(original);
    if original==0 {
      state,trace:=Zero.Run(code,destinations,prefix,ret,original,base,mem,self,value,data,observations);
    } else {
      state,trace:=C.Run(code,destinations,prefix+[ret],original,mem,self,value,data,observations);
      var next,part:=Alloc.Run(code,destinations,prefix+[ret],original,base,mem,self,value,data,observations);
      E.Join(code,destinations,self,value,data,observations,trace,part);trace:=trace+part[1..];state:=next;
      var allocationMemory:=state.state.memory;
      next,part:=Fill.Run(code,destinations,prefix+[ret],original,base,allocationMemory,self,value,data,observations);
      H.Trim(allocationMemory,next.state.memory,base,|mem|);H.Chain(mem,allocationMemory,next.state.memory,|mem|);
      E.Join(code,destinations,self,value,data,observations,trace,part);trace:=trace+part[1..];state:=next;
      next,part:=Unwind.Run(code,destinations,prefix,ret,original,base,state.state.memory,self,value,data,observations);
      E.Join(code,destinations,self,value,data,observations,trace,part);trace:=trace+part[1..];state:=next;
    }
    Layout(state.state.memory,base,original);
  }
}
