module OperationsBinaryLogModel {
  const Word: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  datatype Outcome = Value(result: nat) | LogarithmUndefined(input: nat)
  function Power(n: nat): nat
    ensures Power(n) > 0
    decreases n
  { if n == 0 then 1 else 2*Power(n-1) }
  function Log(x: nat): nat
    decreases x
  { if x <= 1 then 0 else 1+Log(x/2) }
  function Spec(x: nat): Outcome
  { if x == 0 then LogarithmUndefined(0) else Value(Log(x)) }
  function Bool(b: bool): nat { if b then 1 else 0 }
  function Iszero(n: nat): nat { if n == 0 then 1 else 0 }
  function Byte(index: nat,word: nat): nat
  { if index >= 32 then 0 else (word/Power(8*(31-index)))%256 }
  function Or(a: bv8,b: bv8): bv8 { a|b }
  lemma ZeroExtendOr(a: bv8,b: bv8)
    ensures ((a as bv256)|(b as bv256)) == ((a|b) as bv256)
  { }
  lemma ProductNonnegative(a: nat,b: nat)
    ensures a*b >= 0
  { }
  lemma ProductMonotone(a: nat,b: nat,c: nat)
    requires a <= b
    ensures a*c <= b*c
  { ProductNonnegative(b-a,c); assert b*c == a*c+(b-a)*c; }
  lemma PowerAdd(a: nat,b: nat)
    ensures Power(a+b) == Power(a)*Power(b)
    decreases a
  { if a > 0 { PowerAdd(a-1,b); } }
  lemma Quotient(a: nat,b: nat,d: nat)
    requires d > 0 && b < d
    ensures (a*d+b)/d == a
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
  lemma DivideNested(n: nat,d: nat,e: nat)
    requires d > 0 && e > 0
    ensures (n/d)/e == n/(d*e)
  {
    var q := n/d/e;
    var innerR := (n/d)%e;
    var outerR := n%d;
    assert n/d == q*e+innerR;
    assert n == (q*e+innerR)*d+outerR;
    ProductMonotone(innerR+1,e,d);
    assert innerR*d+outerR < d*e;
    assert n == q*(d*e)+(innerR*d+outerR);
    Quotient(q,innerR*d+outerR,d*e);
  }
  lemma LogShift(x: nat,k: nat)
    requires x >= Power(k)
    ensures Log(x) == k+Log(x/Power(k))
    decreases k
  {
    if k > 0 {
      assert x/2 >= Power(k-1);
      LogShift(x/2,k-1);
      DivideNested(x,2,Power(k-1));
    }
  }
  lemma SmallLog(x: nat)
    requires x < 16
    ensures Log(x) == (if x < 2 then 0 else if x < 4 then 1 else if x < 8 then 2 else 3)
  { if x > 1 { SmallLog(x/2); } }
  lemma OrClear(a: bv8,b: bv8)
    requires a&b == 0 && (a as int)+(b as int) < 256
    ensures (Or(a,b) as int) == (a as int)+(b as int)
  { }
  lemma QuotientUpper(n: nat,d: nat,limit: nat)
    requires d > 0 && n < d*limit
    ensures n/d < limit
  {
    var q := n/d;
    assert n == q*d+n%d;
    if q >= limit { ProductMonotone(limit,q,d); }
  }
  lemma Stage(x: nat,previous: bv8,step: nat,next: bv8)
    requires step in {4,8,16,32,64,128}
    requires previous&(step as bv8) == 0 && (previous as int)+step < 256
    requires x/Power(previous as int) < Power(2*step)
    requires next == Or(previous,if x/Power(previous as int) >= Power(step) then step as bv8 else 0)
    ensures (next as int) >= (previous as int)
    ensures 0 <= x/Power(next as int) < Power(step)
    ensures (previous as int)+Log(x/Power(previous as int)) == (next as int)+Log(x/Power(next as int))
  {
    var q := x/Power(previous as int);
    if q >= Power(step) {
      OrClear(previous,step as bv8);
      assert (next as int) == (previous as int)+step;
      LogShift(q,step);
      DivideNested(x,Power(previous as int),Power(step));
      PowerAdd(previous as int,step);
      PowerAdd(step,step);
      QuotientUpper(q,Power(step),Power(step));
    } else { assert next == previous; }
  }

