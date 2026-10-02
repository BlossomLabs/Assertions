// SPDX-License-Identifier: MIT
// The array-decoder signed bound follows from the independent calldata span.
include "../../assertions-navigation/Shift.dfy"
module AssertionsConstrainedRawScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = AssertionsNavigationShift
  lemma Bounds(pointer: S.Word, relative: S.Word, count: S.Word, size: S.Word)
    requires (pointer as nat)+relative+32+count*32 <= size < 0x10000000000000000
    ensures S.ShiftLeft(count,5) == count*32
    ensures G.Signed(((32 as nat)+(((pointer as nat)+(relative as nat))%G.Modulus() as nat))%G.Modulus()) == pointer+relative+32
    ensures G.Signed(((size as nat)+G.Modulus()-(S.ShiftLeft(count,5) as nat))%G.Modulus()) == size-count*32
    ensures pointer+relative+32 <= size-count*32
  {
    A.Scalar(count);
  }
  lemma PayloadAddress(free: S.Word, length: S.Word)
    requires (free as nat)+S.Round32(length)+64 < 0x10000000000000000
    ensures (((32 as nat)+(free as nat))%G.Modulus()+length)%G.Modulus() == free+32+length
  {}
}
