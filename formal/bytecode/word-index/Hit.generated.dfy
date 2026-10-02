// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "../scans/Execution.dfy"
module BytecodeIndexHit {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, needle: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 && word == needle }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[604] == 91 &&
                                              code[8363] == 91 &&
                                              code[8364] == 3 &&
                                              code[8365] == 97 &&
                                              code[8366] == 32 &&
                                              code[8367] == 185 &&
                                              code[8368] == 87 &&
                                              code[8369] == 145 &&
                                              code[8370] == 80 &&
                                              code[8371] == 97 &&
                                              code[8372] == 32 &&
                                              code[8373] == 197 &&
                                              code[8374] == 144 &&
                                              code[8375] == 80 &&
                                              code[8376] == 86 &&
                                              code[8377] == 91 &&
                                              code[8389] == 91 &&
                                              code[8390] == 147 &&
                                              code[8391] == 146 &&
                                              code[8392] == 80 &&
                                              code[8393] == 80 &&
                                              code[8394] == 80 &&
                                              code[8395] == 86
  }
  function Destinations(): set<nat> { {604,8377,8389} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,needle,index,word) && (
                                                                                                                                      if id == 0 then state == Running(8363,[3904669827,604,offset,length,needle,0,length/32,index,needle,word],mem)
                                                                                                                                      else if id == 1 then state == Running(8364,[3904669827,604,offset,length,needle,0,length/32,index,needle,word],mem)
                                                                                                                                      else if id == 2 then state == Running(8365,[3904669827,604,offset,length,needle,0,length/32,index,((word as nat)+G.Modulus()-(needle as nat))%G.Modulus()],mem)
                                                                                                                                      else if id == 3 then state == Running(8368,[3904669827,604,offset,length,needle,0,length/32,index,((word as nat)+G.Modulus()-(needle as nat))%G.Modulus(),8377],mem)
                                                                                                                                      else if id == 4 then state == Running(8369,[3904669827,604,offset,length,needle,0,length/32,index],mem)
                                                                                                                                      else if id == 5 then state == Running(8370,[3904669827,604,offset,length,needle,index,length/32,0],mem)
                                                                                                                                      else if id == 6 then state == Running(8371,[3904669827,604,offset,length,needle,index,length/32],mem)
                                                                                                                                      else if id == 7 then state == Running(8374,[3904669827,604,offset,length,needle,index,length/32,8389],mem)
                                                                                                                                      else if id == 8 then state == Running(8375,[3904669827,604,offset,length,needle,index,8389,length/32],mem)
                                                                                                                                      else if id == 9 then state == Running(8376,[3904669827,604,offset,length,needle,index,8389],mem)
                                                                                                                                      else if id == 10 then state == Running(8389,[3904669827,604,offset,length,needle,index],mem)
                                                                                                                                      else if id == 11 then state == Running(8390,[3904669827,604,offset,length,needle,index],mem)
                                                                                                                                      else if id == 12 then state == Running(8391,[3904669827,index,offset,length,needle,604],mem)
                                                                                                                                      else if id == 13 then state == Running(8392,[3904669827,index,604,length,needle,offset],mem)
                                                                                                                                      else if id == 14 then state == Running(8393,[3904669827,index,604,length,needle],mem)
                                                                                                                                      else if id == 15 then state == Running(8394,[3904669827,index,604,length],mem)
                                                                                                                                      else if id == 16 then state == Running(8395,[3904669827,index,604],mem)
                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(0,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8363,[3904669827,604,offset,length,needle,0,length/32,index,needle,word],mem);
    assert Fetch(code,8363) == Op(91,8364,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(1,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8364,[3904669827,604,offset,length,needle,0,length/32,index,needle,word],mem);
    assert Fetch(code,8364) == Op(3,8365,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(2,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8365,[3904669827,604,offset,length,needle,0,length/32,index,((word as nat)+G.Modulus()-(needle as nat))%G.Modulus()],mem);
    F.Push2(code,8365);
    assert Fetch(code,8365) == Op(97,8368,8377);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(3,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8368,[3904669827,604,offset,length,needle,0,length/32,index,((word as nat)+G.Modulus()-(needle as nat))%G.Modulus(),8377],mem);
    assert Fetch(code,8368) == Op(87,8369,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(4,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8369,[3904669827,604,offset,length,needle,0,length/32,index],mem);
    assert Fetch(code,8369) == Op(145,8370,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(5,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8370,[3904669827,604,offset,length,needle,index,length/32,0],mem);
    assert Fetch(code,8370) == Op(80,8371,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(6,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8371,[3904669827,604,offset,length,needle,index,length/32],mem);
    F.Push2(code,8371);
    assert Fetch(code,8371) == Op(97,8374,8389);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(7,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8374,[3904669827,604,offset,length,needle,index,length/32,8389],mem);
    assert Fetch(code,8374) == Op(144,8375,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(8,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8375,[3904669827,604,offset,length,needle,index,8389,length/32],mem);
    assert Fetch(code,8375) == Op(80,8376,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(9,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8376,[3904669827,604,offset,length,needle,index,8389],mem);
    assert Fetch(code,8376) == Op(86,8377,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(10,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8389,[3904669827,604,offset,length,needle,index],mem);
    assert Fetch(code,8389) == Op(91,8390,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(11,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8390,[3904669827,604,offset,length,needle,index],mem);
    assert Fetch(code,8390) == Op(147,8391,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(12,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8391,[3904669827,index,offset,length,needle,604],mem);
    assert Fetch(code,8391) == Op(146,8392,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(13,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8392,[3904669827,index,604,length,needle,offset],mem);
    assert Fetch(code,8392) == Op(80,8393,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(14,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8393,[3904669827,index,604,length,needle],mem);
    assert Fetch(code,8393) == Op(80,8394,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(15,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8394,[3904669827,index,604,length],mem);
    assert Fetch(code,8394) == Op(80,8395,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(16,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(604,[3904669827,index],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8395,[3904669827,index,604],mem);
    assert Fetch(code,8395) == Op(86,8396,0);
  }
  lemma Start(offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,needle,index,word)
    ensures Good(0,Running(8363,[3904669827,604,offset,length,needle,0,length/32,index,needle,word],mem),offset,length,needle,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,needle,index,word)
    ensures state == Running(604,[3904669827,index],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 18 && trace[0] == Running(8363,[3904669827,604,offset,length,needle,0,length/32,index,needle,word],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,needle,index,word,mem);
    state := Running(8363,[3904669827,604,offset,length,needle,0,length/32,index,needle,word],mem);
    trace := [state];
    Advance0(code,state,offset,length,needle,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,offset,length,needle,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,offset,length,needle,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,offset,length,needle,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,offset,length,needle,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,offset,length,needle,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,offset,length,needle,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,offset,length,needle,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,offset,length,needle,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,offset,length,needle,index,word,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,offset,length,needle,index,word,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,offset,length,needle,index,word,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,offset,length,needle,index,word,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,offset,length,needle,index,word,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,offset,length,needle,index,word,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,offset,length,needle,index,word,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,offset,length,needle,index,word,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
  }
}