  lemma KnownPowers()
    ensures Power(4) == 16 && Power(8) == 256 && Power(16) == 65536
    ensures Power(32) == 4294967296 && Power(64) == 18446744073709551616
    ensures Power(128) == 340282366920938463463374607431768211456 && Power(256) == Word
  {
    assert Power(4) == 16;
    PowerAdd(4,4);
    assert Power(8) == 256;
    PowerAdd(8,8);
    assert Power(16) == 65536;
    PowerAdd(16,16);
    assert Power(32) == 4294967296;
    PowerAdd(32,32);
    assert Power(64) == 18446744073709551616;
    PowerAdd(64,64);
    assert Power(128) == 340282366920938463463374607431768211456;
    PowerAdd(128,128);
    assert Power(256) == 115792089237316195423570985008687907853269984665640564039457584007913129639936;
  }
  lemma BytePowers()
    ensures Power(8) == 256
    ensures Power(16) == 65536
    ensures Power(24) == 16777216
    ensures Power(32) == 4294967296
    ensures Power(40) == 1099511627776
    ensures Power(48) == 281474976710656
    ensures Power(56) == 72057594037927936
    ensures Power(64) == 18446744073709551616
    ensures Power(72) == 4722366482869645213696
    ensures Power(80) == 1208925819614629174706176
    ensures Power(88) == 309485009821345068724781056
    ensures Power(96) == 79228162514264337593543950336
    ensures Power(104) == 20282409603651670423947251286016
    ensures Power(112) == 5192296858534827628530496329220096
    ensures Power(120) == 1329227995784915872903807060280344576
    ensures Power(128) == 340282366920938463463374607431768211456
    ensures Power(136) == 87112285931760246646623899502532662132736
    ensures Power(144) == 22300745198530623141535718272648361505980416
    ensures Power(152) == 5708990770823839524233143877797980545530986496
    ensures Power(160) == 1461501637330902918203684832716283019655932542976
    ensures Power(168) == 374144419156711147060143317175368453031918731001856
    ensures Power(176) == 95780971304118053647396689196894323976171195136475136
    ensures Power(184) == 24519928653854221733733552434404946937899825954937634816
    ensures Power(192) == 6277101735386680763835789423207666416102355444464034512896
    ensures Power(200) == 1606938044258990275541962092341162602522202993782792835301376
    ensures Power(208) == 411376139330301510538742295639337626245683966408394965837152256
    ensures Power(216) == 105312291668557186697918027683670432318895095400549111254310977536
    ensures Power(224) == 26959946667150639794667015087019630673637144422540572481103610249216
    ensures Power(232) == 6901746346790563787434755862277025452451108972170386555162524223799296
    ensures Power(240) == 1766847064778384329583297500742918515827483896875618958121606201292619776
    ensures Power(248) == 452312848583266388373324160190187140051835877600158453279131187530910662656
  {
    KnownPowers();
    PowerAdd(8,8);
    assert Power(16) == 65536;
    PowerAdd(8,16);
    assert Power(24) == 16777216;
    PowerAdd(8,24);
    assert Power(32) == 4294967296;
    PowerAdd(8,32);
    assert Power(40) == 1099511627776;
    PowerAdd(8,40);
    assert Power(48) == 281474976710656;
    PowerAdd(8,48);
    assert Power(56) == 72057594037927936;
    PowerAdd(8,56);
    assert Power(64) == 18446744073709551616;
    PowerAdd(8,64);
    assert Power(72) == 4722366482869645213696;
    PowerAdd(8,72);
    assert Power(80) == 1208925819614629174706176;
    PowerAdd(8,80);
    assert Power(88) == 309485009821345068724781056;
    PowerAdd(8,88);
    assert Power(96) == 79228162514264337593543950336;
    PowerAdd(8,96);
    assert Power(104) == 20282409603651670423947251286016;
    PowerAdd(8,104);
    assert Power(112) == 5192296858534827628530496329220096;
    PowerAdd(8,112);
    assert Power(120) == 1329227995784915872903807060280344576;
    PowerAdd(8,120);
    assert Power(128) == 340282366920938463463374607431768211456;
    PowerAdd(8,128);
    assert Power(136) == 87112285931760246646623899502532662132736;
    PowerAdd(8,136);
    assert Power(144) == 22300745198530623141535718272648361505980416;
    PowerAdd(8,144);
    assert Power(152) == 5708990770823839524233143877797980545530986496;
    PowerAdd(8,152);
    assert Power(160) == 1461501637330902918203684832716283019655932542976;
    PowerAdd(8,160);
    assert Power(168) == 374144419156711147060143317175368453031918731001856;
    PowerAdd(8,168);
    assert Power(176) == 95780971304118053647396689196894323976171195136475136;
    PowerAdd(8,176);
    assert Power(184) == 24519928653854221733733552434404946937899825954937634816;
    PowerAdd(8,184);
    assert Power(192) == 6277101735386680763835789423207666416102355444464034512896;
    PowerAdd(8,192);
    assert Power(200) == 1606938044258990275541962092341162602522202993782792835301376;
    PowerAdd(8,200);
    assert Power(208) == 411376139330301510538742295639337626245683966408394965837152256;
    PowerAdd(8,208);
    assert Power(216) == 105312291668557186697918027683670432318895095400549111254310977536;
    PowerAdd(8,216);
    assert Power(224) == 26959946667150639794667015087019630673637144422540572481103610249216;
    PowerAdd(8,224);
    assert Power(232) == 6901746346790563787434755862277025452451108972170386555162524223799296;
    PowerAdd(8,232);
    assert Power(240) == 1766847064778384329583297500742918515827483896875618958121606201292619776;
    PowerAdd(8,240);
    assert Power(248) == 452312848583266388373324160190187140051835877600158453279131187530910662656;
  }
  lemma Table(index: nat,word: nat)
    requires index < 16 && word == 6928917744019834342450304135053993530982274426945361611473370484834304
    ensures Byte(index,word) == Log(index) && Byte(index,word) < 4
  {
    BytePowers(); SmallLog(index);
    if index == 0 { assert Byte(index,word) == 0; }
    else if index == 1 { assert Byte(index,word) == 0; }
    else if index == 2 { assert Byte(index,word) == 1; }
    else if index == 3 { assert Byte(index,word) == 1; }
    else if index == 4 { assert Byte(index,word) == 2; }
    else if index == 5 { assert Byte(index,word) == 2; }
    else if index == 6 { assert Byte(index,word) == 2; }
    else if index == 7 { assert Byte(index,word) == 2; }
    else if index == 8 { assert Byte(index,word) == 3; }
    else if index == 9 { assert Byte(index,word) == 3; }
    else if index == 10 { assert Byte(index,word) == 3; }
    else if index == 11 { assert Byte(index,word) == 3; }
    else if index == 12 { assert Byte(index,word) == 3; }
    else if index == 13 { assert Byte(index,word) == 3; }
    else if index == 14 { assert Byte(index,word) == 3; }
    else if index == 15 { assert Byte(index,word) == 3; }
  }

  lemma Floor(x: nat)
    requires x > 0
    ensures Power(Log(x)) <= x < Power(Log(x)+1)
    decreases x
  {
    if x > 1 {
      Floor(x/2);
      assert x == 2*(x/2)+x%2;
      assert Log(x) == 1+Log(x/2);
      assert Power(Log(x)) == 2*Power(Log(x/2));
      assert Power(Log(x)+1) == 2*Power(Log(x/2)+1);
    }
  }

}
