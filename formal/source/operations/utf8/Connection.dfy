include "Control.generated.dfy"
module OperationsUtf8Connection {
  import M = OperationsUtf8Model
  import Source = OperationsUtf8Source
  import B = OperationsByteBoundsModel
  method Slice(data: seq<bv8>,start: int,end: int) returns (out: M.Outcome)
    requires |data| < B.Half && B.Signed(start) && B.Signed(end)
    ensures out == M.Slice(data,start,end)
    ensures out.Bytes? ==> M.Utf8(out.data)
  {
    out := Source.Slice(data,start,end);
    M.ValidateUtf8(data,0);
    var a := B.Clamp(start,|data|);
    var b := B.Clamp(end,|data|);
    if out.Bytes? && b > a { M.SliceValid(data,a,b); }
  }
  method At(data: seq<bv8>,index: int) returns (out: M.Outcome)
    requires |data| < B.Half && B.Signed(index)
    ensures out == M.At(data,index)
    ensures out.Bytes? ==> M.Utf8(out.data) && |out.data| == 1
  { out := Source.At(data,index); }
}
