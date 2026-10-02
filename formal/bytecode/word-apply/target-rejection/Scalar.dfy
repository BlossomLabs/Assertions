// SPDX-License-Identifier: MIT
include "../address-kernel/Mask.dfy"
include "../../opcode-kernels/And.dfy"
module BytecodeApplyTargetErrorScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeApplyAddressMask
  import SC = BytecodeScanScalar
  import O = BytecodeOpcodeAnd
  lemma Selector()
    ensures S.ShiftLeft(710513733,225) == 0x54b3288a00000000000000000000000000000000000000000000000000000000
  {
    var input: G.Word := 710513733;
    var amount: G.Word := 225;
    var bits: bv256 := 710513733;
    var header: bv256 := 0x54b3288a00000000000000000000000000000000000000000000000000000000;
    SC.Narrow(input);assert (input as bv256) == bits;
    assert bits << 225 == header;
    SC.ShiftDefinition(input,amount);reveal S.ShiftLeft();
  }
  lemma Swap(a: G.Word,b: G.Word)
    ensures G.BitAnd(a,b) == G.BitAnd(b,a)
  {
    hide G.BitAnd();A.Definition(a,b);A.Definition(b,a);
    assert (a as bv256)&(b as bv256) == (b as bv256)&(a as bv256);
  }
  lemma Mask(code: seq<S.Byte>,pc: nat,destinations: set<nat>,prefix: seq<S.Word>,mem: seq<S.Byte>,target: S.Word,reverse: bool,value: S.Word,data: seq<S.Byte>)
    requires pc < |code| && code[pc] == 0x16 && |prefix| <= 1022 && target < A.Bound()
    ensures S.Step(code,destinations,S.Running(pc,prefix+(if reverse then [0xffffffffffffffffffffffffffffffffffffffff,target] else [target,0xffffffffffffffffffffffffffffffffffffffff]),mem),value,data) == S.Running(pc+1,prefix+[target],mem)
  {
    hide G.BitAnd();A.Canonical(target);
    if reverse {
      Swap(target,0xffffffffffffffffffffffffffffffffffffffff);
      O.Step(code,destinations,pc,prefix,mem,0xffffffffffffffffffffffffffffffffffffffff,target,value,data);
    } else {
      O.Step(code,destinations,pc,prefix,mem,target,0xffffffffffffffffffffffffffffffffffffffff,value,data);
    }
  }
}
