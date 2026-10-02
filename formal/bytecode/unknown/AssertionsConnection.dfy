// SPDX-License-Identifier: MIT
// Assertions-only physical unknown-selector rejection connection.
include "Assertions.generated.dfy"
include "AssertionsTerminal.generated.dfy"
module BytecodeUnknownAssertionsConnection {
  import G = BytecodeGetterMachine
  import A = BytecodeUnknownAssertions
  import T = BytecodeUnknownAssertionsTerminal
  import C = BytecodeDispatchAssertions
  import E = BytecodeUnknownExecution
  ghost method Run(code: seq<G.Byte>, value: G.Word, size: G.Word, word: G.Word)
    returns (state: G.State, trace: seq<G.State>)
    requires A.Matches(code) && A.Admitted(value,size,word)
    ensures state == G.Reverted([])
    ensures E.Trace(code,C.Destinations(),value,size,word,trace)
    ensures trace[0] == G.Running(0,[],[]) && trace[|trace|-1] == state
    ensures forall i: nat | i < |trace| && trace[i].Running? ::
              |trace[i].stack| <= 3 && |trace[i].memory| <= 96
  {
    state,trace := A.Run(code,value,size,word);
  }
}
