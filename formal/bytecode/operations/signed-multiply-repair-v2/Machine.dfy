// SPDX-License-Identifier: MIT
// Reviewed reached-opcode EVM model for Operations checked signed multiplication entry. Adequate execution resources
// and truthful calldata/environment projections remain explicit premises.
include "Conversion.generated.dfy"
module OperationsSignedMultiplyMachine {
  import C = OperationsSignedMultiplyWordConversion
  type Byte = x: nat | x < 256 witness 0
  type Word = x: nat | x < 0x10000000000000000000000000000000000000000000000000000000000000000 witness 0
  function Modulus(): nat { 0x10000000000000000000000000000000000000000000000000000000000000000 }
  datatype State = Running(pc: nat, stack: seq<Word>, memory: seq<Byte>)
                 | Returned(data: seq<Byte>) | Reverted(data: seq<Byte>) | Bad
  datatype Instruction = Op(op: nat, next: nat, immediate: Word)

  function Pow256(n: nat): nat
    ensures Pow256(n) > 0
    decreases n
  { if n == 0 then 1 else 256 * Pow256(n-1) }

  function Encode(n: nat, width: nat): seq<Byte>
    ensures |Encode(n,width)| == width
    decreases width
  { if width == 0 then [] else Encode(n/256,width-1)+[n%256] }

  function Decode(bs: seq<Byte>): nat
    decreases |bs|
  { if |bs| == 0 then 0 else Decode(bs[..|bs|-1])*256+bs[|bs|-1] }

  lemma DecodeBound(bs: seq<Byte>)
    ensures Decode(bs) < Pow256(|bs|)
    decreases |bs|
  {
    if |bs| > 0 {
      DecodeBound(bs[..|bs|-1]);
    }
  }

  lemma RoundTrip(n: nat, width: nat)
    requires n < Pow256(width)
    ensures Decode(Encode(n,width)) == n
    decreases width
  {
    if width > 0 {
      assert n/256 < Pow256(width-1);
      RoundTrip(n/256,width-1);
    }
  }

  lemma WordPower()
    ensures Pow256(32) == Modulus()
  {
    assert Pow256(0) == 1;
    assert Pow256(1) == 256;
    assert Pow256(2) == 65536;
    assert Pow256(3) == 16777216;
    assert Pow256(4) == 4294967296;
    assert Pow256(5) == 1099511627776;
    assert Pow256(6) == 281474976710656;
    assert Pow256(7) == 72057594037927936;
    assert Pow256(8) == 18446744073709551616;
    assert Pow256(9) == 4722366482869645213696;
    assert Pow256(10) == 1208925819614629174706176;
    assert Pow256(11) == 309485009821345068724781056;
    assert Pow256(12) == 79228162514264337593543950336;
    assert Pow256(13) == 20282409603651670423947251286016;
    assert Pow256(14) == 5192296858534827628530496329220096;
    assert Pow256(15) == 1329227995784915872903807060280344576;
    assert Pow256(16) == 340282366920938463463374607431768211456;
    assert Pow256(17) == 87112285931760246646623899502532662132736;
    assert Pow256(18) == 22300745198530623141535718272648361505980416;
    assert Pow256(19) == 5708990770823839524233143877797980545530986496;
    assert Pow256(20) == 1461501637330902918203684832716283019655932542976;
    assert Pow256(21) == 374144419156711147060143317175368453031918731001856;
    assert Pow256(22) == 95780971304118053647396689196894323976171195136475136;
    assert Pow256(23) == 24519928653854221733733552434404946937899825954937634816;
    assert Pow256(24) == 6277101735386680763835789423207666416102355444464034512896;
    assert Pow256(25) == 1606938044258990275541962092341162602522202993782792835301376;
    assert Pow256(26) == 411376139330301510538742295639337626245683966408394965837152256;
    assert Pow256(27) == 105312291668557186697918027683670432318895095400549111254310977536;
    assert Pow256(28) == 26959946667150639794667015087019630673637144422540572481103610249216;
    assert Pow256(29) == 6901746346790563787434755862277025452451108972170386555162524223799296;
    assert Pow256(30) == 1766847064778384329583297500742918515827483896875618958121606201292619776;
    assert Pow256(31) == 452312848583266388373324160190187140051835877600158453279131187530910662656;
    assert Pow256(32) == 115792089237316195423570985008687907853269984665640564039457584007913129639936;
  }

