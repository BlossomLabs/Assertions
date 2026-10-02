// SPDX-License-Identifier: MIT
// Generated actual iota header allocation and pre-copy instructions.
include "Arithmetic.dfy"
include "AllocationScalar.dfy"
include "MaskOpcode.dfy"
include "../alignment/Mask.dfy"
include "../scans/Representation.dfy"
module BytecodeIotaAllocateNonempty {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeIotaArithmetic
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeIotaMaskOpcode
  import R = BytecodeScanRepresentation
  opaque function Aligned(n: Word): Word
    requires n < 0x800000000000000
  { G.BitAnd(n*32+31,BitNot(31)) }
  opaque function Plus(n: Word): Word
    requires n < 0x800000000000000
  { ((Aligned(n) as nat)+32)%G.Modulus() }
  opaque function Free(n: Word): Word
    requires n < 0x800000000000000
  { ((Plus(n) as nat)+128)%G.Modulus() }
  lemma DefineAligned(n: Word)
    requires n < 0x800000000000000
    ensures Aligned(n) == G.BitAnd(n*32+31,BitNot(31))
  { reveal Aligned(); }
  lemma DefinePlus(n: Word)
    requires n < 0x800000000000000
    ensures Plus(n) == ((Aligned(n) as nat)+32)%G.Modulus()
  { reveal Plus(); }
  lemma DefineFree(n: Word)
    requires n < 0x800000000000000
    ensures Free(n) == ((Plus(n) as nat)+128)%G.Modulus()
  { reveal Free(); }
  lemma AlignedLength(n: Word)
    requires n < 0x800000000000000
    ensures Aligned(n) == n*32
  { DefineAligned(n); AM.Mask(n); }
  lemma PlusLength(n: Word)
    requires n < 0x800000000000000
    ensures Plus(n) == n*32+32
  { AlignedLength(n); DefinePlus(n); }
  lemma FreeLength(n: Word)
    requires n < 0x800000000000000
    ensures Free(n) == n*32+160
  { PlusLength(n); DefineFree(n); }
  lemma Normalized(n: Word)
    requires n < 0x800000000000000
    ensures Aligned(n) == n*32 && Plus(n) == n*32+32 && Free(n) == n*32+160
  { AlignedLength(n); PlusLength(n); FreeLength(n); }
  predicate Admitted(n: Word, data: seq<Byte>) { 0 < n < 0x800000000000000 && |data| < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5576] == 91 &&
                                              code[5577] == 96 &&
                                              code[5578] == 64 &&
                                              code[5579] == 81 &&
                                              code[5580] == 144 &&
                                              code[5581] == 128 &&
                                              code[5582] == 130 &&
                                              code[5583] == 82 &&
                                              code[5584] == 128 &&
                                              code[5585] == 96 &&
                                              code[5586] == 31 &&
                                              code[5587] == 1 &&
                                              code[5588] == 96 &&
                                              code[5589] == 31 &&
                                              code[5590] == 25 &&
                                              code[5591] == 22 &&
                                              code[5592] == 96 &&
                                              code[5593] == 32 &&
                                              code[5594] == 1 &&
                                              code[5595] == 130 &&
                                              code[5596] == 1 &&
                                              code[5597] == 96 &&
                                              code[5598] == 64 &&
                                              code[5599] == 82 &&
                                              code[5600] == 128 &&
                                              code[5601] == 21 &&
                                              code[5602] == 97 &&
                                              code[5603] == 21 &&
                                              code[5604] == 242 &&
                                              code[5605] == 87 &&
                                              code[5606] == 96 &&
                                              code[5607] == 32 &&
                                              code[5608] == 130 &&
                                              code[5609] == 1 &&
                                              code[5610] == 129 &&
                                              code[5611] == 128 &&
                                              code[5612] == 54 &&
                                              code[5613] == 131 &&
                                              code[5618] == 91
  }
  function Destinations(): set<nat> { {5618} }
  opaque predicate Good(id: nat, state: State, n: Word, data: seq<Byte>) { Admitted(n,data) && (
                                                                             if id == 0 then state == Running(5576,[2368205965,518,n,96,n*32],Store([],64,128))
                                                                             else if id == 1 then state == Running(5577,[2368205965,518,n,96,n*32],Store([],64,128))
                                                                             else if id == 2 then state == Running(5579,[2368205965,518,n,96,n*32,64],Store([],64,128))
                                                                             else if id == 3 then state == Running(5580,[2368205965,518,n,96,n*32,128],Store([],64,128))
                                                                             else if id == 4 then state == Running(5581,[2368205965,518,n,96,128,n*32],Store([],64,128))
                                                                             else if id == 5 then state == Running(5582,[2368205965,518,n,96,128,n*32,n*32],Store([],64,128))
                                                                             else if id == 6 then state == Running(5583,[2368205965,518,n,96,128,n*32,n*32,128],Store([],64,128))
                                                                             else if id == 7 then state == Running(5584,[2368205965,518,n,96,128,n*32],Store(Store([],64,128),128,n*32))
                                                                             else if id == 8 then state == Running(5585,[2368205965,518,n,96,128,n*32,n*32],Store(Store([],64,128),128,n*32))
                                                                             else if id == 9 then state == Running(5587,[2368205965,518,n,96,128,n*32,n*32,31],Store(Store([],64,128),128,n*32))
                                                                             else if id == 10 then state == Running(5588,[2368205965,518,n,96,128,n*32,n*32+31],Store(Store([],64,128),128,n*32))
                                                                             else if id == 11 then state == Running(5590,[2368205965,518,n,96,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32))
                                                                             else if id == 12 then state == Running(5591,[2368205965,518,n,96,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32))
                                                                             else if id == 13 then state == Running(5592,[2368205965,518,n,96,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32))
                                                                             else if id == 14 then state == Running(5594,[2368205965,518,n,96,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32))
                                                                             else if id == 15 then state == Running(5595,[2368205965,518,n,96,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32))
                                                                             else if id == 16 then state == Running(5596,[2368205965,518,n,96,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32))
                                                                             else if id == 17 then state == Running(5597,[2368205965,518,n,96,128,n*32,Free(n)],Store(Store([],64,128),128,n*32))
                                                                             else if id == 18 then state == Running(5599,[2368205965,518,n,96,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32))
                                                                             else if id == 19 then state == Running(5600,[2368205965,518,n,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 20 then state == Running(5601,[2368205965,518,n,96,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 21 then state == Running(5602,[2368205965,518,n,96,128,n*32,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 22 then state == Running(5605,[2368205965,518,n,96,128,n*32,0,5618],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 23 then state == Running(5606,[2368205965,518,n,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 24 then state == Running(5608,[2368205965,518,n,96,128,n*32,32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 25 then state == Running(5609,[2368205965,518,n,96,128,n*32,32,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 26 then state == Running(5610,[2368205965,518,n,96,128,n*32,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 27 then state == Running(5611,[2368205965,518,n,96,128,n*32,160,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 28 then state == Running(5612,[2368205965,518,n,96,128,n*32,160,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else if id == 29 then state == Running(5613,[2368205965,518,n,96,128,n*32,160,n*32,n*32,|data|],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                             else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(0,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5576,[2368205965,518,n,96,n*32],Store([],64,128));
    assert Fetch(code,5576) == Op(91,5577,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(1,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5577,[2368205965,518,n,96,n*32],Store([],64,128));
    F.Push1(code,5577);
    assert Fetch(code,5577) == Op(96,5579,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(2,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5579,[2368205965,518,n,96,n*32,64],Store([],64,128));
    assert Fetch(code,5579) == Op(81,5580,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(3,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5580,[2368205965,518,n,96,n*32,128],Store([],64,128));
    assert Fetch(code,5580) == Op(144,5581,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(4,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5581,[2368205965,518,n,96,128,n*32],Store([],64,128));
    assert Fetch(code,5581) == Op(128,5582,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(5,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5582,[2368205965,518,n,96,128,n*32,n*32],Store([],64,128));
    assert Fetch(code,5582) == Op(130,5583,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(6,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5583,[2368205965,518,n,96,128,n*32,n*32,128],Store([],64,128));
    assert Fetch(code,5583) == Op(82,5584,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(7,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5584,[2368205965,518,n,96,128,n*32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5584) == Op(128,5585,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(8,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5585,[2368205965,518,n,96,128,n*32,n*32],Store(Store([],64,128),128,n*32));
    F.Push1(code,5585);
    assert Fetch(code,5585) == Op(96,5587,31);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(9,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5587,[2368205965,518,n,96,128,n*32,n*32,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5587) == Op(1,5588,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(10,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5588,[2368205965,518,n,96,128,n*32,n*32+31],Store(Store([],64,128),128,n*32));
    F.Push1(code,5588);
    assert Fetch(code,5588) == Op(96,5590,31);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(11,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5590,[2368205965,518,n,96,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5590) == Op(25,5591,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(12,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,data)
  {
    reveal Matches(); reveal Good();

    A.Fit(n);
    Normalized(n);
    SC.Not31();
    assert state == Running(5591,[2368205965,518,n,96,128,n*32]+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],Store(Store([],64,128),128,n*32));
    MO.Step(code,Destinations(),[2368205965,518,n,96,128,n*32],Store(Store([],64,128),128,n*32),n,value,data);
    assert Step(code,Destinations(),state,value,data) == Running(5592,[2368205965,518,n,96,128,n*32]+[n*32],Store(Store([],64,128),128,n*32));
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5591,[2368205965,518,n,96,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5591) == Op(22,5592,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(13,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5592,[2368205965,518,n,96,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,5592);
    assert Fetch(code,5592) == Op(96,5594,32);
  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(14,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();
    DefinePlus(n);
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5594,[2368205965,518,n,96,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5594) == Op(1,5595,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(15,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5595,[2368205965,518,n,96,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5595) == Op(130,5596,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(16,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();
    DefineFree(n);
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5596,[2368205965,518,n,96,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5596) == Op(1,5597,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(17,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5597,[2368205965,518,n,96,128,n*32,Free(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,5597);
    assert Fetch(code,5597) == Op(96,5599,64);
  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(18,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5599,[2368205965,518,n,96,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5599) == Op(82,5600,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(19,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5600,[2368205965,518,n,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5600) == Op(128,5601,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(20,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5601,[2368205965,518,n,96,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5601) == Op(21,5602,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(21,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5602,[2368205965,518,n,96,128,n*32,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    F.Push2(code,5602);
    assert Fetch(code,5602) == Op(97,5605,5618);
  }
  lemma Advance22(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(22,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5605,[2368205965,518,n,96,128,n*32,0,5618],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5605) == Op(87,5606,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(23,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5606,[2368205965,518,n,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    F.Push1(code,5606);
    assert Fetch(code,5606) == Op(96,5608,32);
  }
  lemma Advance24(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(24,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5608,[2368205965,518,n,96,128,n*32,32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5608) == Op(130,5609,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(25,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5609,[2368205965,518,n,96,128,n*32,32,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5609) == Op(1,5610,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(26,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5610,[2368205965,518,n,96,128,n*32,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5610) == Op(129,5611,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(27,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5611,[2368205965,518,n,96,128,n*32,160,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5611) == Op(128,5612,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(28,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,n,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5612,[2368205965,518,n,96,128,n*32,160,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5612) == Op(54,5613,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good(29,state,n,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5614,[2368205965,518,n,96,128,n*32,160,n*32,n*32,|data|,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5613,[2368205965,518,n,96,128,n*32,160,n*32,n*32,|data|],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5613) == Op(131,5614,0);
  }
  lemma Start(n: Word, data: seq<Byte>)
    requires Admitted(n,data)
    ensures Good(0,Running(5576,[2368205965,518,n,96,n*32],Store([],64,128)),n,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,data)
    ensures state == Running(5614,[2368205965,518,n,96,128,n*32,160,n*32,n*32,|data|,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 31 && trace[0] == Running(5576,[2368205965,518,n,96,n*32],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(n,data);
    state := Running(5576,[2368205965,518,n,96,n*32],Store([],64,128));
    trace := [state];
    Advance0(code,state,n,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,n,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,n,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,n,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,n,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,n,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,n,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,n,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,n,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,n,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,n,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,n,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,n,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,n,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,n,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,n,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,n,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,n,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,n,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,n,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
    Advance20(code,state,n,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    state := next20;
    Advance21(code,state,n,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    state := next21;
    Advance22(code,state,n,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    state := next22;
    Advance23(code,state,n,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    state := next23;
    Advance24(code,state,n,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    state := next24;
    Advance25(code,state,n,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    state := next25;
    Advance26(code,state,n,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    state := next26;
    Advance27(code,state,n,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    state := next27;
    Advance28(code,state,n,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    state := next28;
    Advance29(code,state,n,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    state := next29;
  }
}
