// SPDX-License-Identifier: MIT
include "../../../proof-tools/dafnyevm/src/dafny/util/int.dfy"

// These equations specify ABI bytes independently of interpreter conversion.
module AbiEncoding {
  import opened Int
  const Modulus: int := 115792089237316195423570985008687907853269984665640564039457584007913129639936
  const SignedLimit: int := 57896044618658097711785492504343953926634992332820282019728792003956564819968

  function Power(width: nat): int
    ensures Power(width) > 0
    decreases width
  { if width == 0 then 1 else 256 * Power(width-1) }

  function Bytes(value: int, width: nat): (result: seq<u8>)
    requires 0 <= value < Power(width)
    ensures |result| == width
    decreases width
  {
    if width == 0 then []
    else Bytes(value / 256, width-1) + [(value % 256) as u8]
  }

  function Value(data: seq<u8>): int
    decreases |data|
  {
    if |data| == 0 then 0
    else 256 * Value(data[..|data|-1]) + data[|data|-1] as int
  }

  lemma RoundTrip(value: int, width: nat)
    requires 0 <= value < Power(width)
    ensures Value(Bytes(value,width)) == value
    decreases width
  {
    if width > 0 {
      RoundTrip(value/256,width-1);
      assert Bytes(value,width)[..width-1] == Bytes(value/256,width-1);
    }
  }

  lemma {:fuel Power, 34} WordWidth()
    ensures Power(32) == Modulus
  {
    assert Power(0) == 1;
    assert Power(1) == 256;
    assert Power(2) == 65536;
    assert Power(3) == 16777216;
    assert Power(4) == 4294967296;
    assert Power(5) == 1099511627776;
    assert Power(6) == 281474976710656;
    assert Power(7) == 72057594037927936;
    assert Power(8) == 18446744073709551616;
    assert Power(9) == 4722366482869645213696;
    assert Power(10) == 1208925819614629174706176;
    assert Power(11) == 309485009821345068724781056;
    assert Power(12) == 79228162514264337593543950336;
    assert Power(13) == 20282409603651670423947251286016;
    assert Power(14) == 5192296858534827628530496329220096;
    assert Power(15) == 1329227995784915872903807060280344576;
    assert Power(16) == 340282366920938463463374607431768211456;
    assert Power(17) == 87112285931760246646623899502532662132736;
    assert Power(18) == 22300745198530623141535718272648361505980416;
    assert Power(19) == 5708990770823839524233143877797980545530986496;
    assert Power(20) == 1461501637330902918203684832716283019655932542976;
    assert Power(21) == 374144419156711147060143317175368453031918731001856;
    assert Power(22) == 95780971304118053647396689196894323976171195136475136;
    assert Power(23) == 24519928653854221733733552434404946937899825954937634816;
    assert Power(24) == 6277101735386680763835789423207666416102355444464034512896;
    assert Power(25) == 1606938044258990275541962092341162602522202993782792835301376;
    assert Power(26) == 411376139330301510538742295639337626245683966408394965837152256;
    assert Power(27) == 105312291668557186697918027683670432318895095400549111254310977536;
    assert Power(28) == 26959946667150639794667015087019630673637144422540572481103610249216;
    assert Power(29) == 6901746346790563787434755862277025452451108972170386555162524223799296;
    assert Power(30) == 1766847064778384329583297500742918515827483896875618958121606201292619776;
    assert Power(31) == 452312848583266388373324160190187140051835877600158453279131187530910662656;
    assert Power(32) == 115792089237316195423570985008687907853269984665640564039457584007913129639936;
  }

  function Word(value: int): seq<u8>
    requires 0 <= value < Modulus
    ensures |Word(value)| == 32
  { WordWidth(); Bytes(value,32) }

  function TwosComplement(value: int): int
    requires -SignedLimit <= value < SignedLimit
    ensures 0 <= TwosComplement(value) < Modulus
  { if value < 0 then value + Modulus else value }

  function Panic11(): seq<u8>
  { [0x4e,0x48,0x7b,0x71] + Word(17) }

  function AddCall(signed: bool, a: int, b: int): seq<u8>
    requires signed ==> -SignedLimit <= a < SignedLimit && -SignedLimit <= b < SignedLimit
    requires !signed ==> 0 <= a < Modulus && 0 <= b < Modulus
  {
    (if signed then [0xa5,0xf3,0xc2,0x3b] else [0x77,0x16,0x02,0xf7]) +
    Word(if signed then TwosComplement(a) else a) +
    Word(if signed then TwosComplement(b) else b)
  }
}
