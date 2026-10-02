// SPDX-License-Identifier: MIT
// Generated from complete runtime guard path; GAS consumes a truthful observation.
include "Scalar.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackExhaustionOtherLengthContinue {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import C = BytecodeCopyMachine
  import E = BytecodeExternalExecution
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import H = BytecodeApplyCallbackExhaustionScalar
  import W = BytecodeApplyWrongCallbackScalar
  import O = BytecodeApplyCallbackOutOfGasReturnMemory
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[16107] == 91 &&
                                              code[16108] == 95 &&
                                              code[16109] == 129 &&
                                              code[16110] == 81 &&
                                              code[16111] == 96 &&
                                              code[16112] == 4 &&
                                              code[16113] == 3 &&
                                              code[16114] == 97 &&
                                              code[16115] == 62 &&
                                              code[16116] == 252 &&
                                              code[16117] == 87 &&
                                              code[16124] == 91 &&
                                              code[16125] == 97 &&
                                              code[16126] == 63 &&
                                              code[16127] == 7 &&
                                              code[16128] == 96 &&
                                              code[16129] == 63 &&
                                              code[16130] == 132 &&
                                              code[16131] == 97 &&
                                              code[16132] == 92 &&
                                              code[16133] == 10 &&
                                              code[16134] == 86 &&
                                              code[16135] == 91 &&
                                              code[16136] == 90 &&
                                              code[16137] == 17 &&
                                              code[16138] == 21 &&
                                              code[16139] == 128 &&
                                              code[16140] == 97 &&
                                              code[16141] == 63 &&
                                              code[16142] == 37 &&
                                              code[16143] == 87 &&
                                              code[16144] == 80 &&
                                              code[16145] == 96 &&
                                              code[16146] == 1 &&
                                              code[16147] == 96 &&
                                              code[16148] == 1 &&
                                              code[16149] == 96 &&
                                              code[16150] == 224 &&
                                              code[16151] == 27 &&
                                              code[16152] == 3 &&
                                              code[16153] == 25 &&
                                              code[16154] == 129 &&
                                              code[16155] == 22 &&
                                              code[16156] == 99 &&
                                              code[16157] == 105 &&
                                              code[16158] == 56 &&
                                              code[16159] == 131 &&
                                              code[16160] == 7 &&
                                              code[16161] == 96 &&
                                              code[16162] == 225 &&
                                              code[16163] == 27 &&
                                              code[16164] == 20 &&
                                              code[16165] == 91 &&
                                              code[16166] == 21 &&
                                              code[16167] == 97 &&
                                              code[16168] == 63 &&
                                              code[16169] == 67 &&
                                              code[16170] == 87 &&
                                              code[16195] == 91 &&
                                              code[16196] == 80 &&
                                              code[16197] == 80 &&
                                              code[16198] == 80 &&
                                              code[16199] == 86 &&
                                              code[17017] == 91 &&
                                              code[23562] == 91 &&
                                              code[23563] == 95 &&
                                              code[23564] == 130 &&
                                              code[23565] == 97 &&
                                              code[23566] == 92 &&
                                              code[23567] == 24 &&
                                              code[23568] == 87 &&
                                              code[23576] == 91 &&
                                              code[23577] == 80 &&
                                              code[23578] == 4 &&
                                              code[23579] == 144 &&
                                              code[23580] == 86 }
  function Destinations(): set<nat> { {16124,16135,16165,16195,17017,23562,23576} }
  opaque predicate Admitted(mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) { H.Fits(mem,receipt,length,head) && X.Context(self) && |prefix| <= 1014 && cursor < |observations| && observations[cursor] == X.Gas(gasAfter) && length != 4 && gasAfter > gasBefore/63 }
  lemma Admission(mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures H.Fits(mem,receipt,length,head) && X.Context(self) && |prefix| <= 1014 && cursor < |observations| && observations[cursor] == X.Gas(gasAfter) && length != 4 && gasAfter > gasBefore/63
  { reveal Admitted(); }
  opaque predicate Good(id: nat,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) { Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && H.Fits(mem,receipt,length,head) && (
                                                                                                                                                                                                                                                                  if id == 0 then frame == X.Frame(Running(16107,prefix+[17017,gasBefore,receipt],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 1 then frame == X.Frame(Running(16108,prefix+[17017,gasBefore,receipt],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 2 then frame == X.Frame(Running(16109,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 3 then frame == X.Frame(Running(16110,prefix+[17017,gasBefore,receipt,0,receipt],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 4 then frame == X.Frame(Running(16111,prefix+[17017,gasBefore,receipt,0,length],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 5 then frame == X.Frame(Running(16113,prefix+[17017,gasBefore,receipt,0,length,4],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 6 then frame == X.Frame(Running(16114,prefix+[17017,gasBefore,receipt,0,H.Difference(length)],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 7 then frame == X.Frame(Running(16117,prefix+[17017,gasBefore,receipt,0,H.Difference(length),16124],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 8 then frame == X.Frame(Running(16124,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 9 then frame == X.Frame(Running(16125,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 10 then frame == X.Frame(Running(16128,prefix+[17017,gasBefore,receipt,0,16135],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 11 then frame == X.Frame(Running(16130,prefix+[17017,gasBefore,receipt,0,16135,63],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 12 then frame == X.Frame(Running(16131,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 13 then frame == X.Frame(Running(16134,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,23562],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 14 then frame == X.Frame(Running(23562,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 15 then frame == X.Frame(Running(23563,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 16 then frame == X.Frame(Running(23564,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 17 then frame == X.Frame(Running(23565,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0,63],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 18 then frame == X.Frame(Running(23568,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0,63,23576],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 19 then frame == X.Frame(Running(23576,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 20 then frame == X.Frame(Running(23577,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 21 then frame == X.Frame(Running(23578,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 22 then frame == X.Frame(Running(23579,prefix+[17017,gasBefore,receipt,0,16135,gasBefore/63],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 23 then frame == X.Frame(Running(23580,prefix+[17017,gasBefore,receipt,0,gasBefore/63,16135],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 24 then frame == X.Frame(Running(16135,prefix+[17017,gasBefore,receipt,0,gasBefore/63],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 25 then frame == X.Frame(Running(16136,prefix+[17017,gasBefore,receipt,0,gasBefore/63],mem),returned,cursor+0)
                                                                                                                                                                                                                                                                  else if id == 26 then frame == X.Frame(Running(16137,prefix+[17017,gasBefore,receipt,0,gasBefore/63,gasAfter],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 27 then frame == X.Frame(Running(16138,prefix+[17017,gasBefore,receipt,0,1],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 28 then frame == X.Frame(Running(16139,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 29 then frame == X.Frame(Running(16140,prefix+[17017,gasBefore,receipt,0,0,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 30 then frame == X.Frame(Running(16143,prefix+[17017,gasBefore,receipt,0,0,0,16165],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 31 then frame == X.Frame(Running(16144,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 32 then frame == X.Frame(Running(16145,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 33 then frame == X.Frame(Running(16147,prefix+[17017,gasBefore,receipt,0,1],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 34 then frame == X.Frame(Running(16149,prefix+[17017,gasBefore,receipt,0,1,1],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 35 then frame == X.Frame(Running(16151,prefix+[17017,gasBefore,receipt,0,1,1,224],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 36 then frame == X.Frame(Running(16152,prefix+[17017,gasBefore,receipt,0,1,W.Unit()],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 37 then frame == X.Frame(Running(16153,prefix+[17017,gasBefore,receipt,0,W.Unit()-1],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 38 then frame == X.Frame(Running(16154,prefix+[17017,gasBefore,receipt,0,W.HighMask()],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 39 then frame == X.Frame(Running(16155,prefix+[17017,gasBefore,receipt,0,W.HighMask(),0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 40 then frame == X.Frame(Running(16156,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 41 then frame == X.Frame(Running(16161,prefix+[17017,gasBefore,receipt,0,0,1765311239],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 42 then frame == X.Frame(Running(16163,prefix+[17017,gasBefore,receipt,0,0,1765311239,225],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 43 then frame == X.Frame(Running(16164,prefix+[17017,gasBefore,receipt,0,0,O.Header()],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 44 then frame == X.Frame(Running(16165,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 45 then frame == X.Frame(Running(16166,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 46 then frame == X.Frame(Running(16167,prefix+[17017,gasBefore,receipt,0,1],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 47 then frame == X.Frame(Running(16170,prefix+[17017,gasBefore,receipt,0,1,16195],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 48 then frame == X.Frame(Running(16195,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 49 then frame == X.Frame(Running(16196,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 50 then frame == X.Frame(Running(16197,prefix+[17017,gasBefore,receipt],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 51 then frame == X.Frame(Running(16198,prefix+[17017,gasBefore],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 52 then frame == X.Frame(Running(16199,prefix+[17017],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else if id == 53 then frame == X.Frame(Running(17017,prefix+[],mem),returned,cursor+1)
                                                                                                                                                                                                                                                                  else false) }
  lemma Advance0(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(0,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(1,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16107,prefix+[17017,gasBefore,receipt],mem),returned,cursor+0);
    assert Fetch(code,16107) == Op(91,16108,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance1(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(1,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(2,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16108,prefix+[17017,gasBefore,receipt],mem),returned,cursor+0);
    assert Fetch(code,16108) == Op(95,16109,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance2(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(2,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(3,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16109,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+0);
    assert Fetch(code,16109) == Op(129,16110,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance3(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(3,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(4,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16110,prefix+[17017,gasBefore,receipt,0,receipt],mem),returned,cursor+0);
    assert Fetch(code,16110) == Op(81,16111,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance4(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(4,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(5,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16111,prefix+[17017,gasBefore,receipt,0,length],mem),returned,cursor+0);
    F.Push1(code,16111);
    assert Fetch(code,16111) == Op(96,16113,4);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance5(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(5,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(6,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16113,prefix+[17017,gasBefore,receipt,0,length,4],mem),returned,cursor+0);
    assert Fetch(code,16113) == Op(3,16114,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance6(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(6,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(7,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16114,prefix+[17017,gasBefore,receipt,0,H.Difference(length)],mem),returned,cursor+0);
    F.Push2(code,16114);
    assert Fetch(code,16114) == Op(97,16117,16124);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance7(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(7,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(8,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16117,prefix+[17017,gasBefore,receipt,0,H.Difference(length),16124],mem),returned,cursor+0);
    assert Fetch(code,16117) == Op(87,16118,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance8(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(8,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(9,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16124,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+0);
    assert Fetch(code,16124) == Op(91,16125,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance9(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(9,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(10,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16125,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+0);
    F.Push2(code,16125);
    assert Fetch(code,16125) == Op(97,16128,16135);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance10(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(10,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(11,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16128,prefix+[17017,gasBefore,receipt,0,16135],mem),returned,cursor+0);
    F.Push1(code,16128);
    assert Fetch(code,16128) == Op(96,16130,63);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance11(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(11,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(12,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16130,prefix+[17017,gasBefore,receipt,0,16135,63],mem),returned,cursor+0);
    assert Fetch(code,16130) == Op(132,16131,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance12(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(12,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(13,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16131,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0);
    F.Push2(code,16131);
    assert Fetch(code,16131) == Op(97,16134,23562);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance13(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(13,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(14,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16134,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,23562],mem),returned,cursor+0);
    assert Fetch(code,16134) == Op(86,16135,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance14(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(14,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(15,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23562,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0);
    assert Fetch(code,23562) == Op(91,23563,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance15(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(15,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(16,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23563,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0);
    assert Fetch(code,23563) == Op(95,23564,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance16(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(16,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(17,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23564,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0],mem),returned,cursor+0);
    assert Fetch(code,23564) == Op(130,23565,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance17(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(17,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(18,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23565,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0,63],mem),returned,cursor+0);
    F.Push2(code,23565);
    assert Fetch(code,23565) == Op(97,23568,23576);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance18(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(18,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(19,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23568,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0,63,23576],mem),returned,cursor+0);
    assert Fetch(code,23568) == Op(87,23569,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance19(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(19,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(20,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23576,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0],mem),returned,cursor+0);
    assert Fetch(code,23576) == Op(91,23577,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance20(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(20,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(21,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23577,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore,0],mem),returned,cursor+0);
    assert Fetch(code,23577) == Op(80,23578,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance21(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(21,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(22,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23578,prefix+[17017,gasBefore,receipt,0,16135,63,gasBefore],mem),returned,cursor+0);
    assert Fetch(code,23578) == Op(4,23579,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance22(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(22,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(23,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23579,prefix+[17017,gasBefore,receipt,0,16135,gasBefore/63],mem),returned,cursor+0);
    assert Fetch(code,23579) == Op(144,23580,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance23(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(23,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(24,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(23580,prefix+[17017,gasBefore,receipt,0,gasBefore/63,16135],mem),returned,cursor+0);
    assert Fetch(code,23580) == Op(86,23581,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance24(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(24,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(25,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16135,prefix+[17017,gasBefore,receipt,0,gasBefore/63],mem),returned,cursor+0);
    assert Fetch(code,16135) == Op(91,16136,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance25(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(25,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(26,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16136,prefix+[17017,gasBefore,receipt,0,gasBefore/63],mem),returned,cursor+0);
    assert Fetch(code,16136) == Op(90,16137,0);
    reveal X.Step();
  }
  lemma Advance26(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(26,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(27,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16137,prefix+[17017,gasBefore,receipt,0,gasBefore/63,gasAfter],mem),returned,cursor+1);
    assert Fetch(code,16137) == Op(17,16138,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance27(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(27,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(28,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16138,prefix+[17017,gasBefore,receipt,0,1],mem),returned,cursor+1);
    assert Fetch(code,16138) == Op(21,16139,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance28(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(28,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(29,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16139,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1);
    assert Fetch(code,16139) == Op(128,16140,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance29(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(29,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(30,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16140,prefix+[17017,gasBefore,receipt,0,0,0],mem),returned,cursor+1);
    F.Push2(code,16140);
    assert Fetch(code,16140) == Op(97,16143,16165);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance30(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(30,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(31,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16143,prefix+[17017,gasBefore,receipt,0,0,0,16165],mem),returned,cursor+1);
    assert Fetch(code,16143) == Op(87,16144,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance31(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(31,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(32,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16144,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1);
    assert Fetch(code,16144) == Op(80,16145,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance32(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(32,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(33,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16145,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+1);
    F.Push1(code,16145);
    assert Fetch(code,16145) == Op(96,16147,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance33(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(33,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(34,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16147,prefix+[17017,gasBefore,receipt,0,1],mem),returned,cursor+1);
    F.Push1(code,16147);
    assert Fetch(code,16147) == Op(96,16149,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance34(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(34,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(35,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16149,prefix+[17017,gasBefore,receipt,0,1,1],mem),returned,cursor+1);
    F.Push1(code,16149);
    assert Fetch(code,16149) == Op(96,16151,224);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance35(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(35,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(36,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    W.UnitLiteral(); O.Literal();
    assert frame == X.Frame(Running(16151,prefix+[17017,gasBefore,receipt,0,1,1,224],mem),returned,cursor+1);
    assert Fetch(code,16151) == Op(27,16152,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance36(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(36,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(37,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16152,prefix+[17017,gasBefore,receipt,0,1,W.Unit()],mem),returned,cursor+1);
    assert Fetch(code,16152) == Op(3,16153,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance37(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(37,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(38,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    W.NotLiteral();
    assert frame == X.Frame(Running(16153,prefix+[17017,gasBefore,receipt,0,W.Unit()-1],mem),returned,cursor+1);
    assert Fetch(code,16153) == Op(25,16154,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance38(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(38,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(39,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16154,prefix+[17017,gasBefore,receipt,0,W.HighMask()],mem),returned,cursor+1);
    assert Fetch(code,16154) == Op(129,16155,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance39(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(39,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(40,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    H.Projection(head); H.Projection(0); H.ZeroMask();
    assert frame == X.Frame(Running(16155,prefix+[17017,gasBefore,receipt,0,W.HighMask(),0],mem),returned,cursor+1);
    assert Fetch(code,16155) == Op(22,16156,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance40(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(40,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(41,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16156,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1);
    P.Push4(code,16156);
    assert Fetch(code,16156) == Op(99,16161,1765311239);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance41(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(41,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(42,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16161,prefix+[17017,gasBefore,receipt,0,0,1765311239],mem),returned,cursor+1);
    F.Push1(code,16161);
    assert Fetch(code,16161) == Op(96,16163,225);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance42(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(42,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(43,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    W.UnitLiteral(); O.Literal();
    assert frame == X.Frame(Running(16163,prefix+[17017,gasBefore,receipt,0,0,1765311239,225],mem),returned,cursor+1);
    assert Fetch(code,16163) == Op(27,16164,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance43(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(43,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(44,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16164,prefix+[17017,gasBefore,receipt,0,0,O.Header()],mem),returned,cursor+1);
    assert Fetch(code,16164) == Op(20,16165,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance44(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(44,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(45,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16165,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1);
    assert Fetch(code,16165) == Op(91,16166,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance45(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(45,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(46,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16166,prefix+[17017,gasBefore,receipt,0,0],mem),returned,cursor+1);
    assert Fetch(code,16166) == Op(21,16167,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance46(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(46,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(47,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16167,prefix+[17017,gasBefore,receipt,0,1],mem),returned,cursor+1);
    F.Push2(code,16167);
    assert Fetch(code,16167) == Op(97,16170,16195);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance47(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(47,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(48,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16170,prefix+[17017,gasBefore,receipt,0,1,16195],mem),returned,cursor+1);
    assert Fetch(code,16170) == Op(87,16171,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance48(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(48,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(49,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16195,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+1);
    assert Fetch(code,16195) == Op(91,16196,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance49(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(49,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(50,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16196,prefix+[17017,gasBefore,receipt,0],mem),returned,cursor+1);
    assert Fetch(code,16196) == Op(80,16197,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance50(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(50,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(51,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16197,prefix+[17017,gasBefore,receipt],mem),returned,cursor+1);
    assert Fetch(code,16197) == Op(80,16198,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance51(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(51,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(52,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16198,prefix+[17017,gasBefore],mem),returned,cursor+1);
    assert Fetch(code,16198) == Op(80,16199,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  lemma Advance52(code: seq<Byte>,frame: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(52,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good(53,X.Step(code,Destinations(),frame,self,value,data,observations),mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);
    assert frame == X.Frame(Running(16199,prefix+[17017],mem),returned,cursor+1);
    assert Fetch(code,16199) == Op(86,16200,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();
  }
  ghost method Block0(code: seq<Byte>,initial: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(0,initial,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures Good(20,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace(); frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by { reveal E.Trace(); }
    Advance0(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next0 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next0);trace := trace+[next0];frame := next0;
    Advance1(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next1 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next1);trace := trace+[next1];frame := next1;
    Advance2(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next2 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next2);trace := trace+[next2];frame := next2;
    Advance3(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next3 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next3);trace := trace+[next3];frame := next3;
    Advance4(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next4 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next4);trace := trace+[next4];frame := next4;
    Advance5(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next5 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next5);trace := trace+[next5];frame := next5;
    Advance6(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next6 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next6);trace := trace+[next6];frame := next6;
    Advance7(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next7 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next7);trace := trace+[next7];frame := next7;
    Advance8(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next8 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next8);trace := trace+[next8];frame := next8;
    Advance9(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next9 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next9);trace := trace+[next9];frame := next9;
    Advance10(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next10 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next10);trace := trace+[next10];frame := next10;
    Advance11(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next11 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next11);trace := trace+[next11];frame := next11;
    Advance12(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next12 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next12);trace := trace+[next12];frame := next12;
    Advance13(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next13 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next13);trace := trace+[next13];frame := next13;
    Advance14(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next14 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next14);trace := trace+[next14];frame := next14;
    Advance15(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next15 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next15);trace := trace+[next15];frame := next15;
    Advance16(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next16 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next16);trace := trace+[next16];frame := next16;
    Advance17(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next17 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next17);trace := trace+[next17];frame := next17;
    Advance18(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next18 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next18);trace := trace+[next18];frame := next18;
    Advance19(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next19 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next19);trace := trace+[next19];frame := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(20,initial,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures Good(40,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace(); frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by { reveal E.Trace(); }
    Advance20(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next20 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next20);trace := trace+[next20];frame := next20;
    Advance21(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next21 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next21);trace := trace+[next21];frame := next21;
    Advance22(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next22 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next22);trace := trace+[next22];frame := next22;
    Advance23(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next23 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next23);trace := trace+[next23];frame := next23;
    Advance24(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next24 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next24);trace := trace+[next24];frame := next24;
    Advance25(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next25 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next25);trace := trace+[next25];frame := next25;
    Advance26(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next26 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next26);trace := trace+[next26];frame := next26;
    Advance27(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next27 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next27);trace := trace+[next27];frame := next27;
    Advance28(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next28 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next28);trace := trace+[next28];frame := next28;
    Advance29(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next29 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next29);trace := trace+[next29];frame := next29;
    Advance30(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next30 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next30);trace := trace+[next30];frame := next30;
    Advance31(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next31 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next31);trace := trace+[next31];frame := next31;
    Advance32(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next32 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next32);trace := trace+[next32];frame := next32;
    Advance33(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next33 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next33);trace := trace+[next33];frame := next33;
    Advance34(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next34 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next34);trace := trace+[next34];frame := next34;
    Advance35(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next35 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next35);trace := trace+[next35];frame := next35;
    Advance36(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next36 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next36);trace := trace+[next36];frame := next36;
    Advance37(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next37 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next37);trace := trace+[next37];frame := next37;
    Advance38(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next38 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next38);trace := trace+[next38];frame := next38;
    Advance39(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next39 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next39);trace := trace+[next39];frame := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: X.Frame,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && Good(40,initial,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures Good(53,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 14 && trace[0] == initial && trace[|trace|-1] == frame
  { hide E.Trace(); frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by { reveal E.Trace(); }
    Advance40(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next40 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next40);trace := trace+[next40];frame := next40;
    Advance41(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next41 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next41);trace := trace+[next41];frame := next41;
    Advance42(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next42 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next42);trace := trace+[next42];frame := next42;
    Advance43(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next43 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next43);trace := trace+[next43];frame := next43;
    Advance44(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next44 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next44);trace := trace+[next44];frame := next44;
    Advance45(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next45 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next45);trace := trace+[next45];frame := next45;
    Advance46(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next46 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next46);trace := trace+[next46];frame := next46;
    Advance47(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next47 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next47);trace := trace+[next47];frame := next47;
    Advance48(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next48 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next48);trace := trace+[next48];frame := next48;
    Advance49(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next49 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next49);trace := trace+[next49];frame := next49;
    Advance50(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next50 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next50);trace := trace+[next50];frame := next50;
    Advance51(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next51 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next51);trace := trace+[next51];frame := next51;
    Advance52(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    var next52 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next52);trace := trace+[next52];frame := next52;
  }
  ghost method Run(code: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations)
    ensures frame == X.Frame(Running(17017,prefix+[],mem),returned,cursor+1)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 54 && trace[0] == X.Frame(Running(16107,prefix+[17017,gasBefore,receipt],mem),returned,cursor+0) && trace[|trace|-1] == frame
  { hide E.Trace(); Admission(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations); frame := X.Frame(Running(16107,prefix+[17017,gasBefore,receipt],mem),returned,cursor+0);trace := [frame];reveal Good();
    var initial := frame;var part: seq<X.Frame>;
    assert prefix+[] == prefix;
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by { reveal E.Trace(); }
    frame,part := Block0(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    frame,part := Block1(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    frame,part := Block2(code,frame,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    assert trace[0] == initial;
  }
}
