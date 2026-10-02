// SPDX-License-Identifier: MIT
// Generated current sortWords scratch allocation segments.
include "../../scans/Execution.dfy"
include "../../scans/Representation.dfy"
include "../../scans/DecoderScalar.dfy"
include "MaskOpcode.dfy"
module BytecodeSortScratchNonempty {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  import SC = BytecodeIotaAllocationScalar
  import DS = BytecodeScanDecoderScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeSortScratchAllocationMaskOpcode
  predicate Admitted(n: Word, mem: seq<Byte>, data: seq<Byte>) { 0 < n < 0x800000000000000 && Load(mem,64) == 160+n*32 && 96 <= |mem| <= 192+2*n*32 && Round32(|mem|) == |mem| && |data| < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[3564] == 91 &&
                                              code[3565] == 96 &&
                                              code[3566] == 64 &&
                                              code[3567] == 81 &&
                                              code[3568] == 144 &&
                                              code[3569] == 128 &&
                                              code[3570] == 130 &&
                                              code[3571] == 82 &&
                                              code[3572] == 128 &&
                                              code[3573] == 96 &&
                                              code[3574] == 31 &&
                                              code[3575] == 1 &&
                                              code[3576] == 96 &&
                                              code[3577] == 31 &&
                                              code[3578] == 25 &&
                                              code[3579] == 22 &&
                                              code[3580] == 96 &&
                                              code[3581] == 32 &&
                                              code[3582] == 1 &&
                                              code[3583] == 130 &&
                                              code[3584] == 1 &&
                                              code[3585] == 96 &&
                                              code[3586] == 64 &&
                                              code[3587] == 82 &&
                                              code[3588] == 128 &&
                                              code[3589] == 21 &&
                                              code[3590] == 97 &&
                                              code[3591] == 14 &&
                                              code[3592] == 22 &&
                                              code[3593] == 87 &&
                                              code[3594] == 96 &&
                                              code[3595] == 32 &&
                                              code[3596] == 130 &&
                                              code[3597] == 1 &&
                                              code[3598] == 129 &&
                                              code[3599] == 128 &&
                                              code[3600] == 54 &&
                                              code[3601] == 131 &&
                                              code[3606] == 91
  }
  function Destinations(): set<nat> { {3606} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>) { Admitted(n,mem,data) && (
                                                                                                           if id == 0 then state == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem)
                                                                                                           else if id == 1 then state == Running(3565,[785862473,518,offset,n*32,128,n,0,n*32],mem)
                                                                                                           else if id == 2 then state == Running(3567,[785862473,518,offset,n*32,128,n,0,n*32,64],mem)
                                                                                                           else if id == 3 then state == Running(3568,[785862473,518,offset,n*32,128,n,0,n*32,160+n*32],mem)
                                                                                                           else if id == 4 then state == Running(3569,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],mem)
                                                                                                           else if id == 5 then state == Running(3570,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],mem)
                                                                                                           else if id == 6 then state == Running(3571,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32,160+n*32],mem)
                                                                                                           else if id == 7 then state == Running(3572,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 8 then state == Running(3573,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 9 then state == Running(3575,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32,31],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 10 then state == Running(3576,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+31],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 11 then state == Running(3578,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+31,31],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 12 then state == Running(3579,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 13 then state == Running(3580,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 14 then state == Running(3582,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32,32],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 15 then state == Running(3583,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+32],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 16 then state == Running(3584,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+32,160+n*32],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 17 then state == Running(3585,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+2*n*32],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 18 then state == Running(3587,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+2*n*32,64],Store(mem,160+n*32,n*32))
                                                                                                           else if id == 19 then state == Running(3588,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 20 then state == Running(3589,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 21 then state == Running(3590,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,0],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 22 then state == Running(3593,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,0,3606],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 23 then state == Running(3594,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 24 then state == Running(3596,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 25 then state == Running(3597,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,32,160+n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 26 then state == Running(3598,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 27 then state == Running(3599,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 28 then state == Running(3600,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else if id == 29 then state == Running(3601,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32,n*32,|data|],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(0,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    assert Fetch(code,3564) == Op(91,3565,0);

  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(1,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3565,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    F.Push1(code,3565);
    assert Fetch(code,3565) == Op(96,3567,64);

  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(2,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3567,[785862473,518,offset,n*32,128,n,0,n*32,64],mem);
    assert Fetch(code,3567) == Op(81,3568,0);

  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(3,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3568,[785862473,518,offset,n*32,128,n,0,n*32,160+n*32],mem);
    assert Fetch(code,3568) == Op(144,3569,0);

  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(4,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3569,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],mem);
    assert Fetch(code,3569) == Op(128,3570,0);

  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(5,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3570,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],mem);
    assert Fetch(code,3570) == Op(130,3571,0);

  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(6,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3571,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32,160+n*32],mem);
    assert Fetch(code,3571) == Op(82,3572,0);

  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(7,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3572,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],Store(mem,160+n*32,n*32));
    assert Fetch(code,3572) == Op(128,3573,0);

  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(8,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3573,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],Store(mem,160+n*32,n*32));
    F.Push1(code,3573);
    assert Fetch(code,3573) == Op(96,3575,31);

  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(9,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3575,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32,31],Store(mem,160+n*32,n*32));
    assert Fetch(code,3575) == Op(1,3576,0);

  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(10,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3576,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+31],Store(mem,160+n*32,n*32));
    F.Push1(code,3576);
    assert Fetch(code,3576) == Op(96,3578,31);

  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(11,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3578,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+31,31],Store(mem,160+n*32,n*32));
    assert Fetch(code,3578) == Op(25,3579,0);
    SC.Not31();

  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(12,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();

    assert state == Running(3579,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+31,115792089237316195423570985008687907853269984665640564039457584007913129639904],Store(mem,160+n*32,n*32));
    assert Fetch(code,3579) == Op(22,3580,0);
    var prefix: seq<Word> := [785862473,518,offset,n*32,128,n,0,160+n*32,n*32];
    assert state == Running(3579,prefix+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],Store(mem,160+n*32,n*32));
    MO.Step(code,Destinations(),prefix,Store(mem,160+n*32,n*32),n,value,data);
    assert Step(code,Destinations(),state,value,data) == Running(3580,prefix+[n*32],Store(mem,160+n*32,n*32));

  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(13,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3580,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],Store(mem,160+n*32,n*32));
    F.Push1(code,3580);
    assert Fetch(code,3580) == Op(96,3582,32);

  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(14,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3582,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32,32],Store(mem,160+n*32,n*32));
    assert Fetch(code,3582) == Op(1,3583,0);

  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(15,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3583,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+32],Store(mem,160+n*32,n*32));
    assert Fetch(code,3583) == Op(130,3584,0);

  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(16,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3584,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32+32,160+n*32],Store(mem,160+n*32,n*32));
    assert Fetch(code,3584) == Op(1,3585,0);

  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(17,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3585,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+2*n*32],Store(mem,160+n*32,n*32));
    F.Push1(code,3585);
    assert Fetch(code,3585) == Op(96,3587,64);

  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(18,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3587,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+2*n*32,64],Store(mem,160+n*32,n*32));
    assert Fetch(code,3587) == Op(82,3588,0);

  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(19,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3588,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3588) == Op(128,3589,0);

  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(20,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3589,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3589) == Op(21,3590,0);

  }
  lemma Advance21(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(21,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3590,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,0],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    F.Push2(code,3590);
    assert Fetch(code,3590) == Op(97,3593,3606);

  }
  lemma Advance22(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(22,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3593,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,0,3606],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3593) == Op(87,3594,0);

  }
  lemma Advance23(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(23,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3594,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    F.Push1(code,3594);
    assert Fetch(code,3594) == Op(96,3596,32);

  }
  lemma Advance24(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(24,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3596,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3596) == Op(130,3597,0);

  }
  lemma Advance25(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(25,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3597,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,32,160+n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3597) == Op(1,3598,0);

  }
  lemma Advance26(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(26,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3598,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3598) == Op(129,3599,0);

  }
  lemma Advance27(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(27,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3599,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3599) == Op(128,3600,0);

  }
  lemma Advance28(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(28,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3600,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32,n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3600) == Op(54,3601,0);

  }
  lemma Advance29(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(29,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 13 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3602,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32,n*32,|data|,192+n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32))
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3601,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32,n*32,|data|],Store(Store(mem,160+n*32,n*32),64,192+2*n*32));
    assert Fetch(code,3601) == Op(131,3602,0);

  }
  lemma Start(n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(n,mem,data)
    ensures Good(0,Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem),n,offset,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,mem,data)
    ensures state == Running(3602,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32,n*32,|data|,192+n*32],Store(Store(mem,160+n*32,n*32),64,192+2*n*32)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 31 && trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem) && trace[|trace|-1] == state
  {
    Start(n,offset,mem,data);
    state := Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    trace := [state];
    Advance0(code,state,n,offset,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next0;
    Advance1(code,state,n,offset,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next1;
    Advance2(code,state,n,offset,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next2;
    Advance3(code,state,n,offset,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next3;
    Advance4(code,state,n,offset,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next4;
    Advance5(code,state,n,offset,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next5;
    Advance6(code,state,n,offset,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next6;
    Advance7(code,state,n,offset,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next7;
    Advance8(code,state,n,offset,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next8;
    Advance9(code,state,n,offset,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next9;
    Advance10(code,state,n,offset,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next10;
    Advance11(code,state,n,offset,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next11;
    Advance12(code,state,n,offset,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next12;
    Advance13(code,state,n,offset,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next13;
    Advance14(code,state,n,offset,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next14;
    Advance15(code,state,n,offset,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next15;
    Advance16(code,state,n,offset,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next16;
    Advance17(code,state,n,offset,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next17;
    Advance18(code,state,n,offset,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next18;
    Advance19(code,state,n,offset,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next19;
    Advance20(code,state,n,offset,mem,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next20;
    Advance21(code,state,n,offset,mem,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next21;
    Advance22(code,state,n,offset,mem,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next22;
    Advance23(code,state,n,offset,mem,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next23;
    Advance24(code,state,n,offset,mem,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next24;
    Advance25(code,state,n,offset,mem,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next25;
    Advance26(code,state,n,offset,mem,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next26;
    Advance27(code,state,n,offset,mem,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next27;
    Advance28(code,state,n,offset,mem,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next28;
    Advance29(code,state,n,offset,mem,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    state := next29;
  }
}
