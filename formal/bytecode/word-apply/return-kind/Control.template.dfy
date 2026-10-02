// SPDX-License-Identifier: MIT
// Actual terminal instruction over every fitting physical memory slice.
include "../../copy/Execution.dfy"
include "../../scans/Execution.dfy"
module BytecodeApplyReturnKind {
  import opened BytecodeScanMachine
  import M = BytecodeCopyMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  opaque predicate Matches(code: seq<Byte>) { |code| == @RUNTIME_LENGTH@ && code[498] == @TERMINAL_OPCODE@ }
  lemma Terminal(code: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, offset: Word, size: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && |prefix| <= 1022
    requires |mem|%32 == 0 && (offset as nat)+size <= |mem| < 0x400000000000000000
    ensures var next := M.Step(code,{},Running(498,prefix+[size,offset],mem),value,data); next == Returned(mem[offset..offset+size])
  {
    hide G.Encode();hide G.BitAnd();hide DataWord();hide ShiftRight();
    reveal Matches();
    assert Fetch(code,498) == Op(@TERMINAL_OPCODE@,499,0);
    assert G.Grow(mem,offset+size) == mem;
    M.Delegate(code,{},Running(498,prefix+[size,offset],mem),value,data);
    reveal Step();
  }
}
