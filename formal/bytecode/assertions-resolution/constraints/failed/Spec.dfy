// SPDX-License-Identifier: MIT
// Independent canonical ABI bytes for ConstraintFailed; no serializer invocation.
include "../../../copy/Memory.dfy"
module AssertionsConstraintFailedSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  function Pad(bytes: seq<Byte>): seq<Byte>
    ensures |Pad(bytes)| == S.Round32(|bytes|)
    ensures Pad(bytes)[..|bytes|] == bytes
    ensures forall i {:trigger Pad(bytes)[i]} :: |bytes| <= i < |Pad(bytes)| ==> Pad(bytes)[i] == 0
  {
    B.Rounded(|bytes|);
    bytes+seq(S.Round32(|bytes|)-|bytes|,i requires 0 <= i < S.Round32(|bytes|)-|bytes| => 0)
  }
  function Blob(bytes: seq<Byte>): seq<Byte>
    requires |bytes| < G.Modulus()
    ensures |Blob(bytes)| == 32+S.Round32(|bytes|)
  { G.Encode(|bytes|,32)+Pad(bytes) }
  function Error(assertion: seq<Byte>, entry: Word, param: Word, index: Word,
                 kind: Word, actual: Word, reference: seq<Byte>): seq<Byte>
    requires kind <= 8 && |assertion| < G.Modulus() && |reference| < G.Modulus()
    requires 256+S.Round32(|assertion|) < G.Modulus()
    ensures |Error(assertion,entry,param,index,kind,actual,reference)| == 292+S.Round32(|assertion|)+S.Round32(|reference|)
  {
    G.Encode(0xdeb9f2af,4)+
    G.Encode(224,32)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32)+
    G.Encode(kind,32)+G.Encode(actual,32)+G.Encode(256+S.Round32(|assertion|),32)+
    Blob(assertion)+Blob(reference)
  }
}
