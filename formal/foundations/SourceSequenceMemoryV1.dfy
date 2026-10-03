include "../../proof-tools/dafnyevm/src/dafny/util/arrays.dfy"
// SPDX-License-Identifier: MIT
module SourceSequenceMemoryV1 {
  import Arrays
  function Replace<T>(memory: seq<T>, address: nat, data: seq<T>): seq<T>
    requires address+|data| <= |memory|
    ensures |Replace(memory,address,data)| == |memory|
  { Arrays.Copy(data,memory,address) }
  lemma NestedSlice<T>(memory: seq<T>,lo: nat,hi: nat,a: nat,b: nat)
    requires lo <= hi <= |memory| && a <= b <= hi-lo
    ensures memory[lo..hi][a..b] == memory[lo+a..lo+b]
  {
    forall j | 0 <= j < b-a
      ensures memory[lo..hi][a..b][j] == memory[lo+a..lo+b][j]
    { }
  }
  lemma Outside<T>(memory: seq<T>,address: nat,data: seq<T>,lo: nat,hi: nat)
    requires address+|data| <= |memory| && lo <= hi <= |memory|
    requires hi <= address || address+|data| <= lo
    ensures Replace(memory,address,data)[lo..hi] == memory[lo..hi]
  {
    var after := Replace(memory,address,data);
    assert after[..address] == memory[..address];
    assert after[address+|data|..] == memory[address+|data|..];
    if hi <= address {
      assert after[lo..hi] == after[..address][lo..hi];
      assert memory[lo..hi] == memory[..address][lo..hi];
    } else {
      assert after[lo..hi] == after[address+|data|..][lo-address-|data|..hi-address-|data|];
      assert memory[lo..hi] == memory[address+|data|..][lo-address-|data|..hi-address-|data|];
    }
  }
}
