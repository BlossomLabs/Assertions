// SPDX-License-Identifier: MIT
// Candidate complete copied-payload physical hash/return bridge; no public credit.
include "../hash-bytes-repair-v3/Execution.dfy"
module OperationsHashSuccessKernel {
  import opened OperationsHashBytesMachine
  import B = OperationsHashBytesMemory
  import E = OperationsHashBytesExecution
  function Initial(): seq<Byte> { Store([],64,128) }
  function Copied(data: seq<Byte>,source: Word,count: Word): seq<Byte>
  { B.CalldataCopy(Initial(),data,128,source,count) }
  function Cleared(data: seq<Byte>,source: Word,count: Word): seq<Byte>
  { Store(Copied(data,source,count),128+(count as nat),0) }
  function Finished(data: seq<Byte>,source: Word,count: Word,result: Word): seq<Byte>
  { Store(Cleared(data,source,count),128,result) }
  predicate Observed(data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>) {
    |data|<0x10000000000000000 && count<0x10000000000000000 &&
    (source as nat)+(count as nat)<=|data| &&
    data[source..(source as nat)+(count as nat)] in hashes &&
    hashes[data[source..(source as nat)+(count as nat)]]==result
  }
  lemma Heaps(data: seq<Byte>,source: Word,count: Word,result: Word)
    requires (source as nat)+(count as nat)<=|data|
    ensures Load(Initial(),64)==128 && |Initial()|==96
    ensures Load(Copied(data,source,count),64)==128
    ensures Load(Cleared(data,source,count),64)==128
    ensures Load(Finished(data,source,count,result),64)==128
    ensures Load(Finished(data,source,count,result),128)==result
  {
    StoreLoad([],64,128);
    B.CopyPrefix(Initial(),data,128,source,count,96);
    assert Load(Copied(data,source,count),64)==Load(Initial(),64);
    B.ScratchPayload(Initial(),data,source,count);
    StoreFrame(Cleared(data,source,count),128,result,64);
    StoreLoad(Cleared(data,source,count),128,result);
  }
  lemma Payload(data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Observed(data,source,count,result,hashes)
    ensures |Cleared(data,source,count)|>=128+(count as nat)
    ensures Cleared(data,source,count)[128..128+(count as nat)] in hashes
    ensures hashes[Cleared(data,source,count)[128..128+(count as nat)]]==result
  { E.CopiedPayloadHash(Initial(),data,source,count,hashes); }
  lemma Receipt(data: seq<Byte>,source: Word,count: Word,result: Word)
    ensures Grow(Finished(data,source,count,result),160)[128..160]==Encode(result,32)
  { StoreLoad(Cleared(data,source,count),128,result); }
}
