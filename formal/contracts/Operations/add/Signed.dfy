// SPDX-License-Identifier: MIT
include "Spec.dfy"
include "../shared/Initial.dfy"
include "../shared/Outcome.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/checked-add.dfy"
include "../../../shared/abi/Bridge.dfy"

module OperationsSignedAdd {
  import opened Int
  import EVM
  import Precompiled
  import CheckedAddSpec
  import OperationsInitial
  import OperationsOutcome

  lemma VerifyAdd(a: i256, b: i256, gas: nat, backend: Precompiled.T)
    requires gas >= 600
    ensures OperationsOutcome.Matches(
              EVM.ExecuteN(OperationsInitial.Make(true,a as int,b as int,gas,backend),163),
              CheckedAddSpec.Signed(a as int,b as int))
  {
    assert OperationsOutcome.Matches(
        EVM.ExecuteN(OperationsInitial.Make(true,a as int,b as int,gas,backend),163),
        CheckedAddSpec.Signed(a as int,b as int));
  }
}
