// SPDX-License-Identifier: MIT
include "Fetch.dfy"
module BytecodeScanPush {
  import opened BytecodeScanMachine
  import R = BytecodeScanRepresentation
  import G = BytecodeGetterMachine
  lemma Push4(code: seq<Byte>, pc: nat)
    requires pc+5 <= |code| && code[pc] == 0x63
    ensures Fetch(code,pc) == Op(0x63,pc+5,
                                 (code[pc+1] as nat)*16777216+(code[pc+2] as nat)*65536+(code[pc+3] as nat)*256+code[pc+4])
  {
    R.WindowFits(code,pc+1,4);
    var a := code[pc+1];
    var b := code[pc+2];
    var c := code[pc+3];
    var d := code[pc+4];
    assert code[pc+1..pc+5] == [a,b,c,d];
    assert G.Decode([a]) == a;
    assert [a,b][..1] == [a];
    assert G.Decode([a,b]) == (a as nat)*256+b;
    assert [a,b,c][..2] == [a,b];
    assert G.Decode([a,b,c]) == (a as nat)*65536+(b as nat)*256+c;
    assert [a,b,c,d][..3] == [a,b,c];
    assert G.Decode([a,b,c,d]) == (a as nat)*16777216+(b as nat)*65536+(c as nat)*256+d;
  }
}
