// SPDX-License-Identifier: MIT
include "../resolution/Words.dfy"
module CoreWords {
  import opened ConstraintModel
  import opened ResolutionWords

  datatype WordResult = Got(word: Word) | OutOfBounds(index: int, length: nat)
  function Half(): nat { Limit()/2 }
  predicate SignedIndex(i: int) { -(Half() as int) <= i < Half() }

  function SelectWord(data: seq<Byte>, index: int): WordResult {
    var words := |data|/32;
    var position := if index < 0 then words+index else index;
    if position < 0 || position >= words then OutOfBounds(index,|data|)
    else Got(Read(data[32*position..32*position+32]))
  }

  // Imperative normalization follows _rawWord; exact source gating is added by
  // the core package's source generator. This file alone is not source evidence.
  ghost method RawWord(data: seq<Byte>, index: int) returns (r: WordResult)
    requires |data| < Limit() && SignedIndex(index)
    ensures r == SelectWord(data,index)
  {
    var words := |data|/32;
    assert words < Half();
    var wanted: nat;
    if index < 0 {
      if index < -(words as int) { r := OutOfBounds(index,|data|); return; }
      assert -(Half() as int) < index;
      wanted := words - (-index);
    } else {
      if index >= words { r := OutOfBounds(index,|data|); return; }
      wanted := index;
    }
    assert 32*wanted+32 <= |data|;
    r := Got(Read(data[32*wanted..32*wanted+32]));
  }

  lemma NegativeFromEnd(data: seq<Byte>, index: int)
    requires index < 0
    ensures SelectWord(data,index).Got? <==> -(|data|/32 as int) <= index
  {}

  lemma IgnoresPartialTail(data: seq<Byte>, tail: seq<Byte>, index: int)
    requires |data|%32 == 0 && |tail| < 32
    ensures SelectWord(data+tail,index).Got? == SelectWord(data,index).Got?
    ensures SelectWord(data,index).Got? ==> SelectWord(data+tail,index).word == SelectWord(data,index).word
  {
    assert |data+tail|/32 == |data|/32;
    var position := if index < 0 then |data|/32+index else index;
    if 0 <= position < |data|/32 {
      assert (data+tail)[32*position..32*position+32] == data[32*position..32*position+32];
    }
  }
}