  function Round32(length: nat): nat
    ensures Round32(length) >= length
    ensures Round32(length) % 32 == 0
  { 32*((length+31)/32) }

  // EVM memory expansion rounds the reached end address to whole words.
  // Calldata projections use only their requested window, so extra zero padding
  // here does not impose an alignment restriction on raw calldata.
  function Grow(mem: seq<Byte>, length: nat): seq<Byte>
    ensures |Grow(mem,length)| >= length && |Grow(mem,length)| >= |mem|
  { if |mem| >= length then mem else mem+seq(Round32(length)-|mem|,i => 0) }

  function Store(mem: seq<Byte>, offset: nat, value: Word): seq<Byte> {
    var expanded := Grow(mem,offset+32);
    expanded[..offset]+Encode(value,32)+expanded[offset+32..]
  }

  function Load(mem: seq<Byte>, offset: nat): Word {
    Decode(Grow(mem,offset+32)[offset..offset+32]) % Modulus()
  }

  lemma LoadProjection(mem: seq<Byte>, offset: nat)
    ensures Load(mem,offset) == Decode(Grow(mem,offset+32)[offset..offset+32])
  {
    WordPower();
    DecodeBound(Grow(mem,offset+32)[offset..offset+32]);
  }

  lemma StoreLoad(mem: seq<Byte>, offset: nat, value: Word)
    ensures Load(Store(mem,offset,value),offset) == value
    ensures |Store(mem,offset,value)| >= offset+32
    ensures Store(mem,offset,value)[offset..offset+32] == Encode(value,32)
  {
    WordPower();
    RoundTrip(value,32);
    var expanded := Grow(mem,offset+32);
    assert |Store(mem,offset,value)| == |expanded|;
    assert Grow(Store(mem,offset,value),offset+32) == Store(mem,offset,value);
  }

  lemma StoreFrame(mem: seq<Byte>, offset: nat, value: Word, other: nat)
    requires other+32 <= |mem|
    requires other+32 <= offset || offset+32 <= other
    ensures Load(Store(mem,offset,value),other) == Load(mem,other)
  {
    var expanded := Grow(mem,offset+32);
    assert expanded[..|mem|] == mem;
    assert Store(mem,offset,value)[other..other+32] == mem[other..other+32];
  }

  // The selector is the high four bytes of the loaded 256-bit word.
  // Use the same finite-word shift representation as the reached SHR opcode;
  // the prior alternate integer-division bridge is retained as a failed check.
  function Selector(word: Word): Word {
    Right(word,224)
  }

  function Signed(word: Word): int {
    if word < Modulus()/2 then word as int else word as int - Modulus()
  }

  opaque function BitAnd(a: Word, b: Word): Word {
    ((a as bv256) & (b as bv256)) as nat
  }

  opaque function BitXor(a: Word, b: Word): Word { ((a as bv256) ^ (b as bv256)) as nat }

  opaque function BitOr(a: Word, b: Word): Word {
    ((a as bv256) | (b as bv256)) as nat
  }

  lemma SymmetricBits(a: Word, b: Word)
    ensures BitAnd(a,b) == BitAnd(b,a)
    ensures BitOr(a,b) == BitOr(b,a)
    ensures BitXor(a,b) == BitXor(b,a)
    ensures BitAnd(a,b) == ((a as bv256) & (b as bv256)) as nat
    ensures BitOr(a,b) == ((a as bv256) | (b as bv256)) as nat
    ensures BitXor(a,b) == ((a as bv256) ^ (b as bv256)) as nat
  { reveal BitAnd(); reveal BitOr(); reveal BitXor(); }

  lemma UnitMask(a: Word)
    ensures BitAnd(a,1) <= 1
    ensures BitAnd(1,a) == BitAnd(a,1)
  { SymmetricBits(a,1); }

  opaque function Shift(a: Word, amount: Word): Word {
    if amount >= 256 then 0 else ((a as bv256) << (amount as nat)) as nat
  }

  opaque function Right(a: Word, amount: Word): Word {
    if amount >= 256 then 0 else ((a as bv256) >> (amount as nat)) as nat
  }

