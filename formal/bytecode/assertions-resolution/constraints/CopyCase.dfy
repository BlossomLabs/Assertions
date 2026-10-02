// SPDX-License-Identifier: MIT
// A concrete native mutation witness for the reached payload-copy instruction.
include "../raw/Machine.dfy"
module AssertionsConstraintCopyCase {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCopyMemory
  import A = AssertionsSignedMachine
  type Byte = S.Byte
  lemma PayloadByte(code: seq<Byte>)
    requires 18492 < |code| && code[18492] == 0x37
    ensures var before := S.Running(18492,[1,0,256],S.Expand([],288));
            var after := M.Step(code,{},before,0,[1]);
            after.Running? && after.stack == [] && |after.memory| == 288 && after.memory[256] == 1
  {
    reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
    assert S.Fetch(code,18492) == S.Op(0x37,18493,0);
    assert C.Fits(S.Expand([],288),256,0,1,false);
    B.Rounded(288);
    B.Size(S.Expand([],288),256,[1]);
    B.Span(S.Expand([],288),256,[1]);
  }
}
