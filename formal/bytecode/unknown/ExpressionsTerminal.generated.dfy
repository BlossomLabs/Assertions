// SPDX-License-Identifier: MIT
// Generated exact terminal instruction check with a fixed empty-revert oracle.
include "Bridge.dfy"
module BytecodeUnknownExpressionsTerminal {
  import G = BytecodeGetterMachine
  import B = BytecodeUnknownBridge
  predicate Matches(code: seq<G.Byte>) { |code| == 17776 && code[66] == 253 }
  lemma End(code: seq<G.Byte>, word: G.Word, value: G.Word, size: G.Word)
    requires Matches(code)
    ensures G.Step(code,{},G.Running(66,[G.Selector(word),0,0],B.Memory(true)),value,size,word) == G.Reverted([])
  { reveal G.Step(); }
}
