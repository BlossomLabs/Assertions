// SPDX-License-Identifier: MIT
include "../address-kernel/Mask.dfy"
include "Memory.dfy"
module BytecodeApplyWrongCallbackScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  import WC = BytecodeApplyWordConversion
  import A = BytecodeApplyAddressMask
  import H = BytecodeApplyWrongCallbackMemory
  function Unit(): S.Word { 0x100000000000000000000000000000000000000000000000000000000 }
  function HighMask(): S.Word { 0xffffffff00000000000000000000000000000000000000000000000000000000 }
  function Operation(): S.Word { 0x7787eb4800000000000000000000000000000000000000000000000000000000 }
  lemma UnitLiteral()
    ensures S.ShiftLeft(1,224) == Unit()
  {
    hide G.Shift();
    reveal S.ShiftLeft();
    SC.ShiftDefinition(1,224);
    SC.Narrow(1);
    var bits: bv256 := 0x100000000000000000000000000000000000000000000000000000000;
    assert (1 as bv256) << 224 == bits;
    assert (bits as nat) == Unit();
  }
  lemma NotLiteral()
    ensures S.BitNot(Unit()-1) == HighMask()
  {
    hide S.BitNot();
    var low: bv256 := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    var high: bv256 := 0xffffffff00000000000000000000000000000000000000000000000000000000;
    WC.Inverse256(low);
    assert (low as nat) == Unit()-1;
    assert ((Unit()-1) as bv256) == low;
    assert !low == high;
    assert (high as nat) == HighMask();
    reveal S.BitNot();
  }
  lemma Literals()
    ensures S.ShiftLeft(1,224) == Unit()
    ensures S.BitNot(Unit()-1) == HighMask()
    ensures S.ShiftLeft(H.Selector(),224) == H.Header()
    ensures S.ShiftLeft(1,160) == A.Bound()
  {
    UnitLiteral();
    NotLiteral();
    reveal S.ShiftLeft();
    SC.ShiftDefinition(H.Selector(),224);
    A.Limit();
  }
  lemma High(bits: bv256,amount: nat)
    requires amount == 224
    ensures (0xffffffff00000000000000000000000000000000000000000000000000000000 & bits) == ((bits >> amount) << amount)
  {}
  lemma GenericRight(a: S.Word,amount: S.Word)
    ensures S.ShiftRight(a,amount) == (if amount >= 256 then 0 else (((a as bv256) >> (amount as nat)) as nat))
  {}
  opaque function ShiftBits(bits: bv256,amount: nat): bv256
    requires amount <= 256
  { bits >> amount }
  lemma ShiftProjection(a: S.Word,amount: S.Word)
    requires amount < 256
    ensures S.ShiftRight(a,amount) == (ShiftBits(a as bv256,amount as nat) as nat)
  { hide S.ShiftRight(); GenericRight(a,amount); reveal ShiftBits(); }
  lemma ShiftHigh(bits: bv256,amount: nat)
    requires amount == 224
    ensures (0xffffffff00000000000000000000000000000000000000000000000000000000 & bits) == (ShiftBits(bits,amount) << amount)
  { reveal ShiftBits(); High(bits,amount); }
  lemma {:autoRevealDependencies false} SelectorBits(a: S.Word,amount: S.Word)
    requires amount == 224 && S.ShiftRight(a,amount) == 2005396296
    ensures ShiftBits(a as bv256,amount as nat) == (2005396296 as bv256)
  {
    hide S.ShiftRight();
    ShiftProjection(a,amount);
    var high := ShiftBits(a as bv256,amount as nat);
    WC.Inverse256(high);
    assert (high as nat) == 2005396296;
  }
  lemma LiteralBits()
    ensures (HighMask() as bv256) == 0xffffffff00000000000000000000000000000000000000000000000000000000
    ensures (Operation() as bv256) == 0x7787eb4800000000000000000000000000000000000000000000000000000000
  {
    var mask: bv256 := 0xffffffff00000000000000000000000000000000000000000000000000000000;
    var operation: bv256 := 0x7787eb4800000000000000000000000000000000000000000000000000000000;
    WC.Inverse256(mask);
    WC.Inverse256(operation);
    assert (mask as nat) == HighMask();
    assert (operation as nat) == Operation();
  }
  lemma {:autoRevealDependencies false} MaskWord(a: S.Word)
    requires S.ShiftRight(a,224) == 2005396296
    ensures G.BitAnd(HighMask(),a) == Operation()
    ensures G.BitAnd(HighMask(),Operation()) == Operation()
  {
    hide G.BitAnd();
    hide S.ShiftRight();
    reveal HighMask(); reveal Operation();
    SelectorBits(a,224);
    LiteralBits();
    var bits := a as bv256;
    ShiftHigh(bits,224);
    assert (0xffffffff00000000000000000000000000000000000000000000000000000000 & bits) == (Operation() as bv256);
    A.Definition(HighMask(),a);
    A.Definition(HighMask(),Operation());
    A.WordIdentity(Operation());
    A.NatEquality((HighMask() as bv256) & bits,Operation() as bv256);
    A.NatEquality((HighMask() as bv256) & (Operation() as bv256),Operation() as bv256);
  }
  lemma OperationMask(data: seq<S.Byte>)
    requires S.ShiftRight(S.DataWord(data,0),224) == 2005396296
    ensures G.BitAnd(HighMask(),S.DataWord(data,0)) == Operation()
    ensures G.BitAnd(HighMask(),Operation()) == Operation()
  {
    hide G.BitAnd();
    hide S.DataWord();
    hide S.ShiftRight();
    MaskWord(S.DataWord(data,0));
  }
}
