// SPDX-License-Identifier: MIT
// Generated physical connection to immutable retained dispatcher controls.
include "Execution.dfy"
include "../dispatch/Expressions.generated.dfy"
module BytecodeUnknownExpressions {
  import opened BytecodeDispatchMachine
  import G = BytecodeGetterMachine
  import C = BytecodeDispatchExpressions
  import B = BytecodeUnknownBridge
  import E = BytecodeUnknownExecution
  predicate Admitted(value: Word, size: Word, word: Word) {
    value == 0 && size >= 4 && C.ExpectedSelector(Selector(word)) == -1
  }
  opaque predicate Matches(code: seq<G.Byte>) {
    |code| == 17776 && (forall i: nat | i < |C.Code()| :: code[i] == C.Code()[i])
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
    assert state == Running(24,[(if size < 4 then 1 else 0),63],true);
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
    assert state == Running(63,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,63);
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
    assert state == Running(64,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,64);
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
    assert state == Running(65,[0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,65);
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
    assert state == Running(66,[0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,66);
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
    assert state == Running(36,[Selector(word),Selector(word),227786474],true);
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
    assert state == Running(37,[Selector(word),(if 227786474 == Selector(word) then 1 else 0)],true);
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
    assert state == Running(40,[Selector(word),(if 227786474 == Selector(word) then 1 else 0),67],true);
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
    assert state == Running(67,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
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
    assert state == Running(41,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,41);
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
    assert state == Running(42,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,42);
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
    assert state == Running(47,[Selector(word),Selector(word),2401150191],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,47);
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
    assert state == Running(48,[Selector(word),(if 2401150191 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,48);
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
    assert state == Running(51,[Selector(word),(if 2401150191 == Selector(word) then 1 else 0),88],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,51);
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
    assert state == Running(88,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
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
    assert state == Running(52,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,52);
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
    assert state == Running(53,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,53);
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
    assert state == Running(58,[Selector(word),Selector(word),4260710243],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,58);
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
    assert state == Running(59,[Selector(word),(if 4260710243 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,59);
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
    assert state == Running(62,[Selector(word),(if 4260710243 == Selector(word) then 1 else 0),107],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,62);
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
    assert state == Running(107,[Selector(word)],true);
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
    assert state == Running(63,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,63);
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
    assert state == Running(64,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,64);
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
    assert state == Running(65,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,65);
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
    assert state == Running(66,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,66);
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
    assert state == Running(12,[value],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,12);
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
    assert state == Running(13,[value,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,13);
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
