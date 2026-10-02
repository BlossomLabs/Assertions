include "Control.generated.dfy"
module OperationsIntegerRootConnection {
  import M = OperationsIntegerRootModel
  import B = OperationsBinaryLogModel
  import S = OperationsIntegerRootSource
  method PublicConnection(x: nat) returns (out: nat)
    requires x < B.Word
    ensures out*out <= x < (out+1)*(out+1) && out < B.Power(128)
  { out := S.Public(x); }
}
