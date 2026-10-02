include "Model.dfy"
module OperationsFullMulDivMemory {
  import B = OperationsBinaryLogModel
  function Word(value: nat): seq<nat>
    ensures |Word(value)| == 32
  { seq(32,(i: int) requires 0 <= i < 32 => B.Byte(i,value)) }
  function Store(memory: seq<nat>,offset: nat,value: nat): seq<nat>
    requires offset+32 <= |memory|
    ensures |Store(memory,offset,value)| == |memory|
  { seq(|memory|,(i: int) requires 0 <= i < |memory| => if offset <= i < offset+32 then Word(value)[i-offset] else memory[i]) }
  function Canonical(code: nat): seq<nat> { [78,72,123,113]+Word(code) }
  lemma LowSelector()
    ensures Word(0x4e487b71)[28..32] == [78,72,123,113]
  {
    B.BytePowers();
    forall i: nat | i < 4
      ensures Word(0x4e487b71)[28+i] == [78,72,123,113][i]
    { if i == 0 {} else if i == 1 {} else if i == 2 {} else { assert i == 3; } }
  }
  lemma HighSelector()
    ensures Word(0x4e487b7100000000000000000000000000000000000000000000000000000000)[0..4] == [78,72,123,113]
  {
    B.BytePowers();
    forall i: nat | i < 4
      ensures Word(0x4e487b7100000000000000000000000000000000000000000000000000000000)[i] == [78,72,123,113][i]
    { if i == 0 {} else if i == 1 {} else if i == 2 {} else { assert i == 3; } }
  }
}
