// SPDX-License-Identifier: MIT
// Whole-word base-name reads distinguish bytes/string by exactly five/six bytes.
include "ByteRead.dfy"
include "development/name-join-v1/Join.dfy"
module AssertionsNavigationNameWord {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = AssertionsNavigationHighByte
  import C = AssertionsNavigationConversion
  import W = AssertionsNavigationShift
  import B = AssertionsNavigationByteRead
  import J = AssertionsNavigationNameJoin
  lemma Split(bs: seq<S.Byte>,k: nat)
    requires k <= |bs|
    ensures G.Decode(bs) == G.Decode(bs[..k])*G.Pow256(|bs|-k)+G.Decode(bs[k..])
    decreases |bs|-k
  {
    if k < |bs| {
      Split(bs[..|bs|-1],k);
      assert bs[..|bs|-1][..k] == bs[..k];
      assert bs[..|bs|-1][k..] == bs[k..][..|bs|-k-1];
      assert bs[k..][|bs|-k-1] == bs[|bs|-1];
      calc {
        G.Decode(bs);
        == G.Decode(bs[..|bs|-1])*256+bs[|bs|-1];
        == (G.Decode(bs[..k])*G.Pow256(|bs|-k-1)+G.Decode(bs[k..][..|bs|-k-1]))*256+bs[|bs|-1];
        == G.Decode(bs[..k])*(256*G.Pow256(|bs|-k-1))+(G.Decode(bs[k..][..|bs|-k-1])*256+bs[|bs|-1]);
        == G.Decode(bs[..k])*G.Pow256(|bs|-k)+G.Decode(bs[k..]);
      }
    } else {
      assert k == |bs|;
      assert bs[..k] == bs && bs[k..] == [];
    }
  }
  lemma Widen40(bits: bv40)
    ensures ((bits as bv64) as nat) == (bits as nat)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  lemma Widen48(bits: bv48)
    ensures ((bits as bv64) as nat) == (bits as nat)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  lemma Widen216(bits: bv216)
    ensures ((bits as bv248) as nat) == (bits as nat)
  {}
  lemma Widen208(bits: bv208)
    ensures ((bits as bv248) as nat) == (bits as nat)
  {}
  lemma Nat40(value: nat)
    requires value < 0x10000000000
    ensures (value as bv40) as nat == value
  {
    C.Nat64(value);
    var bits := value as bv64;
    assert bits < 0x10000000000;
    assert ((bits as bv40) as bv64) == bits;
    Widen40(bits as bv40);
  }
  lemma Nat48(value: nat)
    requires value < 0x1000000000000
    ensures (value as bv48) as nat == value
  {
    C.Nat64(value);
    var bits := value as bv64;
    assert bits < 0x1000000000000;
    assert ((bits as bv48) as bv64) == bits;
    Widen48(bits as bv48);
  }
  lemma Nat216(value: nat)
    requires value < 0x1000000000000000000000000000000000000000000000000000000
    ensures (value as bv216) as nat == value
  {
    H.Nat248(value);
    var bits := value as bv248;
    assert bits < 0x1000000000000000000000000000000000000000000000000000000;
    assert ((bits as bv216) as bv248) == bits;
    Widen216(bits as bv216);
  }
  lemma Nat208(value: nat)
    requires value < 0x10000000000000000000000000000000000000000000000000000
    ensures (value as bv208) as nat == value
  {
    H.Nat248(value);
    var bits := value as bv248;
    assert bits < 0x10000000000000000000000000000000000000000000000000000;
    assert ((bits as bv208) as bv248) == bits;
    Widen208(bits as bv208);
  }
  function Join40(high: bv40,low: bv216): bv256 { ((high as bv256)<<216)|(low as bv256) }
  function Join48(high: bv48,low: bv208): bv256 { ((high as bv256)<<208)|(low as bv256) }
  lemma Join40Nat(high: bv40,low: bv216)
    ensures (Join40(high,low) as nat) == 0x1000000000000000000000000000000000000000000000000000000*(high as nat)+(low as nat)
  { J.Forty(high,low); }
  lemma Join48Nat(high: bv48,low: bv208)
    ensures (Join48(high,low) as nat) == 0x10000000000000000000000000000000000000000000000000000*(high as nat)+(low as nat)
  { J.FortyEight(high,low); }
  lemma Right40(high: bv40,low: bv216,amount: S.Word)
    requires amount == 216
    ensures (Join40(high,low)>>(amount as nat)) == (high as bv256)
  { J.RightForty(high,low); J.Fixed216(Join40(high,low),amount); }
  lemma Right48(high: bv48,low: bv208,amount: S.Word)
    requires amount == 208
    ensures (Join48(high,low)>>(amount as nat)) == (high as bv256)
  { J.RightFortyEight(high,low); J.Fixed208(Join48(high,low),amount); }
  lemma Read40(high: nat,low: nat)
    requires high < 1099511627776 && low < 105312291668557186697918027683670432318895095400549111254310977536
    ensures S.ShiftRight(high*105312291668557186697918027683670432318895095400549111254310977536+low,216) == high
  {
    hide S.ShiftRight();
    Nat40(high); Nat216(low);
    var highBits: bv40 := high as bv40;
    var lowBits: bv216 := low as bv216;
    Join40Nat(highBits,lowBits);
    var bits := Join40(highBits,lowBits);
    W.Inverse256(bits);
    Widen40(highBits);
    var input: S.Word := bits as nat;
    var amount: S.Word := 216;
    var output: bv256 := highBits as bv256;
    var result: S.Word := high;
    Right40(highBits,lowBits,amount);
    hide Join40(); hide Join48(); hide H.Join256(); hide H.Join248(); hide H.Join124();
    assert (input as bv256) == bits;
    assert ((input as bv256)>>(amount as nat)) == output;
    assert (output as nat) == result;
    B.RightBridge(input,amount,output,result);
  }
  lemma Calldata5(data: seq<S.Byte>,offset: S.Word)
    requires (offset as nat)+5 <= |data|
    ensures S.ShiftRight(S.DataWord(data,offset),216) == G.Decode(data[offset..offset+5])
  {
    hide S.DataWord(); hide S.ShiftRight();
    var bytes := S.Window(data,offset,32);
    Split(bytes,5);
    G.DecodeBound(bytes); G.DecodeBound(bytes[..5]); G.DecodeBound(bytes[5..]);
    G.WordPower();
    assert G.Pow256(31) == 452312848583266388373324160190187140051835877600158453279131187530910662656;
    assert G.Pow256(30) == 1766847064778384329583297500742918515827483896875618958121606201292619776;
    assert G.Pow256(29) == 6901746346790563787434755862277025452451108972170386555162524223799296;
    assert G.Pow256(28) == 26959946667150639794667015087019630673637144422540572481103610249216;
    assert G.Pow256(27) == 105312291668557186697918027683670432318895095400549111254310977536;
    reveal S.DataWord();
    assert S.DataWord(data,offset) == G.Decode(bytes);
    assert bytes[..5] == data[offset..offset+5];
    Read40(G.Decode(bytes[..5]),G.Decode(bytes[5..]));
  }
  lemma Read48(high: nat,low: nat)
    requires high < 281474976710656 && low < 411376139330301510538742295639337626245683966408394965837152256
    ensures S.ShiftRight(high*411376139330301510538742295639337626245683966408394965837152256+low,208) == high
  {
    hide S.ShiftRight();
    Nat48(high); Nat208(low);
    var highBits: bv48 := high as bv48;
    var lowBits: bv208 := low as bv208;
    Join48Nat(highBits,lowBits);
    var bits := Join48(highBits,lowBits);
    W.Inverse256(bits);
    Widen48(highBits);
    var input: S.Word := bits as nat;
    var amount: S.Word := 208;
    var output: bv256 := highBits as bv256;
    var result: S.Word := high;
    Right48(highBits,lowBits,amount);
    hide Join40(); hide Join48(); hide H.Join256(); hide H.Join248(); hide H.Join124();
    assert (input as bv256) == bits;
    assert ((input as bv256)>>(amount as nat)) == output;
    assert (output as nat) == result;
    B.RightBridge(input,amount,output,result);
  }
  lemma Calldata6(data: seq<S.Byte>,offset: S.Word)
    requires (offset as nat)+6 <= |data|
    ensures S.ShiftRight(S.DataWord(data,offset),208) == G.Decode(data[offset..offset+6])
  {
    hide S.DataWord(); hide S.ShiftRight();
    var bytes := S.Window(data,offset,32);
    Split(bytes,6);
    G.DecodeBound(bytes); G.DecodeBound(bytes[..6]); G.DecodeBound(bytes[6..]);
    G.WordPower();
    assert G.Pow256(31) == 452312848583266388373324160190187140051835877600158453279131187530910662656;
    assert G.Pow256(30) == 1766847064778384329583297500742918515827483896875618958121606201292619776;
    assert G.Pow256(29) == 6901746346790563787434755862277025452451108972170386555162524223799296;
    assert G.Pow256(28) == 26959946667150639794667015087019630673637144422540572481103610249216;
    assert G.Pow256(27) == 105312291668557186697918027683670432318895095400549111254310977536;
    assert G.Pow256(26) == 411376139330301510538742295639337626245683966408394965837152256;
    reveal S.DataWord();
    assert S.DataWord(data,offset) == G.Decode(bytes);
    assert bytes[..6] == data[offset..offset+6];
    Read48(G.Decode(bytes[..6]),G.Decode(bytes[6..]));
  }
}