  opaque function ArithmeticRight(a: Word, amount: Word): Word {
    if a < Modulus()/2 then Right(a,amount)
    else Modulus()-1-Right(Modulus()-1-a,amount)
  }

  lemma SelectorRight(a: Word)
    ensures Right(a,224) == Selector(a)
  { }

  lemma SignedRight(a: Word, amount: Word)
    ensures ArithmeticRight(a,amount) ==
            (if a < Modulus()/2 then Right(a,amount)
             else Modulus()-1-Right(Modulus()-1-a,amount))
    ensures amount >= 256 ==> ArithmeticRight(a,amount) ==
                              (if a < Modulus()/2 then 0 else Modulus()-1)
  { reveal Right(); reveal ArithmeticRight(); }

  function Magnitude(a: Word): nat { if Signed(a) < 0 then -Signed(a) else Signed(a) }
  function SignedQuotient(a: Word,b: Word): Word {
    if b == 0 then 0 else
    var q := Magnitude(a)/Magnitude(b);
    (if (Signed(a) < 0) != (Signed(b) < 0) then -q else q) % Modulus()
  }
  function SignedRemainder(a: Word,b: Word): Word {
    if b == 0 then 0 else
    var r := Magnitude(a)%Magnitude(b);
    (if Signed(a) < 0 then -r else r) % Modulus()
  }
  function SignedProduct(a: Word,b: Word): Word { (Signed(a)*Signed(b))%Modulus() }
  lemma SignedBounds(a: Word)
    ensures -(Modulus()/2) <= Signed(a) < Modulus()/2
    ensures a%Modulus() == Signed(a)%Modulus()
  {}
  lemma ResidueShift(v: int,w: int,k: int,m: int)
    requires m > 0 && v == w+k*m
    ensures v%m == w%m
  {
    var q: int := w/m+k;
    var r: int := w%m;
    assert v == q*m+r;
    assert 0 <= r < m;
    var actual: int := v/m;
    var rest: int := v%m;
    assert v == actual*m+rest;
    if actual < q {
      assert 0 <= q-actual-1;
      ScaleLe(0,(q-actual-1) as nat,m as nat);
      assert q*m >= (actual+1)*m;
      assert v < (actual+1)*m;
      assert false;
    } else if q < actual {
      assert 0 <= actual-q-1;
      ScaleLe(0,(actual-q-1) as nat,m as nat);
      assert actual*m >= (q+1)*m;
      assert v < (q+1)*m;
      assert false;
    }
    assert actual == q;
    assert rest == r;
  }
  lemma ProductResidue(x: int,y: int,m: int)
    requires m > 0
    ensures (x*y)%m == ((x%m)*(y%m))%m
  {
    assert x == (x/m)*m+x%m;
    assert y == (y/m)*m+y%m;
    var k := (x/m)*(y/m)*m+(x/m)*(y%m)+(y/m)*(x%m);
    assert x*y == (x%m)*(y%m)+k*m;
    ResidueShift(x*y,(x%m)*(y%m),k,m);
  }
  lemma SignedProductProjection(a: Word,b: Word)
    ensures Product(a,b) == SignedProduct(a,b)
  {
    SignedBounds(a); SignedBounds(b);
    ProductResidue(Signed(a),Signed(b),Modulus());
  }
  function Abs(v: int): nat { if v < 0 then -v else v }
  lemma AbsoluteProduct(x: int,y: int)
    ensures Abs(x*y) == Abs(x)*Abs(y)
  { if x < 0 { if y < 0 {} else {} } else { if y < 0 {} else {} } }
  lemma SignedResidue(v: int)
    requires -(Modulus()/2) <= v < Modulus()/2
    ensures Signed(v%Modulus()) == v
  { if v < 0 { ResidueShift(v,v+Modulus(),-1,Modulus()); } else {} }
  lemma MagnitudeResidue(v: int)
    requires -(Modulus()/2) <= v <= Modulus()/2
    ensures Magnitude(v%Modulus()) == Abs(v)
  { if v == Modulus()/2 {} else { SignedResidue(v); } }
  lemma MagnitudeBound(a: Word)
    ensures Magnitude(a) <= Modulus()/2
    ensures Magnitude(a) == 0 <==> a == 0
  { SignedBounds(a); }
  lemma QuotientBound(n: nat,d: nat)
    requires d > 0
    ensures n/d <= n
  {
    var q := n/d;
    var r := n%d;
    assert n == q*d+r;
    assert 1 <= d;
    ScaleLe(1,d,q);
    assert q*d >= q;
  }
  lemma QuotientMagnitude(a: Word,b: Word)
    requires b != 0
    ensures Magnitude(SignedQuotient(a,b)) == Magnitude(a)/Magnitude(b)
  {
    MagnitudeBound(a); MagnitudeBound(b);
    var q := Magnitude(a)/Magnitude(b);
    QuotientBound(Magnitude(a),Magnitude(b));
    assert q <= Magnitude(a);
    assert q <= Modulus()/2;
    if (Signed(a) < 0) != (Signed(b) < 0) { MagnitudeResidue(-q); }
    else { MagnitudeResidue(q); }
  }
  lemma SignedProductFitting(a: Word,b: Word)
    requires a != 0 && -(Modulus()/2) <= Signed(a)*Signed(b) < Modulus()/2
    ensures SignedQuotient(Product(b,a),a) == b
  {
    SignedProductProjection(a,b); ProductSymmetric(a,b);
    SignedResidue(Signed(a)*Signed(b));
    AbsoluteProduct(Signed(a),Signed(b));
    MagnitudeBound(a); MagnitudeBound(b);
    DivideProduct(Magnitude(a),Magnitude(b));
    SignedBounds(b);
    if Signed(a) < 0 { if Signed(b) < 0 {} else {} }
    else { if Signed(b) < 0 {} else {} }
  }
  lemma SignedProductTooLarge(a: Word,b: Word)
    requires a != 0 && Abs(Signed(a)*Signed(b)) > Modulus()/2
    ensures SignedQuotient(Product(b,a),a) != b
  {
    MagnitudeBound(a); MagnitudeBound(b); MagnitudeBound(Product(b,a));
    AbsoluteProduct(Signed(a),Signed(b));
    DivideBelowProduct(Magnitude(Product(b,a)),Magnitude(a),Magnitude(b));
    QuotientMagnitude(Product(b,a),a);
  }
  lemma SignedPositiveBoundary(a: Word,b: Word)
    requires Signed(a)*Signed(b) == Modulus()/2
    requires !(Signed(a) < 0 && b == Modulus()/2)
    ensures SignedQuotient(Product(b,a),a) != b
  {
    SignedBounds(a); SignedBounds(b); MagnitudeBound(a); MagnitudeBound(b);
    SignedProductProjection(a,b); ProductSymmetric(a,b);
    AbsoluteProduct(Signed(a),Signed(b));
    DivideProduct(Magnitude(a),Magnitude(b));
    assert a != 0 && b != 0 && b != Modulus()/2;
    if Signed(a) < 0 { assert Signed(b) < 0; }
    else { assert Signed(b) > 0; }
    assert SignedQuotient(Product(b,a),a) == (-(Signed(b)))%Modulus();
    assert SignedQuotient(Product(b,a),a) == Modulus()-b;
  }
  lemma BooleanAnd(left: Word,right: Word)
    requires left <= 1 && right <= 1
    ensures BitAnd(left,right) == (if left != 0 && right != 0 then 1 else 0)
  {
    C.Nat256(left); C.Nat256(right); C.Inverse256(0 as bv256); C.Inverse256(1 as bv256);
    reveal BitAnd();
  }
  lemma BooleanOr(left: Word,right: Word)
    requires left <= 1 && right <= 1
    ensures BitOr(left,right) == (if left != 0 || right != 0 then 1 else 0)
  {
    C.Nat256(left); C.Nat256(right); C.Inverse256(0 as bv256); C.Inverse256(1 as bv256);
    reveal BitOr();
  }
  lemma SignedProductCheck(a: Word,b: Word)
    ensures BitAnd((if b == Modulus()/2 then 1 else 0),(if Signed(a) < 0 then 1 else 0)) ==
            (if Signed(a) < 0 && b == Modulus()/2 then 1 else 0)
    ensures !(Signed(a) < 0 && b == Modulus()/2) ==>
              (BitOr((if a == 0 then 1 else 0),(if b == SignedQuotient(Product(b,a),a) then 1 else 0)) != 0 <==>
               -(Modulus()/2) <= Signed(a)*Signed(b) < Modulus()/2)
  {
    BooleanAnd((if b == Modulus()/2 then 1 else 0),(if Signed(a) < 0 then 1 else 0));
    BooleanOr((if a == 0 then 1 else 0),(if b == SignedQuotient(Product(b,a),a) then 1 else 0));
    if !(Signed(a) < 0 && b == Modulus()/2) {
      if a == 0 {}
      else if -(Modulus()/2) <= Signed(a)*Signed(b) < Modulus()/2 { SignedProductFitting(a,b); }
      else if Signed(a)*Signed(b) == Modulus()/2 { SignedPositiveBoundary(a,b); }
      else { SignedProductTooLarge(a,b); }
    }
  }
  function Product(a: Word,b: Word): Word { (a*b)%Modulus() }
  lemma ProductSymmetric(a: Word,b: Word)
    ensures Product(a,b) == Product(b,a)
  {}
  lemma CheckedProduct(a: Word,b: Word)
    requires a*b < Modulus()
    ensures Product(a,b) == a*b
  {}
  lemma DivideProduct(denominator: nat,other: nat)
    requires denominator > 0
    ensures (denominator*other)/denominator == other
  { DivisionUnique(denominator*other,denominator,other,0); }
  lemma DivideBelowProduct(n: nat,denominator: nat,other: nat)
    requires denominator > 0 && n < denominator*other
    ensures n/denominator < other
  {
    var quotient := n/denominator;
    assert n == quotient*denominator+n%denominator;
    if quotient >= other {
      ScaleLe(other,quotient,denominator);
      assert denominator*other <= quotient*denominator <= n;
      assert false;
    }
  }
  lemma ProductOverflow(a: Word,b: Word)
    requires a > 0
    ensures (Product(a,b)/a != b) == (a*b >= Modulus())
  {
    if a*b < Modulus() { CheckedProduct(a,b); DivideProduct(a,b); }
    else { assert Product(a,b) < Modulus() <= a*b; DivideBelowProduct(Product(a,b),a,b); }
  }
  lemma ProductCheck(a: Word,b: Word)
    ensures BitOr((if a == 0 then 1 else 0),(if Quotient(Product(b,a),a) == b then 1 else 0)) == (if a*b < Modulus() then 1 else 0)
    ensures BitOr((if Quotient(Product(b,a),a) == b then 1 else 0),(if a == 0 then 1 else 0)) == (if a*b < Modulus() then 1 else 0)
  {
    ProductSymmetric(a,b);
    if a > 0 { ProductOverflow(a,b); }
    BooleanOr((if a == 0 then 1 else 0),(if Quotient(Product(b,a),a) == b then 1 else 0));
    BooleanOr((if Quotient(Product(b,a),a) == b then 1 else 0),(if a == 0 then 1 else 0));
  }
  function Quotient(a: Word,b: Word): Word { if b == 0 then 0 else a/b }
  function Remainder(a: Word,b: Word): Word { if b == 0 then 0 else a%b }
  function Panic(number: Word): seq<Byte> { Encode(0x4e487b71,4)+Encode(number,32) }
  function PanicWord(): Word { 0x4e487b7100000000000000000000000000000000000000000000000000000000 }
  lemma Widen32(bits: bv32)
    ensures ((bits as bv256) as int) == (bits as int)
  {}
  lemma JoinPanic32(bits: bv32)
    ensures ((((bits as bv64) << 32) as int)) == (bits as int)*0x100000000
  { C.Join64(bits,0); }
  lemma JoinPanic64(bits: bv64)
    ensures ((((bits as bv128) << 64) as int)) == (bits as int)*0x10000000000000000
  { C.Join128(bits,0); }
  lemma JoinPanic128(bits: bv128)
    ensures ((((bits as bv256) << 128) as int)) == (bits as int)*0x100000000000000000000000000000000
  { C.Join256(bits,0); }
  lemma PanicJoin(bits: bv32)
    ensures ((((((bits as bv64) << 32) as bv128) << 64) as bv256) << 128) as int == (bits as int)*0x100000000000000000000000000000000000000000000000000000000
  {
    var upper64 := (bits as bv64) << 32;
    var upper128 := (upper64 as bv128) << 64;
    JoinPanic32(bits); JoinPanic64(upper64); JoinPanic128(upper128);
  }
  lemma PanicBits(bits: bv32)
    ensures (bits as bv256) << 224 == (((((bits as bv64) << 32) as bv128) << 64) as bv256) << 128
  {}
  lemma FixedPanicStride(bits: bv32)
    ensures (((bits as bv256) << 224) as nat) == (bits as nat)*0x100000000000000000000000000000000000000000000000000000000
  {
    PanicJoin(bits); PanicBits(bits);
    NatEquality((bits as bv256) << 224, (((((bits as bv64) << 32) as bv128) << 64) as bv256) << 128);
  }
  lemma NumericShiftCongruence(bits: bv256,left: nat,right: nat)
    requires left == right && left <= 256 && right <= 256
    ensures ((bits << left) as nat) == ((bits << right) as nat)
  {}
  lemma ShiftCongruence(bits: bv256,left: nat,right: nat)
    requires left == right && left <= 256 && right <= 256
    ensures (bits << left) == (bits << right)
  {}
  lemma NatEquality(left: bv256,right: bv256)
    requires left == right
    ensures (left as nat) == (right as nat)
  {}
  lemma SmallInput(input: Word)
    requires input < 0x100000000
    ensures (input as bv256) == ((input as bv32) as bv256)
  {
    C.Nat32(input);
    var bits := (input as bv32) as bv256;
    Widen32(input as bv32);
    assert (bits as int) == input;
    C.Inverse256(bits);
  }
  lemma ShiftDefinition(input: Word,amount: Word)
    ensures Shift(input,amount) == (if amount >= 256 then 0 else ((input as bv256) << (amount as nat)) as nat)
  { reveal Shift(); }
  lemma ShiftProjectionCongruence(left: bv256,right: bv256,amount: nat)
    requires left == right && amount <= 256
    ensures (((left << amount) as nat)) == (((right << amount) as nat))
  {}
  lemma ShiftBridge(input: Word,amount: Word,bits: bv256,result: Word)
    requires amount < 256 && (input as bv256) == bits
    requires result == ((bits << (amount as nat)) as nat)
    ensures Shift(input,amount) == result
  { ShiftDefinition(input,amount); ShiftProjectionCongruence(input as bv256,bits,amount); }
  lemma ShiftBridgeAt(input: Word,amount: Word,shiftAmount: nat,bits: bv256,result: Word)
    requires amount < 256 && shiftAmount <= 256 && amount == shiftAmount
    requires (input as bv256) == bits && result == ((bits << shiftAmount) as nat)
    ensures Shift(input,amount) == result
  {
    ShiftDefinition(input,amount);
    ShiftProjectionCongruence(input as bv256,bits,amount);
    NumericShiftCongruence(bits,amount,shiftAmount);
  }
  lemma PanicShift()
    ensures Shift(0x4e487b71,224) == PanicWord()
  {
    hide Shift();
    var input: Word := 0x4e487b71;
    var amount: Word := 224;
    var small := input as bv32;
    var bits := small as bv256;
    var expected: Word := PanicWord();
    C.Nat32(input); SmallInput(input);
    FixedPanicStride(small);
    assert expected == input*0x100000000000000000000000000000000000000000000000000000000;
    ShiftBridgeAt(input,amount,224,bits,expected);
  }
  lemma ScaleLe(left: nat,right: nat,factor: nat)
    requires left <= right
    ensures left*factor <= right*factor
  {
    assert (right-left)*factor >= 0;
    assert right*factor == left*factor+(right-left)*factor;
  }
  lemma DivisionUnique(n: nat,denominator: nat,quotient: nat,remainder: nat)
    requires denominator > 0 && remainder < denominator
    requires n == quotient*denominator+remainder
    ensures n/denominator == quotient
  {
    var actual := n/denominator;
    var rest := n%denominator;
    assert n == actual*denominator+rest;
    if actual < quotient {
      ScaleLe(actual+1,quotient,denominator);
      assert n < (actual+1)*denominator;
      assert quotient*denominator <= n;
      assert false;
    } else if quotient < actual {
      ScaleLe(quotient+1,actual,denominator);
      assert n < (quotient+1)*denominator;
      assert actual*denominator <= n;
      assert false;
    }
  }
  lemma Division256(n: nat,denominator: nat)
    requires denominator > 0
    ensures (n/256)/denominator == n/(256*denominator)
  {
    var upper: nat := n/256;
    var low: nat := n%256;
    var quotient: nat := upper/denominator;
    var remainder: nat := upper%denominator;
    assert upper == quotient*denominator+remainder;
    assert n == upper*256+low;
    assert 0 <= remainder*256+low < 256*denominator;
    assert n == quotient*(256*denominator)+(remainder*256+low);
    DivisionUnique(n,256*denominator,quotient,remainder*256+low);
    assert n/(256*denominator) == quotient;
  }
  lemma EncodeConcat(n: nat,left: nat,right: nat)
    ensures Encode(n,left+right) == Encode(n/Pow256(right),left)+Encode(n,right)
    decreases right
  {
    if right > 0 {
      EncodeConcat(n/256,left,right-1);
      assert Pow256(right) == 256*Pow256(right-1);
      Division256(n,Pow256(right-1));
      assert (n/256)/Pow256(right-1) == n/Pow256(right);
    }
  }
  lemma PanicStores(mem: seq<Byte>,number: Word)
    ensures Store(Store(mem,0,PanicWord()),4,number)[..36] == Panic(number)
  {
    WordPower();
    StoreLoad(mem,0,PanicWord());
    StoreLoad(Store(mem,0,PanicWord()),4,number);
    var first := Store(mem,0,PanicWord());
    var second := Store(first,4,number);
    assert second[..4] == first[..4];
    assert second[..36] == first[..4]+second[4..36];
    EncodeConcat(PanicWord(),4,28);
    assert PanicWord()/Pow256(28) == 0x4e487b71;
  }

