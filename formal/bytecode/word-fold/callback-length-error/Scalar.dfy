// SPDX-License-Identifier: MIT
// Compiler-bound operation header for either public map/filter entry.
include "../../word-apply/callback-result-error/Scalar.dfy"
module BytecodeFoldCallbackLengthScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  import WC = BytecodeApplyWordConversion
  function RangeOperation(): S.Word { 0xf1d88dc800000000000000000000000000000000000000000000000000000000 }
  lemma RangeBits()
    ensures (RangeOperation() as bv256) == 0xf1d88dc800000000000000000000000000000000000000000000000000000000
  {
    var bits: bv256 := 0xf1d88dc800000000000000000000000000000000000000000000000000000000;
    WC.Inverse256(bits);
    assert (bits as nat) == RangeOperation();
  }
  lemma {:autoRevealDependencies false} RangeSelector(a: S.Word,amount: S.Word)
    requires amount == 224 && S.ShiftRight(a,amount) == 4057501128
    ensures SC.ShiftBits(a as bv256,amount as nat) == (4057501128 as bv256)
  {
    hide S.ShiftRight();
    SC.ShiftProjection(a,amount);
    var high := SC.ShiftBits(a as bv256,amount as nat);
    WC.Inverse256(high);
    assert (high as nat) == 4057501128;
  }
  lemma {:autoRevealDependencies false} RangeMask(a: S.Word)
    requires S.ShiftRight(a,224) == 4057501128
    ensures G.BitAnd(SC.HighMask(),a) == RangeOperation()
    ensures G.BitAnd(SC.HighMask(),RangeOperation()) == RangeOperation()
  {
    hide G.BitAnd(); hide S.ShiftRight();
    reveal SC.HighMask(); reveal RangeOperation();
    RangeSelector(a,224);
    RangeBits(); SC.LiteralBits();
    var bits := a as bv256;
    SC.ShiftHigh(bits,224);
    assert (0xffffffff00000000000000000000000000000000000000000000000000000000 & bits) == (RangeOperation() as bv256);
    A.Definition(SC.HighMask(),a);
    A.Definition(SC.HighMask(),RangeOperation());
    A.WordIdentity(RangeOperation());
    A.NatEquality((SC.HighMask() as bv256) & bits,RangeOperation() as bv256);
    A.NatEquality((SC.HighMask() as bv256) & (RangeOperation() as bv256),RangeOperation() as bv256);
  }
  function BytesOperation(): S.Word { 0x6d24e79c00000000000000000000000000000000000000000000000000000000 }
  lemma BytesBits()
    ensures (BytesOperation() as bv256) == 0x6d24e79c00000000000000000000000000000000000000000000000000000000
  {
    var bits: bv256 := 0x6d24e79c00000000000000000000000000000000000000000000000000000000;
    WC.Inverse256(bits);
    assert (bits as nat) == BytesOperation();
  }
  lemma {:autoRevealDependencies false} BytesSelector(a: S.Word,amount: S.Word)
    requires amount == 224 && S.ShiftRight(a,amount) == 1831135132
    ensures SC.ShiftBits(a as bv256,amount as nat) == (1831135132 as bv256)
  {
    hide S.ShiftRight();
    SC.ShiftProjection(a,amount);
    var high := SC.ShiftBits(a as bv256,amount as nat);
    WC.Inverse256(high);
    assert (high as nat) == 1831135132;
  }
  lemma {:autoRevealDependencies false} BytesMask(a: S.Word)
    requires S.ShiftRight(a,224) == 1831135132
    ensures G.BitAnd(SC.HighMask(),a) == BytesOperation()
    ensures G.BitAnd(SC.HighMask(),BytesOperation()) == BytesOperation()
  {
    hide G.BitAnd(); hide S.ShiftRight();
    reveal SC.HighMask(); reveal BytesOperation();
    BytesSelector(a,224);
    BytesBits(); SC.LiteralBits();
    var bits := a as bv256;
    SC.ShiftHigh(bits,224);
    assert (0xffffffff00000000000000000000000000000000000000000000000000000000 & bits) == (BytesOperation() as bv256);
    A.Definition(SC.HighMask(),a);
    A.Definition(SC.HighMask(),BytesOperation());
    A.WordIdentity(BytesOperation());
    A.NatEquality((SC.HighMask() as bv256) & bits,BytesOperation() as bv256);
    A.NatEquality((SC.HighMask() as bv256) & (BytesOperation() as bv256),BytesOperation() as bv256);
  }
  function WordsOperation(): S.Word { 0x6de60cb000000000000000000000000000000000000000000000000000000000 }
  lemma WordsBits()
    ensures (WordsOperation() as bv256) == 0x6de60cb000000000000000000000000000000000000000000000000000000000
  {
    var bits: bv256 := 0x6de60cb000000000000000000000000000000000000000000000000000000000;
    WC.Inverse256(bits);
    assert (bits as nat) == WordsOperation();
  }
  lemma {:autoRevealDependencies false} WordsSelector(a: S.Word,amount: S.Word)
    requires amount == 224 && S.ShiftRight(a,amount) == 1843793072
    ensures SC.ShiftBits(a as bv256,amount as nat) == (1843793072 as bv256)
  {
    hide S.ShiftRight();
    SC.ShiftProjection(a,amount);
    var high := SC.ShiftBits(a as bv256,amount as nat);
    WC.Inverse256(high);
    assert (high as nat) == 1843793072;
  }
  lemma {:autoRevealDependencies false} WordsMask(a: S.Word)
    requires S.ShiftRight(a,224) == 1843793072
    ensures G.BitAnd(SC.HighMask(),a) == WordsOperation()
    ensures G.BitAnd(SC.HighMask(),WordsOperation()) == WordsOperation()
  {
    hide G.BitAnd(); hide S.ShiftRight();
    reveal SC.HighMask(); reveal WordsOperation();
    WordsSelector(a,224);
    WordsBits(); SC.LiteralBits();
    var bits := a as bv256;
    SC.ShiftHigh(bits,224);
    assert (0xffffffff00000000000000000000000000000000000000000000000000000000 & bits) == (WordsOperation() as bv256);
    A.Definition(SC.HighMask(),a);
    A.Definition(SC.HighMask(),WordsOperation());
    A.WordIdentity(WordsOperation());
    A.NatEquality((SC.HighMask() as bv256) & bits,WordsOperation() as bv256);
    A.NatEquality((SC.HighMask() as bv256) & (WordsOperation() as bv256),WordsOperation() as bv256);
  }
  function Selector(domain: nat): S.Word { if domain == 0 then 4057501128 else if domain == 1 then 1831135132 else 1843793072 }
  function Operation(domain: nat): S.Word { if domain == 0 then RangeOperation() else if domain == 1 then BytesOperation() else WordsOperation() }
  lemma Mask(domain: nat,data: seq<S.Byte>)
    requires domain < 3 && S.ShiftRight(S.DataWord(data,0),224) == Selector(domain)
    ensures G.BitAnd(SC.HighMask(),S.DataWord(data,0)) == Operation(domain)
    ensures G.BitAnd(SC.HighMask(),Operation(domain)) == Operation(domain)
  {
    hide G.BitAnd();hide S.DataWord();hide S.ShiftRight();
    if domain == 0 { RangeMask(S.DataWord(data,0)); }
    else if domain == 1 { BytesMask(S.DataWord(data,0)); }
    else { WordsMask(S.DataWord(data,0)); }
  }
}
