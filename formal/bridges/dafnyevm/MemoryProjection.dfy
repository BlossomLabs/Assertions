// SPDX-License-Identifier: MIT
include "../../foundations/EvmValues.dfy"
include "../../foundations/SourceTotalMemoryV1.dfy"

// Finite executable buffers represent a bounded window of the unbounded source heap.
module EvmMemoryProjection {
  import D = Int
  import Arrays
  import H = SourceTotalMemoryV1

  function Bits(data: seq<D.u8>): seq<bv8>
    ensures |Bits(data)| == |data|
    ensures forall i :: 0 <= i < |data| ==> Bits(data)[i] == data[i] as bv8
  { seq(|data|, i requires 0 <= i < |data| => data[i] as bv8) }

  ghost predicate Represents(heap: imap<int,bv8>, buffer: seq<D.u8>, origin: int) {
    H.Total(heap) && forall i | 0 <= i < |buffer| :: heap[origin+i] == buffer[i] as bv8
  }

  lemma CopyWindow(heap: imap<int,bv8>, buffer: seq<D.u8>, origin: int, address: nat, data: seq<D.u8>)
    requires Represents(heap,buffer,origin)
    requires address+|data| <= |buffer|
    ensures Represents(H.Copy(heap,origin+address,Bits(data)),Arrays.Copy(data,buffer,address),origin)
    ensures forall a | a < origin+address || a >= origin+address+|data| :: H.Copy(heap,origin+address,Bits(data))[a] == heap[a]
  {
    var after := Arrays.Copy(data,buffer,address);
    forall i | 0 <= i < |buffer|
      ensures H.Copy(heap,origin+address,Bits(data))[origin+i] == after[i] as bv8
    {
      H.Cell(heap,origin+address,Bits(data),origin+i);
      if address <= i < address+|data| { assert after[i] == data[i-address]; }
      else { assert after[i] == buffer[i]; }
    }
    forall a | a < origin+address || a >= origin+address+|data|
      ensures H.Copy(heap,origin+address,Bits(data))[a] == heap[a]
    { H.Cell(heap,origin+address,Bits(data),a); }
  }
}
