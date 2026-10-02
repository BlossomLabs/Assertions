// SPDX-License-Identifier: MIT
// Generated physical connection to immutable retained dispatcher controls.
include "Execution.dfy"
include "../dispatch/Assertions.generated.dfy"
module BytecodeUnknownAssertions {
  import opened BytecodeDispatchMachine
  import G = BytecodeGetterMachine
  import C = BytecodeDispatchAssertions
  import B = BytecodeUnknownBridge
  import E = BytecodeUnknownExecution
  predicate Admitted(value: Word, size: Word, word: Word) {
    value == 0 && size >= 4 && C.ExpectedSelector(Selector(word)) == -1
  }
  opaque predicate Matches(code: seq<G.Byte>) {
    |code| == 20049 && (forall i: nat | i < |C.Code()| :: code[i] == C.Code()[i])
  }
  lemma DestinationBytes(code: seq<G.Byte>)
    requires Matches(code)
    ensures forall d: nat | d in C.Destinations() :: d < |C.Code()| && d < |code| && C.Code()[d] == code[d]
  { reveal Matches(); }
  lemma Frame0(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(0,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance0(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(0,[],false);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,0);
  }
  lemma Frame1(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(1,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance1(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(2,[128],false);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,2);
  }
  lemma Frame2(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(2,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance2(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(4,[128,64],false);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,4);
  }
  lemma Frame3(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(3,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance3(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(5,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,5);
  }
  lemma Frame4(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(4,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance4(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(6,[value],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,6);
  }
  lemma Frame5(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(5,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance5(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(7,[value,value],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,7);
  }
  lemma Frame6(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(6,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance6(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(8,[value,(if value == 0 then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,8);
  }
  lemma Frame7(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(7,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance7(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,11);
  }
  lemma Frame8(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(8,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance8(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(15,[value],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,15);
  }
  lemma Frame9(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(9,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance9(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(16,[value],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,16);
  }
  lemma Frame10(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(10,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance10(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(17,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,17);
  }
  lemma Frame11(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(11,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance11(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(19,[4],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,19);
  }
  lemma Frame12(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(12,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance12(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(20,[4,size],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,20);
  }
  lemma Frame13(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(13,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance13(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(21,[(if size < 4 then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,21);
  }
  lemma Frame14(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(14,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance14(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(24,[(if size < 4 then 1 else 0),262],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,24);
  }
  lemma Frame15(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(15,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance15(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(262,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,262);
  }
  lemma Frame16(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(16,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance16(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(263,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,263);
  }
  lemma Frame17(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(17,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance17(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(264,[0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,264);
  }
  lemma Frame18(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(18,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance18(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(265,[0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,265);
  }
  lemma Frame19(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(19,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance19(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(25,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,25);
  }
  lemma Frame20(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(20,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance20(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(26,[0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,26);
  }
  lemma Frame21(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(21,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance21(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(27,[word],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,27);
  }
  lemma Frame22(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(22,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance22(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(29,[word,224],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,29);
  }
  lemma Frame23(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(23,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance23(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(30,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,30);
  }
  lemma Frame24(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(24,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance24(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(31,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,31);
  }
  lemma Frame25(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(25,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance25(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(36,[Selector(word),Selector(word),1708659178],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,36);
  }
  lemma Frame26(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(26,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance26(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(37,[Selector(word),(if 1708659178 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,37);
  }
  lemma Frame27(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(27,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance27(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(40,[Selector(word),(if 1708659178 > Selector(word) then 1 else 0),158],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,40);
  }
  lemma Frame28(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(28,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance28(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(158,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,158);
  }
  lemma Frame29(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(29,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance29(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(159,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,159);
  }
  lemma Frame30(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(30,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance30(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(160,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,160);
  }
  lemma Frame31(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(31,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance31(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(165,[Selector(word),Selector(word),531649507],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,165);
  }
  lemma Frame32(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(32,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance32(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(166,[Selector(word),(if 531649507 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,166);
  }
  lemma Frame33(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(33,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance33(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(169,[Selector(word),(if 531649507 > Selector(word) then 1 else 0),217],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,169);
  }
  lemma Frame34(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(34,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance34(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(217,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,217);
  }
  lemma Frame35(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(35,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance35(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(218,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,218);
  }
  lemma Frame36(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(36,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance36(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(219,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,219);
  }
  lemma Frame37(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(37,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance37(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(224,[Selector(word),Selector(word),216073698],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,224);
  }
  lemma Frame38(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(38,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance38(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(225,[Selector(word),(if 216073698 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,225);
  }
  lemma Frame39(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(39,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance39(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(228,[Selector(word),(if 216073698 == Selector(word) then 1 else 0),266],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,228);
  }
  lemma Frame40(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(40,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance40(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(266,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame41(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(41,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance41(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(229,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,229);
  }
  lemma Frame42(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(42,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance42(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(230,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,230);
  }
  lemma Frame43(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(43,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance43(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(235,[Selector(word),Selector(word),318463970],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,235);
  }
  lemma Frame44(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(44,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance44(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(236,[Selector(word),(if 318463970 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,236);
  }
  lemma Frame45(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(45,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance45(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(239,[Selector(word),(if 318463970 == Selector(word) then 1 else 0),287],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,239);
  }
  lemma Frame46(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(46,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance46(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(287,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame47(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(47,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance47(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(240,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,240);
  }
  lemma Frame48(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(48,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance48(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(241,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,241);
  }
  lemma Frame49(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(49,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance49(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(246,[Selector(word),Selector(word),346312130],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,246);
  }
  lemma Frame50(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(50,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance50(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(247,[Selector(word),(if 346312130 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,247);
  }
  lemma Frame51(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(51,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance51(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(250,[Selector(word),(if 346312130 == Selector(word) then 1 else 0),306],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,250);
  }
  lemma Frame52(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(52,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance52(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(306,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame53(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(53,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance53(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(251,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,251);
  }
  lemma Frame54(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(54,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance54(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(252,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,252);
  }
  lemma Frame55(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(55,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance55(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(257,[Selector(word),Selector(word),531209010],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,257);
  }
  lemma Frame56(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(56,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance56(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(258,[Selector(word),(if 531209010 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,258);
  }
  lemma Frame57(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(57,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance57(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(261,[Selector(word),(if 531209010 == Selector(word) then 1 else 0),325],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,261);
  }
  lemma Frame58(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(58,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance58(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(325,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame59(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(59,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance59(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(262,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,262);
  }
  lemma Frame60(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(60,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance60(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(263,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,263);
  }
  lemma Frame61(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(61,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance61(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(264,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,264);
  }
  lemma Frame62(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(62,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance62(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(265,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,265);
  }
  lemma Frame63(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(63,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance63(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(170,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,170);
  }
  lemma Frame64(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(64,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance64(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(171,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,171);
  }
  lemma Frame65(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(65,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance65(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(176,[Selector(word),Selector(word),531649507],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,176);
  }
  lemma Frame66(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(66,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance66(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(177,[Selector(word),(if 531649507 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,177);
  }
  lemma Frame67(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(67,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance67(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(180,[Selector(word),(if 531649507 == Selector(word) then 1 else 0),344],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,180);
  }
  lemma Frame68(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(68,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance68(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(344,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame69(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(69,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance69(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(181,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,181);
  }
  lemma Frame70(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(70,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance70(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(182,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,182);
  }
  lemma Frame71(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(71,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance71(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(187,[Selector(word),Selector(word),646875021],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,187);
  }
  lemma Frame72(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(72,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance72(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(188,[Selector(word),(if 646875021 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,188);
  }
  lemma Frame73(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(73,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance73(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(191,[Selector(word),(if 646875021 == Selector(word) then 1 else 0),363],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,191);
  }
  lemma Frame74(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(74,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance74(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(363,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame75(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(75,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance75(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(192,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,192);
  }
  lemma Frame76(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(76,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance76(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(193,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,193);
  }
  lemma Frame77(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(77,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance77(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(198,[Selector(word),Selector(word),1056577207],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,198);
  }
  lemma Frame78(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(78,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance78(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(199,[Selector(word),(if 1056577207 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,199);
  }
  lemma Frame79(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(79,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance79(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(202,[Selector(word),(if 1056577207 == Selector(word) then 1 else 0),390],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,202);
  }
  lemma Frame80(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(80,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance80(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(390,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame81(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(81,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance81(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(203,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,203);
  }
  lemma Frame82(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(82,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance82(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(204,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,204);
  }
  lemma Frame83(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(83,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance83(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(209,[Selector(word),Selector(word),1609111516],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,209);
  }
  lemma Frame84(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(84,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance84(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(210,[Selector(word),(if 1609111516 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,210);
  }
  lemma Frame85(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(85,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance85(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(213,[Selector(word),(if 1609111516 == Selector(word) then 1 else 0),409],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,213);
  }
  lemma Frame86(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(86,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance86(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(409,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame87(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(87,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance87(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(214,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,214);
  }
  lemma Frame88(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(88,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance88(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(215,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,215);
  }
  lemma Frame89(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(89,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance89(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(216,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,216);
  }
  lemma Frame90(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(90,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance90(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(41,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,41);
  }
  lemma Frame91(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(91,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance91(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(42,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,42);
  }
  lemma Frame92(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(92,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance92(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(47,[Selector(word),Selector(word),2780916004],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,47);
  }
  lemma Frame93(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(93,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance93(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(48,[Selector(word),(if 2780916004 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,48);
  }
  lemma Frame94(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(94,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance94(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(51,[Selector(word),(if 2780916004 > Selector(word) then 1 else 0),110],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,51);
  }
  lemma Frame95(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(95,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance95(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(110,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,110);
  }
  lemma Frame96(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(96,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance96(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(111,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,111);
  }
  lemma Frame97(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(97,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance97(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(112,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,112);
  }
  lemma Frame98(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(98,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance98(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(117,[Selector(word),Selector(word),1708659178],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,117);
  }
  lemma Frame99(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(99,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance99(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(118,[Selector(word),(if 1708659178 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,118);
  }
  lemma Frame100(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(100,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance100(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(121,[Selector(word),(if 1708659178 == Selector(word) then 1 else 0),428],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,121);
  }
  lemma Frame101(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(101,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance101(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(428,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame102(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(102,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance102(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(122,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,122);
  }
  lemma Frame103(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(103,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance103(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(123,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,123);
  }
  lemma Frame104(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(104,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance104(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(128,[Selector(word),Selector(word),1766089946],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,128);
  }
  lemma Frame105(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(105,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance105(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(129,[Selector(word),(if 1766089946 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,129);
  }
  lemma Frame106(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(106,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance106(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(132,[Selector(word),(if 1766089946 == Selector(word) then 1 else 0),447],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,132);
  }
  lemma Frame107(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(107,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance107(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(447,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame108(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(108,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance108(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(133,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,133);
  }
  lemma Frame109(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(109,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance109(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(134,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,134);
  }
  lemma Frame110(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(110,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance110(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(139,[Selector(word),Selector(word),1840718111],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,139);
  }
  lemma Frame111(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(111,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance111(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(140,[Selector(word),(if 1840718111 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,140);
  }
  lemma Frame112(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(112,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance112(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(143,[Selector(word),(if 1840718111 == Selector(word) then 1 else 0),458],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,143);
  }
  lemma Frame113(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(113,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance113(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(458,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame114(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(114,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance114(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(144,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,144);
  }
  lemma Frame115(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(115,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance115(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(145,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,145);
  }
  lemma Frame116(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(116,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance116(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(150,[Selector(word),Selector(word),2001242185],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,150);
  }
  lemma Frame117(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(117,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance117(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(151,[Selector(word),(if 2001242185 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,151);
  }
  lemma Frame118(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(118,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance118(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(154,[Selector(word),(if 2001242185 == Selector(word) then 1 else 0),490],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,154);
  }
  lemma Frame119(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(119,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance119(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(490,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame120(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(120,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance120(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(155,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,155);
  }
  lemma Frame121(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(121,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance121(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(156,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,156);
  }
  lemma Frame122(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(122,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance122(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(157,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,157);
  }
  lemma Frame123(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(123,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance123(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(52,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,52);
  }
  lemma Frame124(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(124,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance124(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(53,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,53);
  }
  lemma Frame125(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(125,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance125(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(58,[Selector(word),Selector(word),2780916004],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,58);
  }
  lemma Frame126(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(126,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance126(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(59,[Selector(word),(if 2780916004 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,59);
  }
  lemma Frame127(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(127,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance127(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(62,[Selector(word),(if 2780916004 == Selector(word) then 1 else 0),509],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,62);
  }
  lemma Frame128(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(128,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance128(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(509,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame129(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(129,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance129(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(63,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,63);
  }
  lemma Frame130(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(130,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance130(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(64,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,64);
  }
  lemma Frame131(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(131,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance131(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(69,[Selector(word),Selector(word),2956327104],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,69);
  }
  lemma Frame132(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(132,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance132(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(70,[Selector(word),(if 2956327104 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,70);
  }
  lemma Frame133(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(133,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance133(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(73,[Selector(word),(if 2956327104 == Selector(word) then 1 else 0),528],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,73);
  }
  lemma Frame134(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(134,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance134(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(528,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame135(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(135,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance135(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(74,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,74);
  }
  lemma Frame136(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(136,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance136(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(75,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,75);
  }
  lemma Frame137(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(137,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance137(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(80,[Selector(word),Selector(word),3124924601],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,80);
  }
  lemma Frame138(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(138,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance138(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(81,[Selector(word),(if 3124924601 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,81);
  }
  lemma Frame139(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(139,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance139(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(84,[Selector(word),(if 3124924601 == Selector(word) then 1 else 0),547],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,84);
  }
  lemma Frame140(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(140,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance140(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(547,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame141(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(141,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance141(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(85,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,85);
  }
  lemma Frame142(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(142,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance142(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(86,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,86);
  }
  lemma Frame143(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(143,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance143(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(91,[Selector(word),Selector(word),3209753888],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,91);
  }
  lemma Frame144(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(144,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance144(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(92,[Selector(word),(if 3209753888 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,92);
  }
  lemma Frame145(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(145,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance145(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(95,[Selector(word),(if 3209753888 == Selector(word) then 1 else 0),566],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,95);
  }
  lemma Frame146(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(146,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance146(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(566,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame147(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(147,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance147(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(96,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,96);
  }
  lemma Frame148(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(148,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance148(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(97,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,97);
  }
  lemma Frame149(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(149,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance149(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(102,[Selector(word),Selector(word),3485876640],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,102);
  }
  lemma Frame150(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(150,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance150(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(103,[Selector(word),(if 3485876640 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,103);
  }
  lemma Frame151(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(151,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance151(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(106,[Selector(word),(if 3485876640 == Selector(word) then 1 else 0),585],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,106);
  }
  lemma Frame152(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(152,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance152(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(585,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame153(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(153,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance153(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(107,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,107);
  }
  lemma Frame154(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(154,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance154(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(108,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,108);
  }
  lemma Frame155(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(155,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance155(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(109,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,109);
  }
  lemma Frame156(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(156,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance156(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(12,[value],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,12);
  }
  lemma Frame157(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(157,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance157(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(13,[value,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,13);
  }
  lemma Frame158(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(158,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance158(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(14,[value,0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,14);
  }
  lemma Frame(id: nat, code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(id,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    if id == 0 { Frame0(code,state,value,size,word); }
    else if id == 1 { Frame1(code,state,value,size,word); }
    else if id == 2 { Frame2(code,state,value,size,word); }
    else if id == 3 { Frame3(code,state,value,size,word); }
    else if id == 4 { Frame4(code,state,value,size,word); }
    else if id == 5 { Frame5(code,state,value,size,word); }
    else if id == 6 { Frame6(code,state,value,size,word); }
    else if id == 7 { Frame7(code,state,value,size,word); }
    else if id == 8 { Frame8(code,state,value,size,word); }
    else if id == 9 { Frame9(code,state,value,size,word); }
    else if id == 10 { Frame10(code,state,value,size,word); }
    else if id == 11 { Frame11(code,state,value,size,word); }
    else if id == 12 { Frame12(code,state,value,size,word); }
    else if id == 13 { Frame13(code,state,value,size,word); }
    else if id == 14 { Frame14(code,state,value,size,word); }
    else if id == 15 { Frame15(code,state,value,size,word); }
    else if id == 16 { Frame16(code,state,value,size,word); }
    else if id == 17 { Frame17(code,state,value,size,word); }
    else if id == 18 { Frame18(code,state,value,size,word); }
    else if id == 19 { Frame19(code,state,value,size,word); }
    else if id == 20 { Frame20(code,state,value,size,word); }
    else if id == 21 { Frame21(code,state,value,size,word); }
    else if id == 22 { Frame22(code,state,value,size,word); }
    else if id == 23 { Frame23(code,state,value,size,word); }
    else if id == 24 { Frame24(code,state,value,size,word); }
    else if id == 25 { Frame25(code,state,value,size,word); }
    else if id == 26 { Frame26(code,state,value,size,word); }
    else if id == 27 { Frame27(code,state,value,size,word); }
    else if id == 28 { Frame28(code,state,value,size,word); }
    else if id == 29 { Frame29(code,state,value,size,word); }
    else if id == 30 { Frame30(code,state,value,size,word); }
    else if id == 31 { Frame31(code,state,value,size,word); }
    else if id == 32 { Frame32(code,state,value,size,word); }
    else if id == 33 { Frame33(code,state,value,size,word); }
    else if id == 34 { Frame34(code,state,value,size,word); }
    else if id == 35 { Frame35(code,state,value,size,word); }
    else if id == 36 { Frame36(code,state,value,size,word); }
    else if id == 37 { Frame37(code,state,value,size,word); }
    else if id == 38 { Frame38(code,state,value,size,word); }
    else if id == 39 { Frame39(code,state,value,size,word); }
    else if id == 40 { Frame40(code,state,value,size,word); }
    else if id == 41 { Frame41(code,state,value,size,word); }
    else if id == 42 { Frame42(code,state,value,size,word); }
    else if id == 43 { Frame43(code,state,value,size,word); }
    else if id == 44 { Frame44(code,state,value,size,word); }
    else if id == 45 { Frame45(code,state,value,size,word); }
    else if id == 46 { Frame46(code,state,value,size,word); }
    else if id == 47 { Frame47(code,state,value,size,word); }
    else if id == 48 { Frame48(code,state,value,size,word); }
    else if id == 49 { Frame49(code,state,value,size,word); }
    else if id == 50 { Frame50(code,state,value,size,word); }
    else if id == 51 { Frame51(code,state,value,size,word); }
    else if id == 52 { Frame52(code,state,value,size,word); }
    else if id == 53 { Frame53(code,state,value,size,word); }
    else if id == 54 { Frame54(code,state,value,size,word); }
    else if id == 55 { Frame55(code,state,value,size,word); }
    else if id == 56 { Frame56(code,state,value,size,word); }
    else if id == 57 { Frame57(code,state,value,size,word); }
    else if id == 58 { Frame58(code,state,value,size,word); }
    else if id == 59 { Frame59(code,state,value,size,word); }
    else if id == 60 { Frame60(code,state,value,size,word); }
    else if id == 61 { Frame61(code,state,value,size,word); }
    else if id == 62 { Frame62(code,state,value,size,word); }
    else if id == 63 { Frame63(code,state,value,size,word); }
    else if id == 64 { Frame64(code,state,value,size,word); }
    else if id == 65 { Frame65(code,state,value,size,word); }
    else if id == 66 { Frame66(code,state,value,size,word); }
    else if id == 67 { Frame67(code,state,value,size,word); }
    else if id == 68 { Frame68(code,state,value,size,word); }
    else if id == 69 { Frame69(code,state,value,size,word); }
    else if id == 70 { Frame70(code,state,value,size,word); }
    else if id == 71 { Frame71(code,state,value,size,word); }
    else if id == 72 { Frame72(code,state,value,size,word); }
    else if id == 73 { Frame73(code,state,value,size,word); }
    else if id == 74 { Frame74(code,state,value,size,word); }
    else if id == 75 { Frame75(code,state,value,size,word); }
    else if id == 76 { Frame76(code,state,value,size,word); }
    else if id == 77 { Frame77(code,state,value,size,word); }
    else if id == 78 { Frame78(code,state,value,size,word); }
    else if id == 79 { Frame79(code,state,value,size,word); }
    else if id == 80 { Frame80(code,state,value,size,word); }
    else if id == 81 { Frame81(code,state,value,size,word); }
    else if id == 82 { Frame82(code,state,value,size,word); }
    else if id == 83 { Frame83(code,state,value,size,word); }
    else if id == 84 { Frame84(code,state,value,size,word); }
    else if id == 85 { Frame85(code,state,value,size,word); }
    else if id == 86 { Frame86(code,state,value,size,word); }
    else if id == 87 { Frame87(code,state,value,size,word); }
    else if id == 88 { Frame88(code,state,value,size,word); }
    else if id == 89 { Frame89(code,state,value,size,word); }
    else if id == 90 { Frame90(code,state,value,size,word); }
    else if id == 91 { Frame91(code,state,value,size,word); }
    else if id == 92 { Frame92(code,state,value,size,word); }
    else if id == 93 { Frame93(code,state,value,size,word); }
    else if id == 94 { Frame94(code,state,value,size,word); }
    else if id == 95 { Frame95(code,state,value,size,word); }
    else if id == 96 { Frame96(code,state,value,size,word); }
    else if id == 97 { Frame97(code,state,value,size,word); }
    else if id == 98 { Frame98(code,state,value,size,word); }
    else if id == 99 { Frame99(code,state,value,size,word); }
    else if id == 100 { Frame100(code,state,value,size,word); }
    else if id == 101 { Frame101(code,state,value,size,word); }
    else if id == 102 { Frame102(code,state,value,size,word); }
    else if id == 103 { Frame103(code,state,value,size,word); }
    else if id == 104 { Frame104(code,state,value,size,word); }
    else if id == 105 { Frame105(code,state,value,size,word); }
    else if id == 106 { Frame106(code,state,value,size,word); }
    else if id == 107 { Frame107(code,state,value,size,word); }
    else if id == 108 { Frame108(code,state,value,size,word); }
    else if id == 109 { Frame109(code,state,value,size,word); }
    else if id == 110 { Frame110(code,state,value,size,word); }
    else if id == 111 { Frame111(code,state,value,size,word); }
    else if id == 112 { Frame112(code,state,value,size,word); }
    else if id == 113 { Frame113(code,state,value,size,word); }
    else if id == 114 { Frame114(code,state,value,size,word); }
    else if id == 115 { Frame115(code,state,value,size,word); }
    else if id == 116 { Frame116(code,state,value,size,word); }
    else if id == 117 { Frame117(code,state,value,size,word); }
    else if id == 118 { Frame118(code,state,value,size,word); }
    else if id == 119 { Frame119(code,state,value,size,word); }
    else if id == 120 { Frame120(code,state,value,size,word); }
    else if id == 121 { Frame121(code,state,value,size,word); }
    else if id == 122 { Frame122(code,state,value,size,word); }
    else if id == 123 { Frame123(code,state,value,size,word); }
    else if id == 124 { Frame124(code,state,value,size,word); }
    else if id == 125 { Frame125(code,state,value,size,word); }
    else if id == 126 { Frame126(code,state,value,size,word); }
    else if id == 127 { Frame127(code,state,value,size,word); }
    else if id == 128 { Frame128(code,state,value,size,word); }
    else if id == 129 { Frame129(code,state,value,size,word); }
    else if id == 130 { Frame130(code,state,value,size,word); }
    else if id == 131 { Frame131(code,state,value,size,word); }
    else if id == 132 { Frame132(code,state,value,size,word); }
    else if id == 133 { Frame133(code,state,value,size,word); }
    else if id == 134 { Frame134(code,state,value,size,word); }
    else if id == 135 { Frame135(code,state,value,size,word); }
    else if id == 136 { Frame136(code,state,value,size,word); }
    else if id == 137 { Frame137(code,state,value,size,word); }
    else if id == 138 { Frame138(code,state,value,size,word); }
    else if id == 139 { Frame139(code,state,value,size,word); }
    else if id == 140 { Frame140(code,state,value,size,word); }
    else if id == 141 { Frame141(code,state,value,size,word); }
    else if id == 142 { Frame142(code,state,value,size,word); }
    else if id == 143 { Frame143(code,state,value,size,word); }
    else if id == 144 { Frame144(code,state,value,size,word); }
    else if id == 145 { Frame145(code,state,value,size,word); }
    else if id == 146 { Frame146(code,state,value,size,word); }
    else if id == 147 { Frame147(code,state,value,size,word); }
    else if id == 148 { Frame148(code,state,value,size,word); }
    else if id == 149 { Frame149(code,state,value,size,word); }
    else if id == 150 { Frame150(code,state,value,size,word); }
    else if id == 151 { Frame151(code,state,value,size,word); }
    else if id == 152 { Frame152(code,state,value,size,word); }
    else if id == 153 { Frame153(code,state,value,size,word); }
    else if id == 154 { Frame154(code,state,value,size,word); }
    else if id == 155 { Frame155(code,state,value,size,word); }
    else if id == 156 { Frame156(code,state,value,size,word); }
    else if id == 157 { Frame157(code,state,value,size,word); }
    else if id == 158 { Frame158(code,state,value,size,word); }
    else { reveal C.Good(); assert false; }
  }
  lemma Start(value: Word, size: Word, word: Word)
    ensures C.Good(0,Running(0,[],false),value,size,word)
  { reveal C.Good(); }
  ghost method Run(code: seq<G.Byte>, value: Word, size: Word, word: Word) returns (state: G.State, trace: seq<G.State>)
    requires Matches(code) && Admitted(value,size,word)
    ensures state == G.Reverted([])
    ensures E.Trace(code,C.Destinations(),value,size,word,trace)
    ensures trace[0] == G.Running(0,[],[]) && trace[|trace|-1] == state
    ensures forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
  {
    DestinationBytes(code);
    Start(value,size,word);
    var abstractState := Running(0,[],false);
    var id: nat := 0;
    state := B.Project(abstractState);
    trace := [state];
    while abstractState.Running?
      invariant Matches(code) && Admitted(value,size,word)
      invariant abstractState.Running? ==> C.Good(id,abstractState,value,size,word)
      invariant !abstractState.Running? ==> abstractState.Rejected?
      invariant state == B.Project(abstractState)
      invariant E.Trace(code,C.Destinations(),value,size,word,trace) && trace[|trace|-1] == state
      invariant trace[0] == G.Running(0,[],[])
      invariant forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
      decreases if abstractState.Running? then C.Limit()-abstractState.pc else 0
    {
      C.Advance(id,abstractState,value,size,word);
      Frame(id,code,abstractState,value,size,word);
      var next := Step(C.Code(),C.Destinations(),C.Entries(),abstractState,value,size,word);
      assert !next.Chosen?;
      B.Step(C.Code(),code,C.Destinations(),C.Entries(),abstractState,value,size,word);
      var physicalNext := G.Step(code,C.Destinations(),state,value,size,word);
      assert physicalNext == B.Project(next);
      if next.Running? {
        Frame(C.NextId(id,value,size,word),code,next,value,size,word);
        assert |physicalNext.stack| <= 3 && |physicalNext.memory| <= 96;
      }
      E.Extend(code,C.Destinations(),value,size,word,trace,physicalNext);
      trace := trace+[physicalNext];
      state := physicalNext;
      abstractState := next;
      id := C.NextId(id,value,size,word);
    }
  }
}
