// SPDX-License-Identifier: MIT
// Exact public resolver RETURN consumes the original bytes after validator writes.
include "../../constraints/LoopSpec.dfy"
include "../../raw/public/Execution.dfy"
include "../../../scans/Fetch.dfy"
module AssertionsConstrainedPublicReturn {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import C = BytecodeCopyMachine
  import A = AssertionsSignedMachine
  import B = BytecodeCopyMemory
  import Q = AssertionsRawResolveFrame
  import L = AssertionsConstraintLoopSpec
  import U = AssertionsRawPublicExecution
  import F = BytecodeScanFetch
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>) {
    |code| == 20049 && code[1017] == 91 && code[1018] == 144 && code[1019] == 80 &&
    code[1020] == 128 && code[1021] == 81 && code[1022] == 96 && code[1023] == 32 &&
    code[1024] == 130 && code[1025] == 1 && code[1026] == 243
  }
  lemma MemoryFacts(mem: seq<Byte>, ptr: Word, bytes: seq<Byte>, free: Word)
    requires L.Heap(mem,ptr,bytes,free)
    ensures S.Expand(mem,(ptr as nat)+32) == mem
    ensures G.Grow(mem,(ptr as nat)+32+|bytes|) == mem
  { B.Rounded(|mem|); B.RoundedMonotone((ptr as nat)+32,|mem|); }
  function At(index: nat, ptr: Word, bytes: seq<Byte>, prefix: seq<Word>, mem: seq<Byte>): S.State
    requires index <= 9 && |bytes| < G.Modulus() && (ptr as nat)+32 < G.Modulus()
  {
    if index == 0 then S.Running(1017,prefix+[0,ptr],mem)
    else if index == 1 then S.Running(1018,prefix+[0,ptr],mem)
    else if index == 2 then S.Running(1019,prefix+[ptr,0],mem)
    else if index == 3 then S.Running(1020,prefix+[ptr],mem)
    else if index == 4 then S.Running(1021,prefix+[ptr,ptr],mem)
    else if index == 5 then S.Running(1022,prefix+[ptr,|bytes|],mem)
    else if index == 6 then S.Running(1024,prefix+[ptr,|bytes|,32],mem)
    else if index == 7 then S.Running(1025,prefix+[ptr,|bytes|,32,ptr],mem)
    else if index == 8 then S.Running(1026,prefix+[ptr,|bytes|,ptr+32],mem)
    else S.Returned(bytes)
  }
  lemma {:isolate_assertions} Step(index: nat, code: seq<Byte>, ptr: Word, bytes: seq<Byte>, free: Word,
                                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>)
    requires index < 9 && Matches(code) && L.Heap(mem,ptr,bytes,free) && |prefix| <= 990
    ensures M.Step(code,{},At(index,ptr,bytes,prefix,mem),0,data) == At(index+1,ptr,bytes,prefix,mem)
    ensures Q.Local(code,At(index,ptr,bytes,prefix,mem))
  {
    reveal Matches();
    MemoryFacts(mem,ptr,bytes,free);
    F.Push1(code,1022);
    reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step(); reveal G.Step();
  }
  ghost method Run(code: seq<Byte>, ptr: Word, bytes: seq<Byte>, free: Word,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>) returns (states: seq<S.State>)
    requires Matches(code) && L.Heap(mem,ptr,bytes,free) && |prefix| <= 990
    ensures M.Trace(code,{},0,data,states)
    ensures forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==> Q.Local(code,states[i])
    ensures states[0] == S.Running(1017,prefix+[0,ptr],mem) && states[|states|-1] == S.Returned(bytes)
  {
    states := seq(10,i requires 0 <= i < 10 => At(i,ptr,bytes,prefix,mem));
    forall i {:trigger states[i]} | 0 <= i < 9
      ensures M.Step(code,{},states[i],0,data) == states[i+1]
      ensures Q.Local(code,states[i])
    { Step(i,code,ptr,bytes,free,prefix,mem,data); }
  }
}
