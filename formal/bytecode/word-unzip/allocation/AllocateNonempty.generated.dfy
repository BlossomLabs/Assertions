// SPDX-License-Identifier: MIT
// Generated actual unzipWords header allocation and pre-copy instructions.
include "../../iota/Arithmetic.dfy"
include "../../iota/AllocationScalar.dfy"
include "MaskOpcode.dfy"
include "../../alignment/Mask.dfy"
include "../../scans/Representation.dfy"
module BytecodeUnzipAllocateNonempty {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeIotaArithmetic
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeUnzipAllocationMaskOpcode
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
  predicate Admitted(n: Word, offset: Word, length: Word, lane: Word, count: Word, data: seq<Byte>) { 0 < n < 0x800000000000000 && |data| < G.Modulus() && (offset as nat)+n*32 <= |data| }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6115] == 91 &&
                                              code[6116] == 96 &&
                                              code[6117] == 64 &&
                                              code[6118] == 81 &&
                                              code[6119] == 144 &&
                                              code[6120] == 128 &&
                                              code[6121] == 130 &&
                                              code[6122] == 82 &&
                                              code[6123] == 128 &&
                                              code[6124] == 96 &&
                                              code[6125] == 31 &&
                                              code[6126] == 1 &&
                                              code[6127] == 96 &&
                                              code[6128] == 31 &&
                                              code[6129] == 25 &&
                                              code[6130] == 22 &&
                                              code[6131] == 96 &&
                                              code[6132] == 32 &&
                                              code[6133] == 1 &&
                                              code[6134] == 130 &&
                                              code[6135] == 1 &&
                                              code[6136] == 96 &&
                                              code[6137] == 64 &&
                                              code[6138] == 82 &&
                                              code[6139] == 128 &&
                                              code[6140] == 21 &&
                                              code[6141] == 97 &&
                                              code[6142] == 24 &&
                                              code[6143] == 13 &&
                                              code[6144] == 87 &&
                                              code[6145] == 96 &&
                                              code[6146] == 32 &&
                                              code[6147] == 130 &&
                                              code[6148] == 1 &&
                                              code[6149] == 129 &&
                                              code[6150] == 128 &&
                                              code[6151] == 54 &&
                                              code[6152] == 131 &&
                                              code[6157] == 91
  }
  function Destinations(): set<nat> { {6157} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, data: seq<Byte>) { Admitted(n,offset,length,lane,count,data) && (
                                                                                                                                  if id == 0 then state == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128))
                                                                                                                                  else if id == 1 then state == Running(6116,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128))
                                                                                                                                  else if id == 2 then state == Running(6118,[2989505972,518,offset,length,lane,96,count,n,n*32,64],Store([],64,128))
                                                                                                                                  else if id == 3 then state == Running(6119,[2989505972,518,offset,length,lane,96,count,n,n*32,128],Store([],64,128))
                                                                                                                                  else if id == 4 then state == Running(6120,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store([],64,128))
                                                                                                                                  else if id == 5 then state == Running(6121,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32],Store([],64,128))
                                                                                                                                  else if id == 6 then state == Running(6122,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32,128],Store([],64,128))
                                                                                                                                  else if id == 7 then state == Running(6123,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 8 then state == Running(6124,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 9 then state == Running(6126,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32,31],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 10 then state == Running(6127,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32+31],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 11 then state == Running(6129,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 12 then state == Running(6130,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 13 then state == Running(6131,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 14 then state == Running(6133,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 15 then state == Running(6134,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 16 then state == Running(6135,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 17 then state == Running(6136,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Free(n)],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 18 then state == Running(6138,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32))
                                                                                                                                  else if id == 19 then state == Running(6139,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 20 then state == Running(6140,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 21 then state == Running(6141,[2989505972,518,offset,length,lane,96,count,n,128,n*32,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 22 then state == Running(6144,[2989505972,518,offset,length,lane,96,count,n,128,n*32,0,6157],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 23 then state == Running(6145,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 24 then state == Running(6147,[2989505972,518,offset,length,lane,96,count,n,128,n*32,32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 25 then state == Running(6148,[2989505972,518,offset,length,lane,96,count,n,128,n*32,32,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 26 then state == Running(6149,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 27 then state == Running(6150,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 28 then state == Running(6151,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else if id == 29 then state == Running(6152,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32,n*32,|data|],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
                                                                                                                                  else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(0,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    assert Fetch(code,6115) == Op(91,6116,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(1,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6116,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    F.Push1(code,6116);
    assert Fetch(code,6116) == Op(96,6118,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(2,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6118,[2989505972,518,offset,length,lane,96,count,n,n*32,64],Store([],64,128));
    assert Fetch(code,6118) == Op(81,6119,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(3,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6119,[2989505972,518,offset,length,lane,96,count,n,n*32,128],Store([],64,128));
    assert Fetch(code,6119) == Op(144,6120,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(4,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6120,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store([],64,128));
    assert Fetch(code,6120) == Op(128,6121,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(5,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6121,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32],Store([],64,128));
    assert Fetch(code,6121) == Op(130,6122,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(6,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6122,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32,128],Store([],64,128));
    assert Fetch(code,6122) == Op(82,6123,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(7,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6123,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6123) == Op(128,6124,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(8,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6124,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32],Store(Store([],64,128),128,n*32));
    F.Push1(code,6124);
    assert Fetch(code,6124) == Op(96,6126,31);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(9,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6126,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6126) == Op(1,6127,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(10,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6127,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32+31],Store(Store([],64,128),128,n*32));
    F.Push1(code,6127);
    assert Fetch(code,6127) == Op(96,6129,31);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(11,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6129,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32+31,31],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6129) == Op(25,6130,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(12,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();

    A.Fit(n);
    Normalized(n);
    SC.Not31();
    assert state == Running(6130,[2989505972,518,offset,length,lane,96,count,n,128,n*32]+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],Store(Store([],64,128),128,n*32));
    MO.Step(code,Destinations(),[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store(Store([],64,128),128,n*32),n,value,data);
    assert Step(code,Destinations(),state,value,data) == Running(6131,[2989505972,518,offset,length,lane,96,count,n,128,n*32]+[n*32],Store(Store([],64,128),128,n*32));
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6130,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6130) == Op(22,6131,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(13,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6131,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Aligned(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,6131);
    assert Fetch(code,6131) == Op(96,6133,32);
  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(14,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,offset,length,lane,count,data)
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
    assert state == Running(6133,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Aligned(n),32],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6133) == Op(1,6134,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(15,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6134,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Plus(n)],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6134) == Op(130,6135,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(16,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,offset,length,lane,count,data)
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
    assert state == Running(6135,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Plus(n),128],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6135) == Op(1,6136,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(17,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6136,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Free(n)],Store(Store([],64,128),128,n*32));
    F.Push1(code,6136);
    assert Fetch(code,6136) == Op(96,6138,64);
  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(18,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6138,[2989505972,518,offset,length,lane,96,count,n,128,n*32,Free(n),64],Store(Store([],64,128),128,n*32));
    assert Fetch(code,6138) == Op(82,6139,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(19,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6139,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6139) == Op(128,6140,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(20,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6140,[2989505972,518,offset,length,lane,96,count,n,128,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6140) == Op(21,6141,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(21,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6141,[2989505972,518,offset,length,lane,96,count,n,128,n*32,0],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    F.Push2(code,6141);
    assert Fetch(code,6141) == Op(97,6144,6157);
  }
  lemma Advance22(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(22,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6144,[2989505972,518,offset,length,lane,96,count,n,128,n*32,0,6157],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6144) == Op(87,6145,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(23,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6145,[2989505972,518,offset,length,lane,96,count,n,128,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    F.Push1(code,6145);
    assert Fetch(code,6145) == Op(96,6147,32);
  }
  lemma Advance24(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(24,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6147,[2989505972,518,offset,length,lane,96,count,n,128,n*32,32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6147) == Op(130,6148,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(25,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6148,[2989505972,518,offset,length,lane,96,count,n,128,n*32,32,128],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6148) == Op(1,6149,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(26,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6149,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6149) == Op(129,6150,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(27,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6150,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6150) == Op(128,6151,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(28,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,n,offset,length,lane,count,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6151,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32,n*32],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6151) == Op(54,6152,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data) && Good(29,state,n,offset,length,lane,count,data)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6153,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32,n*32,|data|,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
  {
    reveal Matches(); reveal Good();
    reveal Step();
    A.Fit(n);
    Normalized(n);
    SC.Not31();

    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running(6152,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32,n*32,|data|],Store(Store(Store([],64,128),128,n*32),64,Free(n)));
    assert Fetch(code,6152) == Op(131,6153,0);
  }
  lemma Start(n: Word, offset: Word, length: Word, lane: Word, count: Word, data: seq<Byte>)
    requires Admitted(n,offset,length,lane,count,data)
    ensures Good(0,Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128)),n,offset,length,lane,count,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, length: Word, lane: Word, count: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,data)
    ensures state == Running(6153,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32,n*32,|data|,160],Store(Store(Store([],64,128),128,n*32),64,Free(n)))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 31 && trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(n,offset,length,lane,count,data);
    state := Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    trace := [state];
    Advance0(code,state,n,offset,length,lane,count,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next0;
    Advance1(code,state,n,offset,length,lane,count,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next1;
    Advance2(code,state,n,offset,length,lane,count,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next2;
    Advance3(code,state,n,offset,length,lane,count,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next3;
    Advance4(code,state,n,offset,length,lane,count,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next4;
    Advance5(code,state,n,offset,length,lane,count,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next5;
    Advance6(code,state,n,offset,length,lane,count,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next6;
    Advance7(code,state,n,offset,length,lane,count,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next7;
    Advance8(code,state,n,offset,length,lane,count,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next8;
    Advance9(code,state,n,offset,length,lane,count,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next9;
    Advance10(code,state,n,offset,length,lane,count,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next10;
    Advance11(code,state,n,offset,length,lane,count,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next11;
    Advance12(code,state,n,offset,length,lane,count,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next12;
    Advance13(code,state,n,offset,length,lane,count,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next13;
    Advance14(code,state,n,offset,length,lane,count,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next14;
    Advance15(code,state,n,offset,length,lane,count,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next15;
    Advance16(code,state,n,offset,length,lane,count,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next16;
    Advance17(code,state,n,offset,length,lane,count,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next17;
    Advance18(code,state,n,offset,length,lane,count,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next18;
    Advance19(code,state,n,offset,length,lane,count,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next19;
    Advance20(code,state,n,offset,length,lane,count,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next20;
    Advance21(code,state,n,offset,length,lane,count,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next21;
    Advance22(code,state,n,offset,length,lane,count,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next22;
    Advance23(code,state,n,offset,length,lane,count,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next23;
    Advance24(code,state,n,offset,length,lane,count,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next24;
    Advance25(code,state,n,offset,length,lane,count,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next25;
    Advance26(code,state,n,offset,length,lane,count,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next26;
    Advance27(code,state,n,offset,length,lane,count,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next27;
    Advance28(code,state,n,offset,length,lane,count,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next28;
    Advance29(code,state,n,offset,length,lane,count,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(6115,[2989505972,518,offset,length,lane,96,count,n,n*32],Store([],64,128));
    state := next29;
  }
}
