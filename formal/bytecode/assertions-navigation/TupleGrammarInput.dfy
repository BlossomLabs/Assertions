// SPDX-License-Identifier: MIT
// Discharge tuple-loop geometric admission from an encoded independent grammar.
// Physical recursive child traces remain a separate obligation.
include "TupleGrammar.dfy"
include "TupleLoop.dfy"
module AssertionsNavigationTupleGrammarInput {
  import opened BytecodeScanMachine
  import S = AssertionsNavigationDescriptorSpec
  import E = AssertionsNavigationDescriptorEncoding
  import G = AssertionsNavigationTupleGrammar
  import L = AssertionsNavigationTupleLoop
  function Bytes(text: seq<nat>): seq<Byte>
  { seq(|text|, i requires 0 <= i < |text| => text[i]%256) }
  lemma Admission(types: seq<S.Type>,data: seq<Byte>,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>)
    requires S.Valid(S.Tuple(types))
    requires (offset as nat)+length <= |data| < 0x10000000000000000
    requires p+|E.Encode(S.Tuple(types))| <= limit <= length && |prefix| <= 930
    requires data[offset+p..offset+p+|E.Encode(S.Tuple(types))|] == Bytes(E.Encode(S.Tuple(types)))
    ensures L.Geometry(data,offset,length,p,limit,G.Children(types,p),prefix)
    ensures L.Admitted(data,offset,length,p,limit,G.Children(types,p),prefix)
  {
    E.EncodeValid(S.Tuple(types));
    G.Geometry(types,p);
    forall i | 0 <= i < |types|
      ensures L.Cursor(p,G.Children(types,p),i) <= G.Children(types,p)[i].end < limit
      ensures data[offset+G.Children(types,p)[i].end] == (if i+1 == |types| then 41 else 44)
    {
      assert L.Cursor(p,G.Children(types,p),i) == G.Cursor(types,p,i);
      var at := G.Children(types,p)[i].end-p;
      assert data[offset+p..offset+p+|E.Encode(S.Tuple(types))|][at] == Bytes(E.Encode(S.Tuple(types)))[at];
      assert Bytes(E.Encode(S.Tuple(types)))[at] == E.Encode(S.Tuple(types))[at];
      assert data[offset+G.Children(types,p)[i].end] == E.Encode(S.Tuple(types))[at];
    }
    L.GeometryBounds(data,offset,length,p,limit,G.Children(types,p),prefix);
  }
}
