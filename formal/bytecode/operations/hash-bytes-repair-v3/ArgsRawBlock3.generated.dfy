// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "Args.generated.dfy"
module OperationsHashRawBlockArgs3 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesArgs
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b) && R.Good(60,initial,value,|data|,word,a,b)
    ensures state==Reverted([])
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
    assert state==Running(19066,[2854126814,1329,2513,size,4,0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance69(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19067,[2854126814,1329,2513,size,4,0,0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance70(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19068,[2854126814,1329,2513,size,4,0,0,0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
  }
}
