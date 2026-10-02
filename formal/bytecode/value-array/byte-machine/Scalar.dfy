// SPDX-License-Identifier: MIT
include "Machine.dfy"
module BytecodeCollectionsArrayByteScalar {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCollectionsArrayByteMachine
  lemma ProductMonotone(a: nat,b: nat,d: nat)
    requires a <= b
    ensures a*d <= b*d
  { assert b*d == a*d+(b-a)*d; }
  lemma Quotient(a: nat,b: nat,d: nat)
    requires d > 0 && b < d
    ensures (a*d+b)/d == a
  {
    var value := a*d+b;var q := value/d;
    assert value == q*d+value%d;
    if q < a {
      ProductMonotone(q+1,a,d);
      assert (q+1)*d == q*d+d;
      assert value < q*d+d;
    } else if q > a {
      ProductMonotone(a+1,q,d);
      assert (a+1)*d == a*d+d;
      assert value < (a+1)*d;
    }
  }
  lemma DecodeHead(bytes: seq<Byte>)
    requires |bytes| > 0
    ensures G.Decode(bytes) == bytes[0]*G.Pow256(|bytes|-1)+G.Decode(bytes[1..])
    decreases |bytes|
  {
    if |bytes| > 1 {
      DecodeHead(bytes[..|bytes|-1]);
      assert bytes[..|bytes|-1][1..] == bytes[1..|bytes|-1];
      assert bytes[1..][..|bytes|-2] == bytes[1..|bytes|-1];
      assert G.Pow256(|bytes|-1) == 256*G.Pow256(|bytes|-2);
    }
  }
  lemma WordPowers()
    ensures G.Pow256(32) == G.Modulus()
    ensures G.Pow256(31) == 0x100000000000000000000000000000000000000000000000000000000000000
  {
    assert G.Pow256(0) == 0x1;
    assert G.Pow256(1) == 0x100;
    assert G.Pow256(2) == 0x10000;
    assert G.Pow256(3) == 0x1000000;
    assert G.Pow256(4) == 0x100000000;
    assert G.Pow256(5) == 0x10000000000;
    assert G.Pow256(6) == 0x1000000000000;
    assert G.Pow256(7) == 0x100000000000000;
    assert G.Pow256(8) == 0x10000000000000000;
    assert G.Pow256(9) == 0x1000000000000000000;
    assert G.Pow256(10) == 0x100000000000000000000;
    assert G.Pow256(11) == 0x10000000000000000000000;
    assert G.Pow256(12) == 0x1000000000000000000000000;
    assert G.Pow256(13) == 0x100000000000000000000000000;
    assert G.Pow256(14) == 0x10000000000000000000000000000;
    assert G.Pow256(15) == 0x1000000000000000000000000000000;
    assert G.Pow256(16) == 0x100000000000000000000000000000000;
    assert G.Pow256(17) == 0x10000000000000000000000000000000000;
    assert G.Pow256(18) == 0x1000000000000000000000000000000000000;
    assert G.Pow256(19) == 0x100000000000000000000000000000000000000;
    assert G.Pow256(20) == 0x10000000000000000000000000000000000000000;
    assert G.Pow256(21) == 0x1000000000000000000000000000000000000000000;
    assert G.Pow256(22) == 0x100000000000000000000000000000000000000000000;
    assert G.Pow256(23) == 0x10000000000000000000000000000000000000000000000;
    assert G.Pow256(24) == 0x1000000000000000000000000000000000000000000000000;
    assert G.Pow256(25) == 0x100000000000000000000000000000000000000000000000000;
    assert G.Pow256(26) == 0x10000000000000000000000000000000000000000000000000000;
    assert G.Pow256(27) == 0x1000000000000000000000000000000000000000000000000000000;
    assert G.Pow256(28) == 0x100000000000000000000000000000000000000000000000000000000;
    assert G.Pow256(29) == 0x10000000000000000000000000000000000000000000000000000000000;
    assert G.Pow256(30) == 0x1000000000000000000000000000000000000000000000000000000000000;
    assert G.Pow256(31) == 0x100000000000000000000000000000000000000000000000000000000000000;
    assert G.Pow256(32) == 0x10000000000000000000000000000000000000000000000000000000000000000;
  }
  lemma FirstByte(data: seq<Byte>,offset: Word)
    ensures B.ByteWord(0,DataWord(data,offset)) == (if offset < |data| then data[offset] else 0)
  {
    var bytes := Window(data,offset,32);
    G.DecodeBound(bytes);G.DecodeBound(bytes[1..]);
    DecodeHead(bytes);WordPowers();
    assert G.Decode(bytes) < G.Modulus();
    Quotient(bytes[0],G.Decode(bytes[1..]),G.Pow256(31));
    assert G.Decode(bytes)/G.Pow256(31) == bytes[0];
    assert bytes[0]%256 == bytes[0];
  }
}
