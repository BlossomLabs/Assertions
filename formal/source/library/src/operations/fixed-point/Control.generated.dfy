include "Bounds.dfy"
module OperationsFixedPointSource {
  import B = OperationsBinaryLogModel
  import L = OperationsBinaryLogSource
  import M = OperationsFixedPointModel
  import A = OperationsFixedPointBounds
  import P = OperationsFullMulDivSource
  method Reduce(entry: int) returns (x: int,k: int)
    requires M.Signed(entry)
    ensures x == M.ExpReduction(M.ExpScale(entry),M.ExpExponent(M.ExpScale(entry)))
    ensures k == M.ExpExponent(M.ExpScale(entry))
  {
    x := entry;
    x := M.S(M.Trunc(M.S(M.Shl(x,M.U(78))),3814697265625));
    k := M.Sar(M.S(M.S(M.Trunc(M.S(M.Shl(x,M.U(96))),54916777467707473351141471128))+39614081257132168796771975168),M.U(96));
    x := M.S(x-M.S(k*54916777467707473351141471128));
  }
  method ExpNumerator(x: int) returns (p: int)
    requires M.Signed(x)
    ensures p == M.ExpNumerator(x)
  {
    A.Powers(); A.ExpCoefficient();
    var y: int := M.S(x+1346386616545796478920950773328);
    y := M.S(M.Sar(M.S(y*x),M.U(96))+57155421227552351082224309758442);
    assert y == M.ExpY(x);
    p := M.S(M.S(y+x)-94201549194550492254356042504812);
    p := M.S(M.Sar(M.S(p*y),M.U(96))+28719021644029726153956944680412240);
    assert p == M.ExpCore(x);
    p := M.S(M.S(p*x)+347437083999162433888837515002539729507623920905942392673140736);
  }
  method ExpDenominator(x: int) returns (q: int)
    requires M.Signed(x)
    ensures q == M.ExpDenominator(x)
  {
    q := M.S(x-2855989394907223263936484059900);
    assert M.ExpDenominator(x) == M.Horner(x,q,[50020603652535783019961831881945, -533845033583426703283633433725380, 3604857256930695427073651918091429, -14423608567350463180887372962807573, 26449188498355588339934803723976023]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+50020603652535783019961831881945);
    assert M.ExpDenominator(x) == M.Horner(x,q,[-533845033583426703283633433725380, 3604857256930695427073651918091429, -14423608567350463180887372962807573, 26449188498355588339934803723976023]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))-533845033583426703283633433725380);
    assert M.ExpDenominator(x) == M.Horner(x,q,[3604857256930695427073651918091429, -14423608567350463180887372962807573, 26449188498355588339934803723976023]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+3604857256930695427073651918091429);
    assert M.ExpDenominator(x) == M.Horner(x,q,[-14423608567350463180887372962807573, 26449188498355588339934803723976023]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))-14423608567350463180887372962807573);
    assert M.ExpDenominator(x) == M.Horner(x,q,[26449188498355588339934803723976023]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+26449188498355588339934803723976023);
    assert M.ExpDenominator(x) == M.Horner(x,q,[]);
  }
  method ExpParts(x: int) returns (p: int,q: int)
    requires M.Signed(x)
    ensures p == M.ExpNumerator(x) && q == M.ExpDenominator(x)
  { p := ExpNumerator(x); q := ExpDenominator(x); }
  method Normalize(entry: int,log: nat) returns (x: int,k: int)
    requires M.Signed(entry) && log < 256
    ensures x == M.LnNormalization(entry,log)
    ensures k == M.S((log as int)-96)
  {
    x := entry;
    A.Identity(log as int); A.Identity((log as int)-96); A.Identity(255-(log as int));
    k := M.S(M.S(log)-96);
    x := M.S(M.Shl(x,M.U(M.U(M.S(159-k)))));
    x := M.S(M.Shr(M.U(x),M.U(159)));
  }
  method LnParts(x: int) returns (p: int,q: int)
    requires M.Signed(x)
    ensures p == M.LnNumerator(x) && q == M.LnDenominator(x)
  {
    A.Powers();
    p := M.S(x+3273285459638523848632254066296);
    ghost var seed := p;
    assert M.Horner(x,seed,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]) == M.Horner(x,p,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]);
    p := M.S(M.Sar(M.S(p*x),M.U(96))+24828157081833163892658089445524);
    assert M.Horner(x,seed,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]) == M.Horner(x,p,[43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]);
    p := M.S(M.Sar(M.S(p*x),M.U(96))+43456485725739037958740375743393);
    assert M.Horner(x,seed,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]) == M.Horner(x,p,[-11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]);
    p := M.S(M.Sar(M.S(p*x),M.U(96))-11111509109440967052023855526967);
    assert M.Horner(x,seed,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]) == M.Horner(x,p,[-45023709667254063763336534515857, -14706773417378608786704636184526]);
    p := M.S(M.Sar(M.S(p*x),M.U(96))-45023709667254063763336534515857);
    assert M.Horner(x,seed,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]) == M.Horner(x,p,[-14706773417378608786704636184526]);
    p := M.S(M.Sar(M.S(p*x),M.U(96))-14706773417378608786704636184526);
    assert M.Horner(x,seed,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]) == M.Horner(x,p,[]);
    assert p == M.Horner(x,seed,[24828157081833163892658089445524, 43456485725739037958740375743393, -11111509109440967052023855526967, -45023709667254063763336534515857, -14706773417378608786704636184526]);
    p := M.S(M.S(p*x)-62999401287715976015676079709131874438408901006995465699328);
    q := M.S(x+5573035233440673466300451813936);
    assert M.LnDenominator(x) == M.Horner(x,q,[71694874799317883764090561454958, 283447036172924575727196451306956, 401686690394027663651624208769553, 204048457590392012362485061816622, 31853899698501571402653359427138, 909429971244387300277376558375]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+71694874799317883764090561454958);
    assert M.LnDenominator(x) == M.Horner(x,q,[283447036172924575727196451306956, 401686690394027663651624208769553, 204048457590392012362485061816622, 31853899698501571402653359427138, 909429971244387300277376558375]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+283447036172924575727196451306956);
    assert M.LnDenominator(x) == M.Horner(x,q,[401686690394027663651624208769553, 204048457590392012362485061816622, 31853899698501571402653359427138, 909429971244387300277376558375]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+401686690394027663651624208769553);
    assert M.LnDenominator(x) == M.Horner(x,q,[204048457590392012362485061816622, 31853899698501571402653359427138, 909429971244387300277376558375]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+204048457590392012362485061816622);
    assert M.LnDenominator(x) == M.Horner(x,q,[31853899698501571402653359427138, 909429971244387300277376558375]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+31853899698501571402653359427138);
    assert M.LnDenominator(x) == M.Horner(x,q,[909429971244387300277376558375]);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+909429971244387300277376558375);
    assert M.LnDenominator(x) == M.Horner(x,q,[]);
  }
  method LnFinish(entry: int,k: int) returns (r: int)
    requires M.Signed(entry)
    ensures r == M.LnFinish(entry,k) && M.Signed(r)
  {
    r := entry;
    r := M.S(r*1677202110996718588342820967067443963516166);
    r := M.S(r+M.S(16597577552685614221487285958193947469193820559219878177908093499208371*k));
    r := M.S(r+600920179829731861736702779321621459595472258049074101567377883020018308);
    ghost var previous := r;
    r := M.Sar(r,M.U(174));
    A.SignedShift(previous,M.U(174));
  }
  method ExpFinish(r: int,k: int) returns (out: int)
    ensures out == M.ExpFinish(r,k)
    ensures M.Signed(out)
  {
    A.Residue(M.U(r)*3822833074963236453042738258902158003155416615667);
    A.Residue(M.S(195-k));
    out := M.S(M.Shr(M.U(M.U(r)*3822833074963236453042738258902158003155416615667),M.U(M.U(M.S(195-k)))));
  }
  method Exp(entry: int) returns (out: M.Outcome)
    requires M.Signed(entry)
    ensures out == M.Exp(entry)
    ensures out.Value? ==> M.Signed(out.result)
    ensures out.Panic? ==> entry >= M.ExpUpper && out.code == 17
  {
    var x := entry;
    if (x <= -42139678854452767551) { out := M.Value(0); return; }
    if (x >= 135305999368893231589) {
      ghost var payload := P.OpsPanic(17,seq(64,i => 0));
      out := M.Panic(17); return;
    }
    var k: int;
    x,k := Reduce(entry);
    A.ScaledRange(entry); A.ReducedRange(M.ExpScale(entry));
    A.ExpDenominatorPositive(x);
    var p,q := ExpParts(x);
    assert q > 0;
    var r: int;
    r := M.S(M.Trunc(p,q));
    var result := ExpFinish(r,k);
    assert result == M.ExpFinish(M.S(M.Trunc(p,q)),k);
    out := M.Value(result);
  }
  method Ln(entry: int) returns (out: M.Outcome)
    requires M.Signed(entry)
    ensures out == M.Ln(entry)
    ensures out.Value? ==> M.Signed(out.result)
    ensures out.Undefined? ==> entry <= 0 && out.argument == entry
    ensures !out.Panic?
  {
    var x := entry;
    if (x <= 0) { out := M.Undefined(entry); return; }
    assert M.U(entry) == entry;
    var log := L.Library(M.U(entry));
    var k: int;
    x,k := Normalize(entry,log);
    A.NormalizedRange(entry,log);
    A.LnDenominatorPositive(x);
    var p,q := LnParts(x);
    assert q > 0;
    var r: int;
    r := M.S(M.Trunc(p,q));
    r := LnFinish(r,k);
    out := M.Value(r);
  }
  method ExpDenominatorWitness()
  {
    var x: int := 0;
    var q: int;
    A.Powers();
    A.Identity(-2855989394907223263936484059900);
    q := M.S(x-2855989394907223263936484059900);
    assert q == -2855989394907223263936484059900;
    A.Identity(50020603652535783019961831881945);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+50020603652535783019961831881945);
    assert q == 50020603652535783019961831881945;
    A.Identity(-533845033583426703283633433725380);
    q := M.S(M.Sar(M.S(q*x),M.U(96))-533845033583426703283633433725380);
    assert q == -533845033583426703283633433725380;
    A.Identity(3604857256930695427073651918091429);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+3604857256930695427073651918091429);
    assert q == 3604857256930695427073651918091429;
    A.Identity(-14423608567350463180887372962807573);
    q := M.S(M.Sar(M.S(q*x),M.U(96))-14423608567350463180887372962807573);
    assert q == -14423608567350463180887372962807573;
    A.Identity(26449188498355588339934803723976023);
    q := M.S(M.Sar(M.S(q*x),M.U(96))+26449188498355588339934803723976023);
    assert q == 26449188498355588339934803723976023;
    assert q == M.ExpDenominator(0);
  }
  method LnFinishWitness()
  {
    var r: int := 0;
    var k: int := 0;
    r := M.S(r*1677202110996718588342820967067443963516166);
    r := M.S(r+M.S(16597577552685614221487285958193947469193820559219878177908093499208371*k));
    r := M.S(r+600920179829731861736702779321621459595472258049074101567377883020018308);
    ghost var previous := r;
    r := M.Sar(r,M.U(174));
    A.SignedShift(previous,M.U(174));
    assert r == M.LnFinish(0,0);
  }
}
