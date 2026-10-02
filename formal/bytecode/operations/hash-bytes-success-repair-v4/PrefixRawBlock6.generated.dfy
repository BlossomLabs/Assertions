// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "../hash-bytes-repair-v3/Execution.dfy"
include "Prefix.generated.dfy"
module OperationsHashRawBlockPrefix6 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashSuccessPrefix
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b) && R.Good(120,initial,value,|data|,word,a,b)
    ensures R.Good(140,state,value,|data|,word,a,b)
  {
    var size: Word:=|data|; state:=initial;
    R.Advance120(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18791,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,size],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance121(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18793,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,size,32],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance122(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18794,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,size,32,b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance123(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18795,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,size,32,b,((4)+(a))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance124(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18796,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,size,32,((((4)+(a))%Modulus())+(b))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance125(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18797,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,size,((((((4)+(a))%Modulus())+(b))%Modulus())+(32))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance126(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18798,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,(if (((((((4)+(a))%Modulus())+(b))%Modulus())+(32))%Modulus()) > (size) then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance127(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18799,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,(if (if (((((((4)+(a))%Modulus())+(b))%Modulus())+(32))%Modulus()) > (size) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance128(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18802,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,(if (if (((((((4)+(a))%Modulus())+(b))%Modulus())+(32))%Modulus()) > (size) then 1 else 0) == 0 then 1 else 0),18806],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance129(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18806,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance130(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18807,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance131(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18808,[2854126814,1329,2513,size,4,0,0,a,19102,b,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),size],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance132(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18809,[2854126814,1329,2513,size,4,0,0,a,19102,b,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance133(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18810,[2854126814,1329,2513,size,4,0,0,a,((((4)+(a))%Modulus())+(32))%Modulus(),b,((4)+(a))%Modulus(),19102],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance134(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18811,[2854126814,1329,2513,size,4,0,0,a,((((4)+(a))%Modulus())+(32))%Modulus(),b,19102,((4)+(a))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance135(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18812,[2854126814,1329,2513,size,4,0,0,a,((((4)+(a))%Modulus())+(32))%Modulus(),b,19102],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance136(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19102,[2854126814,1329,2513,size,4,0,0,a,((((4)+(a))%Modulus())+(32))%Modulus(),b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance137(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19103,[2854126814,1329,2513,size,4,0,0,a,((((4)+(a))%Modulus())+(32))%Modulus(),b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance138(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19104,[2854126814,1329,2513,size,4,0,0,a,b,((((4)+(a))%Modulus())+(32))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance139(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19105,[2854126814,1329,((((4)+(a))%Modulus())+(32))%Modulus(),size,4,0,0,a,b,2513],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
  }
}
