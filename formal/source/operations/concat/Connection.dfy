include "Control.generated.dfy"
module OperationsConcatConnection {
  import M = OperationsConcatModel
  import S = OperationsConcatSource
  ghost method Concat(parts: seq<seq<bv8>>,delimiter: seq<bv8>,ptr: int) returns (out: M.Outcome)
    requires |parts| < M.Word && |delimiter| < M.Word
    requires forall i | 0 <= i < |parts| :: |parts[i]| < M.Word
    requires 128 <= ptr && ptr % 32 == 0
    requires M.Length(parts,delimiter) < M.Word ==> ptr+64+M.Length(parts,delimiter) < M.Word
    ensures out == M.Spec(parts,delimiter)
    ensures out.Bytes? ==> |out.data| == M.Length(parts,delimiter)
  { out := S.Concat(parts,delimiter,ptr); M.JoinLength(parts,delimiter); }
}
