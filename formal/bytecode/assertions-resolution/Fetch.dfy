// SPDX-License-Identifier: MIT
include "../scans/Fetch.dfy"
module AssertionsConstraintFetch {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  lemma Push4(code: seq<S.Byte>, pc: nat)
    requires pc+5 <= |code| && code[pc] == 0x63
    ensures S.Fetch(code,pc) == S.Op(0x63,pc+5,(((code[pc+1] as nat)*256+code[pc+2])*256+code[pc+3])*256+code[pc+4])
  {
    R.WindowFits(code,pc+1,4);
    var a := code[pc+1]; var b := code[pc+2];
    var c := code[pc+3]; var d := code[pc+4];
    assert code[pc+1..pc+5] == [a,b,c,d];
    assert [a,b,c,d][..3] == [a,b,c];
    assert [a,b,c][..2] == [a,b];
    assert [a,b][..1] == [a];
    assert G.Decode([a]) == a;
    assert G.Decode([a,b]) == (a as nat)*256+b;
    assert G.Decode([a,b,c]) == ((a as nat)*256+b)*256+c;
    assert G.Decode([a,b,c,d]) == (((a as nat)*256+b)*256+c)*256+d;
  }
}
