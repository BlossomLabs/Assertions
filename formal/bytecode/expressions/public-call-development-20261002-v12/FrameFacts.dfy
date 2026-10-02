// SPDX-License-Identifier: MIT
include "../../scans/Representation.dfy"
module ExpressionsAddressCompleteFrameFacts {
  import opened BytecodeScanMachine
  import R = BytecodeScanRepresentation
  lemma StoreProgress(mem: seq<Byte>, offset: Word, word: Word)
    requires |mem|%32 == 0
    ensures |Store(mem,offset,word)|%32 == 0
    ensures |Store(mem,offset,word)| >= |mem|
    ensures |Store(mem,offset,word)| >= (offset as nat)+32
    ensures Load(Store(mem,offset,word),offset) == word
  {
    R.Expansion(mem,(offset as nat)+32);
    R.StoredWord(mem,offset,word);
  }
}
