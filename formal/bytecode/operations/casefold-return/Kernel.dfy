// SPDX-License-Identifier: MIT
// Explicit pure translation of reached dynamic-return memory; native pending.
include "../casefold-machine/Kernel.dfy"
include "../dynamic-return-shared/DynamicReturnMemory.dfy"
include "../dynamic-return-shared/MemoryTranslation.dfy"
include "../dynamic-return-shared/RoundMask.dfy"
module OperationsCaseFoldReturnKernel {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import I = OperationsCaseFoldInputs
  import K = OperationsCaseFoldKernel
  import A = OperationsCodeMachine
  import AM = OperationsCodeMemory
  import D = OperationsDynamicReturnMemory
  import T = OperationsSerializerMemoryTranslation
  import RM = OperationsCodeRoundMask
  import CM = OperationsCodeConstantMask
  function Body(data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool):seq<S.Byte>
    requires K.Input(data,offset,length)
  { seq(length,i requires 0<=i<length => I.Fold(lower,data[offset+i])) }
  predicate Layout(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool) {
    K.Inv(mem,data,offset,length,length,lower) && D.Layout(mem,Body(data,offset,length,lower),128,K.Free(length))
  }
  lemma SourceLayout(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool)
    requires K.Inv(mem,data,offset,length,length,lower)
    ensures Layout(mem,data,offset,length,lower)
  {
    T.Load(mem,64);T.Load(mem,128);T.Round(length);
    forall i:nat {:trigger mem[160+i]} | i<length
      ensures mem[160+i]==Body(data,offset,length,lower)[i]
    {}
    assert mem[160..160+length]==Body(data,offset,length,lower);
  }
  function Head(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool):seq<S.Byte>
    requires Layout(mem,data,offset,length,lower)
  { S.Store(mem,K.Free(length),32) }
  function Length(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool):seq<S.Byte>
    requires Layout(mem,data,offset,length,lower)
  { S.Store(Head(mem,data,offset,length,lower),K.Free(length)+32,length) }
  function Payload(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool):seq<S.Byte>
    requires Layout(mem,data,offset,length,lower)
  { C.Memory(Length(mem,data,offset,length,lower),K.Free(length)+64,160,length) }
  function Final(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool):seq<S.Byte>
    requires Layout(mem,data,offset,length,lower)
  { S.Store(Payload(mem,data,offset,length,lower),K.Free(length)+64+length,0) }
  function Canonical(body:seq<S.Byte>):seq<S.Byte> {
    G.Encode(32,32)+G.Encode(|body|,32)+body+seq(S.Round32(|body|)-|body|,i => 0)
  }
  lemma Stages(mem:seq<S.Byte>,data:seq<S.Byte>,offset:S.Word,length:S.Word,lower:bool)
    requires Layout(mem,data,offset,length,lower)
    ensures D.Head(mem,Body(data,offset,length,lower),128,K.Free(length))==Head(mem,data,offset,length,lower)
    ensures D.Length(mem,Body(data,offset,length,lower),128,K.Free(length))==Length(mem,data,offset,length,lower)
    ensures D.Payload(mem,Body(data,offset,length,lower),128,K.Free(length))==Payload(mem,data,offset,length,lower)
    ensures D.Final(mem,Body(data,offset,length,lower),128,K.Free(length))==Final(mem,data,offset,length,lower)
    ensures |Head(mem,data,offset,length,lower)|%32==0 && |Head(mem,data,offset,length,lower)|<G.Modulus()
    ensures |Length(mem,data,offset,length,lower)|%32==0 && |Length(mem,data,offset,length,lower)|<G.Modulus()
    ensures |Payload(mem,data,offset,length,lower)|%32==0 && |Payload(mem,data,offset,length,lower)|<G.Modulus()
    ensures |Final(mem,data,offset,length,lower)|%32==0 && |Final(mem,data,offset,length,lower)|<G.Modulus()
    ensures S.Load(Head(mem,data,offset,length,lower),128)==length
    ensures S.Load(Final(mem,data,offset,length,lower),64)==K.Free(length)
    ensures |Final(mem,data,offset,length,lower)|>=K.Free(length)+64+S.Round32(length)
    ensures S.Window(Final(mem,data,offset,length,lower),K.Free(length),64+S.Round32(length))==Canonical(Body(data,offset,length,lower))
  {
    SourceLayout(mem,data,offset,length,lower);
    var body:=Body(data,offset,length,lower);var f:=K.Free(length);
    AM.RoundedBound(length);AM.RoundedBound(f+32);
    T.Store(mem,f,32);
    AM.RoundedBound(f+64);T.Store(Head(mem,data,offset,length,lower),f+32,length);
    AM.RoundedBound(f+64+length);T.Copy(Length(mem,data,offset,length,lower),f+64,160,length);
    AM.RoundedBound(f+96+length);T.Store(Payload(mem,data,offset,length,lower),f+64+length,0);
    D.ExactSource(mem,body,128,f);D.ExactReturn(mem,body,128,f);
    T.Load(Head(mem,data,offset,length,lower),128);T.Load(Final(mem,data,offset,length,lower),64);
    T.WindowSlice(Final(mem,data,offset,length,lower),f,64+S.Round32(length));
    T.Encode(32,32);T.Encode(length,32);T.Round(length);
  }
  lemma Mask()
    ensures S.BitNot(31)==G.Modulus()-32
  { CM.MaskNat256();CM.BitsMask256();assert !(31 as bv256)==CM.Mask256();RM.NatEquality(!(31 as bv256),CM.Mask256()); }
  lemma Round(length:S.Word)
    requires length<I.U64
    ensures G.BitAnd(length+31,G.Modulus()-32)==S.Round32(length)
  { RM.Exact(length);RM.BitAndDef(length+31,G.Modulus()-32);T.Round(length); }
}
