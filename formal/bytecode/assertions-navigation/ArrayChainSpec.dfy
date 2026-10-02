// SPDX-License-Identifier: MIT
// Declarative complete successful array-suffix grammar and ABI footprint.
include "ArrayDecimal.dfy"
module AssertionsNavigationArrayChainSpec {
  import S = BytecodeScanMachine
  import N = AssertionsNavigationArrayDecimal
  datatype Shape = Shape(end: nat,dynamic: bool,words: nat)
  function NextWords(data: seq<S.Byte>,offset: nat,start: nat,stop: nat,dynamic: bool,words: nat): nat
    requires start+1 <= stop && N.Digits(data,offset+start+1,offset+stop)
  {
    if dynamic || stop == start+1 then 1
    else words*N.Number(data,offset+start+1,offset+stop,0)
  }
  predicate Valid(data: seq<S.Byte>,offset: nat,start: nat,limit: nat,dynamic: bool,words: nat,closings: seq<nat>)
    decreases |closings|
  {
    start <= limit && offset+limit <= |data| && 1 <= words <= 4294967295 &&
    (dynamic ==> words == 1) &&
    if |closings| == 0 then start == limit || data[offset+start] != 91
    else
      start < limit && data[offset+start] == 91 && start+1 <= closings[0] < limit &&
      data[offset+closings[0]] == 93 && N.Digits(data,offset+start+1,offset+closings[0]) &&
      N.Number(data,offset+start+1,offset+closings[0],0) <= 4294967295 &&
      (closings[0] > start+1 ==> N.Number(data,offset+start+1,offset+closings[0],0) > 0) &&
      Valid(data,offset,closings[0]+1,limit,dynamic || closings[0] == start+1,
            NextWords(data,offset,start,closings[0],dynamic,words),closings[1..])
  }
  function Result(data: seq<S.Byte>,offset: nat,start: nat,limit: nat,dynamic: bool,words: nat,closings: seq<nat>): Shape
    requires Valid(data,offset,start,limit,dynamic,words,closings)
    ensures start <= Result(data,offset,start,limit,dynamic,words,closings).end <= limit
    ensures 1 <= Result(data,offset,start,limit,dynamic,words,closings).words <= 4294967295
    ensures Result(data,offset,start,limit,dynamic,words,closings).dynamic ==> Result(data,offset,start,limit,dynamic,words,closings).words == 1
    decreases |closings|
  {
    if |closings| == 0 then Shape(start,dynamic,words)
    else Result(data,offset,closings[0]+1,limit,dynamic || closings[0] == start+1,
                NextWords(data,offset,start,closings[0],dynamic,words),closings[1..])
  }
  lemma ClosingUnique(data: seq<S.Byte>,offset: nat,start: nat,left: nat,right: nat)
    requires start+1 <= left && start+1 <= right
    requires N.Digits(data,offset+start+1,offset+left) && N.Digits(data,offset+start+1,offset+right)
    requires offset+left < |data| && offset+right < |data|
    requires data[offset+left] == 93 && data[offset+right] == 93
    ensures left == right
  {
    if left < right { assert 48 <= data[offset+left] <= 57; }
    if right < left { assert 48 <= data[offset+right] <= 57; }
  }
  lemma Unique(data: seq<S.Byte>,offset: nat,start: nat,limit: nat,dynamic: bool,words: nat,left: seq<nat>,right: seq<nat>)
    requires Valid(data,offset,start,limit,dynamic,words,left) && Valid(data,offset,start,limit,dynamic,words,right)
    ensures left == right
    ensures Result(data,offset,start,limit,dynamic,words,left) == Result(data,offset,start,limit,dynamic,words,right)
    decreases |left|
  {
    if |left| > 0 && |right| > 0 {
      ClosingUnique(data,offset,start,left[0],right[0]);
      Unique(data,offset,left[0]+1,limit,dynamic || left[0] == start+1,
             NextWords(data,offset,start,left[0],dynamic,words),left[1..],right[1..]);
      assert left == [left[0]]+left[1..];
      assert right == [right[0]]+right[1..];
    }
  }
}
