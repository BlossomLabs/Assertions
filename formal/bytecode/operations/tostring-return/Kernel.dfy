// SPDX-License-Identifier: MIT
// Pure memory bridge for reached generic bytes/string serialization; native pending.
include "../dynamic-return-shared/DynamicReturnMemory.dfy"
include "../dynamic-return-shared/MemoryTranslation.dfy"
include "../dynamic-return-shared/RoundMask.dfy"
include "../casefold-machine/Execution.dfy"
module OperationsToStringReturnKernel {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import A = OperationsCodeMachine
  import AM = OperationsCodeMemory
  import D = OperationsDynamicReturnMemory
  import T = OperationsSerializerMemoryTranslation
  import RM = OperationsCodeRoundMask
  import CM = OperationsCodeConstantMask
  predicate Layout(mem:seq<S.Byte>,body:seq<S.Byte>,base:S.Word,free:S.Word) {
    |mem|%32==0 && |mem|<G.Modulus() && D.Layout(mem,body,base,free)
  }
  function Head(mem:seq<S.Byte>,body:seq<S.Byte>,base:S.Word,free:S.Word):seq<S.Byte>
    requires Layout(mem,body,base,free)
  { S.Store(mem,free,32) }
  function Length(mem:seq<S.Byte>,body:seq<S.Byte>,base:S.Word,free:S.Word):seq<S.Byte>
    requires Layout(mem,body,base,free)
  { S.Store(Head(mem,body,base,free),free+32,|body|) }
  function Payload(mem:seq<S.Byte>,body:seq<S.Byte>,base:S.Word,free:S.Word):seq<S.Byte>
    requires Layout(mem,body,base,free)
  { C.Memory(Length(mem,body,base,free),free+64,base+32,|body|) }
  function Final(mem:seq<S.Byte>,body:seq<S.Byte>,base:S.Word,free:S.Word):seq<S.Byte>
    requires Layout(mem,body,base,free)
  { S.Store(Payload(mem,body,base,free),free+64+|body|,0) }
  function Canonical(body:seq<S.Byte>):seq<S.Byte> {
    G.Encode(32,32)+G.Encode(|body|,32)+body+seq(S.Round32(|body|)-|body|,i => 0)
  }
  lemma Stages(mem:seq<S.Byte>,body:seq<S.Byte>,base:S.Word,free:S.Word)
    requires Layout(mem,body,base,free)
    ensures D.Head(mem,body,base,free)==Head(mem,body,base,free)
    ensures D.Length(mem,body,base,free)==Length(mem,body,base,free)
    ensures D.Payload(mem,body,base,free)==Payload(mem,body,base,free)
    ensures D.Final(mem,body,base,free)==Final(mem,body,base,free)
    ensures S.Load(mem,64)==free && S.Load(mem,base)==|body|
    ensures S.Expand(mem,96)==mem
    ensures |Head(mem,body,base,free)|%32==0 && |Head(mem,body,base,free)|<G.Modulus()
    ensures |Length(mem,body,base,free)|%32==0 && |Length(mem,body,base,free)|<G.Modulus()
    ensures |Payload(mem,body,base,free)|%32==0 && |Payload(mem,body,base,free)|<G.Modulus()
    ensures |Final(mem,body,base,free)|%32==0 && |Final(mem,body,base,free)|<G.Modulus()
    ensures S.Load(Head(mem,body,base,free),base)==|body|
    ensures S.Expand(Head(mem,body,base,free),base+32)==Head(mem,body,base,free)
    ensures S.Load(Final(mem,body,base,free),64)==free
    ensures S.Expand(Final(mem,body,base,free),96)==Final(mem,body,base,free)
    ensures |Final(mem,body,base,free)|>=free+64+S.Round32(|body|)
    ensures S.Window(Final(mem,body,base,free),free,64+S.Round32(|body|))==Canonical(body)
  {
    AM.RoundedBound(free+32);T.Store(mem,free,32);
    AM.RoundedBound(free+64);T.Store(Head(mem,body,base,free),free+32,|body|);
    AM.RoundedBound(free+64+|body|);T.Copy(Length(mem,body,base,free),free+64,base+32,|body|);
    AM.RoundedBound(free+96+|body|);T.Store(Payload(mem,body,base,free),free+64+|body|,0);
    D.ExactSource(mem,body,base,free);D.ExactReturn(mem,body,base,free);
    T.Load(mem,64);T.Load(mem,base);T.Load(Head(mem,body,base,free),base);T.Load(Final(mem,body,base,free),64);
    T.WindowSlice(Final(mem,body,base,free),free,64+S.Round32(|body|));T.Encode(32,32);T.Encode(|body|,32);T.Round(|body|);
  }
  lemma Mask()
    ensures S.BitNot(31)==G.Modulus()-32
  { CM.MaskNat256();CM.BitsMask256();assert !(31 as bv256)==CM.Mask256();RM.NatEquality(!(31 as bv256),CM.Mask256()); }
  lemma Round(length:S.Word)
    requires length<0x10000000000000000
    ensures G.BitAnd(length+31,G.Modulus()-32)==S.Round32(length)
  { RM.Exact(length);RM.BitAndDef(length+31,G.Modulus()-32);T.Round(length); }
}
