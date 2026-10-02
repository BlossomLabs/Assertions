// SPDX-License-Identifier: MIT
include "SourceSequenceMemoryV1.dfy"
module SourceSequenceCellV4 {
  import M = SourceSequenceMemoryV1
  lemma Cell<T>(memory: seq<T>,address: nat,data: seq<T>,i: nat)
    requires address+|data| <= |memory| && i < |memory|
    ensures address <= i < address+|data| ==> M.Replace(memory,address,data)[i] == data[i-address]
    ensures i < address || address+|data| <= i ==> M.Replace(memory,address,data)[i] == memory[i]
  {
    if i < address { } else if i < address+|data| { } else { }
  }
}
