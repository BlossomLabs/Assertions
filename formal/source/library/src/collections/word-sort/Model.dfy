// SPDX-License-Identifier: MIT
include "../word-memory/Connection.dfy"
include "../sort-core/Connection.dfy"
module CollectionsWordSortModel {
  import opened AbiFrames
  import W = CollectionsWordMemoryModel
  import C = CollectionsSortConnection
  function Key(keys: seq<nat>,id: nat): nat { if id < |keys| then keys[id] else 0 }
  function Le(keys: seq<nat>,a: nat,b: nat): bool { Key(keys,a) <= Key(keys,b) }
  predicate Represents(keys: seq<nat>,ids: seq<nat>,payload: seq<Byte>) {
    |payload| == 32*|ids| &&
    forall i :: 0 <= i < |ids| ==> W.Words(payload)[i] == Key(keys,ids[i])
  }
  predicate Apart(base: nat,other: nat,size: nat) {
    base+32+size <= other || other+32+size <= base
  }
  predicate Buffers(memory: seq<Byte>,base: nat,other: nat,payload: seq<Byte>,scratch: seq<Byte>) {
    W.Fits(|memory|) && |payload| == |scratch| && Apart(base,other,|payload|) &&
    W.Frame(memory,base,payload) && W.Frame(memory,other,scratch)
  }
}
