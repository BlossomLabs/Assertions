// SPDX-License-Identifier: MIT
// Exact unsigned zero literal memory; native proof pending.
include "Sign.dfy"
module OperationsToStringZeroMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import K = OperationsToStringFillMemory
  import B = OperationsCaseFoldBinary
  import Q = OperationsToStringSign
  import H = OperationsToStringFrame
  predicate Input(mem:seq<S.Byte>,base:S.Word) {
    96<=|mem|<=base && |mem|%32==0 && base>=128 && base%32==0 && base+206<G.Modulus() && S.Load(mem,64)==base
  }
  function Allocated(mem:seq<S.Byte>,base:S.Word):seq<S.Byte>
    requires Input(mem,base)
  { S.Store(mem,64,base+64) }
  function Header(mem:seq<S.Byte>,base:S.Word):seq<S.Byte>
    requires Input(mem,base)
  { S.Store(Allocated(mem,base),base,1) }
  function Initial(mem:seq<S.Byte>,base:S.Word):seq<S.Byte>
    requires Input(mem,base)
  { S.Store(Header(mem,base),base+32,B.Cell(48)) }
  lemma Ready(mem:seq<S.Byte>,base:S.Word)
    requires Input(mem,base)
    ensures |Initial(mem,base)|==base+64 && K.Ready(Initial(mem,base),base,1)
    ensures K.Payload(Initial(mem,base),base,1)==[48]
    ensures H.Stable(mem,Initial(mem,base),|mem|)
  {
    R.StoredWord(mem,64,base+64);R.StoredWord(Allocated(mem,base),base,1);R.StoredFrame(Allocated(mem,base),base,1,64);
    R.StoredWord(Header(mem,base),base+32,B.Cell(48));R.StoredFrame(Header(mem,base),base+32,B.Cell(48),64);R.StoredFrame(Header(mem,base),base+32,B.Cell(48),base);
    B.CellWord(48);B.PowerLiteral();Q.EncodeTop(48,32);
    assert S.Round32(base+32)==base+32 && S.Round32(base+64)==base+64;
    H.Store(mem,64,base+64,|mem|);H.Store(Allocated(mem,base),base,1,|mem|);H.Chain(mem,Allocated(mem,base),Header(mem,base),|mem|);
    H.Store(Header(mem,base),base+32,B.Cell(48),|mem|);H.Chain(mem,Header(mem,base),Initial(mem,base),|mem|);
  }
}
