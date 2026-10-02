include "Control.generated.dfy"
module OperationsRawCallConnection {
  import M = OperationsRawCallModel
  import S = OperationsRawCallSource
  lemma Guard(gasBefore: int,gasAfter: int,ret: seq<bv8>)
    requires 0 <= gasBefore < M.Mod && 0 <= gasAfter < M.Mod
    ensures S.Reject(gasBefore,gasAfter,ret) == (gasAfter <= gasBefore / 63 || ret == S.Signal())
  { }
  lemma RawCall(target: int,data: seq<bv8>,o: M.Observation)
    requires M.Valid(o) && target == o.target && data == o.input
    ensures o.success ==> S.RawCall(target,data,o) == M.Success(o.reason)
    ensures !o.success && (o.gasAfter <= o.gasBefore / 63 || o.reason == S.Signal()) ==> S.RawCall(target,data,o) == M.OutOfGas
    ensures !o.success && o.gasAfter > o.gasBefore / 63 && o.reason != S.Signal() ==> S.RawCall(target,data,o) == M.Failed(target,data)
  { Guard(o.gasBefore,o.gasAfter,o.reason); }
  lemma LongPrefixIsOrdinary(suffix: seq<bv8>)
    requires |suffix| > 0
    ensures !S.Reject(63000,1001,S.Signal()+suffix)
  { Guard(63000,1001,S.Signal()+suffix); }
  lemma GroundLongSignalWitness()
    ensures !S.Reject(63000,1001,S.Signal()+[255])
  { }

}
