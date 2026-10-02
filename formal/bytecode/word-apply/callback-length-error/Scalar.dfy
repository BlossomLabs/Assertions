// SPDX-License-Identifier: MIT
// Compiler-bound operation header for either public map/filter entry.
include "../callback-result-error/Scalar.dfy"
module BytecodeApplyCallbackLengthScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  import WC = BytecodeApplyWordConversion
  function MapOperation(): S.Word { 0xed6dc3be00000000000000000000000000000000000000000000000000000000 }
  function Operation(filter: bool): S.Word { if filter then SC.Operation() else MapOperation() }
  function Selector(filter: bool): S.Word { if filter then 2005396296 else 3983393726 }
  lemma MapBits()
    ensures (MapOperation() as bv256) == 0xed6dc3be00000000000000000000000000000000000000000000000000000000
  {
    var bits: bv256 := 0xed6dc3be00000000000000000000000000000000000000000000000000000000;
    WC.Inverse256(bits);
    assert (bits as nat) == MapOperation();
  }
  lemma {:autoRevealDependencies false} MapSelector(a: S.Word,amount: S.Word)
    requires amount == 224 && S.ShiftRight(a,amount) == 3983393726
    ensures SC.ShiftBits(a as bv256,amount as nat) == (3983393726 as bv256)
  {
    hide S.ShiftRight();
    SC.ShiftProjection(a,amount);
    var high := SC.ShiftBits(a as bv256,amount as nat);
    WC.Inverse256(high);
    assert (high as nat) == 3983393726;
  }
  lemma {:autoRevealDependencies false} MapMask(a: S.Word)
    requires S.ShiftRight(a,224) == 3983393726
    ensures G.BitAnd(SC.HighMask(),a) == MapOperation()
    ensures G.BitAnd(SC.HighMask(),MapOperation()) == MapOperation()
  {
    hide G.BitAnd(); hide S.ShiftRight();
    reveal SC.HighMask(); reveal MapOperation();
    MapSelector(a,224);
    MapBits(); SC.LiteralBits();
    var bits := a as bv256;
    SC.ShiftHigh(bits,224);
    assert (0xffffffff00000000000000000000000000000000000000000000000000000000 & bits) == (MapOperation() as bv256);
    A.Definition(SC.HighMask(),a);
    A.Definition(SC.HighMask(),MapOperation());
    A.WordIdentity(MapOperation());
    A.NatEquality((SC.HighMask() as bv256) & bits,MapOperation() as bv256);
    A.NatEquality((SC.HighMask() as bv256) & (MapOperation() as bv256),MapOperation() as bv256);
  }
  lemma Mask(filter: bool,data: seq<S.Byte>)
    requires S.ShiftRight(S.DataWord(data,0),224) == Selector(filter)
    ensures G.BitAnd(SC.HighMask(),S.DataWord(data,0)) == Operation(filter)
    ensures G.BitAnd(SC.HighMask(),Operation(filter)) == Operation(filter)
  {
    hide G.BitAnd(); hide S.DataWord(); hide S.ShiftRight();
    if filter { SC.OperationMask(data); }
    else { MapMask(S.DataWord(data,0)); }
  }
}
