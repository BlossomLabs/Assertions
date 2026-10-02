// SPDX-License-Identifier: MIT
// Generated current sortWords initial-copy instructions, before/after CALLDATACOPY.
include "../../scans/Execution.dfy"
include "../../scans/Representation.dfy"
module BytecodeSortAllocationCopyTail {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  predicate Admitted(n: Word, mem: seq<Byte>) { n < 0x800000000000000 && |mem| <= 192+n*32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[3511] == 95 &&
                                              code[3512] == 146 &&
                                              code[3513] == 1 &&
                                              code[3514] == 130 &&
                                              code[3515] == 144 &&
                                              code[3516] == 82 &&
                                              code[3517] == 80 &&
                                              code[3518] == 147 &&
                                              code[3519] == 148 &&
                                              code[3520] == 80 &&
                                              code[3521] == 97 &&
                                              code[3522] == 13 &&
                                              code[3523] == 209 &&
                                              code[3524] == 146 &&
                                              code[3525] == 80 &&
                                              code[3526] == 96 &&
                                              code[3527] == 32 &&
                                              code[3528] == 145 &&
                                              code[3529] == 80 &&
                                              code[3530] == 133 &&
                                              code[3531] == 144 &&
                                              code[3532] == 80 &&
                                              code[3533] == 97 &&
                                              code[3534] == 92 &&
                                              code[3535] == 10 &&
                                              code[3536] == 86 &&
                                              code[23562] == 91
  }
  function Destinations(): set<nat> { {23562} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, mem: seq<Byte>) { Admitted(n,mem) && (
                                                                                          if id == 0 then state == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem)
                                                                                          else if id == 1 then state == Running(3512,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32,0],mem)
                                                                                          else if id == 2 then state == Running(3513,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,n*32,160],mem)
                                                                                          else if id == 3 then state == Running(3514,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,160+n*32],mem)
                                                                                          else if id == 4 then state == Running(3515,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,160+n*32,0],mem)
                                                                                          else if id == 5 then state == Running(3516,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,0,160+n*32],mem)
                                                                                          else if id == 6 then state == Running(3517,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset],Store(mem,160+n*32,0))
                                                                                          else if id == 7 then state == Running(3518,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0],Store(mem,160+n*32,0))
                                                                                          else if id == 8 then state == Running(3519,[785862473,518,offset,n*32,96,0,offset,n*32,n*32,128],Store(mem,160+n*32,0))
                                                                                          else if id == 9 then state == Running(3520,[785862473,518,offset,n*32,128,0,offset,n*32,n*32,96],Store(mem,160+n*32,0))
                                                                                          else if id == 10 then state == Running(3521,[785862473,518,offset,n*32,128,0,offset,n*32,n*32],Store(mem,160+n*32,0))
                                                                                          else if id == 11 then state == Running(3524,[785862473,518,offset,n*32,128,0,offset,n*32,n*32,3537],Store(mem,160+n*32,0))
                                                                                          else if id == 12 then state == Running(3525,[785862473,518,offset,n*32,128,0,3537,n*32,n*32,offset],Store(mem,160+n*32,0))
                                                                                          else if id == 13 then state == Running(3526,[785862473,518,offset,n*32,128,0,3537,n*32,n*32],Store(mem,160+n*32,0))
                                                                                          else if id == 14 then state == Running(3528,[785862473,518,offset,n*32,128,0,3537,n*32,n*32,32],Store(mem,160+n*32,0))
                                                                                          else if id == 15 then state == Running(3529,[785862473,518,offset,n*32,128,0,3537,32,n*32,n*32],Store(mem,160+n*32,0))
                                                                                          else if id == 16 then state == Running(3530,[785862473,518,offset,n*32,128,0,3537,32,n*32],Store(mem,160+n*32,0))
                                                                                          else if id == 17 then state == Running(3531,[785862473,518,offset,n*32,128,0,3537,32,n*32,n*32],Store(mem,160+n*32,0))
                                                                                          else if id == 18 then state == Running(3532,[785862473,518,offset,n*32,128,0,3537,32,n*32,n*32],Store(mem,160+n*32,0))
                                                                                          else if id == 19 then state == Running(3533,[785862473,518,offset,n*32,128,0,3537,32,n*32],Store(mem,160+n*32,0))
                                                                                          else if id == 20 then state == Running(3536,[785862473,518,offset,n*32,128,0,3537,32,n*32,23562],Store(mem,160+n*32,0))
                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(0,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    assert Fetch(code,3511) == Op(95,3512,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(1,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3512,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32,0],mem);
    assert Fetch(code,3512) == Op(146,3513,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(2,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3513,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,n*32,160],mem);
    assert Fetch(code,3513) == Op(1,3514,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(3,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3514,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,160+n*32],mem);
    assert Fetch(code,3514) == Op(130,3515,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(4,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3515,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,160+n*32,0],mem);
    assert Fetch(code,3515) == Op(144,3516,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(5,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3516,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset,0,160+n*32],mem);
    assert Fetch(code,3516) == Op(82,3517,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(6,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3517,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0,offset],Store(mem,160+n*32,0));
    assert Fetch(code,3517) == Op(80,3518,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(7,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3518,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,0],Store(mem,160+n*32,0));
    assert Fetch(code,3518) == Op(147,3519,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(8,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3519,[785862473,518,offset,n*32,96,0,offset,n*32,n*32,128],Store(mem,160+n*32,0));
    assert Fetch(code,3519) == Op(148,3520,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(9,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3520,[785862473,518,offset,n*32,128,0,offset,n*32,n*32,96],Store(mem,160+n*32,0));
    assert Fetch(code,3520) == Op(80,3521,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(10,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3521,[785862473,518,offset,n*32,128,0,offset,n*32,n*32],Store(mem,160+n*32,0));
    F.Push2(code,3521);
    assert Fetch(code,3521) == Op(97,3524,3537);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(11,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3524,[785862473,518,offset,n*32,128,0,offset,n*32,n*32,3537],Store(mem,160+n*32,0));
    assert Fetch(code,3524) == Op(146,3525,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(12,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3525,[785862473,518,offset,n*32,128,0,3537,n*32,n*32,offset],Store(mem,160+n*32,0));
    assert Fetch(code,3525) == Op(80,3526,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(13,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3526,[785862473,518,offset,n*32,128,0,3537,n*32,n*32],Store(mem,160+n*32,0));
    F.Push1(code,3526);
    assert Fetch(code,3526) == Op(96,3528,32);
  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(14,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3528,[785862473,518,offset,n*32,128,0,3537,n*32,n*32,32],Store(mem,160+n*32,0));
    assert Fetch(code,3528) == Op(145,3529,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(15,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3529,[785862473,518,offset,n*32,128,0,3537,32,n*32,n*32],Store(mem,160+n*32,0));
    assert Fetch(code,3529) == Op(80,3530,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(16,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3530,[785862473,518,offset,n*32,128,0,3537,32,n*32],Store(mem,160+n*32,0));
    assert Fetch(code,3530) == Op(133,3531,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(17,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3531,[785862473,518,offset,n*32,128,0,3537,32,n*32,n*32],Store(mem,160+n*32,0));
    assert Fetch(code,3531) == Op(144,3532,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(18,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3532,[785862473,518,offset,n*32,128,0,3537,32,n*32,n*32],Store(mem,160+n*32,0));
    assert Fetch(code,3532) == Op(80,3533,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(19,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,offset,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3533,[785862473,518,offset,n*32,128,0,3537,32,n*32],Store(mem,160+n*32,0));
    F.Push2(code,3533);
    assert Fetch(code,3533) == Op(97,3536,23562);
  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good(20,state,n,offset,mem)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23562,[785862473,518,offset,n*32,128,0,3537,32,n*32],Store(mem,160+n*32,0))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running(3536,[785862473,518,offset,n*32,128,0,3537,32,n*32,23562],Store(mem,160+n*32,0));
    assert Fetch(code,3536) == Op(86,3537,0);
  }
  lemma Start(n: Word, offset: Word, mem: seq<Byte>)
    requires Admitted(n,mem)
    ensures Good(0,Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem),n,offset,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,mem)
    ensures state == Running(23562,[785862473,518,offset,n*32,128,0,3537,32,n*32],Store(mem,160+n*32,0)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 22 && trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem) && trace[|trace|-1] == state
  {
    Start(n,offset,mem);
    state := Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    trace := [state];
    Advance0(code,state,n,offset,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next0;
    Advance1(code,state,n,offset,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next1;
    Advance2(code,state,n,offset,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next2;
    Advance3(code,state,n,offset,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next3;
    Advance4(code,state,n,offset,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next4;
    Advance5(code,state,n,offset,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next5;
    Advance6(code,state,n,offset,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next6;
    Advance7(code,state,n,offset,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next7;
    Advance8(code,state,n,offset,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next8;
    Advance9(code,state,n,offset,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next9;
    Advance10(code,state,n,offset,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next10;
    Advance11(code,state,n,offset,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next11;
    Advance12(code,state,n,offset,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next12;
    Advance13(code,state,n,offset,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next13;
    Advance14(code,state,n,offset,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next14;
    Advance15(code,state,n,offset,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next15;
    Advance16(code,state,n,offset,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next16;
    Advance17(code,state,n,offset,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next17;
    Advance18(code,state,n,offset,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next18;
    Advance19(code,state,n,offset,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next19;
    Advance20(code,state,n,offset,mem,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(3511,[785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32],mem);
    state := next20;
  }
}
