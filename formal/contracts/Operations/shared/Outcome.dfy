// SPDX-License-Identifier: MIT
include "../add/Spec.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/state.dfy"

module OperationsOutcome {
  import opened EvmState
  import CheckedAddSpec

  ghost predicate Matches(final: State, expected: CheckedAddSpec.Outcome)
  {
    if expected.Returned? then final.RETURNS? && final.data == expected.data
    else final.ERROR? && final.error == REVERTS && final.data == expected.data
  }
}
