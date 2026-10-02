// SPDX-License-Identifier: MIT
// Independent raw-input/receipt specification. Unverified candidate; no opcode
// or public bytecode theorem is supplied by this file.
include "Indices.dfy"
module OperationsByteAtInputs {
  import I = OperationsByteAtIndices
  type Byte = n: nat | n < 256 witness 0
  type Word = I.Word
  const U64: nat := 0x10000000000000000
  function Power(n: nat): nat
    ensures Power(n) > 0
    decreases n
  { if n == 0 then 1 else 256*Power(n-1) }
  function Cell(data: seq<Byte>,offset: nat): Byte {
    if offset < |data| then data[offset] else 0
  }
  function Load(data: seq<Byte>,offset: nat,width: nat): nat
    ensures Load(data,offset,width) < Power(width)
    decreases width
  { if width == 0 then 0 else 256*Load(data,offset,width-1)+Cell(data,offset+width-1) }
  function Encode(n: nat,width: nat): seq<Byte>
    ensures |Encode(n,width)| == width
    decreases width
  { if width == 0 then [] else Encode(n/256,width-1)+[n%256] }
  lemma WordPower()
    ensures Power(32) == I.M
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
  function DataWord(data: seq<Byte>,offset: nat): Word {
    WordPower(); Load(data,offset,32)
  }
  function Offset(data: seq<Byte>): Word { DataWord(data,4) }
  function Length(data: seq<Byte>): Word { DataWord(data,4+Offset(data)) }
  function Index(data: seq<Byte>): Word { DataWord(data,36) }
  predicate Frame(data: seq<Byte>) { |data| < U64 }
  predicate Assigned(data: seq<Byte>,value: Word) {
    value != 0 || |data| < 4 || data[..4] == [0x9a,0xe8,0xe8,0xea]
  }
  predicate Span(data: seq<Byte>) {
    |data| >= 68 && Offset(data) < U64 && Offset(data)+36 <= |data| &&
    Length(data) < U64 && Offset(data)+36+Length(data) <= |data|
  }
  datatype Case = Nonzero | Short | Args | OffsetBound | LengthWindow |
                  LengthBound | PayloadWindow | InvalidHigh | InvalidLow |
                  Positive | Negative
  function Admission(data: seq<Byte>,value: Word): Case
    ensures Admission(data,value) in {Positive,Negative} ==>
              value == 0 && Span(data) && I.FitsIndex(Index(data),Length(data))
    ensures Admission(data,value) == Positive ==> 0 <= I.Signed(Index(data)) < Length(data)
    ensures Admission(data,value) == Negative ==> -(Length(data) as int) <= I.Signed(Index(data)) < 0
  {
    if value != 0 then Nonzero
    else if |data| < 4 then Short
    else if |data| < 68 then Args
    else if Offset(data) >= U64 then OffsetBound
    else if Offset(data)+36 > |data| then LengthWindow
    else if Length(data) >= U64 then LengthBound
    else if Offset(data)+36+Length(data) > |data| then PayloadWindow
    else if I.Signed(Index(data)) >= Length(data) then InvalidHigh
    else if I.Signed(Index(data)) < -(Length(data) as int) then InvalidLow
    else if I.Signed(Index(data)) < 0 then Negative else Positive
  }
  datatype Receipt = Returned(data: seq<Byte>) | Reverted(data: seq<Byte>)
  function InvalidIndex(c: Word,b: Word): seq<Byte> {
    Encode(0xdf75cbae,4)+Encode(c,32)+Encode(b,32)
  }
  function ByteEnvelope(cell: Byte): seq<Byte> {
    Encode(32,32)+Encode(1,32)+[cell]+seq(31,i => 0 as Byte)
  }
  function Intended(data: seq<Byte>,value: Word): Receipt
    requires Frame(data) && Assigned(data,value)
  {
    var kind := Admission(data,value);
    if kind in {InvalidHigh,InvalidLow} then Reverted(InvalidIndex(Index(data),Length(data)))
    else if kind in {Positive,Negative} then
      I.OriginalByteWindow(Offset(data),Length(data),Index(data),|data|);
      Returned(ByteEnvelope(data[Offset(data)+36+I.Position(Index(data),Length(data))]))
    else Reverted([])
  }
  lemma OffsetAliases(data: seq<Byte>)
    ensures Offset(data) == 0 ==> Length(data) == Offset(data)
    ensures Offset(data) == 32 ==> Length(data) == Index(data)
  {}
  lemma InvalidReceiptWidth(c: Word,b: Word)
    ensures |InvalidIndex(c,b)| == 68
  {}
  lemma ByteEnvelopeWidth(cell: Byte)
    ensures |ByteEnvelope(cell)| == 96
  {}
  lemma EmptyAliasedSpanInvalid(data: seq<Byte>,value: Word)
    requires Span(data) && Offset(data) == 0
    ensures Admission(data,value) !in {Positive,Negative}
  { OffsetAliases(data); I.EmptyInvalid(Index(data)); }
}
