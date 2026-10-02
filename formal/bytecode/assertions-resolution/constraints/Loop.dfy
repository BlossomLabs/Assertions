// SPDX-License-Identifier: MIT
// The complete physical orchestration segments around one validator iteration.
include "Init.generated.dfy"
include "Prepare.generated.dfy"
include "Dispatch.generated.dfy"
include "Increment.generated.dfy"
include "Exit.generated.dfy"
include "Empty.generated.dfy"
module AssertionsConstraintLoopSegments {
  import I = AssertionsConstraintInit
  import P = AssertionsConstraintPrepare
  import D = AssertionsConstraintDispatch
  import N = AssertionsConstraintIncrement
  import X = AssertionsConstraintExit
  import Z = AssertionsConstraintEmpty
  import S = BytecodeScanMachine
  type Byte = S.Byte
  type Word = S.Word
  opaque predicate Matches(code: seq<Byte>, ret: Word) {
    I.Matches(code,ret) && P.Matches(code,ret) && D.Matches(code,ret) &&
    N.Matches(code,ret) && X.Matches(code,ret) && Z.Matches(code,ret)
  }
  function Destinations(ret: Word): set<nat> {
    I.Destinations(ret)+P.Destinations(ret)+D.Destinations(ret)+N.Destinations(ret)+X.Destinations(ret)+Z.Destinations(ret)
  }
}
