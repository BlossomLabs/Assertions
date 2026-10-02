// SPDX-License-Identifier: MIT
// Decimal payload memory invariant; native proof pending.
include "Decimal.dfy"
include "Frame.dfy"
include "Memory.dfy"
include "../casefold-machine/Memory.dfy"
include "../casefold-machine/Binary.generated.dfy"
module OperationsToStringFillMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import F = OperationsCaseFoldMachine
  import P = OperationsCaseFoldMemory
  import D = OperationsToStringDecimal
  import I = OperationsToStringInputs
  import H = OperationsToStringFrame
  predicate Ready(mem:seq<S.Byte>,base:S.Word,length:S.Word) {
    base>=128 && base%32==0 && length<=78 && base+128+length<G.Modulus() &&
    |mem|%32==0 && base+32+length<=|mem|<G.Modulus() &&
    S.Load(mem,base)==length && S.Load(mem,64)==base+32+S.Round32(length)
  }
  function Payload(mem:seq<S.Byte>,base:S.Word,length:S.Word):seq<S.Byte>
    requires Ready(mem,base,length)
  { mem[base+32..base+32+length] }
  predicate Inv(mem:seq<S.Byte>,base:S.Word,original:S.Word,current:S.Word,left:S.Word) {
    D.Steps(original)<=78 && Ready(mem,base,D.Steps(original)) &&
    D.Fill(Payload(mem,base,D.Steps(original)),original,current,left)
  }
  lemma Load(mem:seq<S.Byte>,base:S.Word,length:S.Word)
    requires Ready(mem,base,length)
    ensures S.Expand(mem,base+32)==mem
  { C.RoundedMonotone(base+32,|mem|);assert S.Round32(|mem|)==|mem|; }
  lemma LoadFrame(mem:seq<S.Byte>,writeAt:S.Word,byte:S.Byte,at:S.Word)
    requires |mem|%32==0 && writeAt<|mem| && at+32<=|mem|
    requires writeAt<at || at+32<=writeAt
    ensures S.Load(F.Store8(mem,writeAt,byte),at)==S.Load(mem,at)
  {
    P.InBounds(mem,writeAt,byte);
    assert F.Store8(mem,writeAt,byte)[at..at+32]==mem[at..at+32] by {
      forall j:nat {:trigger F.Store8(mem,writeAt,byte)[at+j]} | j<32
        ensures F.Store8(mem,writeAt,byte)[at+j]==mem[at+j]
      { P.Frame(mem,writeAt,byte,at+j); }
    }
    R.WordProjection(mem,at);R.WordProjection(F.Store8(mem,writeAt,byte),at);
    R.WindowFits(mem,at,32);R.WindowFits(F.Store8(mem,writeAt,byte),at,32);
  }
  lemma Next(mem:seq<S.Byte>,base:S.Word,original:S.Word,current:S.Word,left:S.Word)
    requires Inv(mem,base,original,current,left) && current>0
    ensures left>0 && F.Fits(mem,base+32+left-1)
    ensures Inv(F.Store8(mem,base+32+left-1,I.Digit(current)),base,original,current/10,left-1)
    ensures H.Stable(mem,F.Store8(mem,base+32+left-1,I.Digit(current)),base)
    ensures |F.Store8(mem,base+32+left-1,I.Digit(current))|==|mem|
  {
    D.WordDigits(original);D.FillNext(Payload(mem,base,D.Steps(original)),original,current,left);
    assert left>0 && left<=D.Steps(original);
    var pos:S.Word:=base+32+left-1;var byte:=I.Digit(current);
    C.RoundedMonotone(pos+1,|mem|);assert S.Round32(|mem|)==|mem|;
    H.Store8(mem,pos,byte,base);
    P.InBounds(mem,pos,byte);LoadFrame(mem,pos,byte,base);LoadFrame(mem,pos,byte,64);
    var next:=F.Store8(mem,pos,byte);
    assert next[base+32..base+32+D.Steps(original)]==Payload(mem,base,D.Steps(original))[left-1:=byte] by {
      forall j:nat {:trigger next[base+32+j]} | j<D.Steps(original)
        ensures next[base+32+j]==(if j==left-1 then byte else mem[base+32+j])
      { if j==left-1 { P.Write(mem,pos,byte); } else { P.Frame(mem,pos,byte,base+32+j); } }
    }
  }
  lemma Finish(mem:seq<S.Byte>,base:S.Word,original:S.Word,left:S.Word)
    requires Inv(mem,base,original,0,left)
    ensures left==0 && Payload(mem,base,D.Steps(original))==I.Digits(original)
  { D.FillDone(Payload(mem,base,D.Steps(original)),original,left); }
}
