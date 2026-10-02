// SPDX-License-Identifier: MIT
// Exact physical scalar return and zero-modulus panic byte layouts.
include "../modexp-execution/Execution.dfy"
module OperationsModularPowerUnsignedMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = BytecodeScanRepresentation
  predicate Admitted(mem:seq<S.Byte>) {
    |mem|%32==0 && 96<=|mem|<G.Modulus() && S.Load(mem,64)==128
  }
  function Panic(mem:seq<S.Byte>):seq<S.Byte> {
    S.Store(S.Store(mem,0,0x4e487b7100000000000000000000000000000000000000000000000000000000),4,18)
  }
  function PanicData():seq<S.Byte> { G.Encode(0x4e487b71,4)+G.Encode(18,32) }
  lemma ReturnLayout(mem:seq<S.Byte>,result:S.Word)
    requires Admitted(mem)
    ensures S.Load(S.Store(mem,128,result),64)==128
    ensures |S.Store(mem,128,result)|%32==0 && |S.Store(mem,128,result)|<G.Modulus()
    ensures S.Window(S.Store(mem,128,result),128,32)==G.Encode(result,32)
  {
    Q.StoredWord(mem,128,result);
    Q.StoredFrame(mem,128,result,64);
    Q.WindowFits(S.Store(mem,128,result),128,32);
  }
  lemma PanicLayout(mem:seq<S.Byte>)
    requires Admitted(mem)
    ensures |Panic(mem)|%32==0 && |Panic(mem)|<G.Modulus()
    ensures S.Window(Panic(mem),0,36)==PanicData()
  {
    var first:=S.Store(mem,0,0x4e487b7100000000000000000000000000000000000000000000000000000000);
    Q.StoredWord(mem,0,0x4e487b7100000000000000000000000000000000000000000000000000000000);
    Q.StoredWord(first,4,18);
    Q.WindowFits(Panic(mem),0,36);
    assert G.Encode(0x4e487b7100000000000000000000000000000000000000000000000000000000,32)[..4]==G.Encode(0x4e487b71,4);
    forall i:nat | i<4
      ensures Panic(mem)[i]==first[i]
    {}
    assert Panic(mem)[..4]==G.Encode(0x4e487b71,4);
    assert Panic(mem)[4..36]==G.Encode(18,32);
  }
}
