// SPDX-License-Identifier: MIT
// Generated actual zipWords header allocation and pre-copy instructions.
include "../../iota/Arithmetic.dfy"
include "../../iota/AllocationScalar.dfy"
include "MaskOpcode.dfy"
include "../../alignment/Mask.dfy"
include "../../scans/Representation.dfy"
module BytecodeZipAllocateEmpty {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeIotaArithmetic
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeZipAllocationMaskOpcode
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
  predicate Admitted(n: Word, a: Word, length: Word, b: Word, count: Word, data: seq<Byte>) { n == 0 && |data| < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2047] == 91 &&
                                              code[2048] == 96 &&
                                              code[2049] == 64 &&
                                              code[2050] == 81 &&
                                              code[2051] == 144 &&
                                              code[2052] == 128 &&
                                              code[2053] == 130 &&
                                              code[2054] == 82 &&
                                              code[2055] == 128 &&
                                              code[2056] == 96 &&
                                              code[2057] == 31 &&
                                              code[2058] == 1 &&
                                              code[2059] == 96 &&
                                              code[2060] == 31 &&
                                              code[2061] == 25 &&
                                              code[2062] == 22 &&
                                              code[2063] == 96 &&
                                              code[2064] == 32 &&
                                              code[2065] == 1 &&
                                              code[2066] == 130 &&
                                              code[2067] == 1 &&
                                              code[2068] == 96 &&
                                              code[2069] == 64 &&
                                              code[2070] == 82 &&
                                              code[2071] == 128 &&
                                              code[2072] == 21 &&
                                              code[2073] == 97 &&
                                              code[2074] == 8 &&
                                              code[2075] == 41 &&
                                              code[2076] == 87 &&
                                              code[2089] == 91 &&
                                              code[2090] == 80 &&
                                              code[2091] == 145 &&
                                              code[2092] == 80 &&
                                              code[2093] == 95
  }
  function Destinations(): set<nat> { {2089} }
  opaque predicate Good(id: nat, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, data: seq<Byte>) { Admitted(n,a,length,b,count,data) && (
                                                                                                                          if id == 0 then state == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128))
                                                                                                                          else if id == 1 then state == Running(2048,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128))
                                                                                                                          else if id == 2 then state == Running(2050,[269019481,518,a,length,b,length,96,count,n*32,64],Store([],64,128))
                                                                                                                          else if id == 3 then state == Running(2051,[269019481,518,a,length,b,length,96,count,n*32,128],Store([],64,128))
                                                                                                                          else if id == 4 then state == Running(2052,[269019481,518,a,length,b,length,96,count,128,n*32],Store([],64,128))
                                                                                                                          else if id == 5 then state == Running(2053,[269019481,518,a,length,b,length,96,count,128,n*32,n*32],Store([],64,128))
                                                                                                                          else if id == 6 then state == Running(2054,[269019481,518,a,length,b,length,96,count,128,n*32,n*32,128],Store([],64,128))
                                                                                                                          else if id == 7 then state == Running(2055,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 8 then state == Running(2056,[269019481,518,a,length,b,length,96,count,128,n*32,n*32],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 9 then state == Running(2058,[269019481,518,a,length,b,length,96,count,128,n*32,n*32,31],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 10 then state == Running(2059,[269019481,518,a,length,b,length,96,count,128,n*32,n*32+31],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 11 then state == Running(2061,[269019481,518,a,length,b,length,96,count,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 12 then state == Running(2062,[269019481,518,a,length,b,length,96,count,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 13 then state == Running(2063,[269019481,518,a,length,b,length,96,count,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 14 then state == Running(2065,[269019481,518,a,length,b,length,96,count,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 15 then state == Running(2066,[269019481,518,a,length,b,length,96,count,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 16 then state == Running(2067,[269019481,518,a,length,b,length,96,count,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 17 then state == Running(2068,[269019481,518,a,length,b,length,96,count,128,n*32,Free(n)],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 18 then state == Running(2070,[269019481,518,a,length,b,length,96,count,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32))
                                                                                                                          else if id == 19 then state == Running(2071,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 20 then state == Running(2072,[269019481,518,a,length,b,length,96,count,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 21 then state == Running(2073,[269019481,518,a,length,b,length,96,count,128,n*32,1],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 22 then state == Running(2076,[269019481,518,a,length,b,length,96,count,128,n*32,1,2089],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 23 then state == Running(2089,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 24 then state == Running(2090,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 25 then state == Running(2091,[269019481,518,a,length,b,length,96,count,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 26 then state == Running(2092,[269019481,518,a,length,b,length,128,count,96],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else if id == 27 then state == Running(2093,[269019481,518,a,length,b,length,128,count],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(0,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    assert Fetch(code,2047) == Op(91,2048,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(1,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2048,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    F.Push1(code,2048);
    assert Fetch(code,2048) == Op(96,2050,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(2,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2050,[269019481,518,a,length,b,length,96,count,n*32,64],Store([],64,128));
    assert Fetch(code,2050) == Op(81,2051,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(3,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2051,[269019481,518,a,length,b,length,96,count,n*32,128],Store([],64,128));
    assert Fetch(code,2051) == Op(144,2052,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(4,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2052,[269019481,518,a,length,b,length,96,count,128,n*32],Store([],64,128));
    assert Fetch(code,2052) == Op(128,2053,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(5,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2053,[269019481,518,a,length,b,length,96,count,128,n*32,n*32],Store([],64,128));
    assert Fetch(code,2053) == Op(130,2054,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(6,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2054,[269019481,518,a,length,b,length,96,count,128,n*32,n*32,128],Store([],64,128));
    assert Fetch(code,2054) == Op(82,2055,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(7,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2055,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2055) == Op(128,2056,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(8,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2056,[269019481,518,a,length,b,length,96,count,128,n*32,n*32],Store(Store([],64,128),128,n*32));
    F.Push1(code,2056);
    assert Fetch(code,2056) == Op(96,2058,31);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(9,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2058,[269019481,518,a,length,b,length,96,count,128,n*32,n*32,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2058) == Op(1,2059,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(10,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2059,[269019481,518,a,length,b,length,96,count,128,n*32,n*32+31],Store(Store([],64,128),128,n*32));
    F.Push1(code,2059);
    assert Fetch(code,2059) == Op(96,2061,31);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(11,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2061,[269019481,518,a,length,b,length,96,count,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2061) == Op(25,2062,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(12,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();

    A.Fit(n);
    Normalized(n);
    SC.Not31();
    assert state == Running(2062,[269019481,518,a,length,b,length,96,count,128,n*32]+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],Store(Store([],64,128),128,n*32));
    MO.Step(code,Destinations(),[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store([],64,128),128,n*32),n,value,data);
    assert Step(code,Destinations(),state,value,data) == Running(2063,[269019481,518,a,length,b,length,96,count,128,n*32]+[n*32],Store(Store([],64,128),128,n*32));
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2062,[269019481,518,a,length,b,length,96,count,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2062) == Op(22,2063,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(13,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2063,[269019481,518,a,length,b,length,96,count,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,2063);
    assert Fetch(code,2063) == Op(96,2065,32);
  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(14,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,a,length,b,count,data)
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
    assert state == Running(2065,[269019481,518,a,length,b,length,96,count,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2065) == Op(1,2066,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(15,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2066,[269019481,518,a,length,b,length,96,count,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2066) == Op(130,2067,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(16,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,a,length,b,count,data)
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
    assert state == Running(2067,[269019481,518,a,length,b,length,96,count,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2067) == Op(1,2068,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(17,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2068,[269019481,518,a,length,b,length,96,count,128,n*32,Free(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,2068);
    assert Fetch(code,2068) == Op(96,2070,64);
  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(18,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2070,[269019481,518,a,length,b,length,96,count,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32));
    assert Fetch(code,2070) == Op(82,2071,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(19,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2071,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2071) == Op(128,2072,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(20,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2072,[269019481,518,a,length,b,length,96,count,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2072) == Op(21,2073,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(21,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2073,[269019481,518,a,length,b,length,96,count,128,n*32,1],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    F.Push2(code,2073);
    assert Fetch(code,2073) == Op(97,2076,2089);
  }
  lemma Advance22(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(22,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2076,[269019481,518,a,length,b,length,96,count,128,n*32,1,2089],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2076) == Op(87,2077,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(23,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2089,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2089) == Op(91,2090,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(24,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2090,[269019481,518,a,length,b,length,96,count,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2090) == Op(80,2091,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(25,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2091,[269019481,518,a,length,b,length,96,count,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2091) == Op(145,2092,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(26,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,n,a,length,b,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2092,[269019481,518,a,length,b,length,128,count,96],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2092) == Op(80,2093,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,data) && Good(27,state,n,a,length,b,count,data)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(2094,[269019481,518,a,length,b,length,128,count,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(2093,[269019481,518,a,length,b,length,128,count],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,2093) == Op(95,2094,0);
  }
  lemma Start(n: Word, a: Word, length: Word, b: Word, count: Word, data: seq<Byte>)
    requires Admitted(n,a,length,b,count,data)
    ensures Good(0,Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128)),n,a,length,b,count,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, a: Word, length: Word, b: Word, count: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,a,length,b,count,data)
    ensures state == Running(2094,[269019481,518,a,length,b,length,128,count,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 29 && trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(n,a,length,b,count,data);
    state := Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    trace := [state];
    Advance0(code,state,n,a,length,b,count,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next0;
    Advance1(code,state,n,a,length,b,count,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next1;
    Advance2(code,state,n,a,length,b,count,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next2;
    Advance3(code,state,n,a,length,b,count,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next3;
    Advance4(code,state,n,a,length,b,count,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next4;
    Advance5(code,state,n,a,length,b,count,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next5;
    Advance6(code,state,n,a,length,b,count,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next6;
    Advance7(code,state,n,a,length,b,count,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next7;
    Advance8(code,state,n,a,length,b,count,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next8;
    Advance9(code,state,n,a,length,b,count,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next9;
    Advance10(code,state,n,a,length,b,count,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next10;
    Advance11(code,state,n,a,length,b,count,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next11;
    Advance12(code,state,n,a,length,b,count,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next12;
    Advance13(code,state,n,a,length,b,count,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next13;
    Advance14(code,state,n,a,length,b,count,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next14;
    Advance15(code,state,n,a,length,b,count,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next15;
    Advance16(code,state,n,a,length,b,count,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next16;
    Advance17(code,state,n,a,length,b,count,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next17;
    Advance18(code,state,n,a,length,b,count,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next18;
    Advance19(code,state,n,a,length,b,count,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next19;
    Advance20(code,state,n,a,length,b,count,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next20;
    Advance21(code,state,n,a,length,b,count,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next21;
    Advance22(code,state,n,a,length,b,count,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next22;
    Advance23(code,state,n,a,length,b,count,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next23;
    Advance24(code,state,n,a,length,b,count,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next24;
    Advance25(code,state,n,a,length,b,count,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next25;
    Advance26(code,state,n,a,length,b,count,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next26;
    Advance27(code,state,n,a,length,b,count,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(2047,[269019481,518,a,length,b,length,96,count,n*32],Store([],64,128));
    state := next27;
  }
}
