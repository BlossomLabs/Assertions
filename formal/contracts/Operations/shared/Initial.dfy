// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsRuntime.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/execution.dfy"
include "../../../shared/abi/Encoding.dfy"
include "../../../shared/abi/Bridge.dfy"

module OperationsInitial {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Context
  import WorldState
  import Precompiled
  import OperationsRuntime
  import AbiEncoding
  import AbiBridge
  import U256

  function Make(signed: bool, a: int, b: int, gas: nat, backend: Precompiled.T): ExecutingState
    requires signed ==> -AbiEncoding.SignedLimit <= a < AbiEncoding.SignedLimit && -AbiEncoding.SignedLimit <= b < AbiEncoding.SignedLimit
    requires !signed ==> 0 <= a < AbiEncoding.Modulus && 0 <= b < AbiEncoding.Modulus
  {
    var context := Context.Create(0,0,0,0,AbiEncoding.AddCall(signed,a,b),false,0,
                                  Context.Block.Info(0,0,0,0,0,0,0));
    EVM.Create(EvmFork.CANCUN,context,map[0:=WorldState.DefaultAccount()],gas,OperationsRuntime.Code(),backend)
  }

  lemma Shape(signed: bool, a: int, b: int, gas: nat, backend: Precompiled.T)
    requires signed ==> -AbiEncoding.SignedLimit <= a < AbiEncoding.SignedLimit && -AbiEncoding.SignedLimit <= b < AbiEncoding.SignedLimit
    requires !signed ==> 0 <= a < AbiEncoding.Modulus && 0 <= b < AbiEncoding.Modulus
    ensures Make(signed,a,b,gas,backend).PC() == 0
    ensures Make(signed,a,b,gas,backend).Gas() == gas
    ensures Make(signed,a,b,gas,backend).evm.stack.contents == []
    ensures Make(signed,a,b,gas,backend).evm.memory.contents == []
    ensures Make(signed,a,b,gas,backend).evm.context.callValue == 0
    ensures Make(signed,a,b,gas,backend).evm.context.CallDataSize() == 68
    ensures Make(signed,a,b,gas,backend).evm.context.CallDataRead(4) as int ==
            (if signed then AbiEncoding.TwosComplement(a) else a)
    ensures Make(signed,a,b,gas,backend).evm.context.CallDataRead(36) as int ==
            (if signed then AbiEncoding.TwosComplement(b) else b)
    ensures U256.Shr(Make(signed,a,b,gas,backend).evm.context.CallDataRead(0),224) ==
            (if signed then 0xa5f3c23b else 0x771602f7)
  {
    var data := AbiEncoding.AddCall(signed,a,b);
    var aw := if signed then AbiEncoding.TwosComplement(a) else a;
    var bw := if signed then AbiEncoding.TwosComplement(b) else b;
    assert data[4..36] == AbiEncoding.Word(aw);
    assert data[36..68] == AbiEncoding.Word(bw);
    AbiBridge.FullWord(data,4,aw);
    AbiBridge.FullWord(data,36,bw);
    AbiBridge.Selector(signed,a,b);
  }
}
