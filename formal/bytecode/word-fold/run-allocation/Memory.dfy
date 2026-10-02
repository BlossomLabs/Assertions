// SPDX-License-Identifier: MIT
// Exact six-word FoldRun heap, independent of the full-width range element count.
include "../raw-inputs/Inputs.dfy"
include "../../scans/Representation.dfy"
module BytecodeFoldRunMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeFoldRawInputs
  import R = BytecodeScanRepresentation
  function Count(data: seq<S.Byte>,domain: nat): S.Word
    requires domain < 3
  {
    if domain == 0 then I.RangeCount(data) else if domain == 1 then I.SourceLength(data) else (I.SourceLength(data) as nat)/32
  }
  function Slots(data: seq<S.Byte>,domain: nat): seq<S.Word>
    requires domain < 3
  { [domain,Count(data,domain),I.Target(data),I.AccOffset(data),I.Initial(data),I.Exit(data)] }
  function Stage(data: seq<S.Byte>,domain: nat,stores: nat): seq<S.Byte>
    requires domain < 3 && stores <= 6
    decreases stores
  {
    if stores == 0 then S.Store(S.Store([],64,128),64,320)
    else S.Store(Stage(data,domain,stores-1),128+32*(stores-1),Slots(data,domain)[stores-1])
  }
  function Heap(data: seq<S.Byte>,domain: nat): seq<S.Byte>
    requires domain < 3
  { Stage(data,domain,6) }
  lemma Next(data: seq<S.Byte>,domain: nat,stores: nat)
    requires domain < 3 && stores < 6
    ensures Stage(data,domain,stores+1) == S.Store(Stage(data,domain,stores),128+32*stores,Slots(data,domain)[stores])
  {}
  lemma Frames(data: seq<S.Byte>,domain: nat,stores: nat)
    requires domain < 3 && stores <= 6
    ensures |Stage(data,domain,stores)| == (if stores == 0 then 96 else 128+32*stores)
    ensures |Stage(data,domain,stores)|%32 == 0 && S.Load(Stage(data,domain,stores),64) == 320
    ensures forall j: nat :: j < stores ==> S.Load(Stage(data,domain,stores),128+32*j) == Slots(data,domain)[j]
    decreases stores
  {
    if stores == 0 {
      R.StoredWord([],64,128);
      R.StoredWord(S.Store([],64,128),64,320);
    } else {
      Frames(data,domain,stores-1);
      var previous := Stage(data,domain,stores-1);
      var offset: S.Word := 128+32*(stores-1);
      var word := Slots(data,domain)[stores-1];
      R.StoredWord(previous,offset,word);
      R.StoredFrame(previous,offset,word,64);
      forall j: nat | j < stores-1
        ensures S.Load(Stage(data,domain,stores),128+32*j) == Slots(data,domain)[j]
      {
        R.StoredFrame(previous,offset,word,128+32*j);
      }
    }
  }
  lemma Layout(data: seq<S.Byte>,domain: nat)
    requires domain < 3
    ensures |Heap(data,domain)| == 320 && S.Load(Heap(data,domain),64) == 320
    ensures S.Load(Heap(data,domain),128) == domain
    ensures S.Load(Heap(data,domain),160) == Count(data,domain)
    ensures S.Load(Heap(data,domain),192) == I.Target(data)
    ensures S.Load(Heap(data,domain),224) == I.AccOffset(data)
    ensures S.Load(Heap(data,domain),256) == I.Initial(data)
    ensures S.Load(Heap(data,domain),288) == I.Exit(data)
  { Frames(data,domain,6); }
}
