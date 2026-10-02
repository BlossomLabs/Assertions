module OperationsWordMatchModel {
  const Word: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  const Half: int := Word/2
  function Power(n: nat): nat
    ensures Power(n) > 0
    decreases n
  { if n == 0 then 1 else 256*Power(n-1) }
  function Bits(n: nat): nat
    ensures Bits(n) > 0
    decreases n
  { if n == 0 then 1 else 2*Bits(n-1) }
  function Pack(s: seq<bv8>): nat
    decreases |s|
  { if |s| == 0 then 0 else Pack(s[..|s|-1])*256+(s[|s|-1] as int) }
  function Shl(shift: nat,value: nat): nat
  { if shift >= 256 then 0 else (value*Bits(shift))%Word }
  function Shr(shift: nat,value: nat): nat
  { if shift >= 256 then 0 else value/Bits(shift) }
  function Window(s: seq<bv8>,offset: nat,outside: seq<bv8>): seq<bv8>
    requires offset <= |s| && |outside| == 32
    ensures |Window(s,offset,outside)| == 32
  {
    var available := if |s|-offset < 32 then |s|-offset else 32;
    s[offset..offset+available]+outside[..32-available]
  }
  predicate Matches(s: seq<bv8>,needle: seq<bv8>,pos: nat)
    requires pos+|needle| <= |s|
  { s[pos..pos+|needle|] == needle }
  predicate Contains(s: seq<bv8>,needle: seq<bv8>)
  { |needle| <= |s| && exists p | 0 <= p <= |s|-|needle| :: Matches(s,needle,p) }
  lemma ProductNonnegative(a: nat,b: nat)
    ensures a*b >= 0
  { }
  lemma ProductMonotone(a: nat,b: nat,c: nat)
    requires a <= b
    ensures a*c <= b*c
  { ProductNonnegative(b-a,c); assert b*c == a*c+(b-a)*c; }
  lemma BitsAdd(a: nat,b: nat)
    ensures Bits(a+b) == Bits(a)*Bits(b)
    decreases a
  { if a > 0 { BitsAdd(a-1,b); } }
  lemma BitsBytes(n: nat)
    ensures Bits(8*n) == Power(n)
    decreases n
  {
    if n > 0 {
      BitsBytes(n-1);
      BitsAdd(8,8*(n-1));
      assert Bits(8) == 256;
    }
  }
  lemma PowerAdd(a: nat,b: nat)
    ensures Power(a+b) == Power(a)*Power(b)
    decreases a
  { if a > 0 { PowerAdd(a-1,b); } }
  lemma WordPower()
    ensures Power(32) == Word
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
  lemma PackBound(s: seq<bv8>)
    ensures Pack(s) < Power(|s|)
    decreases |s|
  {
    if |s| > 0 {
      PackBound(s[..|s|-1]);
      ProductMonotone(Pack(s[..|s|-1])+1,Power(|s|-1),256);
    }
  }
  lemma PackSplit(s: seq<bv8>,k: nat)
    requires k <= |s|
    ensures Pack(s) == Pack(s[..k])*Power(|s|-k)+Pack(s[k..])
    decreases |s|-k
  {
    if k == |s| {
      assert s[..k] == s;
      assert s[k..] == [];
    } else {
      PackSplit(s[..|s|-1],k);
      assert s[..|s|-1][..k] == s[..k];
      assert s[..|s|-1][k..] == s[k..][..|s[k..]|-1];
      assert s[k..][|s[k..]|-1] == s[|s|-1];
      assert Power(|s|-k) == 256*Power(|s|-k-1);
    }
  }
  lemma Quotient(a: nat,b: nat,d: nat)
    requires d > 0 && b < d
    ensures (a*d+b)/d == a
    ensures (a*d+b)%d == b
  {
    var value := a*d+b;
    var q := value/d;
    assert value == q*d+value%d;
    if q < a {
      ProductMonotone(q+1,a,d);
      assert (q+1)*d == q*d+d;
      assert value < q*d+d;
    } else if q > a {
      ProductMonotone(a+1,q,d);
      assert (a+1)*d == a*d+d;
      assert value >= q*d;
    }
  }
  lemma PackPrefix(s: seq<bv8>,k: nat)
    requires k <= |s|
    ensures Pack(s)/Power(|s|-k) == Pack(s[..k])
  {
    PackSplit(s,k);
    PackBound(s[k..]);
    Quotient(Pack(s[..k]),Pack(s[k..]),Power(|s|-k));
  }
  lemma PackInjective(a: seq<bv8>,b: seq<bv8>)
    requires |a| == |b| && Pack(a) == Pack(b)
    ensures a == b
    decreases |a|
  {
    if |a| > 0 {
      Quotient(Pack(a[..|a|-1]),a[|a|-1] as int,256);
      Quotient(Pack(b[..|b|-1]),b[|b|-1] as int,256);
      assert a[|a|-1] == b[|b|-1];
      assert Pack(a[..|a|-1]) == Pack(b[..|b|-1]);
      PackInjective(a[..|a|-1],b[..|b|-1]);
      assert a == a[..|a|-1]+[a[|a|-1]];
      assert b == b[..|b|-1]+[b[|b|-1]];
    }
  }
  lemma WindowPrefix(s: seq<bv8>,offset: nat,outside: seq<bv8>,k: nat)
    requires offset <= |s| && |outside| == 32 && k <= 32 && offset+k <= |s|
    ensures Window(s,offset,outside)[..k] == s[offset..offset+k]
  {
    var available := if |s|-offset < 32 then |s|-offset else 32;
    assert k <= available;
    assert (s[offset..offset+available]+outside[..32-available])[..k] == s[offset..offset+k];
  }
  lemma ShiftPrefix(word: seq<bv8>,k: nat)
    requires |word| == 32 && 1 <= k <= 32
    ensures Shr(8*(32-k),Pack(word)) == Pack(word[..k])
  { BitsBytes(32-k); PackPrefix(word,k); }
  lemma Drop(left: nat)
    requires 1 <= left < 32
    ensures Shl(3,32-left) == 8*(32-left)
  { assert Bits(3) == 8; }
  lemma MatchedPrefix(s: seq<bv8>,needle: seq<bv8>,pos: nat,j: nat,k: nat)
    requires pos+|needle| <= |s| && j+k <= |needle|
    requires s[pos..pos+j] == needle[..j]
    requires s[pos+j..pos+j+k] == needle[j..j+k]
    ensures s[pos..pos+j+k] == needle[..j+k]
  {
    assert s[pos..pos+j+k] == s[pos..pos+j]+s[pos+j..pos+j+k];
    assert needle[..j+k] == needle[..j]+needle[j..j+k];
  }
  lemma Mismatch(s: seq<bv8>,needle: seq<bv8>,pos: nat,j: nat,k: nat)
    requires pos+|needle| <= |s| && j+k <= |needle|
    requires s[pos+j..pos+j+k] != needle[j..j+k]
    ensures !Matches(s,needle,pos)
  {
    if Matches(s,needle,pos) {
      forall z {:trigger needle[j..j+k][z]} | 0 <= z < k
        ensures s[pos+j..pos+j+k][z] == needle[j..j+k][z]
      { assert s[pos..pos+|needle|][j+z] == needle[j+z]; }
      assert s[pos+j..pos+j+k] == needle[j..j+k];
    }
  }
}
