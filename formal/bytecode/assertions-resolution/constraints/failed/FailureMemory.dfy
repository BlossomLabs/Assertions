// SPDX-License-Identifier: MIT
// Isolate caller heap admission from the validator's symbolic trace composition.
include "DecoderFrame.dfy"
include "Caller.generated.dfy"
module AssertionsConstraintFalseFailureMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = AssertionsConstraintDecoderMemory
  import D = AssertionsConstraintFalseDecoderFrame
  import C = AssertionsConstraintFailedCaller
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Admitted(mem: seq<Byte>, free: Word, kind: Word, offset: Word,
                    length: Word, data: seq<Byte>, assertion: Word, assertionLength: Word,
                    ret: Word, base: Word, count: Word, ptr: Word, entry: Word, param: Word,
                    words: Word, index: Word, actual: Word, prefix: seq<Word>)
    requires H.Fits(mem,free,offset,length,data) && kind <= 8 && |prefix| <= 927
    requires assertion >= 96 && assertion+32+assertionLength <= |mem| && assertion+32+assertionLength <= free
    requires S.Load(mem,assertion) == assertionLength
    requires (H.NextFree(free,length) as nat)+356+S.Round32(assertionLength)+S.Round32(length) < 0x10000000000000000
    ensures C.Admitted(ret,base,count,ptr,assertion,entry,param,words,index,actual,free,kind,free+64,H.NextFree(free,length),assertionLength,length,prefix,H.Construct(mem,free,kind,offset,length,data))
  {
    hide H.Construct();
    H.Built(mem,free,kind,offset,length,data);
    D.Constraint(mem,free,kind,offset,length,data,assertion,32+assertionLength);
    var output := H.Construct(mem,free,kind,offset,length,data);
    D.Subspan(output,mem,assertion,32+assertionLength,0,32);
    assert G.Grow(output,assertion+32) == output && G.Grow(mem,assertion+32) == mem;
    assert S.Load(output,assertion) == assertionLength;
    assert assertion+32+assertionLength <= |output|;
  }
}
