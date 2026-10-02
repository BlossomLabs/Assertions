// SPDX-License-Identifier: MIT
// Independent public gather boundary layout and standard empty bytes[] result.
include "../../scans/Representation.dfy"
include "../../assertions-navigation/Shift.dfy"
module AssertionsGatherPublicSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import W = AssertionsNavigationShift
  import SC = BytecodeScanScalar
  type Word = S.Word
  type Byte = S.Byte
  function Selector(): Word { 0x6db7211f }
  function Initial(): seq<Byte> { S.Store([],64,128) }
  predicate Calldata(data: seq<Byte>, relative: Word, count: Word) {
    36 <= |data| < 0x10000000000000000 && relative < 0x10000000000000000 && count < 0x10000000000000000 &&
    4+relative+32+count*32 <= |data| && S.DataWord(data,4) == relative && S.DataWord(data,4+relative) == count
  }
  function Args(relative: Word): Word
    requires relative < 0x10000000000000000
  { 4+relative+32 }
  lemma Constant64()
    ensures S.ShiftLeft(1,64) == 0x10000000000000000
  {
    reveal S.ShiftLeft(); reveal G.Shift();
    SC.ShiftDefinition(1,64);
    assert (1 as bv256) << 64 == 0x10000000000000000 as bv256;
  }
  lemma ZeroStride()
    ensures S.ShiftLeft(0,5) == 0
  {
    reveal S.ShiftLeft(); reveal G.Shift();
    SC.ShiftDefinition(0,5);
    assert (0 as bv256) << 5 == 0 as bv256;
  }
  lemma Layout(data: seq<Byte>, relative: Word, count: Word)
    requires Calldata(data,relative,count)
    ensures S.ShiftLeft(count,5) == count*32
    ensures (((4 as nat)+relative)%G.Modulus()+32+S.ShiftLeft(count,5))%G.Modulus() <= |data|
    ensures ((4 as nat)+relative)%G.Modulus() == 4+relative
    ensures (((4 as nat)+relative)%G.Modulus()+32)%G.Modulus() == Args(relative)
  {
    hide S.ShiftLeft(); hide G.Shift();
    W.Scalar(count);
  }
  function EmptyResult(): seq<Byte> { G.Encode(32,32)+G.Encode(0,32) }
  function EmptyImage(mem: seq<Byte>): seq<Byte> { S.Store(S.Store(mem,160,32),192,0) }
  predicate EmptyHeap(mem: seq<Byte>) {
    |mem|%32 == 0 && 160 <= |mem| < G.Modulus() && S.Load(mem,64) == 160 && S.Load(mem,128) == 0
  }
  lemma EmptySerialization(mem: seq<Byte>)
    requires EmptyHeap(mem)
    ensures S.Load(S.Store(mem,160,32),128) == 0
    ensures S.Load(S.Store(mem,160,32),64) == 160
    ensures EmptyImage(mem)[160..224] == EmptyResult()
    ensures S.Load(EmptyImage(mem),64) == 160 && S.Load(EmptyImage(mem),128) == 0
  {
    R.StoredWord(mem,160,32);
    var first := S.Store(mem,160,32);
    R.StoredWord(first,192,0);
    R.StoredFrame(first,192,0,160);
    R.StoredFrame(mem,160,32,64); R.StoredFrame(first,192,0,64);
    R.StoredFrame(mem,160,32,128); R.StoredFrame(first,192,0,128);
    assert first[160..192] == G.Encode(32,32);
    assert EmptyImage(mem)[192..224] == G.Encode(0,32);
    assert EmptyImage(mem)[160..192] == first[160..192];
  }
}
