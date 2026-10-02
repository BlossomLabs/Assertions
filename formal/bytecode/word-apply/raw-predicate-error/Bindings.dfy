// SPDX-License-Identifier: MIT
include "../raw-wrong-size-repair-v4/Bindings.dfy"
include "../predicate-error-iteration-repair-v2/Engine.dfy"
module BytecodeApplyRawNoncanonicalPredicateBindings {
  import opened BytecodeScanMachine
  import X = BytecodeExternalMachine
  import C = BytecodeApplyRawLoopPrefixCompletion
  import L = BytecodeApplyRawLoopState
  import F = BytecodeApplyRawWrongSizeBindings
  function Completed(data: seq<Byte>,actual: seq<seq<Byte>>): seq<seq<Byte>>
    requires C.Successful(data,true,actual)
    ensures L.Receipts(data,true,Completed(data,actual))
    ensures Completed(data,actual) == F.Completed(data,true,actual)
  { F.Completed(data,true,actual) }
  opaque predicate BadTape(data: seq<Byte>,actual: seq<seq<Byte>>,self: Word,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,returned: seq<Byte>)
    requires C.Successful(data,true,actual) && |actual| < L.N(data)
  { F.BadTape(data,true,actual,self,cursor,observations,gasBefore,requestedGas,returned) }
}
