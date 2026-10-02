// SPDX-License-Identifier: MIT
include "../v1/SequenceMemory.dfy"
module SourceReplacementSpanV7 {
  import M = SourceSequenceMemoryV1
  lemma ReplaceSpan<T>(prefix: seq<T>,hole: seq<T>,suffix: seq<T>,data: seq<T>)
    requires |hole| == |data|
    ensures M.Replace(prefix+hole+suffix,|prefix|,data) == prefix+data+suffix
  {
    var original := prefix+hole+suffix;
    assert original[..|prefix|] == prefix;
    assert original[|prefix|+|hole|..] == suffix;
  }
}
