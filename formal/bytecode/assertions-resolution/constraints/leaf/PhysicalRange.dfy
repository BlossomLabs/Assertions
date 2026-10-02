// SPDX-License-Identifier: MIT
// Cold terminal instruction theorem for an independent three-word range error.
include "../../ErrorMemory.dfy"
include "../../../assertions-machine/Signed.dfy"
module AssertionsConstraintPhysicalRange {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsSignedMachine
  import B = AssertionsConstraintErrorMemory
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Step(code: seq<Byte>, destinations: set<nat>, prefix: seq<Word>, mem: seq<Byte>,
                                   free: Word, entry: Word, param: Word, index: Word, value: Word, data: seq<Byte>)
    requires |code| > 1431 && code[1431] == 253 && |prefix| <= 1022
    requires |mem|%32 == 0 && (free as nat)+100 < G.Modulus()
    ensures M.Step(code,destinations,S.Running(1431,prefix+[100,free],B.RangeWithSelector(mem,free,0x295a41c5,entry,param,index)),value,data) ==
            S.Reverted(G.Encode(0x295a41c5,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32))
  {
    B.Three(mem,free,0x295a41c5,entry,param,index);
    var image := B.RangeWithSelector(mem,free,0x295a41c5,entry,param,index);
    assert G.Grow(image,(free as nat)+100) == image;
    assert image[free..free+100] == G.Encode(0x295a41c5,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32);
    assert S.Fetch(code,1431) == S.Op(253,1432,0);
    reveal M.Step(); reveal S.Step();
  }
}