  lemma MinimumBitProjection()
    ensures (((1 as bv256) << 255) as nat) == 0x8000000000000000000000000000000000000000000000000000000000000000
  {
    C.Nat32(0x80000000);
    FixedPanicStride(0x80000000 as bv32);
    NatEquality((1 as bv256) << 255,((0x80000000 as bv32) as bv256) << 224);
  }
  lemma MinimumShift()
    ensures Shift(1,255) == Modulus()/2
  {
    hide Shift();
    C.Nat256(1);
    MinimumBitProjection();
    ShiftBridgeAt(1,255,255,1 as bv256,Modulus()/2);
  }

  function Fetch(code: seq<Byte>, pc: nat): Instruction
    requires pc < |code|
  {
    var op := code[pc];
    if op == 0x5f then Op(op,pc+1,0)
    else if op == 0x60 && pc+1 < |code| then Op(op,pc+2,code[pc+1] as nat)
    else if op == 0x61 && pc+2 < |code| then Op(op,pc+3,(code[pc+1] as nat)*256+(code[pc+2] as nat))
    else if op == 0x62 && pc+3 < |code| then Op(op,pc+4,((code[pc+1] as nat)*256+(code[pc+2] as nat))*256+(code[pc+3] as nat))
    else if op == 0x63 && pc+4 < |code| then Op(op,pc+5,(((code[pc+1] as nat)*256+(code[pc+2] as nat))*256+(code[pc+3] as nat))*256+(code[pc+4] as nat))
    else Op(op,pc+1,0)
  }

