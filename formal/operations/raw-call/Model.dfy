module OperationsRawCallModel {
  const Mod: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  datatype Observation = Observation(target: int,input: seq<bv8>,success: bool,reason: seq<bv8>,gasBefore: int,gasAfter: int)
  datatype Outcome = Success(data: seq<bv8>) | OutOfGas | Failed(target: int,input: seq<bv8>)
  predicate Valid(o: Observation) {
    0 <= o.target < 0x10000000000000000000000000000000000000000 &&
    0 <= o.gasBefore < Mod && 0 <= o.gasAfter < Mod && |o.input| < Mod && |o.reason| < Mod
  }
}
