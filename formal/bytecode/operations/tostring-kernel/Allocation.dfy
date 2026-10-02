// SPDX-License-Identifier: MIT
// Exact decimal array allocation and conservative resources; native proof pending.
include "FillMemory.dfy"
include "../dynamic-return-shared/RoundMask.dfy"
include "../dynamic-return-shared/MemoryTranslation.dfy"
module OperationsToStringAllocation {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import I = OperationsToStringInputs
  import D = OperationsToStringDecimal
  import K = OperationsToStringFillMemory
  import RM = OperationsCodeRoundMask
  import CM = OperationsCodeConstantMask
  import T = OperationsSerializerMemoryTranslation
  import H = OperationsToStringFrame
  predicate Input(mem:seq<S.Byte>,data:seq<S.Byte>,base:S.Word,original:S.Word) {
    I.Frame(data) && 96<=|mem| && |mem|%32==0 && |mem|<=base && base>=128 && base%32==0 &&
    base+206<G.Modulus() && original>0 && D.Steps(original)<=78 && S.Load(mem,64)==base
  }
  function Free(base:S.Word,length:S.Word):S.Word
    requires base+206<G.Modulus() && length<=78
  { base+32+S.Round32(length) }
  function Header(mem:seq<S.Byte>,base:S.Word,length:S.Word):seq<S.Byte> { S.Store(mem,base,length) }
  function Allocated(mem:seq<S.Byte>,base:S.Word,length:S.Word):seq<S.Byte>
    requires base+206<G.Modulus() && length<=78
  { S.Store(Header(mem,base,length),64,Free(base,length)) }
  function Initial(mem:seq<S.Byte>,data:seq<S.Byte>,base:S.Word,length:S.Word):seq<S.Byte>
    requires base+206<G.Modulus() && length<=78 && I.Frame(data)
  { C.Calldata(Allocated(mem,base,length),base+32,|data|,length,data) }
  lemma Mask()
    ensures S.BitNot(31)==G.Modulus()-32
  { CM.MaskNat256();CM.BitsMask256();assert !(31 as bv256)==CM.Mask256();RM.NatEquality(!(31 as bv256),CM.Mask256()); }
  lemma Round(length:S.Word)
    requires length<=78
    ensures G.BitAnd(length+31,G.Modulus()-32)==S.Round32(length)
  { RM.Exact(length);RM.BitAndDef(length+31,G.Modulus()-32);T.Round(length); }
  lemma Load(mem:seq<S.Byte>,data:seq<S.Byte>,base:S.Word,original:S.Word)
    requires Input(mem,data,base,original)
    ensures S.Expand(mem,96)==mem
  {
    C.RoundedMonotone(96,|mem|);
  }
  lemma CopiedLoad(mem:seq<S.Byte>,dst:S.Word,count:S.Word,data:seq<S.Byte>,at:S.Word)
    requires I.Frame(data) && at+32<=|mem| && at+32<=dst
    ensures S.Load(C.Calldata(mem,dst,|data|,count,data),at)==S.Load(mem,at)
  {
    var next:=C.Calldata(mem,dst,|data|,count,data);
    C.Size(mem,dst,S.Window(data,|data|,count));C.Frame(mem,dst,S.Window(data,|data|,count));
    assert next[at..at+32]==mem[at..at+32] by {
      forall j:nat {:trigger next[at+j]} | j<32 ensures next[at+j]==mem[at+j] {}
    }
    R.WordProjection(mem,at);R.WordProjection(next,at);R.WindowFits(mem,at,32);R.WindowFits(next,at,32);
  }
  lemma Begin(mem:seq<S.Byte>,data:seq<S.Byte>,base:S.Word,original:S.Word)
    requires Input(mem,data,base,original)
    ensures K.Inv(Initial(mem,data,base,D.Steps(original)),base,original,original,D.Steps(original))
    ensures H.Stable(mem,Initial(mem,data,base,D.Steps(original)),|mem|)
    ensures |Initial(mem,data,base,D.Steps(original))|==Free(base,D.Steps(original))
  {
    D.WordDigits(original);D.Length(original);C.Rounded(D.Steps(original));
    var length:S.Word:=D.Steps(original);
    R.StoredWord(mem,base,length);R.StoredWord(Header(mem,base,length),64,Free(base,length));
    R.StoredFrame(Header(mem,base,length),64,Free(base,length),base);
    assert S.Round32(base+32)==base+32;
    var middle:=Allocated(mem,base,length);
    CopiedLoad(middle,base+32,length,data,base);CopiedLoad(middle,base+32,length,data,64);
    C.Size(middle,base+32,S.Window(data,|data|,length));
    assert S.Round32(base+32+length)==base+32+S.Round32(length);
    var final:=Initial(mem,data,base,length);
    assert K.Ready(final,base,length);
    D.FillBegin(K.Payload(final,base,length),original);
    H.Store(mem,base,length,|mem|);H.Store(Header(mem,base,length),64,Free(base,length),|mem|);
    H.Chain(mem,Header(mem,base,length),middle,|mem|);H.Calldata(middle,base+32,|data|,length,data,|mem|);H.Chain(mem,middle,final,|mem|);
  }
}
