// SPDX-License-Identifier: MIT
// Exact first-byte, bit membership and scalar ABI layout bridges; native pending.
include "../charset-inputs/Inputs.dfy"
include "../../external-calls/Execution.dfy"
include "../../scans/Representation.dfy"
include "../../word-fold/byte-representation-repair-v9/Representation.dfy"
module OperationsCharsetKernel {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import I = OperationsCharsetInputs
  import B = BytecodeFoldByteRepresentationV9
  function Initial():seq<S.Byte> { S.Store([],64,128) }
  predicate Memory(mem:seq<S.Byte>) {
    |mem|%32==0 && 96<=|mem|<G.Modulus() && S.Load(mem,64)==128
  }
  lemma InitialFits()
    ensures Memory(Initial())
  { R.StoredWord([],64,128); }
  lemma ReturnLayout(mem:seq<S.Byte>,result:S.Word)
    requires Memory(mem)
    ensures S.Load(S.Store(mem,128,result),64)==128
    ensures |S.Store(mem,128,result)|%32==0 && |S.Store(mem,128,result)|<G.Modulus()
    ensures S.Window(S.Store(mem,128,result),128,32)==G.Encode(result,32)
  { R.StoredWord(mem,128,result);R.StoredFrame(mem,128,result,64);R.WindowFits(S.Store(mem,128,result),128,32); }
  lemma First(data:seq<S.Byte>,offset:S.Word,length:S.Word,index:S.Word)
    requires (offset as nat)+length<=|data|<I.U64 && index<length
    ensures S.ShiftRight(S.DataWord(data,offset+index),248)==data[offset+index]
  { B.Source(data,offset,length,index); }
  lemma Membership(mask:S.Word,cell:S.Byte)
    ensures I.Member(mask,cell) <==> G.BitAnd(mask,S.ShiftLeft(1,cell))!=0
  { reveal S.ShiftLeft(); }
  lemma NegativeFlag(flag:S.Word)
    ensures (G.Modulus()-flag)%G.Modulus()==0 <==> flag==0
  {}
  lemma Flag(data:seq<S.Byte>,offset:S.Word,length:S.Word,index:S.Word,mask:S.Word)
    requires (offset as nat)+length<=|data|<I.U64 && index<length
    ensures I.Member(mask,data[offset+index]) <==>
            (G.Modulus()-G.BitAnd(mask,S.ShiftLeft(1,S.ShiftRight(S.DataWord(data,offset+index),248))))%G.Modulus()!=0
  {
    First(data,offset,length,index);Membership(mask,data[offset+index]);
    NegativeFlag(G.BitAnd(mask,S.ShiftLeft(1,data[offset+index])));
  }
}
