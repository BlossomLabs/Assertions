// SPDX-License-Identifier: MIT
// Recursive composition of actual compiled binary-loop cases with independent math.
include "../modexp-loop-controls/Zero.generated.dfy"
include "../modexp-loop-controls/Final.generated.dfy"
include "../modexp-loop-controls/Odd.generated.dfy"
include "../modexp-loop-controls/Even.generated.dfy"
include "../modexp-kernel/Model.dfy"
module OperationsModularPowerLoopEngine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  import K = OperationsModularPowerKernel
  import Zero = OperationsModularPowerLoopZero
  import Final = OperationsModularPowerLoopFinal
  import Odd = OperationsModularPowerLoopOdd
  import Even = OperationsModularPowerLoopEven
  predicate Matches(code:seq<S.Byte>) {
    Zero.Matches(code) && Final.Matches(code) && Odd.Matches(code) && Even.Matches(code)
  }
  lemma Join(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,
             data:seq<S.Byte>,observations:seq<E.Observation>,left:seq<E.Frame>,right:seq<E.Frame>)
    requires E.Trace(code,destinations,self,value,data,observations,left)
    requires E.Trace(code,destinations,self,value,data,observations,right)
    requires left[|left|-1]==right[0]
    ensures E.Trace(code,destinations,self,value,data,observations,left+right[1..])
  {
    forall i:nat {:trigger (left+right[1..])[i]} | i<|left+right[1..]|-1
      ensures E.Execute(code,destinations,(left+right[1..])[i],self,value,data,observations)==(left+right[1..])[i+1] && (left+right[1..])[i+1].state!=S.Bad
    {
      if i<|left|-1 {
        assert (left+right[1..])[i]==left[i];
        assert (left+right[1..])[i+1]==left[i+1];
      } else {
        var j:=i-|left|+1;
        assert 0<=j<|right|-1;
        assert (left+right[1..])[i]==right[j];
        assert (left+right[1..])[i+1]==right[j+1];
      }
    }
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,outer:seq<S.Word>,returnPc:S.Word,
                   base:S.Word,exponent:S.Word,modulus:S.Word,result:S.Word,
                   mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,
                   data:seq<S.Byte>,observations:seq<E.Observation>)
    returns(finalBase:S.Word,frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && {3085,9367,9396,9402,9429,9435}<=destinations
    requires |outer|<=1000 && modulus>0 && base<modulus && result<modulus && |mem|<G.Modulus()
    ensures finalBase<modulus
    ensures frame==M.Frame(S.Running(3085,outer+[returnPc,finalBase,0,modulus,K.Loop(base,exponent,result,modulus)],mem),returned,cursor)
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
    ensures trace[0]==M.Frame(S.Running(9367,outer+[returnPc,base,exponent,modulus,result],mem),returned,cursor) && trace[|trace|-1]==frame
    decreases exponent
  {
    if exponent==0 {
      frame,trace:=Zero.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,mem,returned,cursor,self,value,data,observations);
      finalBase:=base;
    } else {
      var nextE:S.Word:=exponent/2;
      var nextR:S.Word:=if exponent%2==1 then E.ProductModulo(result,base,modulus) else result;
      var nextA:S.Word:=if nextE==0 then base else E.ProductModulo(base,base,modulus);
      assert nextR<modulus && nextA<modulus;
      if exponent==1 {
        frame,trace:=Final.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,mem,returned,cursor,self,value,data,observations);
      } else if exponent%2==1 {
        frame,trace:=Odd.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,mem,returned,cursor,self,value,data,observations);
      } else {
        frame,trace:=Even.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,mem,returned,cursor,self,value,data,observations);
      }
      assert frame==M.Frame(S.Running(9367,outer+[returnPc,nextA,nextE,modulus,nextR],mem),returned,cursor);
      var tail:seq<E.Frame>;
      finalBase,frame,tail:=Run(code,destinations,outer,returnPc,nextA,nextE,modulus,nextR,mem,returned,cursor,self,value,data,observations);
      Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      assert K.Loop(base,exponent,result,modulus)==K.Loop(nextA,nextE,nextR,modulus);
    }
  }
}
