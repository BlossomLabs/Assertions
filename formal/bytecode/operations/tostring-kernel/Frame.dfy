// SPDX-License-Identifier: MIT
// Pure preservation of allocated prefix bytes; native proof pending.
include "../casefold-machine/Memory.dfy"
include "../../scans/Representation.dfy"
module OperationsToStringFrame {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import F = OperationsCaseFoldMachine
  import P = OperationsCaseFoldMemory
  import R = BytecodeScanRepresentation
  predicate Stable(before:seq<S.Byte>,after:seq<S.Byte>,limit:nat) {
    96<=limit<=|before| && limit<=|after| && before[96..limit]==after[96..limit]
  }
  lemma Same(mem:seq<S.Byte>,limit:nat)
    requires 96<=limit<=|mem|
    ensures Stable(mem,mem,limit)
  {}
  lemma Trim(before:seq<S.Byte>,after:seq<S.Byte>,limit:nat,shorter:nat)
    requires Stable(before,after,limit) && 96<=shorter<=limit
    ensures Stable(before,after,shorter)
  { assert before[96..shorter]==before[96..limit][..shorter-96];assert after[96..shorter]==after[96..limit][..shorter-96]; }
  lemma Chain(a:seq<S.Byte>,b:seq<S.Byte>,c:seq<S.Byte>,limit:nat)
    requires Stable(a,b,limit) && Stable(b,c,limit)
    ensures Stable(a,c,limit)
  {}
  lemma Store(mem:seq<S.Byte>,at:S.Word,value:S.Word,limit:nat)
    requires 96<=limit<=|mem| && (at+32<=96 || limit<=at)
    ensures Stable(mem,S.Store(mem,at,value),limit)
  {
    var next:=S.Store(mem,at,value);var expanded:=S.Expand(mem,at+32);
    assert expanded[..|mem|]==mem;
    assert |next|>=|mem|;
    forall i:nat {:trigger next[i]} | 96<=i<limit ensures next[i]==mem[i] {
      if i<at { assert next[i]==expanded[i]; } else { assert at+32<=i;assert next[i]==expanded[i]; }
    }
  }
  lemma Calldata(mem:seq<S.Byte>,dst:S.Word,src:S.Word,count:S.Word,data:seq<S.Byte>,limit:nat)
    requires 96<=limit<=|mem| && limit<=dst
    ensures Stable(mem,C.Calldata(mem,dst,src,count,data),limit)
  {
    C.Size(mem,dst,S.Window(data,src,count));C.Frame(mem,dst,S.Window(data,src,count));
    var next:=C.Calldata(mem,dst,src,count,data);
    forall i:nat {:trigger next[i]} | 96<=i<limit ensures next[i]==mem[i] {}
  }
  lemma Store8(mem:seq<S.Byte>,at:S.Word,byte:S.Byte,limit:nat)
    requires 96<=limit<=|mem| && limit<=at<|mem| && |mem|%32==0
    ensures Stable(mem,F.Store8(mem,at,byte),limit)
  {
    P.InBounds(mem,at,byte);var next:=F.Store8(mem,at,byte);
    forall i:nat {:trigger next[i]} | 96<=i<limit ensures next[i]==mem[i] { P.Frame(mem,at,byte,i); }
  }
}
