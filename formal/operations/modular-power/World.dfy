include "Memory.dfy"
module OperationsModularPowerWorld {
  import B = OperationsBinaryLogModel
  import M = OperationsModularPowerMemory
  import P = OperationsModularPowerPower
  datatype Reply = Reply(target: nat,gasQuote: nat,input: seq<nat>,success: bool,data: seq<nat>)
  predicate Valid(base: nat,exponent: nat,modulus: nat,reply: Reply)
    requires base < B.Word && exponent < B.Word && 0 < modulus < B.Word
  {
    reply.target == 5 && reply.gasQuote < B.Word && reply.input == M.Request(base,exponent,modulus)
    && |reply.data| < B.Word && M.Bytes(reply.data)
    && (reply.success && |reply.data| == 32 ==> reply.data == M.Word(P.Power(base,exponent)%modulus))
  }
  predicate World(world: (nat,nat,nat) -> Reply)
  {
    forall base: nat,exponent: nat,modulus: nat |
      base < modulus && 0 < modulus < B.Word && exponent < B.Word :: Valid(base,exponent,modulus,world(base,exponent,modulus))
  }
}
