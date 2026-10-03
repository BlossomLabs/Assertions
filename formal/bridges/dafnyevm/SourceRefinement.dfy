// SPDX-License-Identifier: MIT
include "FoundationRefinement.dfy"
include "../../foundations/SourceSequenceMemoryV1.dfy"
include "../../source/assertions/constraints/Model.dfy"
include "../../source/assertions/resolution/Words.dfy"
include "../../source/operations/scalars/Model.dfy"
include "../../source/collections/word-memory/Model.dfy"
include "../../source/operations/full-mul-div/Memory.dfy"
include "../../source/operations/modular-power/Memory.dfy"

// Bind equivalence to the actual rewritten declarations, not only to adapters.
module EvmSourceRefinement {
  import R = EvmFoundationRefinement
  import E = EvmEncoding
  import F = AbiFrames
  import C = ConstraintModel
  import W = ResolutionWords
  import Q = SourceSequenceMemoryV1
  import S = OperationsScalarModel
  import M = CollectionsWordMemoryModel
  import D = OperationsFullMulDivMemory
  import P = OperationsModularPowerMemory
  import V = EvmValues
  import Int

  lemma ConstraintRead(data: seq<C.Byte>)
    ensures C.Read(data) == R.ReadReference(data)
  { reveal C.Read(); R.ReadPreserved(data); }

  lemma ConstraintSigned(w: C.Word)
    ensures C.Signed(w) == (if w < Int.TWO_255 then w as int else w as int-Int.TWO_256)
  { reveal C.Signed(); R.SignedPreserved(w); }

  lemma SerializedWord(w: C.Word)
    ensures W.EncodeWord(w) == F.Word(w)
  { E.WordSame(w); }

  lemma SequenceCopy<T>(memory: seq<T>, address: nat, data: seq<T>)
    requires address+|data| <= |memory|
    ensures Q.Replace(memory,address,data) == memory[..address]+data+memory[address+|data|..]
  { R.CopyPreserved(memory,address,data); }

  lemma ScalarDivision(a: int, b: int)
    ensures S.Abs(a) == (if a < 0 then -a else a)
    ensures S.Trunc(a,b) == (if b == 0 then 0 else if (a < 0) != (b < 0) then -(S.Abs(a)/S.Abs(b)) else S.Abs(a)/S.Abs(b))
    ensures S.Rem(a,b) == a-S.Trunc(a,b)*b
  { R.TruncPreserved(a,b); }

  lemma ScalarBits(a: int, b: int)
    requires S.Word(a) && S.Word(b)
    ensures S.And(a,b) == (((a as bv256)&(b as bv256)) as int)
    ensures S.Or(a,b) == (((a as bv256)|(b as bv256)) as int)
    ensures S.Xor(a,b) == (((a as bv256)^(b as bv256)) as int)
  { R.BitwisePreserved(a,b); }

  lemma CollectionArithmetic(a: nat, b: nat)
    ensures M.Add(a,b) == (a+b) % F.Pow256(32)
    ensures M.Mul(a,b) == (a*b) % F.Pow256(32)
  {}

  lemma CollectionLoad(memory: seq<F.Byte>, address: nat)
    requires address+32 <= |memory|
    ensures M.Load(memory,address) == F.ReadNat(memory[address..address+32])
  { E.LoadSame(memory,address); }

  lemma CollectionStore(memory: seq<F.Byte>, address: nat, value: nat)
    requires address+32 <= |memory|
    ensures M.Store(memory,address,value) == memory[..address]+F.Word(value)+memory[address+32..]
  { R.StorePreserved(memory,address,value); }

  lemma FullMultiplyStore(memory: seq<nat>, offset: nat, value: nat)
    requires offset+32 <= |memory|
    ensures D.Store(memory,offset,value) == memory[..offset]+D.Word(value)+memory[offset+32..]
  { R.CopyPreserved(memory,offset,D.Word(value)); }

  lemma ModularStore(memory: seq<nat>, offset: nat, value: nat)
    requires P.Bytes(memory) && value < 0x10000000000000000000000000000000000000000000000000000000000000000
    requires offset+32 <= |memory|
    ensures P.Store(memory,offset,value) == memory[..offset]+P.Word(value)+memory[offset+32..]
  { R.CopyPreserved(memory,offset,P.Word(value)); }

  lemma ModularReply(memory: seq<nat>, offset: nat, data: seq<nat>)
    requires P.Bytes(memory) && P.Bytes(data) && offset+32 <= |memory|
    ensures P.CopyReply(memory,offset,data) == memory[..offset]+data[..(if |data| < 32 then |data| else 32)]+memory[offset+(if |data| < 32 then |data| else 32)..]
  { R.CopyPreserved(memory,offset,data[..(if |data| < 32 then |data| else 32)]); }
}
