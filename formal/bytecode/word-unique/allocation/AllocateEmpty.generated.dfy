// SPDX-License-Identifier: MIT
// Generated actual uniqueWords header allocation and pre-copy instructions.
include "../../iota/Arithmetic.dfy"
include "../../iota/AllocationScalar.dfy"
include "MaskOpcode.dfy"
include "../../alignment/Mask.dfy"
include "../../scans/Representation.dfy"
module BytecodeUniqueAllocateEmpty {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeIotaArithmetic
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeUniqueAllocationMaskOpcode
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
  predicate Admitted(n: Word, offset: Word, length: Word, ordered: Word, data: seq<Byte>) { n == 0 && length == n*32 && |data| < G.Modulus() && (offset as nat)+n*32 <= |data| }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6676] == 91 &&
                                              code[6677] == 96 &&
                                              code[6678] == 64 &&
                                              code[6679] == 81 &&
                                              code[6680] == 144 &&
                                              code[6681] == 128 &&
                                              code[6682] == 130 &&
                                              code[6683] == 82 &&
                                              code[6684] == 128 &&
                                              code[6685] == 96 &&
                                              code[6686] == 31 &&
                                              code[6687] == 1 &&
                                              code[6688] == 96 &&
                                              code[6689] == 31 &&
                                              code[6690] == 25 &&
                                              code[6691] == 22 &&
                                              code[6692] == 96 &&
                                              code[6693] == 32 &&
                                              code[6694] == 1 &&
                                              code[6695] == 130 &&
                                              code[6696] == 1 &&
                                              code[6697] == 96 &&
                                              code[6698] == 64 &&
                                              code[6699] == 82 &&
                                              code[6700] == 128 &&
                                              code[6701] == 21 &&
                                              code[6702] == 97 &&
                                              code[6703] == 26 &&
                                              code[6704] == 62 &&
                                              code[6705] == 87 &&
                                              code[6718] == 91 &&
                                              code[6719] == 80 &&
                                              code[6720] == 144 &&
                                              code[6721] == 80 &&
                                              code[6722] == 95 &&
                                              code[6723] == 128
  }
  function Destinations(): set<nat> { {6718} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, length: Word, ordered: Word, data: seq<Byte>) { Admitted(n,offset,length,ordered,data) && (
                                                                                                                        if id == 0 then state == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128))
                                                                                                                        else if id == 1 then state == Running(6677,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128))
                                                                                                                        else if id == 2 then state == Running(6679,[3045624246,518,offset,length,ordered,96,n*32,64],Store([],64,128))
                                                                                                                        else if id == 3 then state == Running(6680,[3045624246,518,offset,length,ordered,96,n*32,128],Store([],64,128))
                                                                                                                        else if id == 4 then state == Running(6681,[3045624246,518,offset,length,ordered,96,128,n*32],Store([],64,128))
                                                                                                                        else if id == 5 then state == Running(6682,[3045624246,518,offset,length,ordered,96,128,n*32,n*32],Store([],64,128))
                                                                                                                        else if id == 6 then state == Running(6683,[3045624246,518,offset,length,ordered,96,128,n*32,n*32,128],Store([],64,128))
                                                                                                                        else if id == 7 then state == Running(6684,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 8 then state == Running(6685,[3045624246,518,offset,length,ordered,96,128,n*32,n*32],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 9 then state == Running(6687,[3045624246,518,offset,length,ordered,96,128,n*32,n*32,31],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 10 then state == Running(6688,[3045624246,518,offset,length,ordered,96,128,n*32,n*32+31],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 11 then state == Running(6690,[3045624246,518,offset,length,ordered,96,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 12 then state == Running(6691,[3045624246,518,offset,length,ordered,96,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 13 then state == Running(6692,[3045624246,518,offset,length,ordered,96,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 14 then state == Running(6694,[3045624246,518,offset,length,ordered,96,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 15 then state == Running(6695,[3045624246,518,offset,length,ordered,96,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 16 then state == Running(6696,[3045624246,518,offset,length,ordered,96,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 17 then state == Running(6697,[3045624246,518,offset,length,ordered,96,128,n*32,Free(n)],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 18 then state == Running(6699,[3045624246,518,offset,length,ordered,96,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32))
                                                                                                                        else if id == 19 then state == Running(6700,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 20 then state == Running(6701,[3045624246,518,offset,length,ordered,96,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 21 then state == Running(6702,[3045624246,518,offset,length,ordered,96,128,n*32,1],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 22 then state == Running(6705,[3045624246,518,offset,length,ordered,96,128,n*32,1,6718],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 23 then state == Running(6718,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 24 then state == Running(6719,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 25 then state == Running(6720,[3045624246,518,offset,length,ordered,96,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 26 then state == Running(6721,[3045624246,518,offset,length,ordered,128,96],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 27 then state == Running(6722,[3045624246,518,offset,length,ordered,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else if id == 28 then state == Running(6723,[3045624246,518,offset,length,ordered,128,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(0,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    assert Fetch(code,6676) == Op(91,6677,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(1,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6677,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    F.Push1(code,6677);
    assert Fetch(code,6677) == Op(96,6679,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(2,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6679,[3045624246,518,offset,length,ordered,96,n*32,64],Store([],64,128));
    assert Fetch(code,6679) == Op(81,6680,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(3,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6680,[3045624246,518,offset,length,ordered,96,n*32,128],Store([],64,128));
    assert Fetch(code,6680) == Op(144,6681,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(4,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6681,[3045624246,518,offset,length,ordered,96,128,n*32],Store([],64,128));
    assert Fetch(code,6681) == Op(128,6682,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(5,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6682,[3045624246,518,offset,length,ordered,96,128,n*32,n*32],Store([],64,128));
    assert Fetch(code,6682) == Op(130,6683,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(6,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6683,[3045624246,518,offset,length,ordered,96,128,n*32,n*32,128],Store([],64,128));
    assert Fetch(code,6683) == Op(82,6684,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(7,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6684,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6684) == Op(128,6685,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(8,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6685,[3045624246,518,offset,length,ordered,96,128,n*32,n*32],Store(Store([],64,128),128,n*32));
    F.Push1(code,6685);
    assert Fetch(code,6685) == Op(96,6687,31);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(9,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6687,[3045624246,518,offset,length,ordered,96,128,n*32,n*32,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6687) == Op(1,6688,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(10,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6688,[3045624246,518,offset,length,ordered,96,128,n*32,n*32+31],Store(Store([],64,128),128,n*32));
    F.Push1(code,6688);
    assert Fetch(code,6688) == Op(96,6690,31);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(11,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6690,[3045624246,518,offset,length,ordered,96,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6690) == Op(25,6691,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(12,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();

    A.Fit(n);
    Normalized(n);
    SC.Not31();
    assert state == Running(6691,[3045624246,518,offset,length,ordered,96,128,n*32]+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],Store(Store([],64,128),128,n*32));
    MO.Step(code,Destinations(),[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store([],64,128),128,n*32),n,value,data);
    assert Step(code,Destinations(),state,value,data) == Running(6692,[3045624246,518,offset,length,ordered,96,128,n*32]+[n*32],Store(Store([],64,128),128,n*32));
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6691,[3045624246,518,offset,length,ordered,96,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6691) == Op(22,6692,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(13,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6692,[3045624246,518,offset,length,ordered,96,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,6692);
    assert Fetch(code,6692) == Op(96,6694,32);
  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(14,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,offset,length,ordered,data)
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
    assert state == Running(6694,[3045624246,518,offset,length,ordered,96,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6694) == Op(1,6695,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(15,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6695,[3045624246,518,offset,length,ordered,96,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6695) == Op(130,6696,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(16,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,offset,length,ordered,data)
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
    assert state == Running(6696,[3045624246,518,offset,length,ordered,96,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6696) == Op(1,6697,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(17,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6697,[3045624246,518,offset,length,ordered,96,128,n*32,Free(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,6697);
    assert Fetch(code,6697) == Op(96,6699,64);
  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(18,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6699,[3045624246,518,offset,length,ordered,96,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6699) == Op(82,6700,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(19,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6700,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6700) == Op(128,6701,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(20,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6701,[3045624246,518,offset,length,ordered,96,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6701) == Op(21,6702,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(21,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6702,[3045624246,518,offset,length,ordered,96,128,n*32,1],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    F.Push2(code,6702);
    assert Fetch(code,6702) == Op(97,6705,6718);
  }
  lemma Advance22(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(22,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6705,[3045624246,518,offset,length,ordered,96,128,n*32,1,6718],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6705) == Op(87,6706,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(23,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6718,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6718) == Op(91,6719,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(24,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6719,[3045624246,518,offset,length,ordered,96,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6719) == Op(80,6720,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(25,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6720,[3045624246,518,offset,length,ordered,96,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6720) == Op(144,6721,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(26,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6721,[3045624246,518,offset,length,ordered,128,96],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6721) == Op(80,6722,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(27,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,n,offset,length,ordered,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6722,[3045624246,518,offset,length,ordered,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6722) == Op(95,6723,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data) && Good(28,state,n,offset,length,ordered,data)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6724,[3045624246,518,offset,length,ordered,128,0,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6723,[3045624246,518,offset,length,ordered,128,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6723) == Op(128,6724,0);
  }
  lemma Start(n: Word, offset: Word, length: Word, ordered: Word, data: seq<Byte>)
    requires Admitted(n,offset,length,ordered,data)
    ensures Good(0,Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128)),n,offset,length,ordered,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,offset,length,ordered,data)
    ensures state == Running(6724,[3045624246,518,offset,length,ordered,128,0,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 30 && trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(n,offset,length,ordered,data);
    state := Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    trace := [state];
    Advance0(code,state,n,offset,length,ordered,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next0;
    Advance1(code,state,n,offset,length,ordered,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next1;
    Advance2(code,state,n,offset,length,ordered,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next2;
    Advance3(code,state,n,offset,length,ordered,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next3;
    Advance4(code,state,n,offset,length,ordered,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next4;
    Advance5(code,state,n,offset,length,ordered,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next5;
    Advance6(code,state,n,offset,length,ordered,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next6;
    Advance7(code,state,n,offset,length,ordered,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next7;
    Advance8(code,state,n,offset,length,ordered,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next8;
    Advance9(code,state,n,offset,length,ordered,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next9;
    Advance10(code,state,n,offset,length,ordered,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next10;
    Advance11(code,state,n,offset,length,ordered,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next11;
    Advance12(code,state,n,offset,length,ordered,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next12;
    Advance13(code,state,n,offset,length,ordered,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next13;
    Advance14(code,state,n,offset,length,ordered,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next14;
    Advance15(code,state,n,offset,length,ordered,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next15;
    Advance16(code,state,n,offset,length,ordered,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next16;
    Advance17(code,state,n,offset,length,ordered,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next17;
    Advance18(code,state,n,offset,length,ordered,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next18;
    Advance19(code,state,n,offset,length,ordered,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next19;
    Advance20(code,state,n,offset,length,ordered,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next20;
    Advance21(code,state,n,offset,length,ordered,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next21;
    Advance22(code,state,n,offset,length,ordered,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next22;
    Advance23(code,state,n,offset,length,ordered,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next23;
    Advance24(code,state,n,offset,length,ordered,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next24;
    Advance25(code,state,n,offset,length,ordered,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next25;
    Advance26(code,state,n,offset,length,ordered,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next26;
    Advance27(code,state,n,offset,length,ordered,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next27;
    Advance28(code,state,n,offset,length,ordered,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(6676,[3045624246,518,offset,length,ordered,96,n*32],Store([],64,128));
    state := next28;
  }
}
