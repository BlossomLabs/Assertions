// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "PayloadWindow.generated.dfy"
module OperationsHashRawBlockPayloadWindow5 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesPayloadWindow
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b) && R.Good(100,initial,value,|data|,word,a,b)
    ensures R.Good(120,state,value,|data|,word,a,b)
  {
    var size: Word:=|data|; state:=initial;
    R.Advance100(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18762,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance101(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18763,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance102(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18764,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,((4)+(a))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance103(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18765,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance104(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18767,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,1],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance105(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18769,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,1,1],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance106(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18771,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,1,1,64],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance107(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18772,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,1,18446744073709551616],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance108(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18773,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,18446744073709551615],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance109(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18774,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,18446744073709551615,b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance110(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18775,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,(if (b) > (18446744073709551615) then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance111(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18776,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,(if (if (b) > (18446744073709551615) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance112(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18779,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,(if (if (b) > (18446744073709551615) then 1 else 0) == 0 then 1 else 0),18783],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance113(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18783,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance114(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18784,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance115(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18786,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,32],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance116(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18787,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,32,((4)+(a))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance117(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18788,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),0,b,((((4)+(a))%Modulus())+(32))%Modulus()],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance118(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18789,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance119(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(18790,[2854126814,1329,2513,size,4,0,0,a,19102,size,((4)+(a))%Modulus(),((((4)+(a))%Modulus())+(32))%Modulus(),b],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
  }
}
