// SPDX-License-Identifier: MIT
// Generated actual reverseWords header allocation and pre-copy instructions.
include "../../iota/Arithmetic.dfy"
include "../../iota/AllocationScalar.dfy"
include "MaskOpcode.dfy"
include "../../alignment/Mask.dfy"
include "../../scans/Representation.dfy"
module BytecodeReverseAllocateEmpty {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeIotaArithmetic
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeReverseAllocationMaskOpcode
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
  predicate Admitted(n: Word, offset: Word, data: seq<Byte>) { n == 0 && |data| < G.Modulus() && (offset as nat)+n*32 <= |data| }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5799] == 91 &&
                                              code[5800] == 96 &&
                                              code[5801] == 64 &&
                                              code[5802] == 81 &&
                                              code[5803] == 144 &&
                                              code[5804] == 128 &&
                                              code[5805] == 130 &&
                                              code[5806] == 82 &&
                                              code[5807] == 128 &&
                                              code[5808] == 96 &&
                                              code[5809] == 31 &&
                                              code[5810] == 1 &&
                                              code[5811] == 96 &&
                                              code[5812] == 31 &&
                                              code[5813] == 25 &&
                                              code[5814] == 22 &&
                                              code[5815] == 96 &&
                                              code[5816] == 32 &&
                                              code[5817] == 1 &&
                                              code[5818] == 130 &&
                                              code[5819] == 1 &&
                                              code[5820] == 96 &&
                                              code[5821] == 64 &&
                                              code[5822] == 82 &&
                                              code[5823] == 128 &&
                                              code[5824] == 21 &&
                                              code[5825] == 97 &&
                                              code[5826] == 22 &&
                                              code[5827] == 209 &&
                                              code[5828] == 87 &&
                                              code[5841] == 91 &&
                                              code[5842] == 80 &&
                                              code[5843] == 145 &&
                                              code[5844] == 80 &&
                                              code[5845] == 95
  }
  function Destinations(): set<nat> { {5841} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, data: seq<Byte>) { Admitted(n,offset,data) && (
                                                                                           if id == 0 then state == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128))
                                                                                           else if id == 1 then state == Running(5800,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128))
                                                                                           else if id == 2 then state == Running(5802,[2874738232,518,offset,n*32,96,n,n*32,64],Store([],64,128))
                                                                                           else if id == 3 then state == Running(5803,[2874738232,518,offset,n*32,96,n,n*32,128],Store([],64,128))
                                                                                           else if id == 4 then state == Running(5804,[2874738232,518,offset,n*32,96,n,128,n*32],Store([],64,128))
                                                                                           else if id == 5 then state == Running(5805,[2874738232,518,offset,n*32,96,n,128,n*32,n*32],Store([],64,128))
                                                                                           else if id == 6 then state == Running(5806,[2874738232,518,offset,n*32,96,n,128,n*32,n*32,128],Store([],64,128))
                                                                                           else if id == 7 then state == Running(5807,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 8 then state == Running(5808,[2874738232,518,offset,n*32,96,n,128,n*32,n*32],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 9 then state == Running(5810,[2874738232,518,offset,n*32,96,n,128,n*32,n*32,31],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 10 then state == Running(5811,[2874738232,518,offset,n*32,96,n,128,n*32,n*32+31],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 11 then state == Running(5813,[2874738232,518,offset,n*32,96,n,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 12 then state == Running(5814,[2874738232,518,offset,n*32,96,n,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 13 then state == Running(5815,[2874738232,518,offset,n*32,96,n,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 14 then state == Running(5817,[2874738232,518,offset,n*32,96,n,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 15 then state == Running(5818,[2874738232,518,offset,n*32,96,n,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 16 then state == Running(5819,[2874738232,518,offset,n*32,96,n,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 17 then state == Running(5820,[2874738232,518,offset,n*32,96,n,128,n*32,Free(n)],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 18 then state == Running(5822,[2874738232,518,offset,n*32,96,n,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32))
                                                                                           else if id == 19 then state == Running(5823,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 20 then state == Running(5824,[2874738232,518,offset,n*32,96,n,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 21 then state == Running(5825,[2874738232,518,offset,n*32,96,n,128,n*32,1],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 22 then state == Running(5828,[2874738232,518,offset,n*32,96,n,128,n*32,1,5841],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 23 then state == Running(5841,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 24 then state == Running(5842,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 25 then state == Running(5843,[2874738232,518,offset,n*32,96,n,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 26 then state == Running(5844,[2874738232,518,offset,n*32,128,n,96],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else if id == 27 then state == Running(5845,[2874738232,518,offset,n*32,128,n],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(0,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    assert Fetch(code,5799) == Op(91,5800,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(1,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5800,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    F.Push1(code,5800);
    assert Fetch(code,5800) == Op(96,5802,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(2,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5802,[2874738232,518,offset,n*32,96,n,n*32,64],Store([],64,128));
    assert Fetch(code,5802) == Op(81,5803,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(3,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5803,[2874738232,518,offset,n*32,96,n,n*32,128],Store([],64,128));
    assert Fetch(code,5803) == Op(144,5804,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(4,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5804,[2874738232,518,offset,n*32,96,n,128,n*32],Store([],64,128));
    assert Fetch(code,5804) == Op(128,5805,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(5,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5805,[2874738232,518,offset,n*32,96,n,128,n*32,n*32],Store([],64,128));
    assert Fetch(code,5805) == Op(130,5806,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(6,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5806,[2874738232,518,offset,n*32,96,n,128,n*32,n*32,128],Store([],64,128));
    assert Fetch(code,5806) == Op(82,5807,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(7,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5807,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5807) == Op(128,5808,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(8,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5808,[2874738232,518,offset,n*32,96,n,128,n*32,n*32],Store(Store([],64,128),128,n*32));
    F.Push1(code,5808);
    assert Fetch(code,5808) == Op(96,5810,31);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(9,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5810,[2874738232,518,offset,n*32,96,n,128,n*32,n*32,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5810) == Op(1,5811,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(10,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5811,[2874738232,518,offset,n*32,96,n,128,n*32,n*32+31],Store(Store([],64,128),128,n*32));
    F.Push1(code,5811);
    assert Fetch(code,5811) == Op(96,5813,31);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(11,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5813,[2874738232,518,offset,n*32,96,n,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5813) == Op(25,5814,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(12,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,offset,data)
  {
    reveal Matches(); reveal Good();

    A.Fit(n);
    Normalized(n);
    SC.Not31();
    assert state == Running(5814,[2874738232,518,offset,n*32,96,n,128,n*32]+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],Store(Store([],64,128),128,n*32));
    MO.Step(code,Destinations(),[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store([],64,128),128,n*32),n,value,data);
    assert Step(code,Destinations(),state,value,data) == Running(5815,[2874738232,518,offset,n*32,96,n,128,n*32]+[n*32],Store(Store([],64,128),128,n*32));
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5814,[2874738232,518,offset,n*32,96,n,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5814) == Op(22,5815,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(13,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5815,[2874738232,518,offset,n*32,96,n,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,5815);
    assert Fetch(code,5815) == Op(96,5817,32);
  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(14,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,offset,data)
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
    assert state == Running(5817,[2874738232,518,offset,n*32,96,n,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5817) == Op(1,5818,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(15,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5818,[2874738232,518,offset,n*32,96,n,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5818) == Op(130,5819,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(16,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,offset,data)
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
    assert state == Running(5819,[2874738232,518,offset,n*32,96,n,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5819) == Op(1,5820,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(17,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5820,[2874738232,518,offset,n*32,96,n,128,n*32,Free(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,5820);
    assert Fetch(code,5820) == Op(96,5822,64);
  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(18,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5822,[2874738232,518,offset,n*32,96,n,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32));
    assert Fetch(code,5822) == Op(82,5823,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(19,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5823,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5823) == Op(128,5824,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(20,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5824,[2874738232,518,offset,n*32,96,n,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5824) == Op(21,5825,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(21,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5825,[2874738232,518,offset,n*32,96,n,128,n*32,1],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    F.Push2(code,5825);
    assert Fetch(code,5825) == Op(97,5828,5841);
  }
  lemma Advance22(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(22,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5828,[2874738232,518,offset,n*32,96,n,128,n*32,1,5841],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5828) == Op(87,5829,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(23,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5841,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5841) == Op(91,5842,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(24,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5842,[2874738232,518,offset,n*32,96,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5842) == Op(80,5843,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(25,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5843,[2874738232,518,offset,n*32,96,n,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5843) == Op(145,5844,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(26,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,n,offset,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5844,[2874738232,518,offset,n*32,128,n,96],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5844) == Op(80,5845,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, n: Word, offset: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,data) && Good(27,state,n,offset,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5846,[2874738232,518,offset,n*32,128,n,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(5845,[2874738232,518,offset,n*32,128,n],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,5845) == Op(95,5846,0);
  }
  lemma Start(n: Word, offset: Word, data: seq<Byte>)
    requires Admitted(n,offset,data)
    ensures Good(0,Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128)),n,offset,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,offset,data)
    ensures state == Running(5846,[2874738232,518,offset,n*32,128,n,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 29 && trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(n,offset,data);
    state := Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    trace := [state];
    Advance0(code,state,n,offset,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next0;
    Advance1(code,state,n,offset,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next1;
    Advance2(code,state,n,offset,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next2;
    Advance3(code,state,n,offset,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next3;
    Advance4(code,state,n,offset,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next4;
    Advance5(code,state,n,offset,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next5;
    Advance6(code,state,n,offset,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next6;
    Advance7(code,state,n,offset,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next7;
    Advance8(code,state,n,offset,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next8;
    Advance9(code,state,n,offset,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next9;
    Advance10(code,state,n,offset,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next10;
    Advance11(code,state,n,offset,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next11;
    Advance12(code,state,n,offset,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next12;
    Advance13(code,state,n,offset,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next13;
    Advance14(code,state,n,offset,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next14;
    Advance15(code,state,n,offset,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next15;
    Advance16(code,state,n,offset,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next16;
    Advance17(code,state,n,offset,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next17;
    Advance18(code,state,n,offset,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next18;
    Advance19(code,state,n,offset,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next19;
    Advance20(code,state,n,offset,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next20;
    Advance21(code,state,n,offset,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next21;
    Advance22(code,state,n,offset,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next22;
    Advance23(code,state,n,offset,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next23;
    Advance24(code,state,n,offset,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next24;
    Advance25(code,state,n,offset,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next25;
    Advance26(code,state,n,offset,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next26;
    Advance27(code,state,n,offset,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(5799,[2874738232,518,offset,n*32,96,n,n*32],Store([],64,128));
    state := next27;
  }
}
