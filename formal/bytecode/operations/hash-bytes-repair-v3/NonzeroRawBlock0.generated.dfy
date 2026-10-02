// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "Nonzero.generated.dfy"
module OperationsHashRawBlockNonzero0 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesNonzero
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b) && R.Good(0,initial,value,|data|,word,a,b)
    ensures state==Reverted([])
  {
    var size: Word:=|data|; state:=initial;
    R.Advance0(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(0,[],[]);
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance1(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(2,[128],[]);
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance2(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(4,[128,64],[]);
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance3(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(5,[],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance4(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(6,[value],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance5(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(7,[value,value],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance6(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(8,[value,(if value == 0 then 1 else 0)],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance7(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance8(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(12,[value],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance9(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(13,[value,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
    R.Advance10(code,state,value,|data|,word,a,b);
    reveal R.Good(); reveal R.Matches();
    assert state==Running(14,[value,0,0],Store([],64,128));
    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);
    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);
  }
}
