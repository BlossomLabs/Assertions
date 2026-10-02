// SPDX-License-Identifier: MIT
// Constructive physical byte read: calldata word, SHR 248, SHL 248.
include "HighByte.dfy"
include "WordHead.dfy"
module AssertionsNavigationByteRead {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = AssertionsNavigationHighByte
  import C = AssertionsNavigationConversion
  import W = AssertionsNavigationShift
  import J = AssertionsNavigationJoinProbe
  import N = AssertionsNavigationWordHead
  type Byte = S.Byte
  type Word = S.Word
  lemma WidenByte(bits: bv8)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  lemma RightBits(high: bv8,low: bv248)
    ensures (H.Join256(high,low) >> 248) == (high as bv256)
  {}
  lemma FixedRight(bits: bv256,amount: Word)
    requires amount == 248
    ensures (bits >> (amount as nat)) == (bits >> 248)
  {}
  lemma LeftBits(high: bv8)
    ensures ((high as bv256)<<248) == H.Join256(high,0)
  {}
  lemma RightDefinition(value: Word,amount: Word)
    requires amount < 256
    ensures S.ShiftRight(value,amount) == (((value as bv256)>>(amount as nat)) as nat)
  { reveal S.ShiftRight(); }
  lemma RightBridge(value: Word,amount: Word,bits: bv256,result: Word)
    requires amount < 256 && ((value as bv256)>>(amount as nat)) == bits && (bits as nat) == result
    ensures S.ShiftRight(value,amount) == result
  {
    hide S.ShiftRight();
    W.NatEquality((value as bv256)>>(amount as nat),bits);
    RightDefinition(value,amount);
  }
  lemma Right(high: Byte,low: nat)
    requires low < 0x100000000000000000000000000000000000000000000000000000000000000
    ensures S.ShiftRight((high as nat)*0x100000000000000000000000000000000000000000000000000000000000000+low,248) == high
  {
    hide S.ShiftRight();
    C.Nat8(high); H.Nat248(low);
    H.Join256Nat(high as bv8,low as bv248);
    var bits := H.Join256(high as bv8,low as bv248);
    W.Inverse256(bits);
    RightBits(high as bv8,low as bv248);
    WidenByte(high as bv8);
    var input: Word := bits as nat;
    var amount: Word := 248;
    var output: bv256 := (high as bv8) as bv256;
    var result: Word := output as nat;
    assert (input as bv256) == bits;
    FixedRight(bits,amount);
    assert ((input as bv256) >> (amount as nat)) == output;
    RightBridge(input,amount,output,result);
  }
  lemma Left(high: Byte)
    ensures S.ShiftLeft(high,248) == (high as nat)*0x100000000000000000000000000000000000000000000000000000000000000
  {
    C.Nat8(high);
    assert ((high as bv8) as bv256) == (high as bv256);
    LeftBits(high as bv8);
    H.Join256Nat(high as bv8,0);
    reveal S.ShiftLeft();
  }
  lemma Calldata(data: seq<Byte>,offset: Word)
    requires offset < |data|
    ensures S.ShiftRight(S.DataWord(data,offset),248) == data[offset]
    ensures S.ShiftLeft(S.ShiftRight(S.DataWord(data,offset),248),248) == (data[offset] as nat)*0x100000000000000000000000000000000000000000000000000000000000000
  {
    hide S.DataWord(); hide G.Decode();
    N.Calldata(data,offset);
    Right(data[offset],G.Decode(S.Window(data,offset,32)[1..]));
    Left(data[offset]);
  }
}
