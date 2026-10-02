include "Control.generated.dfy"
module OperationsSplitConnection {
  import M = OperationsSplitModel
  import W = OperationsWordMatchModel
  import S = OperationsSplitSource
  method Split(data: seq<bv8>,delimiter: seq<bv8>,dataOffset: nat,delimiterOffset: nat,outsideData: seq<bv8>,outsideDelimiter: seq<bv8>) returns (out: M.Outcome)
    requires |data|+1 < W.Half && |delimiter| < W.Half
    requires |outsideData| == 32 && |outsideDelimiter| == 32
    requires dataOffset+|data|+32 < W.Word && delimiterOffset+|delimiter|+32 < W.Word
    ensures out == M.Spec(data,delimiter)
    ensures out.Parts? ==> M.Join(out.data,delimiter) == data
  {
    out := S.Split(data,delimiter,dataOffset,delimiterOffset,outsideData,outsideDelimiter);
    if |delimiter| > 0 { M.TailProperties(data,delimiter,0,0); }
  }
}
