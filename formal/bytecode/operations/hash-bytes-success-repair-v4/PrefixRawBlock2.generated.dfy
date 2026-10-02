// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "../hash-bytes-repair-v3/Execution.dfy"
include "Prefix.generated.dfy"
module OperationsHashRawBlockPrefix2 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashSuccessPrefix
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b) && R.Good(40,initial,value,|data|,word,a,b)
    ensures R.Good(60,state,value,|data|,word,a,b)
  {
    var size: Word:=|data|; state:=initial;
    R.Advance40(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(376,[2854126814],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance41(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(377,[2854126814,2854126814],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance42(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(382,[2854126814,2854126814,2805156195],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance43(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(383,[2854126814,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance44(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(386,[2854126814,0,2480],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance45(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(387,[2854126814],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance46(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(388,[2854126814,2854126814],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance47(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(393,[2854126814,2854126814,2854126814],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance48(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(394,[2854126814,1],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance49(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(397,[2854126814,1,2499],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance50(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2499,[2854126814],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance51(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2500,[2854126814],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance52(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2503,[2854126814,1329],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance53(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2506,[2854126814,1329,2513],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance54(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2507,[2854126814,1329,2513,size],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance55(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2509,[2854126814,1329,2513,size,4],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance56(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2512,[2854126814,1329,2513,size,4,19052],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance57(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19052,[2854126814,1329,2513,size,4],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance58(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19053,[2854126814,1329,2513,size,4],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance59(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(19054,[2854126814,1329,2513,size,4,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
  }
}
