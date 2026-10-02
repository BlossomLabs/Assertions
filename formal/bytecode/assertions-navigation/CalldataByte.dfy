// SPDX-License-Identifier: MIT
// Universal high-byte AND projection, including zero padding after calldata ends.
include "HighByte.dfy"
include "WordHead.dfy"
module AssertionsNavigationCalldataByte {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = AssertionsNavigationHighByte
  import N = AssertionsNavigationWordHead
  lemma Projection(data: seq<S.Byte>,offset: S.Word)
    requires offset < |data|
    ensures G.BitAnd(S.DataWord(data,offset),0xff00000000000000000000000000000000000000000000000000000000000000) == (data[offset] as nat)*0x100000000000000000000000000000000000000000000000000000000000000
  {
    hide S.DataWord(); hide G.Decode(); hide G.BitAnd();
    N.Calldata(data,offset);
    H.Mask(data[offset],G.Decode(S.Window(data,offset,32)[1..]));
  }
}
