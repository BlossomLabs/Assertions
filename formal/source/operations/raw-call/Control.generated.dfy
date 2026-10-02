include "Model.dfy"
module OperationsRawCallSource {
  import M = OperationsRawCallModel
  function Signal(): seq<bv8> { [210, 113, 6, 14] }
  function Reject(gasBefore: int,gasAfter: int,ret: seq<bv8>): bool
    requires 0 <= gasBefore < M.Mod && 0 <= gasAfter < M.Mod
  {
    var head := if (|ret| == 4) then ret[..4] else [0,0,0,0];
    ((gasAfter <= (gasBefore / 63)) || (head == Signal()))
  }
  function RawCall(target: int,data: seq<bv8>,o: M.Observation): M.Outcome
    requires M.Valid(o) && target == o.target && data == o.input
  {
    var success := o.success;
    var result := o.reason;
    if !success
    then if Reject(o.gasBefore,o.gasAfter,result) then M.OutOfGas else M.Failed(target,data)
    else M.Success(result)
  }
}
