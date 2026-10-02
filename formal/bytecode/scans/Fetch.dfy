// SPDX-License-Identifier: MIT
include "Representation.dfy"
module BytecodeScanFetch {
  import opened BytecodeScanMachine
  import R = BytecodeScanRepresentation
  import G = BytecodeGetterMachine
  lemma Push1(code: seq<Byte>, pc: nat)
    requires pc+2 <= |code| && code[pc] == 0x60
    ensures Fetch(code,pc) == Op(0x60,pc+2,code[pc+1])
  {
    R.WindowFits(code,pc+1,1);
    assert code[pc+1..pc+2] == [code[pc+1]];
    assert G.Decode([code[pc+1]]) == code[pc+1];
  }
  lemma Push2(code: seq<Byte>, pc: nat)
    requires pc+3 <= |code| && code[pc] == 0x61
    ensures Fetch(code,pc) == Op(0x61,pc+3,(code[pc+1] as nat)*256+code[pc+2])
  {
    R.WindowFits(code,pc+1,2);
    var first := code[pc+1];
    var second := code[pc+2];
    assert code[pc+1..pc+3] == [first,second];
    assert [first,second][..1] == [first];
    assert G.Decode([first]) == first;
    assert G.Decode([first,second]) == (first as nat)*256+second;
  }
}
