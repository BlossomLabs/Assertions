// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "../hash-bytes-repair-v3/Execution.dfy"
include "Prefix.generated.dfy"
module OperationsHashRawBlockPrefix3 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashSuccessPrefix
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b) && R.Good(60,initial,value,|data|,word,a,b)
    ensures R.Good(80,state,value,|data|,word,a,b)
  {
    var size: Word:=|data|; state:=initial;
    R.Advance60(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19055,[2854126814,1329,2513,size,4,0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance61(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19057,[2854126814,1329,2513,size,4,0,0,32],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance62(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19058,[2854126814,1329,2513,size,4,0,0,32,4],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance63(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19059,[2854126814,1329,2513,size,4,0,0,32,4,size],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance64(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19060,[2854126814,1329,2513,size,4,0,0,32,((size)+Modulus()-(4))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance65(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19061,[2854126814,1329,2513,size,4,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance66(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19062,[2854126814,1329,2513,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance67(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19065,[2854126814,1329,2513,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0),19069],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance68(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19069,[2854126814,1329,2513,size,4,0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance69(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19070,[2854126814,1329,2513,size,4,0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance70(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19071,[2854126814,1329,2513,size,4,0,0,4],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance71(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19072,[2854126814,1329,2513,size,4,0,0,a],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance72(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19074,[2854126814,1329,2513,size,4,0,0,a,1],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance73(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19076,[2854126814,1329,2513,size,4,0,0,a,1,1],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance74(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19078,[2854126814,1329,2513,size,4,0,0,a,1,1,64],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance75(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19079,[2854126814,1329,2513,size,4,0,0,a,1,18446744073709551616],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance76(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19080,[2854126814,1329,2513,size,4,0,0,a,18446744073709551615],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance77(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19081,[2854126814,1329,2513,size,4,0,0,a,18446744073709551615,a],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance78(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19082,[2854126814,1329,2513,size,4,0,0,a,(if (a) > (18446744073709551615) then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance79(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19083,[2854126814,1329,2513,size,4,0,0,a,(if (if (a) > (18446744073709551615) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
  }
}
