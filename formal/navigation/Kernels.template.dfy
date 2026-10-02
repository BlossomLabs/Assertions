// SPDX-License-Identifier: MIT
// Source-derived kernels; Assertions.sol SHA-256: $HASH
include "Runtime.dfy"

module NavigationKernels {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened NavigationRuntime

  ghost method ReadWord(data: seq<Byte>, pos: nat) returns (r: NumberResult)
    requires Uint(|data|) && Uint(pos)
    ensures r == WordAt(data,pos)
  {
    assert Sint(pos/32);
    if $WORD_GUARD {
      r := Failed(ReturnDataOutOfBounds(pos/32,|data|)); return;
    }
    r := Number(ReadNat(data[pos..pos+32]));
  }

  ghost method NormalizeIndex(index: int, count: nat) returns (r: NumberResult)
    requires Sint(index) && Uint(count)
    ensures r == Normalize(index,count)
  {
    if index < 0 {
      var signedCount := Signed(count);
      if signedCount == -(Half() as int) { r := Failed(Error.Panic(17)); return; }
      if index < -signedCount {
        r := Failed(ElementIndexOutOfBounds(index,count)); return;
      }
      assert index > -(Half() as int) && count < Half() && -index <= count;
      var magnitude := -index;
      var value := $NEGATIVE_INDEX;
      assert Uint(value);
      r := Number(value); return;
    }
    if index >= count { r := Failed(ElementIndexOutOfBounds(index,count)); return; }
    r := Number(index);
  }
}