  opaque function Step(code: seq<Byte>, destinations: set<nat>, state: State,
                       value: Word, size: Word, word: Word, a: Word, b: Word): State {
    if !state.Running? then state
    else if state.pc >= |code| then Bad
    else
      var ins := Fetch(code,state.pc);
      var s := state.stack;
      var n := |s|;
      var mem := state.memory;
      if ins.op in {0x5f,0x60,0x61,0x62,0x63} && n < 1024 then Running(ins.next,s+[ins.immediate],mem)
      else if ins.op == 0x5b then Running(ins.next,s,mem)
      else if ins.op == 0x34 && n < 1024 then Running(ins.next,s+[value],mem)
      else if ins.op == 0x36 && n < 1024 then Running(ins.next,s+[size],mem)
      else if 0x80 <= ins.op <= 0x8f && n >= ins.op-0x7f && n < 1024 then Running(ins.next,s+[s[n-(ins.op-0x7f)]],mem)
      else if 0x90 <= ins.op <= 0x9f && n >= ins.op-0x8f+1 then
        var k := ins.op-0x8f;
        Running(ins.next,s[n-1:=s[n-1-k]][n-1-k:=s[n-1]],mem)
      else if ins.op == 0x50 && n >= 1 then Running(ins.next,s[..n-1],mem)
      else if ins.op == 0x15 && n >= 1 then Running(ins.next,s[..n-1]+[if s[n-1] == 0 then 1 else 0],mem)
      else if ins.op == 0x35 && n >= 1 && s[n-1] in {0,4,36} then Running(ins.next,s[..n-1]+[if s[n-1] == 0 then word else if s[n-1] == 4 then a else b],mem)
      else if ins.op == 0x02 && n >= 2 then Running(ins.next,s[..n-2]+[Product(s[n-1],s[n-2])],mem)
      else if ins.op == 0x05 && n >= 2 then Running(ins.next,s[..n-2]+[SignedQuotient(s[n-1],s[n-2])],mem)
      else if ins.op == 0x19 && n >= 1 then Running(ins.next,s[..n-1]+[Modulus()-1-s[n-1]],mem)
      else if ins.op == 0x04 && n >= 2 then Running(ins.next,s[..n-2]+[Quotient(s[n-1],s[n-2])],mem)
      else if ins.op == 0x06 && n >= 2 then Running(ins.next,s[..n-2]+[Remainder(s[n-1],s[n-2])],mem)
      else if ins.op == 0x1c && n >= 2 then Running(ins.next,s[..n-2]+[Right(s[n-2],s[n-1])],mem)
      else if ins.op == 0x1d && n >= 2 then Running(ins.next,s[..n-2]+[ArithmeticRight(s[n-2],s[n-1])],mem)
      else if ins.op == 0x1b && n >= 2 then Running(ins.next,s[..n-2]+[Shift(s[n-2],s[n-1])],mem)
      else if ins.op == 0x16 && n >= 2 then Running(ins.next,s[..n-2]+[BitAnd(s[n-1],s[n-2])],mem)
      else if ins.op == 0x18 && n >= 2 then Running(ins.next,s[..n-2]+[BitXor(s[n-1],s[n-2])],mem)
      else if ins.op == 0x17 && n >= 2 then Running(ins.next,s[..n-2]+[BitOr(s[n-1],s[n-2])],mem)
      else if ins.op == 0x01 && n >= 2 then Running(ins.next,s[..n-2]+[((s[n-1] as nat)+(s[n-2] as nat))%Modulus()],mem)
      else if ins.op == 0x03 && n >= 2 then Running(ins.next,s[..n-2]+[(s[n-1]+Modulus()-s[n-2])%Modulus()],mem)
      else if ins.op in {0x10,0x11,0x12,0x13,0x14} && n >= 2 then
        var truth := if ins.op == 0x10 then s[n-1] < s[n-2]
                     else if ins.op == 0x11 then s[n-1] > s[n-2]
                     else if ins.op == 0x12 then Signed(s[n-1]) < Signed(s[n-2])
                     else if ins.op == 0x13 then Signed(s[n-1]) > Signed(s[n-2])
                     else s[n-1] == s[n-2];
        Running(ins.next,s[..n-2]+[if truth then 1 else 0],mem)
      else if ins.op == 0x52 && n >= 2 then Running(ins.next,s[..n-2],Store(mem,s[n-1],s[n-2]))
      else if ins.op == 0x51 && n >= 1 then Running(ins.next,s[..n-1]+[Load(mem,s[n-1])],mem)
      else if ins.op == 0x56 && n >= 1 then
        if s[n-1] in destinations && s[n-1] < |code| && code[s[n-1]] == 0x5b then Running(s[n-1],s[..n-1],mem) else Bad
      else if ins.op == 0x57 && n >= 2 then
        if s[n-2] == 0 then Running(ins.next,s[..n-2],mem)
        else if s[n-1] in destinations && s[n-1] < |code| && code[s[n-1]] == 0x5b then Running(s[n-1],s[..n-2],mem)
        else Bad
      else if ins.op in {0xf3,0xfd} && n >= 2 then
        var bytes := Grow(mem,(s[n-1] as nat)+(s[n-2] as nat))[s[n-1]..(s[n-1] as nat)+(s[n-2] as nat)];
        if ins.op == 0xf3 then Returned(bytes) else Reverted(bytes)
      else Bad
  }
}
