// SPDX-License-Identifier: MIT
// Decimal memory base geometry; native proof pending.
include "../../scans/Representation.dfy"
module OperationsToStringMemory {
  import S = BytecodeScanMachine
  import R = BytecodeScanRepresentation
  function Base():seq<S.Byte> { S.Store([],64,128) }
  lemma BaseFits()
    ensures |Base()|==96 && |Base()|%32==0 && S.Load(Base(),64)==128
  { R.StoredWord([],64,128); }
}
