// SPDX-License-Identifier: MIT
include "../../opcode-kernels/And.dfy"
include "../../alignment/Mask.dfy"
module BytecodeApplyCallbackSuccessScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeOpcodeAnd
  import AM = BytecodeWordLengthMask
  lemma Not31()
    ensures S.BitNot(31) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
  {}
  lemma MaskLiteral()
    ensures G.BitAnd(95,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) == 64
  { hide G.BitAnd(); AM.Mask(2); Not31(); }
  lemma Append(prefix: seq<S.Word>,tail: seq<S.Word>,more: seq<S.Word>)
    ensures (prefix+tail)+more == prefix+(tail+more)
  {
    var lhs := (prefix+tail)+more; var rhs := prefix+(tail+more);
    assert |lhs| == |rhs|;
    forall i: nat | i < |lhs|
      ensures lhs[i] == rhs[i]
    { if i < |prefix| {} else if i < |prefix|+|tail| {} else {} }
  }
  lemma At(code: seq<S.Byte>,destinations: set<nat>,prefix: seq<S.Word>,mem: seq<S.Byte>,value: S.Word,data: seq<S.Byte>)
    requires |code| > 16972 && code[16972] == 0x16 && |prefix| <= 1022
    ensures S.Step(code,destinations,S.Running(16972,prefix+[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,95],mem),value,data) == S.Running(16973,prefix+[64],mem)
  {
    hide G.BitAnd(); MaskLiteral();
    O.Step(code,destinations,16972,prefix,mem,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,95,value,data);
  }
  lemma Fourteen(prefix: seq<S.Word>,a0: S.Word,a1: S.Word,a2: S.Word,a3: S.Word,a4: S.Word,a5: S.Word,a6: S.Word,a7: S.Word,a8: S.Word,a9: S.Word,a10: S.Word,a11: S.Word,a12: S.Word,a13: S.Word)
    ensures (prefix+[a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10])+[a11,a12,a13] == prefix+[a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13]
  {
    var lhs := (prefix+[a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10])+[a11,a12,a13]; var rhs := prefix+[a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13];
    assert |lhs| == |rhs|;
    forall index: nat | index < |lhs|
      ensures lhs[index] == rhs[index]
    {
      if index < |prefix| {}
      else {
        if index == |prefix|+0 { assert lhs[index] == a0; assert rhs[index] == a0; }
        else if index == |prefix|+1 { assert lhs[index] == a1; assert rhs[index] == a1; }
        else if index == |prefix|+2 { assert lhs[index] == a2; assert rhs[index] == a2; }
        else if index == |prefix|+3 { assert lhs[index] == a3; assert rhs[index] == a3; }
        else if index == |prefix|+4 { assert lhs[index] == a4; assert rhs[index] == a4; }
        else if index == |prefix|+5 { assert lhs[index] == a5; assert rhs[index] == a5; }
        else if index == |prefix|+6 { assert lhs[index] == a6; assert rhs[index] == a6; }
        else if index == |prefix|+7 { assert lhs[index] == a7; assert rhs[index] == a7; }
        else if index == |prefix|+8 { assert lhs[index] == a8; assert rhs[index] == a8; }
        else if index == |prefix|+9 { assert lhs[index] == a9; assert rhs[index] == a9; }
        else if index == |prefix|+10 { assert lhs[index] == a10; assert rhs[index] == a10; }
        else if index == |prefix|+11 { assert lhs[index] == a11; assert rhs[index] == a11; }
        else if index == |prefix|+12 { assert lhs[index] == a12; assert rhs[index] == a12; }
        else if index == |prefix|+13 { assert lhs[index] == a13; assert rhs[index] == a13; }
        else { assert false; }
      }
    }
  }
}
