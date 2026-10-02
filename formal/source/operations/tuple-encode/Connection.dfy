include "Control.generated.dfy"
module OperationsTupleEncodeConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import M = OperationsTupleEncodeModel
  import S = OperationsTupleEncodeSource
  ghost method Raw(t: seq<Byte>,values: seq<seq<Byte>>) returns (receipt: M.Receipt)
    requires M.Budget(t,values)
    ensures receipt.Returned? ==> M.Canonical(t,values,receipt.wire)
    ensures receipt.Aborted? ==> !receipt.reason.Success?
  { receipt := S.Raw(t,values); }
  ghost method Bytes(t: seq<Byte>,values: seq<seq<Byte>>) returns (receipt: M.Receipt,payload: seq<Byte>)
    requires M.Budget(t,values)
    ensures receipt.Returned? ==> M.Canonical(t,values,payload) && receipt.wire == Encode(AbiType.Bytes,Buffer(payload))
    ensures receipt.Aborted? ==> !receipt.reason.Success?
  { receipt,payload := S.Bytes(t,values); }
}
