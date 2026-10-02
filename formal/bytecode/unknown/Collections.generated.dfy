// SPDX-License-Identifier: MIT
// Generated physical connection to immutable retained dispatcher controls.
include "Execution.dfy"
include "../dispatch/Collections.generated.dfy"
module BytecodeUnknownCollections {
  import opened BytecodeDispatchMachine
  import G = BytecodeGetterMachine
  import C = BytecodeDispatchCollections
  import B = BytecodeUnknownBridge
  import E = BytecodeUnknownExecution
  predicate Admitted(value: Word, size: Word, word: Word) {
    value == 0 && size >= 4 && C.ExpectedSelector(Selector(word)) == -1
  }
  opaque predicate Matches(code: seq<G.Byte>) {
    |code| == 24560 && (forall i: nat | i < |C.Code()| :: code[i] == C.Code()[i])
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
    assert state == Running(24,[(if size < 4 then 1 else 0),454],true);
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
    assert state == Running(454,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,454);
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
    assert state == Running(455,[],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,455);
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
    assert state == Running(456,[0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,456);
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
    assert state == Running(457,[0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,457);
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
    assert state == Running(36,[Selector(word),Selector(word),2368205965],true);
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
    assert state == Running(37,[Selector(word),(if 2368205965 > Selector(word) then 1 else 0)],true);
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
    assert state == Running(40,[Selector(word),(if 2368205965 > Selector(word) then 1 else 0),254],true);
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
    assert state == Running(254,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,254);
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
    assert state == Running(255,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,255);
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
    assert state == Running(256,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,256);
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
    assert state == Running(261,[Selector(word),Selector(word),961624077],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,261);
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
    assert state == Running(262,[Selector(word),(if 961624077 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,262);
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
    assert state == Running(265,[Selector(word),(if 961624077 > Selector(word) then 1 else 0),361],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,265);
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
    assert state == Running(361,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,361);
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
    assert state == Running(362,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,362);
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
    assert state == Running(363,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,363);
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
    assert state == Running(368,[Selector(word),Selector(word),391003434],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,368);
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
    assert state == Running(369,[Selector(word),(if 391003434 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,369);
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
    assert state == Running(372,[Selector(word),(if 391003434 > Selector(word) then 1 else 0),420],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,372);
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
    assert state == Running(420,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,420);
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
    assert state == Running(421,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,421);
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
    assert state == Running(422,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,422);
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
    assert state == Running(427,[Selector(word),Selector(word),166449333],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,427);
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
    assert state == Running(428,[Selector(word),(if 166449333 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,428);
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
    assert state == Running(431,[Selector(word),(if 166449333 == Selector(word) then 1 else 0),458],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,431);
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
    assert state == Running(458,[Selector(word)],true);
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
    assert state == Running(432,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,432);
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
    assert state == Running(433,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,433);
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
    assert state == Running(438,[Selector(word),Selector(word),269019481],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,438);
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
    assert state == Running(439,[Selector(word),(if 269019481 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,439);
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
    assert state == Running(442,[Selector(word),(if 269019481 == Selector(word) then 1 else 0),499],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,442);
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
    assert state == Running(499,[Selector(word)],true);
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
    assert state == Running(443,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,443);
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
    assert state == Running(444,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,444);
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
    assert state == Running(449,[Selector(word),Selector(word),307145824],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,449);
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
    assert state == Running(450,[Selector(word),(if 307145824 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,450);
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
    assert state == Running(453,[Selector(word),(if 307145824 == Selector(word) then 1 else 0),531],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,453);
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
    assert state == Running(531,[Selector(word)],true);
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
    assert state == Running(454,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,454);
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
    assert state == Running(455,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,455);
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
    assert state == Running(456,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,456);
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
    assert state == Running(457,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,457);
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
    assert state == Running(373,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,373);
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
    assert state == Running(374,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,374);
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
    assert state == Running(379,[Selector(word),Selector(word),391003434],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,379);
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
    assert state == Running(380,[Selector(word),(if 391003434 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,380);
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
    assert state == Running(383,[Selector(word),(if 391003434 == Selector(word) then 1 else 0),566],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,383);
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
    assert state == Running(566,[Selector(word)],true);
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
    assert state == Running(384,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,384);
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
    assert state == Running(385,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,385);
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
    assert state == Running(390,[Selector(word),Selector(word),394725771],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,390);
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
    assert state == Running(391,[Selector(word),(if 394725771 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,391);
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
    assert state == Running(394,[Selector(word),(if 394725771 == Selector(word) then 1 else 0),585],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,394);
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
    assert state == Running(585,[Selector(word)],true);
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
    assert state == Running(395,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,395);
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
    assert state == Running(396,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,396);
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
    assert state == Running(401,[Selector(word),Selector(word),476661964],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,401);
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
    assert state == Running(402,[Selector(word),(if 476661964 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,402);
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
    assert state == Running(405,[Selector(word),(if 476661964 == Selector(word) then 1 else 0),618],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,405);
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
    assert state == Running(618,[Selector(word)],true);
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
    assert state == Running(406,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,406);
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
    assert state == Running(407,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,407);
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
    assert state == Running(412,[Selector(word),Selector(word),785862473],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,412);
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
    assert state == Running(413,[Selector(word),(if 785862473 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,413);
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
    assert state == Running(416,[Selector(word),(if 785862473 == Selector(word) then 1 else 0),637],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,416);
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
    assert state == Running(637,[Selector(word)],true);
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
    assert state == Running(417,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,417);
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
    assert state == Running(418,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,418);
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
    assert state == Running(419,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,419);
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
    assert state == Running(266,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,266);
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
    assert state == Running(267,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,267);
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
    assert state == Running(272,[Selector(word),Selector(word),1831135132],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,272);
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
    assert state == Running(273,[Selector(word),(if 1831135132 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,273);
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
    assert state == Running(276,[Selector(word),(if 1831135132 > Selector(word) then 1 else 0),324],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,276);
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
    assert state == Running(324,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,324);
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
    assert state == Running(325,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,325);
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
    assert state == Running(326,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,326);
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
    assert state == Running(331,[Selector(word),Selector(word),961624077],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,331);
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
    assert state == Running(332,[Selector(word),(if 961624077 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,332);
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
    assert state == Running(335,[Selector(word),(if 961624077 == Selector(word) then 1 else 0),656],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,335);
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
    assert state == Running(656,[Selector(word)],true);
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
    assert state == Running(336,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,336);
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
    assert state == Running(337,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,337);
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
    assert state == Running(342,[Selector(word),Selector(word),994174373],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,342);
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
    assert state == Running(343,[Selector(word),(if 994174373 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,343);
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
    assert state == Running(346,[Selector(word),(if 994174373 == Selector(word) then 1 else 0),675],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,346);
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
    assert state == Running(675,[Selector(word)],true);
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
    assert state == Running(347,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,347);
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
    assert state == Running(348,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,348);
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
    assert state == Running(353,[Selector(word),Selector(word),1085790307],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,353);
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
    assert state == Running(354,[Selector(word),(if 1085790307 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,354);
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
    assert state == Running(357,[Selector(word),(if 1085790307 == Selector(word) then 1 else 0),694],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,357);
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
    assert state == Running(694,[Selector(word)],true);
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
    assert state == Running(358,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,358);
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
    assert state == Running(359,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,359);
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
    assert state == Running(360,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,360);
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
    assert state == Running(277,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,277);
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
    assert state == Running(278,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,278);
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
    assert state == Running(283,[Selector(word),Selector(word),1831135132],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,283);
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
    assert state == Running(284,[Selector(word),(if 1831135132 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,284);
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
    assert state == Running(287,[Selector(word),(if 1831135132 == Selector(word) then 1 else 0),713],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,287);
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
    assert state == Running(713,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
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
    assert state == Running(288,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,288);
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
    assert state == Running(289,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,289);
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
    assert state == Running(294,[Selector(word),Selector(word),1843793072],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,294);
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
    assert state == Running(295,[Selector(word),(if 1843793072 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,295);
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
    assert state == Running(298,[Selector(word),(if 1843793072 == Selector(word) then 1 else 0),732],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,298);
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
    assert state == Running(732,[Selector(word)],true);
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
    assert state == Running(299,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,299);
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
    assert state == Running(300,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,300);
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
    assert state == Running(305,[Selector(word),Selector(word),1963819735],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,305);
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
    assert state == Running(306,[Selector(word),(if 1963819735 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,306);
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
    assert state == Running(309,[Selector(word),(if 1963819735 == Selector(word) then 1 else 0),751],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,309);
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
    assert state == Running(751,[Selector(word)],true);
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
    assert state == Running(310,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,310);
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
    assert state == Running(311,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,311);
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
    assert state == Running(316,[Selector(word),Selector(word),2005396296],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,316);
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
    assert state == Running(317,[Selector(word),(if 2005396296 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,317);
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
    assert state == Running(320,[Selector(word),(if 2005396296 == Selector(word) then 1 else 0),770],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,320);
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
    assert state == Running(770,[Selector(word)],true);
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
    assert state == Running(321,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,321);
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
    assert state == Running(322,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,322);
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
    assert state == Running(323,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,323);
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
    assert state == Running(41,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,41);
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
    assert state == Running(42,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,42);
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
    assert state == Running(47,[Selector(word),Selector(word),3309852450],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,47);
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
    assert state == Running(48,[Selector(word),(if 3309852450 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,48);
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
    assert state == Running(51,[Selector(word),(if 3309852450 > Selector(word) then 1 else 0),158],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,51);
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
    assert state == Running(158,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,158);
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
    assert state == Running(159,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,159);
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
    assert state == Running(160,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,160);
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
    assert state == Running(165,[Selector(word),Selector(word),2874738232],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,165);
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
    assert state == Running(166,[Selector(word),(if 2874738232 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,166);
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
    assert state == Running(169,[Selector(word),(if 2874738232 > Selector(word) then 1 else 0),217],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,169);
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
    assert state == Running(217,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,217);
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
    assert state == Running(218,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,218);
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
    assert state == Running(219,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,219);
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
    assert state == Running(224,[Selector(word),Selector(word),2368205965],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,224);
  }
  lemma Frame159(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(159,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance159(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(225,[Selector(word),(if 2368205965 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,225);
  }
  lemma Frame160(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(160,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance160(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(228,[Selector(word),(if 2368205965 == Selector(word) then 1 else 0),789],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,228);
  }
  lemma Frame161(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(161,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance161(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(789,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame162(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(162,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance162(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(229,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,229);
  }
  lemma Frame163(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(163,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance163(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(230,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,230);
  }
  lemma Frame164(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(164,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance164(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(235,[Selector(word),Selector(word),2412878959],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,235);
  }
  lemma Frame165(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(165,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance165(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(236,[Selector(word),(if 2412878959 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,236);
  }
  lemma Frame166(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(166,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance166(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(239,[Selector(word),(if 2412878959 == Selector(word) then 1 else 0),808],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,239);
  }
  lemma Frame167(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(167,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance167(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(808,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame168(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(168,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance168(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(240,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,240);
  }
  lemma Frame169(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(169,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance169(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(241,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,241);
  }
  lemma Frame170(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(170,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance170(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(246,[Selector(word),Selector(word),2625112747],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,246);
  }
  lemma Frame171(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(171,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance171(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(247,[Selector(word),(if 2625112747 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,247);
  }
  lemma Frame172(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(172,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance172(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(250,[Selector(word),(if 2625112747 == Selector(word) then 1 else 0),827],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,250);
  }
  lemma Frame173(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(173,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance173(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(827,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame174(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(174,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance174(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(251,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,251);
  }
  lemma Frame175(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(175,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance175(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(252,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,252);
  }
  lemma Frame176(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(176,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance176(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(253,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,253);
  }
  lemma Frame177(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(177,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance177(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(170,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,170);
  }
  lemma Frame178(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(178,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance178(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(171,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,171);
  }
  lemma Frame179(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(179,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance179(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(176,[Selector(word),Selector(word),2874738232],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,176);
  }
  lemma Frame180(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(180,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance180(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(177,[Selector(word),(if 2874738232 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,177);
  }
  lemma Frame181(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(181,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance181(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(180,[Selector(word),(if 2874738232 == Selector(word) then 1 else 0),846],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,180);
  }
  lemma Frame182(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(182,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance182(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(846,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame183(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(183,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance183(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(181,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,181);
  }
  lemma Frame184(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(184,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance184(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(182,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,182);
  }
  lemma Frame185(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(185,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance185(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(187,[Selector(word),Selector(word),2989505972],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,187);
  }
  lemma Frame186(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(186,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance186(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(188,[Selector(word),(if 2989505972 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,188);
  }
  lemma Frame187(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(187,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance187(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(191,[Selector(word),(if 2989505972 == Selector(word) then 1 else 0),865],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,191);
  }
  lemma Frame188(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(188,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance188(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(865,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame189(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(189,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance189(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(192,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,192);
  }
  lemma Frame190(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(190,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance190(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(193,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,193);
  }
  lemma Frame191(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(191,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance191(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(198,[Selector(word),Selector(word),3001508401],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,198);
  }
  lemma Frame192(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(192,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance192(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(199,[Selector(word),(if 3001508401 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,199);
  }
  lemma Frame193(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(193,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance193(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(202,[Selector(word),(if 3001508401 == Selector(word) then 1 else 0),884],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,202);
  }
  lemma Frame194(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(194,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance194(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(884,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame195(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(195,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance195(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(203,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,203);
  }
  lemma Frame196(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(196,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance196(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(204,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,204);
  }
  lemma Frame197(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(197,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance197(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(209,[Selector(word),Selector(word),3045624246],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,209);
  }
  lemma Frame198(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(198,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance198(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(210,[Selector(word),(if 3045624246 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,210);
  }
  lemma Frame199(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(199,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance199(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(213,[Selector(word),(if 3045624246 == Selector(word) then 1 else 0),903],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,213);
  }
  lemma Frame200(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(200,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance200(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(903,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame201(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(201,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance201(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(214,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,214);
  }
  lemma Frame202(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(202,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance202(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(215,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,215);
  }
  lemma Frame203(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(203,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance203(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(216,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,216);
  }
  lemma Frame204(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(204,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance204(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(52,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,52);
  }
  lemma Frame205(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(205,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance205(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(53,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,53);
  }
  lemma Frame206(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(206,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance206(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(58,[Selector(word),Selector(word),3904669827],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,58);
  }
  lemma Frame207(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(207,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance207(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(59,[Selector(word),(if 3904669827 > Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,59);
  }
  lemma Frame208(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(208,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance208(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(62,[Selector(word),(if 3904669827 > Selector(word) then 1 else 0),110],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,62);
  }
  lemma Frame209(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(209,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance209(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(110,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,110);
  }
  lemma Frame210(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(210,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance210(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(111,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,111);
  }
  lemma Frame211(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(211,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance211(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(112,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,112);
  }
  lemma Frame212(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(212,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance212(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(117,[Selector(word),Selector(word),3309852450],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,117);
  }
  lemma Frame213(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(213,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance213(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(118,[Selector(word),(if 3309852450 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,118);
  }
  lemma Frame214(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(214,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance214(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(121,[Selector(word),(if 3309852450 == Selector(word) then 1 else 0),922],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,121);
  }
  lemma Frame215(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(215,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance215(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(922,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame216(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(216,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance216(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(122,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,122);
  }
  lemma Frame217(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(217,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance217(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(123,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,123);
  }
  lemma Frame218(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(218,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance218(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(128,[Selector(word),Selector(word),3395859074],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,128);
  }
  lemma Frame219(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(219,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance219(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(129,[Selector(word),(if 3395859074 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,129);
  }
  lemma Frame220(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(220,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance220(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(132,[Selector(word),(if 3395859074 == Selector(word) then 1 else 0),941],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,132);
  }
  lemma Frame221(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(221,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance221(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(941,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame222(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(222,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance222(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(133,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,133);
  }
  lemma Frame223(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(223,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance223(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(134,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,134);
  }
  lemma Frame224(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(224,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance224(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(139,[Selector(word),Selector(word),3411229406],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,139);
  }
  lemma Frame225(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(225,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance225(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(140,[Selector(word),(if 3411229406 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,140);
  }
  lemma Frame226(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(226,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance226(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(143,[Selector(word),(if 3411229406 == Selector(word) then 1 else 0),960],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,143);
  }
  lemma Frame227(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(227,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance227(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(960,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame228(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(228,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance228(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(144,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,144);
  }
  lemma Frame229(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(229,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance229(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(145,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,145);
  }
  lemma Frame230(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(230,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance230(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(150,[Selector(word),Selector(word),3705265211],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,150);
  }
  lemma Frame231(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(231,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance231(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(151,[Selector(word),(if 3705265211 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,151);
  }
  lemma Frame232(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(232,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance232(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(154,[Selector(word),(if 3705265211 == Selector(word) then 1 else 0),979],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,154);
  }
  lemma Frame233(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(233,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance233(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(979,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame234(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(234,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance234(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(155,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,155);
  }
  lemma Frame235(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(235,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance235(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(156,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,156);
  }
  lemma Frame236(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(236,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance236(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(157,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,157);
  }
  lemma Frame237(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(237,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance237(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(63,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,63);
  }
  lemma Frame238(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(238,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance238(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(64,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,64);
  }
  lemma Frame239(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(239,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance239(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(69,[Selector(word),Selector(word),3904669827],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,69);
  }
  lemma Frame240(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(240,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance240(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(70,[Selector(word),(if 3904669827 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,70);
  }
  lemma Frame241(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(241,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance241(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(73,[Selector(word),(if 3904669827 == Selector(word) then 1 else 0),998],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,73);
  }
  lemma Frame242(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(242,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance242(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(998,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame243(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(243,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance243(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(74,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,74);
  }
  lemma Frame244(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(244,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance244(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(75,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,75);
  }
  lemma Frame245(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(245,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance245(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(80,[Selector(word),Selector(word),3921833887],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,80);
  }
  lemma Frame246(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(246,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance246(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(81,[Selector(word),(if 3921833887 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,81);
  }
  lemma Frame247(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(247,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance247(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(84,[Selector(word),(if 3921833887 == Selector(word) then 1 else 0),1017],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,84);
  }
  lemma Frame248(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(248,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance248(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(1017,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame249(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(249,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance249(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(85,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,85);
  }
  lemma Frame250(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(250,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance250(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(86,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,86);
  }
  lemma Frame251(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(251,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance251(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(91,[Selector(word),Selector(word),3983393726],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,91);
  }
  lemma Frame252(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(252,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance252(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(92,[Selector(word),(if 3983393726 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,92);
  }
  lemma Frame253(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(253,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance253(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(95,[Selector(word),(if 3983393726 == Selector(word) then 1 else 0),1036],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,95);
  }
  lemma Frame254(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(254,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance254(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(1036,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame255(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(255,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance255(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(96,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,96);
  }
  lemma Frame256(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(256,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance256(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(97,[Selector(word),Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,97);
  }
  lemma Frame257(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(257,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance257(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(102,[Selector(word),Selector(word),4057501128],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,102);
  }
  lemma Frame258(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(258,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance258(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(103,[Selector(word),(if 4057501128 == Selector(word) then 1 else 0)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,103);
  }
  lemma Frame259(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(259,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance259(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(106,[Selector(word),(if 4057501128 == Selector(word) then 1 else 0),1055],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,106);
  }
  lemma Frame260(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(260,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance260(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(1055,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    assert false;
  }
  lemma Frame261(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(261,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance261(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(107,[Selector(word)],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,107);
  }
  lemma Frame262(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(262,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance262(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(108,[Selector(word),0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,108);
  }
  lemma Frame263(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(263,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance263(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(109,[Selector(word),0,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,109);
  }
  lemma Frame264(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(264,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance264(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(12,[value],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,12);
  }
  lemma Frame265(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(265,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance265(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running(13,[value,0],true);
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
    B.PrefixFetch(C.Code(),code,13);
  }
  lemma Frame266(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(266,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
    reveal C.Good(); reveal Matches();
    C.Advance266(state,value,size,word);
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
    else if id == 159 { Frame159(code,state,value,size,word); }
    else if id == 160 { Frame160(code,state,value,size,word); }
    else if id == 161 { Frame161(code,state,value,size,word); }
    else if id == 162 { Frame162(code,state,value,size,word); }
    else if id == 163 { Frame163(code,state,value,size,word); }
    else if id == 164 { Frame164(code,state,value,size,word); }
    else if id == 165 { Frame165(code,state,value,size,word); }
    else if id == 166 { Frame166(code,state,value,size,word); }
    else if id == 167 { Frame167(code,state,value,size,word); }
    else if id == 168 { Frame168(code,state,value,size,word); }
    else if id == 169 { Frame169(code,state,value,size,word); }
    else if id == 170 { Frame170(code,state,value,size,word); }
    else if id == 171 { Frame171(code,state,value,size,word); }
    else if id == 172 { Frame172(code,state,value,size,word); }
    else if id == 173 { Frame173(code,state,value,size,word); }
    else if id == 174 { Frame174(code,state,value,size,word); }
    else if id == 175 { Frame175(code,state,value,size,word); }
    else if id == 176 { Frame176(code,state,value,size,word); }
    else if id == 177 { Frame177(code,state,value,size,word); }
    else if id == 178 { Frame178(code,state,value,size,word); }
    else if id == 179 { Frame179(code,state,value,size,word); }
    else if id == 180 { Frame180(code,state,value,size,word); }
    else if id == 181 { Frame181(code,state,value,size,word); }
    else if id == 182 { Frame182(code,state,value,size,word); }
    else if id == 183 { Frame183(code,state,value,size,word); }
    else if id == 184 { Frame184(code,state,value,size,word); }
    else if id == 185 { Frame185(code,state,value,size,word); }
    else if id == 186 { Frame186(code,state,value,size,word); }
    else if id == 187 { Frame187(code,state,value,size,word); }
    else if id == 188 { Frame188(code,state,value,size,word); }
    else if id == 189 { Frame189(code,state,value,size,word); }
    else if id == 190 { Frame190(code,state,value,size,word); }
    else if id == 191 { Frame191(code,state,value,size,word); }
    else if id == 192 { Frame192(code,state,value,size,word); }
    else if id == 193 { Frame193(code,state,value,size,word); }
    else if id == 194 { Frame194(code,state,value,size,word); }
    else if id == 195 { Frame195(code,state,value,size,word); }
    else if id == 196 { Frame196(code,state,value,size,word); }
    else if id == 197 { Frame197(code,state,value,size,word); }
    else if id == 198 { Frame198(code,state,value,size,word); }
    else if id == 199 { Frame199(code,state,value,size,word); }
    else if id == 200 { Frame200(code,state,value,size,word); }
    else if id == 201 { Frame201(code,state,value,size,word); }
    else if id == 202 { Frame202(code,state,value,size,word); }
    else if id == 203 { Frame203(code,state,value,size,word); }
    else if id == 204 { Frame204(code,state,value,size,word); }
    else if id == 205 { Frame205(code,state,value,size,word); }
    else if id == 206 { Frame206(code,state,value,size,word); }
    else if id == 207 { Frame207(code,state,value,size,word); }
    else if id == 208 { Frame208(code,state,value,size,word); }
    else if id == 209 { Frame209(code,state,value,size,word); }
    else if id == 210 { Frame210(code,state,value,size,word); }
    else if id == 211 { Frame211(code,state,value,size,word); }
    else if id == 212 { Frame212(code,state,value,size,word); }
    else if id == 213 { Frame213(code,state,value,size,word); }
    else if id == 214 { Frame214(code,state,value,size,word); }
    else if id == 215 { Frame215(code,state,value,size,word); }
    else if id == 216 { Frame216(code,state,value,size,word); }
    else if id == 217 { Frame217(code,state,value,size,word); }
    else if id == 218 { Frame218(code,state,value,size,word); }
    else if id == 219 { Frame219(code,state,value,size,word); }
    else if id == 220 { Frame220(code,state,value,size,word); }
    else if id == 221 { Frame221(code,state,value,size,word); }
    else if id == 222 { Frame222(code,state,value,size,word); }
    else if id == 223 { Frame223(code,state,value,size,word); }
    else if id == 224 { Frame224(code,state,value,size,word); }
    else if id == 225 { Frame225(code,state,value,size,word); }
    else if id == 226 { Frame226(code,state,value,size,word); }
    else if id == 227 { Frame227(code,state,value,size,word); }
    else if id == 228 { Frame228(code,state,value,size,word); }
    else if id == 229 { Frame229(code,state,value,size,word); }
    else if id == 230 { Frame230(code,state,value,size,word); }
    else if id == 231 { Frame231(code,state,value,size,word); }
    else if id == 232 { Frame232(code,state,value,size,word); }
    else if id == 233 { Frame233(code,state,value,size,word); }
    else if id == 234 { Frame234(code,state,value,size,word); }
    else if id == 235 { Frame235(code,state,value,size,word); }
    else if id == 236 { Frame236(code,state,value,size,word); }
    else if id == 237 { Frame237(code,state,value,size,word); }
    else if id == 238 { Frame238(code,state,value,size,word); }
    else if id == 239 { Frame239(code,state,value,size,word); }
    else if id == 240 { Frame240(code,state,value,size,word); }
    else if id == 241 { Frame241(code,state,value,size,word); }
    else if id == 242 { Frame242(code,state,value,size,word); }
    else if id == 243 { Frame243(code,state,value,size,word); }
    else if id == 244 { Frame244(code,state,value,size,word); }
    else if id == 245 { Frame245(code,state,value,size,word); }
    else if id == 246 { Frame246(code,state,value,size,word); }
    else if id == 247 { Frame247(code,state,value,size,word); }
    else if id == 248 { Frame248(code,state,value,size,word); }
    else if id == 249 { Frame249(code,state,value,size,word); }
    else if id == 250 { Frame250(code,state,value,size,word); }
    else if id == 251 { Frame251(code,state,value,size,word); }
    else if id == 252 { Frame252(code,state,value,size,word); }
    else if id == 253 { Frame253(code,state,value,size,word); }
    else if id == 254 { Frame254(code,state,value,size,word); }
    else if id == 255 { Frame255(code,state,value,size,word); }
    else if id == 256 { Frame256(code,state,value,size,word); }
    else if id == 257 { Frame257(code,state,value,size,word); }
    else if id == 258 { Frame258(code,state,value,size,word); }
    else if id == 259 { Frame259(code,state,value,size,word); }
    else if id == 260 { Frame260(code,state,value,size,word); }
    else if id == 261 { Frame261(code,state,value,size,word); }
    else if id == 262 { Frame262(code,state,value,size,word); }
    else if id == 263 { Frame263(code,state,value,size,word); }
    else if id == 264 { Frame264(code,state,value,size,word); }
    else if id == 265 { Frame265(code,state,value,size,word); }
    else if id == 266 { Frame266(code,state,value,size,word); }
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
