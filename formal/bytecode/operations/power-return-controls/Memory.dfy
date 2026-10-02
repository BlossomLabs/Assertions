// SPDX-License-Identifier: MIT
// Exact fresh scalar return packet. Native verification pending.
include "../power-opcode-kernel/Execution.dfy"
module OperationsPowerReturnMemory {
  import M = OperationsSignedMultiplyMachine
  function Heap():seq<M.Byte> { M.Store([],64,128) }
  function Packet(result:M.Word):seq<M.Byte> { M.Store(Heap(),128,result) }
  lemma Layout(result:M.Word)
    ensures |Heap()|==96 && M.Load(Heap(),64)==128
    ensures |Packet(result)|==160 && M.Load(Packet(result),64)==128
    ensures M.Grow(Packet(result),160)==Packet(result)
    ensures Packet(result)[128..160]==M.Encode(result,32)
  {
    M.StoreLoad([],64,128);
    M.StoreLoad(Heap(),128,result);
    M.StoreFrame(Heap(),128,result,64);
  }
}
