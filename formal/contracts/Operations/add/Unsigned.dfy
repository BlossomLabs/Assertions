// SPDX-License-Identifier: MIT
include "Spec.dfy"
include "../shared/Initial.dfy"
include "../shared/Outcome.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/checked-add.dfy"
include "../../../shared/abi/Bridge.dfy"
include "../shared/Entry.dfy"
include "../shared/Dispatcher.dfy"
include "../shared/Decode.dfy"
include "../shared/Panic.dfy"
include "../shared/Return.dfy"
include "Dispatch.dfy"
include "Calls.dfy"
include "Arithmetic.dfy"

module OperationsUnsignedAdd {
  import opened Int
  import EVM
  import Precompiled
  import CheckedAddSpec
  import OperationsInitial
  import OperationsOutcome
  import opened EvmState
  import OperationsEntry
  import OperationsDispatcher
  import OperationsUnsignedDispatcher
  import OperationsDecode
  import OperationsUnsignedCalls
  import OperationsUnsignedArithmetic
  import OperationsPanic
  import OperationsReturn
  import OperationsCodeFacts
  import ExecutionTraceProof
  import Execution
  import U256
  import CheckedAddition

  // This is the public-entry obligation. Status remains unverified until
  // dispatcher, decoder, arithmetic and terminal path composition discharge it.
  lemma VerifyAdd(a: u256, b: u256, gas: nat, backend: Precompiled.T)
    requires gas >= 600
    ensures OperationsOutcome.Matches(
              EVM.ExecuteN(OperationsInitial.Make(false,a as int,b as int,gas,backend),163),
              CheckedAddSpec.Unsigned(a as int,b as int))
  {
    var initial := OperationsInitial.Make(false,a as int,b as int,gas,backend);
    OperationsInitial.Shape(false,a as int,b as int,gas,backend);
    var entry := OperationsEntry.Initialize(initial);
    var selected := OperationsDispatcher.Selector(entry[15],0x771602f7);
    ExecutionTraceProof.Join(entry,selected);
    var states := entry+selected[1..];
    var first := OperationsUnsignedDispatcher.FirstSplit(selected[4]);
    ExecutionTraceProof.Join(states,first); states := states+first[1..];
    var ranges := OperationsUnsignedDispatcher.RangeSplits(first[5]);
    ExecutionTraceProof.Join(states,ranges); states := states+ranges[1..];
    var signature := OperationsUnsignedDispatcher.SignatureCases(ranges[16]);
    ExecutionTraceProof.Join(states,signature); states := states+signature[1..];
    var decodeCall := OperationsUnsignedCalls.DecodeCall(signature[20]);
    ExecutionTraceProof.Join(states,decodeCall); states := states+decodeCall[1..];
    var pair := OperationsDecode.CheckWordPair(decodeCall[7],2122,1329,0x771602f7);
    ExecutionTraceProof.Join(states,pair); states := states+pair[1..];
    OperationsCodeFacts.Destination2122(initial.evm.code);
    var decoded := OperationsDecode.ReadWordPair(pair[11],a,b,2122,1329,0x771602f7);
    ExecutionTraceProof.Join(states,decoded); states := states+decoded[1..];
    var bodyCall := OperationsUnsignedCalls.BodyCall(decoded[14],a,b);
    ExecutionTraceProof.Join(states,bodyCall); states := states+bodyCall[1..];
    var additionCall := OperationsUnsignedCalls.AdditionCall(bodyCall[3],a,b);
    ExecutionTraceProof.Join(states,additionCall); states := states+additionCall[1..];
    var arithmetic := OperationsUnsignedArithmetic.Check(additionCall[7],a,b);
    ExecutionTraceProof.Join(states,arithmetic); states := states+arithmetic[1..];
    CheckedAddition.Unsigned(a,b);
    if a as int+b as int < TWO_256 {
      var additionReturn := OperationsUnsignedCalls.AdditionReturn(arithmetic[10],U256.Add(a,b),a,b);
      ExecutionTraceProof.Join(states,additionReturn); states := states+additionReturn[1..];
      var bodyReturn := OperationsUnsignedCalls.BodyReturn(additionReturn[6],U256.Add(a,b),a,b);
      ExecutionTraceProof.Join(states,bodyReturn); states := states+bodyReturn[1..];
      var encoded := OperationsReturn.Encode(bodyReturn[7],U256.Add(a,b),0x771602f7);
      ExecutionTraceProof.Join(states,encoded); states := states+encoded[1..];
      var terminal := OperationsReturn.Finish(encoded[10],U256.Add(a,b),0x771602f7);
      ExecutionTraceProof.Join(states,terminal); states := states+terminal[1..];
      assert |states| == 144;
      assert states[143].RETURNS? && states[143].gas == gas-520;
      assert OperationsOutcome.Matches(states[143],CheckedAddSpec.Unsigned(a as int,b as int));
    } else {
      var panicCall := OperationsUnsignedArithmetic.PanicCall(arithmetic[10]);
      ExecutionTraceProof.Join(states,panicCall); states := states+panicCall[1..];
      OperationsReturn.MemoryLayout(0);
      var terminal := OperationsPanic.Report(panicCall[3]);
      ExecutionTraceProof.Join(states,terminal); states := states+terminal[1..];
      assert |states| == 128;
      assert states[127] == ERROR(REVERTS,gas-465,CheckedAddSpec.Unsigned(a as int,b as int).data);
      assert OperationsOutcome.Matches(states[127],CheckedAddSpec.Unsigned(a as int,b as int));
    }
    ExecutionTraceProof.Replay(states,163);
    Execution.ExecuteNCorrespondence(initial,163,[]);
  }
}
