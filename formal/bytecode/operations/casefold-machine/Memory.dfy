// SPDX-License-Identifier: MIT
// Exact MSTORE8 expansion and original-byte frames; native pending.
include "Machine.dfy"
include "../../copy/Memory.dfy"
module OperationsCaseFoldMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import F = OperationsCaseFoldMachine
  lemma Write(mem:seq<S.Byte>,offset:S.Word,value:S.Word)
    ensures F.Store8(mem,offset,value)==C.Write(mem,offset,[value%256])
    ensures F.Store8(mem,offset,value)[offset]==value%256
    ensures |F.Store8(mem,offset,value)|==(if |mem|>=S.Round32((offset as nat)+1) then |mem| else S.Round32((offset as nat)+1))
  { C.Rounded((offset as nat)+1);C.Span(mem,offset,[value%256]);C.Size(mem,offset,[value%256]); }
  lemma Frame(mem:seq<S.Byte>,offset:S.Word,value:S.Word,index:nat)
    requires index<|mem| && index!=offset
    ensures F.Store8(mem,offset,value)[index]==mem[index]
  { Write(mem,offset,value);C.Frame(mem,offset,[value%256]); }
  lemma InBounds(mem:seq<S.Byte>,offset:S.Word,value:S.Word)
    requires offset<|mem| && |mem|%32==0
    ensures |F.Store8(mem,offset,value)|==|mem|
    ensures F.Store8(mem,offset,value)==mem[offset:=value%256]
  { Write(mem,offset,value);C.Rounded((offset as nat)+1);C.RoundedMonotone((offset as nat)+1,|mem|);
    forall index:nat {:trigger F.Store8(mem,offset,value)[index]} | index<|mem|
      ensures F.Store8(mem,offset,value)[index]==(if index==offset then value%256 else mem[index])
    { if index!=offset { Frame(mem,offset,value,index); } }
  }
}
