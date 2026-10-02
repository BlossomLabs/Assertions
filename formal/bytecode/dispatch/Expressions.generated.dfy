// SPDX-License-Identifier: MIT
// Generated from exact canonical runtime bytes by generate.py.
include "Machine.dfy"
module BytecodeDispatchExpressions {
  import opened BytecodeDispatchMachine
  function At(i: nat): Byte {     if i == 0 then 96
    else if i == 1 then 128
    else if i == 2 then 96
    else if i == 3 then 64
    else if i == 4 then 82
    else if i == 5 then 52
    else if i == 6 then 128
    else if i == 7 then 21
    else if i == 8 then 97
    else if i == 9 then 0
    else if i == 10 then 15
    else if i == 11 then 87
    else if i == 12 then 95
    else if i == 13 then 95
    else if i == 14 then 253
    else if i == 15 then 91
    else if i == 16 then 80
    else if i == 17 then 96
    else if i == 18 then 4
    else if i == 19 then 54
    else if i == 20 then 16
    else if i == 21 then 97
    else if i == 22 then 0
    else if i == 23 then 63
    else if i == 24 then 87
    else if i == 25 then 95
    else if i == 26 then 53
    else if i == 27 then 96
    else if i == 28 then 224
    else if i == 29 then 28
    else if i == 30 then 128
    else if i == 31 then 99
    else if i == 32 then 13
    else if i == 33 then 147
    else if i == 34 then 190
    else if i == 35 then 234
    else if i == 36 then 20
    else if i == 37 then 97
    else if i == 38 then 0
    else if i == 39 then 67
    else if i == 40 then 87
    else if i == 41 then 128
    else if i == 42 then 99
    else if i == 43 then 143
    else if i == 44 then 30
    else if i == 45 then 164
    else if i == 46 then 239
    else if i == 47 then 20
    else if i == 48 then 97
    else if i == 49 then 0
    else if i == 50 then 88
    else if i == 51 then 87
    else if i == 52 then 128
    else if i == 53 then 99
    else if i == 54 then 253
    else if i == 55 then 245
    else if i == 56 then 71
    else if i == 57 then 99
    else if i == 58 then 20
    else if i == 59 then 97
    else if i == 60 then 0
    else if i == 61 then 107
    else if i == 62 then 87
    else if i == 63 then 91
    else if i == 64 then 95
    else if i == 65 then 95
    else if i == 66 then 253
    else if i == 67 then 91
    else if i == 68 then 97
    else if i == 69 then 0
    else if i == 70 then 86
    else if i == 71 then 97
    else if i == 72 then 0
    else if i == 73 then 81
    else if i == 74 then 54
    else if i == 75 then 96
    else if i == 76 then 4
    else if i == 77 then 97
    else if i == 78 then 48
    else if i == 79 then 33
    else if i == 80 then 86
    else if i == 81 then 91
    else if i == 82 then 97
    else if i == 83 then 0
    else if i == 84 then 149
    else if i == 85 then 86
    else if i == 86 then 91
    else if i == 87 then 0
    else if i == 88 then 91
    else if i == 89 then 97
    else if i == 90 then 0
    else if i == 91 then 86
    else if i == 92 then 97
    else if i == 93 then 0
    else if i == 94 then 102
    else if i == 95 then 54
    else if i == 96 then 96
    else if i == 97 then 4
    else if i == 98 then 97
    else if i == 99 then 48
    else if i == 100 then 136
    else if i == 101 then 86
    else if i == 102 then 91
    else if i == 103 then 97
    else if i == 104 then 6
    else if i == 105 then 115
    else if i == 106 then 86
    else if i == 107 then 91
    else 0 }
  function Code(): seq<Byte> { seq(108,i requires 0 <= i < 108 => At(i)) }
  predicate IsDestination(p: nat) { p == 15 || p == 63 || p == 67 || p == 81 || p == 86 || p == 88 || p == 102 || p == 107 }
  predicate IsEntry(p: nat) { p == 67 || p == 88 || p == 107 }
  function Destinations(): set<nat> { set p: nat | p < 108 && IsDestination(p) }
  function Entries(): set<nat> { set p: nat | p < 108 && IsEntry(p) }
  function Limit(): nat { 108 }
  function ExpectedSelector(s: Word): int {
    if s == 227786474 then 67
    else if s == 2401150191 then 88
    else if s == 4260710243 then 107
    else -1
  }
  function Expected(value: Word, size: Word, word: Word): int {
    if value != 0 || size < 4 then -1 else ExpectedSelector(Selector(word))
  }
  function Result(state: State): int {
    if state.Chosen? then state.entryPc as int else -1
  }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word) {
    if id == 0 then state == Running(0,[],false) && true
    else if id == 1 then state == Running(2,[128],false) && true
    else if id == 2 then state == Running(4,[128,64],false) && true
    else if id == 3 then state == Running(5,[],true) && true
    else if id == 4 then state == Running(6,[value],true) && true
    else if id == 5 then state == Running(7,[value,value],true) && true
    else if id == 6 then state == Running(8,[value,(if value == 0 then 1 else 0)],true) && true
    else if id == 7 then state == Running(11,[value,(if value == 0 then 1 else 0),15],true) && true
    else if id == 8 then state == Running(15,[value],true) && (true && ((if value == 0 then 1 else 0) != 0))
    else if id == 9 then state == Running(16,[value],true) && (true && ((if value == 0 then 1 else 0) != 0))
    else if id == 10 then state == Running(17,[],true) && (true && ((if value == 0 then 1 else 0) != 0))
    else if id == 11 then state == Running(19,[4],true) && (true && ((if value == 0 then 1 else 0) != 0))
    else if id == 12 then state == Running(20,[4,size],true) && (true && ((if value == 0 then 1 else 0) != 0))
    else if id == 13 then state == Running(21,[(if size < 4 then 1 else 0)],true) && (true && ((if value == 0 then 1 else 0) != 0))
    else if id == 14 then state == Running(24,[(if size < 4 then 1 else 0),63],true) && (true && ((if value == 0 then 1 else 0) != 0))
    else if id == 15 then state == Running(63,[],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && ((if size < 4 then 1 else 0) != 0))
    else if id == 16 then state == Running(64,[],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && ((if size < 4 then 1 else 0) != 0))
    else if id == 17 then state == Running(65,[0],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && ((if size < 4 then 1 else 0) != 0))
    else if id == 18 then state == Running(66,[0,0],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && ((if size < 4 then 1 else 0) != 0))
    else if id == 19 then state == Running(25,[],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 20 then state == Running(26,[0],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 21 then state == Running(27,[word],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 22 then state == Running(29,[word,224],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 23 then state == Running(30,[Selector(word)],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 24 then state == Running(31,[Selector(word),Selector(word)],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 25 then state == Running(36,[Selector(word),Selector(word),227786474],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 26 then state == Running(37,[Selector(word),(if 227786474 == Selector(word) then 1 else 0)],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 27 then state == Running(40,[Selector(word),(if 227786474 == Selector(word) then 1 else 0),67],true) && ((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0))
    else if id == 28 then state == Running(67,[Selector(word)],true) && (((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && ((if 227786474 == Selector(word) then 1 else 0) != 0))
    else if id == 29 then state == Running(41,[Selector(word)],true) && (((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0))
    else if id == 30 then state == Running(42,[Selector(word),Selector(word)],true) && (((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0))
    else if id == 31 then state == Running(47,[Selector(word),Selector(word),2401150191],true) && (((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0))
    else if id == 32 then state == Running(48,[Selector(word),(if 2401150191 == Selector(word) then 1 else 0)],true) && (((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0))
    else if id == 33 then state == Running(51,[Selector(word),(if 2401150191 == Selector(word) then 1 else 0),88],true) && (((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0))
    else if id == 34 then state == Running(88,[Selector(word)],true) && ((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && ((if 2401150191 == Selector(word) then 1 else 0) != 0))
    else if id == 35 then state == Running(52,[Selector(word)],true) && ((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0))
    else if id == 36 then state == Running(53,[Selector(word),Selector(word)],true) && ((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0))
    else if id == 37 then state == Running(58,[Selector(word),Selector(word),4260710243],true) && ((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0))
    else if id == 38 then state == Running(59,[Selector(word),(if 4260710243 == Selector(word) then 1 else 0)],true) && ((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0))
    else if id == 39 then state == Running(62,[Selector(word),(if 4260710243 == Selector(word) then 1 else 0),107],true) && ((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0))
    else if id == 40 then state == Running(107,[Selector(word)],true) && (((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0)) && ((if 4260710243 == Selector(word) then 1 else 0) != 0))
    else if id == 41 then state == Running(63,[Selector(word)],true) && (((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0)) && !((if 4260710243 == Selector(word) then 1 else 0) != 0))
    else if id == 42 then state == Running(64,[Selector(word)],true) && (((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0)) && !((if 4260710243 == Selector(word) then 1 else 0) != 0))
    else if id == 43 then state == Running(65,[Selector(word),0],true) && (((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0)) && !((if 4260710243 == Selector(word) then 1 else 0) != 0))
    else if id == 44 then state == Running(66,[Selector(word),0,0],true) && (((((true && ((if value == 0 then 1 else 0) != 0)) && !((if size < 4 then 1 else 0) != 0)) && !((if 227786474 == Selector(word) then 1 else 0) != 0)) && !((if 2401150191 == Selector(word) then 1 else 0) != 0)) && !((if 4260710243 == Selector(word) then 1 else 0) != 0))
    else if id == 45 then state == Running(12,[value],true) && (true && !((if value == 0 then 1 else 0) != 0))
    else if id == 46 then state == Running(13,[value,0],true) && (true && !((if value == 0 then 1 else 0) != 0))
    else if id == 47 then state == Running(14,[value,0,0],true) && (true && !((if value == 0 then 1 else 0) != 0))
    else false
  }
  function NextId(id: nat, value: Word, size: Word, word: Word): nat {
    if id == 0 then 1
    else if id == 1 then 2
    else if id == 2 then 3
    else if id == 3 then 4
    else if id == 4 then 5
    else if id == 5 then 6
    else if id == 6 then 7
    else if id == 7 then (if ((if value == 0 then 1 else 0) != 0) then 8 else 45)
    else if id == 8 then 9
    else if id == 9 then 10
    else if id == 10 then 11
    else if id == 11 then 12
    else if id == 12 then 13
    else if id == 13 then 14
    else if id == 14 then (if ((if size < 4 then 1 else 0) != 0) then 15 else 19)
    else if id == 15 then 16
    else if id == 16 then 17
    else if id == 17 then 18
    else if id == 18 then 18
    else if id == 19 then 20
    else if id == 20 then 21
    else if id == 21 then 22
    else if id == 22 then 23
    else if id == 23 then 24
    else if id == 24 then 25
    else if id == 25 then 26
    else if id == 26 then 27
    else if id == 27 then (if ((if 227786474 == Selector(word) then 1 else 0) != 0) then 28 else 29)
    else if id == 28 then 28
    else if id == 29 then 30
    else if id == 30 then 31
    else if id == 31 then 32
    else if id == 32 then 33
    else if id == 33 then (if ((if 2401150191 == Selector(word) then 1 else 0) != 0) then 34 else 35)
    else if id == 34 then 34
    else if id == 35 then 36
    else if id == 36 then 37
    else if id == 37 then 38
    else if id == 38 then 39
    else if id == 39 then (if ((if 4260710243 == Selector(word) then 1 else 0) != 0) then 40 else 41)
    else if id == 40 then 40
    else if id == 41 then 42
    else if id == 42 then 43
    else if id == 43 then 44
    else if id == 44 then 44
    else if id == 45 then 46
    else if id == 46 then 47
    else if id == 47 then 47
    else 0
  }
  lemma Advance0(state: State, value: Word, size: Word, word: Word)
    requires Good(0,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(0,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(0,[],false);
    assert Code()[0] == 96;
    assert 0 !in Entries();
    assert Fetch(Code(),0) == Op(96,2,128);
    SelectorBound(word);
  }

  lemma Advance1(state: State, value: Word, size: Word, word: Word)
    requires Good(1,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(1,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(2,[128],false);
    assert Code()[2] == 96;
    assert 2 !in Entries();
    assert Fetch(Code(),2) == Op(96,4,64);
    SelectorBound(word);
  }

  lemma Advance2(state: State, value: Word, size: Word, word: Word)
    requires Good(2,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(2,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(4,[128,64],false);
    assert Code()[4] == 82;
    assert 4 !in Entries();
    assert Fetch(Code(),4) == Op(82,5,0);
    SelectorBound(word);
  }

  lemma Advance3(state: State, value: Word, size: Word, word: Word)
    requires Good(3,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(3,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(5,[],true);
    assert Code()[5] == 52;
    assert 5 !in Entries();
    assert Fetch(Code(),5) == Op(52,6,0);
    SelectorBound(word);
  }

  lemma Advance4(state: State, value: Word, size: Word, word: Word)
    requires Good(4,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(4,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(6,[value],true);
    assert Code()[6] == 128;
    assert 6 !in Entries();
    assert Fetch(Code(),6) == Op(128,7,0);
    SelectorBound(word);
  }

  lemma Advance5(state: State, value: Word, size: Word, word: Word)
    requires Good(5,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(5,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(7,[value,value],true);
    assert Code()[7] == 21;
    assert 7 !in Entries();
    assert Fetch(Code(),7) == Op(21,8,0);
    SelectorBound(word);
  }

  lemma Advance6(state: State, value: Word, size: Word, word: Word)
    requires Good(6,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(6,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(8,[value,(if value == 0 then 1 else 0)],true);
    assert Code()[8] == 97;
    assert 8 !in Entries();
    assert Fetch(Code(),8) == Op(97,11,15);
    SelectorBound(word);
  }

  lemma Advance7(state: State, value: Word, size: Word, word: Word)
    requires Good(7,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(7,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],true);
    assert Code()[11] == 87;
    assert 11 !in Entries();
    assert Fetch(Code(),11) == Op(87,12,0);
    assert 15 in Destinations();
    assert 15 < |Code()| && Code()[15] == 91;
    SelectorBound(word);
  }

  lemma Advance8(state: State, value: Word, size: Word, word: Word)
    requires Good(8,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(8,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(15,[value],true);
    assert Code()[15] == 91;
    assert 15 !in Entries();
    assert Fetch(Code(),15) == Op(91,16,0);
    SelectorBound(word);
  }

  lemma Advance9(state: State, value: Word, size: Word, word: Word)
    requires Good(9,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(9,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(16,[value],true);
    assert Code()[16] == 80;
    assert 16 !in Entries();
    assert Fetch(Code(),16) == Op(80,17,0);
    SelectorBound(word);
  }

  lemma Advance10(state: State, value: Word, size: Word, word: Word)
    requires Good(10,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(10,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(17,[],true);
    assert Code()[17] == 96;
    assert 17 !in Entries();
    assert Fetch(Code(),17) == Op(96,19,4);
    SelectorBound(word);
  }

  lemma Advance11(state: State, value: Word, size: Word, word: Word)
    requires Good(11,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(11,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(19,[4],true);
    assert Code()[19] == 54;
    assert 19 !in Entries();
    assert Fetch(Code(),19) == Op(54,20,0);
    SelectorBound(word);
  }

  lemma Advance12(state: State, value: Word, size: Word, word: Word)
    requires Good(12,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(12,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(20,[4,size],true);
    assert Code()[20] == 16;
    assert 20 !in Entries();
    assert Fetch(Code(),20) == Op(16,21,0);
    SelectorBound(word);
  }

  lemma Advance13(state: State, value: Word, size: Word, word: Word)
    requires Good(13,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(13,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(21,[(if size < 4 then 1 else 0)],true);
    assert Code()[21] == 97;
    assert 21 !in Entries();
    assert Fetch(Code(),21) == Op(97,24,63);
    SelectorBound(word);
  }

  lemma Advance14(state: State, value: Word, size: Word, word: Word)
    requires Good(14,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(14,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(24,[(if size < 4 then 1 else 0),63],true);
    assert Code()[24] == 87;
    assert 24 !in Entries();
    assert Fetch(Code(),24) == Op(87,25,0);
    assert 63 in Destinations();
    assert 63 < |Code()| && Code()[63] == 91;
    SelectorBound(word);
  }

  lemma Advance15(state: State, value: Word, size: Word, word: Word)
    requires Good(15,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(15,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(63,[],true);
    assert Code()[63] == 91;
    assert 63 !in Entries();
    assert Fetch(Code(),63) == Op(91,64,0);
    SelectorBound(word);
  }

  lemma Advance16(state: State, value: Word, size: Word, word: Word)
    requires Good(16,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(16,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(64,[],true);
    assert Code()[64] == 95;
    assert 64 !in Entries();
    assert Fetch(Code(),64) == Op(95,65,0);
    SelectorBound(word);
  }

  lemma Advance17(state: State, value: Word, size: Word, word: Word)
    requires Good(17,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(17,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(65,[0],true);
    assert Code()[65] == 95;
    assert 65 !in Entries();
    assert Fetch(Code(),65) == Op(95,66,0);
    SelectorBound(word);
  }

  lemma Advance18(state: State, value: Word, size: Word, word: Word)
    requires Good(18,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(18,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(66,[0,0],true);
    assert Code()[66] == 253;
    assert 66 !in Entries();
    assert Fetch(Code(),66) == Op(253,67,0);
    SelectorBound(word);
  }

  lemma Advance19(state: State, value: Word, size: Word, word: Word)
    requires Good(19,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(19,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(25,[],true);
    assert Code()[25] == 95;
    assert 25 !in Entries();
    assert Fetch(Code(),25) == Op(95,26,0);
    SelectorBound(word);
  }

  lemma Advance20(state: State, value: Word, size: Word, word: Word)
    requires Good(20,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(20,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(26,[0],true);
    assert Code()[26] == 53;
    assert 26 !in Entries();
    assert Fetch(Code(),26) == Op(53,27,0);
    SelectorBound(word);
  }

  lemma Advance21(state: State, value: Word, size: Word, word: Word)
    requires Good(21,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(21,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(27,[word],true);
    assert Code()[27] == 96;
    assert 27 !in Entries();
    assert Fetch(Code(),27) == Op(96,29,224);
    SelectorBound(word);
  }

  lemma Advance22(state: State, value: Word, size: Word, word: Word)
    requires Good(22,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(22,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(29,[word,224],true);
    assert Code()[29] == 28;
    assert 29 !in Entries();
    assert Fetch(Code(),29) == Op(28,30,0);
    SelectorBound(word);
  }

  lemma Advance23(state: State, value: Word, size: Word, word: Word)
    requires Good(23,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(23,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(30,[Selector(word)],true);
    assert Code()[30] == 128;
    assert 30 !in Entries();
    assert Fetch(Code(),30) == Op(128,31,0);
    SelectorBound(word);
  }

  lemma Advance24(state: State, value: Word, size: Word, word: Word)
    requires Good(24,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(24,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(31,[Selector(word),Selector(word)],true);
    assert Code()[31] == 99;
    assert 31 !in Entries();
    assert Fetch(Code(),31) == Op(99,36,227786474);
    SelectorBound(word);
  }

  lemma Advance25(state: State, value: Word, size: Word, word: Word)
    requires Good(25,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(25,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(36,[Selector(word),Selector(word),227786474],true);
    assert Code()[36] == 20;
    assert 36 !in Entries();
    assert Fetch(Code(),36) == Op(20,37,0);
    SelectorBound(word);
  }

  lemma Advance26(state: State, value: Word, size: Word, word: Word)
    requires Good(26,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(26,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(37,[Selector(word),(if 227786474 == Selector(word) then 1 else 0)],true);
    assert Code()[37] == 97;
    assert 37 !in Entries();
    assert Fetch(Code(),37) == Op(97,40,67);
    SelectorBound(word);
  }

  lemma Advance27(state: State, value: Word, size: Word, word: Word)
    requires Good(27,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(27,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(40,[Selector(word),(if 227786474 == Selector(word) then 1 else 0),67],true);
    assert Code()[40] == 87;
    assert 40 !in Entries();
    assert Fetch(Code(),40) == Op(87,41,0);
    assert 67 in Destinations();
    assert 67 < |Code()| && Code()[67] == 91;
    SelectorBound(word);
  }

  lemma Advance28(state: State, value: Word, size: Word, word: Word)
    requires Good(28,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(28,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(67,[Selector(word)],true);
    assert Code()[67] == 91;
    SelectorBound(word);
  }

  lemma Advance29(state: State, value: Word, size: Word, word: Word)
    requires Good(29,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(29,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(41,[Selector(word)],true);
    assert Code()[41] == 128;
    assert 41 !in Entries();
    assert Fetch(Code(),41) == Op(128,42,0);
    SelectorBound(word);
  }

  lemma Advance30(state: State, value: Word, size: Word, word: Word)
    requires Good(30,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(30,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(42,[Selector(word),Selector(word)],true);
    assert Code()[42] == 99;
    assert 42 !in Entries();
    assert Fetch(Code(),42) == Op(99,47,2401150191);
    SelectorBound(word);
  }

  lemma Advance31(state: State, value: Word, size: Word, word: Word)
    requires Good(31,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(31,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(47,[Selector(word),Selector(word),2401150191],true);
    assert Code()[47] == 20;
    assert 47 !in Entries();
    assert Fetch(Code(),47) == Op(20,48,0);
    SelectorBound(word);
  }

  lemma Advance32(state: State, value: Word, size: Word, word: Word)
    requires Good(32,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(32,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(48,[Selector(word),(if 2401150191 == Selector(word) then 1 else 0)],true);
    assert Code()[48] == 97;
    assert 48 !in Entries();
    assert Fetch(Code(),48) == Op(97,51,88);
    SelectorBound(word);
  }

  lemma Advance33(state: State, value: Word, size: Word, word: Word)
    requires Good(33,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(33,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(51,[Selector(word),(if 2401150191 == Selector(word) then 1 else 0),88],true);
    assert Code()[51] == 87;
    assert 51 !in Entries();
    assert Fetch(Code(),51) == Op(87,52,0);
    assert 88 in Destinations();
    assert 88 < |Code()| && Code()[88] == 91;
    SelectorBound(word);
  }

  lemma Advance34(state: State, value: Word, size: Word, word: Word)
    requires Good(34,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(34,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(88,[Selector(word)],true);
    assert Code()[88] == 91;
    SelectorBound(word);
  }

  lemma Advance35(state: State, value: Word, size: Word, word: Word)
    requires Good(35,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(35,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(52,[Selector(word)],true);
    assert Code()[52] == 128;
    assert 52 !in Entries();
    assert Fetch(Code(),52) == Op(128,53,0);
    SelectorBound(word);
  }

  lemma Advance36(state: State, value: Word, size: Word, word: Word)
    requires Good(36,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(36,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(53,[Selector(word),Selector(word)],true);
    assert Code()[53] == 99;
    assert 53 !in Entries();
    assert Fetch(Code(),53) == Op(99,58,4260710243);
    SelectorBound(word);
  }

  lemma Advance37(state: State, value: Word, size: Word, word: Word)
    requires Good(37,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(37,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(58,[Selector(word),Selector(word),4260710243],true);
    assert Code()[58] == 20;
    assert 58 !in Entries();
    assert Fetch(Code(),58) == Op(20,59,0);
    SelectorBound(word);
  }

  lemma Advance38(state: State, value: Word, size: Word, word: Word)
    requires Good(38,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(38,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(59,[Selector(word),(if 4260710243 == Selector(word) then 1 else 0)],true);
    assert Code()[59] == 97;
    assert 59 !in Entries();
    assert Fetch(Code(),59) == Op(97,62,107);
    SelectorBound(word);
  }

  lemma Advance39(state: State, value: Word, size: Word, word: Word)
    requires Good(39,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(39,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(62,[Selector(word),(if 4260710243 == Selector(word) then 1 else 0),107],true);
    assert Code()[62] == 87;
    assert 62 !in Entries();
    assert Fetch(Code(),62) == Op(87,63,0);
    assert 107 in Destinations();
    assert 107 < |Code()| && Code()[107] == 91;
    SelectorBound(word);
  }

  lemma Advance40(state: State, value: Word, size: Word, word: Word)
    requires Good(40,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(40,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(107,[Selector(word)],true);
    assert Code()[107] == 91;
    SelectorBound(word);
  }

  lemma Advance41(state: State, value: Word, size: Word, word: Word)
    requires Good(41,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(41,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(63,[Selector(word)],true);
    assert Code()[63] == 91;
    assert 63 !in Entries();
    assert Fetch(Code(),63) == Op(91,64,0);
    SelectorBound(word);
  }

  lemma Advance42(state: State, value: Word, size: Word, word: Word)
    requires Good(42,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(42,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(64,[Selector(word)],true);
    assert Code()[64] == 95;
    assert 64 !in Entries();
    assert Fetch(Code(),64) == Op(95,65,0);
    SelectorBound(word);
  }

  lemma Advance43(state: State, value: Word, size: Word, word: Word)
    requires Good(43,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(43,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(65,[Selector(word),0],true);
    assert Code()[65] == 95;
    assert 65 !in Entries();
    assert Fetch(Code(),65) == Op(95,66,0);
    SelectorBound(word);
  }

  lemma Advance44(state: State, value: Word, size: Word, word: Word)
    requires Good(44,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(44,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(66,[Selector(word),0,0],true);
    assert Code()[66] == 253;
    assert 66 !in Entries();
    assert Fetch(Code(),66) == Op(253,67,0);
    SelectorBound(word);
  }

  lemma Advance45(state: State, value: Word, size: Word, word: Word)
    requires Good(45,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(45,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(12,[value],true);
    assert Code()[12] == 95;
    assert 12 !in Entries();
    assert Fetch(Code(),12) == Op(95,13,0);
    SelectorBound(word);
  }

  lemma Advance46(state: State, value: Word, size: Word, word: Word)
    requires Good(46,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(46,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(13,[value,0],true);
    assert Code()[13] == 95;
    assert 13 !in Entries();
    assert Fetch(Code(),13) == Op(95,14,0);
    SelectorBound(word);
  }

  lemma Advance47(state: State, value: Word, size: Word, word: Word)
    requires Good(47,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(47,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    assert state == Running(14,[value,0,0],true);
    assert Code()[14] == 253;
    assert 14 !in Entries();
    assert Fetch(Code(),14) == Op(253,15,0);
    SelectorBound(word);
  }
  lemma Advance(id: nat, state: State, value: Word, size: Word, word: Word)
    requires Good(id,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(id,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
    if id == 0 { Advance0(state,value,size,word); }
    else if id == 1 { Advance1(state,value,size,word); }
    else if id == 2 { Advance2(state,value,size,word); }
    else if id == 3 { Advance3(state,value,size,word); }
    else if id == 4 { Advance4(state,value,size,word); }
    else if id == 5 { Advance5(state,value,size,word); }
    else if id == 6 { Advance6(state,value,size,word); }
    else if id == 7 { Advance7(state,value,size,word); }
    else if id == 8 { Advance8(state,value,size,word); }
    else if id == 9 { Advance9(state,value,size,word); }
    else if id == 10 { Advance10(state,value,size,word); }
    else if id == 11 { Advance11(state,value,size,word); }
    else if id == 12 { Advance12(state,value,size,word); }
    else if id == 13 { Advance13(state,value,size,word); }
    else if id == 14 { Advance14(state,value,size,word); }
    else if id == 15 { Advance15(state,value,size,word); }
    else if id == 16 { Advance16(state,value,size,word); }
    else if id == 17 { Advance17(state,value,size,word); }
    else if id == 18 { Advance18(state,value,size,word); }
    else if id == 19 { Advance19(state,value,size,word); }
    else if id == 20 { Advance20(state,value,size,word); }
    else if id == 21 { Advance21(state,value,size,word); }
    else if id == 22 { Advance22(state,value,size,word); }
    else if id == 23 { Advance23(state,value,size,word); }
    else if id == 24 { Advance24(state,value,size,word); }
    else if id == 25 { Advance25(state,value,size,word); }
    else if id == 26 { Advance26(state,value,size,word); }
    else if id == 27 { Advance27(state,value,size,word); }
    else if id == 28 { Advance28(state,value,size,word); }
    else if id == 29 { Advance29(state,value,size,word); }
    else if id == 30 { Advance30(state,value,size,word); }
    else if id == 31 { Advance31(state,value,size,word); }
    else if id == 32 { Advance32(state,value,size,word); }
    else if id == 33 { Advance33(state,value,size,word); }
    else if id == 34 { Advance34(state,value,size,word); }
    else if id == 35 { Advance35(state,value,size,word); }
    else if id == 36 { Advance36(state,value,size,word); }
    else if id == 37 { Advance37(state,value,size,word); }
    else if id == 38 { Advance38(state,value,size,word); }
    else if id == 39 { Advance39(state,value,size,word); }
    else if id == 40 { Advance40(state,value,size,word); }
    else if id == 41 { Advance41(state,value,size,word); }
    else if id == 42 { Advance42(state,value,size,word); }
    else if id == 43 { Advance43(state,value,size,word); }
    else if id == 44 { Advance44(state,value,size,word); }
    else if id == 45 { Advance45(state,value,size,word); }
    else if id == 46 { Advance46(state,value,size,word); }
    else if id == 47 { Advance47(state,value,size,word); }
    else { assert false; }
  }
  ghost method Run(value: Word, size: Word, word: Word) returns (state: State)
    ensures state.Chosen? || state.Rejected?
    ensures Result(state) == Expected(value,size,word)
    ensures state.Chosen? ==> state.freePointer && state.remaining == [Selector(word)]
  {
    reveal Good();
    state := Running(0,[],false);
    var id: nat := 0;
    while state.Running?
      invariant state != Bad
      invariant state.Running? ==> Good(id,state,value,size,word)
      invariant !state.Running? ==> Result(state) == Expected(value,size,word)
      invariant state.Chosen? ==> state.freePointer && state.remaining == [Selector(word)]
      decreases if state.Running? then Limit()-state.pc else 0
    {
      Advance(id,state,value,size,word);
      state := Step(Code(),Destinations(),Entries(),state,value,size,word);
      id := NextId(id,value,size,word);
    }
  }
}
