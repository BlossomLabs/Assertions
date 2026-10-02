// SPDX-License-Identifier: MIT
// Generated actual code-less target path to complete physical REVERT.
include "../../external-calls/Execution.dfy"
include "../../scans/Push.dfy"
include "Memory.dfy"
include "Scalar.dfy"
include "Sequence.dfy"
module BytecodeApplyTargetRejected {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTargetErrorMemory
  import SC = BytecodeApplyTargetErrorScalar
  import AM = BytecodeApplyAddressMask
  import Q = BytecodeApplyTargetErrorSequence
  predicate Admitted(target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) { X.Context(self) && target < AM.Bound() && 0 < n < 0x800000000000000 && |prefix| <= 1018 && cursor < |observations| && observations[cursor] == X.CodeSize(target,0) }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[1114] == 91 &&
                                              code[1115] == 96 &&
                                              code[1116] == 64 &&
                                              code[1117] == 81 &&
                                              code[1118] == 128 &&
                                              code[1119] == 145 &&
                                              code[1120] == 3 &&
                                              code[1121] == 144 &&
                                              code[1122] == 253 &&
                                              code[15859] == 91 &&
                                              code[15860] == 128 &&
                                              code[15861] == 96 &&
                                              code[15862] == 1 &&
                                              code[15863] == 96 &&
                                              code[15864] == 1 &&
                                              code[15865] == 96 &&
                                              code[15866] == 160 &&
                                              code[15867] == 27 &&
                                              code[15868] == 3 &&
                                              code[15869] == 22 &&
                                              code[15870] == 59 &&
                                              code[15871] == 95 &&
                                              code[15872] == 3 &&
                                              code[15873] == 97 &&
                                              code[15874] == 62 &&
                                              code[15875] == 40 &&
                                              code[15876] == 87 &&
                                              code[15877] == 96 &&
                                              code[15878] == 64 &&
                                              code[15879] == 81 &&
                                              code[15880] == 99 &&
                                              code[15881] == 42 &&
                                              code[15882] == 89 &&
                                              code[15883] == 148 &&
                                              code[15884] == 69 &&
                                              code[15885] == 96 &&
                                              code[15886] == 225 &&
                                              code[15887] == 27 &&
                                              code[15888] == 129 &&
                                              code[15889] == 82 &&
                                              code[15890] == 96 &&
                                              code[15891] == 1 &&
                                              code[15892] == 96 &&
                                              code[15893] == 1 &&
                                              code[15894] == 96 &&
                                              code[15895] == 160 &&
                                              code[15896] == 27 &&
                                              code[15897] == 3 &&
                                              code[15898] == 130 &&
                                              code[15899] == 22 &&
                                              code[15900] == 96 &&
                                              code[15901] == 4 &&
                                              code[15902] == 130 &&
                                              code[15903] == 1 &&
                                              code[15904] == 82 &&
                                              code[15905] == 96 &&
                                              code[15906] == 36 &&
                                              code[15907] == 1 &&
                                              code[15908] == 97 &&
                                              code[15909] == 4 &&
                                              code[15910] == 90 &&
                                              code[15911] == 86 &&
                                              code[15912] == 91 }
  function Destinations(): set<nat> { {1114,15912} }
  opaque predicate Good(id: nat,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) { Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && (
                                                                                                                                                                                                          if id == 0 then frame == X.Frame(Running(15859,prefix+[12334,target],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 1 then frame == X.Frame(Running(15860,prefix+[12334,target],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 2 then frame == X.Frame(Running(15861,prefix+[12334,target,target],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 3 then frame == X.Frame(Running(15863,prefix+[12334,target,target,1],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 4 then frame == X.Frame(Running(15865,prefix+[12334,target,target,1,1],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 5 then frame == X.Frame(Running(15867,prefix+[12334,target,target,1,1,160],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 6 then frame == X.Frame(Running(15868,prefix+[12334,target,target,1,1461501637330902918203684832716283019655932542976],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 7 then frame == X.Frame(Running(15869,prefix+[12334,target,target,1461501637330902918203684832716283019655932542975],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 8 then frame == X.Frame(Running(15870,prefix+[12334,target,target],A.Heap(n)),returned,cursor+0)
                                                                                                                                                                                                          else if id == 9 then frame == X.Frame(Running(15871,prefix+[12334,target,0],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 10 then frame == X.Frame(Running(15872,prefix+[12334,target,0,0],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 11 then frame == X.Frame(Running(15873,prefix+[12334,target,0],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 12 then frame == X.Frame(Running(15876,prefix+[12334,target,0,15912],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 13 then frame == X.Frame(Running(15877,prefix+[12334,target],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 14 then frame == X.Frame(Running(15879,prefix+[12334,target,64],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 15 then frame == X.Frame(Running(15880,prefix+[12334,target,O.Extent(n)],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 16 then frame == X.Frame(Running(15885,prefix+[12334,target,O.Extent(n),710513733],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 17 then frame == X.Frame(Running(15887,prefix+[12334,target,O.Extent(n),710513733,225],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 18 then frame == X.Frame(Running(15888,prefix+[12334,target,O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 19 then frame == X.Frame(Running(15889,prefix+[12334,target,O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656,O.Extent(n)],A.Heap(n)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 20 then frame == X.Frame(Running(15890,prefix+[12334,target,O.Extent(n)],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 21 then frame == X.Frame(Running(15892,prefix+[12334,target,O.Extent(n),1],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 22 then frame == X.Frame(Running(15894,prefix+[12334,target,O.Extent(n),1,1],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 23 then frame == X.Frame(Running(15896,prefix+[12334,target,O.Extent(n),1,1,160],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 24 then frame == X.Frame(Running(15897,prefix+[12334,target,O.Extent(n),1,1461501637330902918203684832716283019655932542976],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 25 then frame == X.Frame(Running(15898,prefix+[12334,target,O.Extent(n),1461501637330902918203684832716283019655932542975],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 26 then frame == X.Frame(Running(15899,prefix+[12334,target,O.Extent(n),1461501637330902918203684832716283019655932542975,target],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 27 then frame == X.Frame(Running(15900,prefix+[12334,target,O.Extent(n),target],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 28 then frame == X.Frame(Running(15902,prefix+[12334,target,O.Extent(n),target,4],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 29 then frame == X.Frame(Running(15903,prefix+[12334,target,O.Extent(n),target,4,O.Extent(n)],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 30 then frame == X.Frame(Running(15904,prefix+[12334,target,O.Extent(n),target,O.Extent(n)+4],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 31 then frame == X.Frame(Running(15905,prefix+[12334,target,O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 32 then frame == X.Frame(Running(15907,prefix+[12334,target,O.Extent(n),36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 33 then frame == X.Frame(Running(15908,prefix+[12334,target,O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 34 then frame == X.Frame(Running(15911,prefix+[12334,target,O.Extent(n)+36,1114],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 35 then frame == X.Frame(Running(1114,prefix+[12334,target,O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 36 then frame == X.Frame(Running(1115,prefix+[12334,target,O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 37 then frame == X.Frame(Running(1117,prefix+[12334,target,O.Extent(n)+36,64],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 38 then frame == X.Frame(Running(1118,prefix+[12334,target,O.Extent(n)+36,O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 39 then frame == X.Frame(Running(1119,prefix+[12334,target,O.Extent(n)+36,O.Extent(n),O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 40 then frame == X.Frame(Running(1120,prefix+[12334,target,O.Extent(n),O.Extent(n),O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 41 then frame == X.Frame(Running(1121,prefix+[12334,target,O.Extent(n),36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else if id == 42 then frame == X.Frame(Running(1122,prefix+[12334,target,36,O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1)
                                                                                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(0,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(1,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15859,prefix+[12334,target],A.Heap(n)),returned,cursor+0);
    assert Fetch(code,15859) == Op(91,15860,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance1(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(1,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(2,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15860,prefix+[12334,target],A.Heap(n)),returned,cursor+0);
    assert Fetch(code,15860) == Op(128,15861,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance2(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(2,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(3,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15861,prefix+[12334,target,target],A.Heap(n)),returned,cursor+0);
    F.Push1(code,15861);
    assert Fetch(code,15861) == Op(96,15863,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance3(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(3,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(4,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15863,prefix+[12334,target,target,1],A.Heap(n)),returned,cursor+0);
    F.Push1(code,15863);
    assert Fetch(code,15863) == Op(96,15865,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance4(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(4,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(5,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15865,prefix+[12334,target,target,1,1],A.Heap(n)),returned,cursor+0);
    F.Push1(code,15865);
    assert Fetch(code,15865) == Op(96,15867,160);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance5(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(5,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(6,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15867,prefix+[12334,target,target,1,1,160],A.Heap(n)),returned,cursor+0);
    assert Fetch(code,15867) == Op(27,15868,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
    AM.Limit();

  }
  lemma Advance6(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(6,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(7,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15868,prefix+[12334,target,target,1,1461501637330902918203684832716283019655932542976],A.Heap(n)),returned,cursor+0);
    assert Fetch(code,15868) == Op(3,15869,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance7(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(7,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(8,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15869,prefix+[12334,target,target,1461501637330902918203684832716283019655932542975],A.Heap(n)),returned,cursor+0);
    assert Fetch(code,15869) == Op(22,15870,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    Q.FourPair(prefix,12334,target,target,0xffffffffffffffffffffffffffffffffffffffff);
    Q.ThreeOne(prefix,12334,target,target);
    assert frame.state == Running(15869,(prefix+[12334,target])+[target,0xffffffffffffffffffffffffffffffffffffffff],A.Heap(n));
    SC.Mask(code,15869,Destinations(),prefix+[12334,target],A.Heap(n),target,false,value,data);

  }
  lemma Advance8(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(8,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(9,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15870,prefix+[12334,target,target],A.Heap(n)),returned,cursor+0);
    assert Fetch(code,15870) == Op(59,15871,0);
    Q.ThreeOne(prefix,12334,target,target);
    Q.ThreeOne(prefix,12334,target,0);
    assert frame == X.Frame(Running(15870,(prefix+[12334,target])+[target],A.Heap(n)),returned,cursor);
    assert X.Address(target) == target;
    X.CodeSizeStep(code,15870,prefix+[12334,target],A.Heap(n),self,target,0,returned,cursor,observations,value,data);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);

  }
  lemma Advance9(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(9,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(10,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15871,prefix+[12334,target,0],A.Heap(n)),returned,cursor+1);
    assert Fetch(code,15871) == Op(95,15872,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance10(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(10,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(11,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15872,prefix+[12334,target,0,0],A.Heap(n)),returned,cursor+1);
    assert Fetch(code,15872) == Op(3,15873,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance11(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(11,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(12,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15873,prefix+[12334,target,0],A.Heap(n)),returned,cursor+1);
    F.Push2(code,15873);
    assert Fetch(code,15873) == Op(97,15876,15912);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance12(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(12,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(13,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15876,prefix+[12334,target,0,15912],A.Heap(n)),returned,cursor+1);
    assert Fetch(code,15876) == Op(87,15877,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance13(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(13,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(14,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15877,prefix+[12334,target],A.Heap(n)),returned,cursor+1);
    F.Push1(code,15877);
    assert Fetch(code,15877) == Op(96,15879,64);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance14(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(14,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(15,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15879,prefix+[12334,target,64],A.Heap(n)),returned,cursor+1);
    assert Fetch(code,15879) == Op(81,15880,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance15(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(15,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(16,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15880,prefix+[12334,target,O.Extent(n)],A.Heap(n)),returned,cursor+1);
    P.Push4(code,15880);
    assert Fetch(code,15880) == Op(99,15885,710513733);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance16(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(16,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(17,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15885,prefix+[12334,target,O.Extent(n),710513733],A.Heap(n)),returned,cursor+1);
    F.Push1(code,15885);
    assert Fetch(code,15885) == Op(96,15887,225);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance17(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(17,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(18,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15887,prefix+[12334,target,O.Extent(n),710513733,225],A.Heap(n)),returned,cursor+1);
    assert Fetch(code,15887) == Op(27,15888,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
    SC.Selector();

  }
  lemma Advance18(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(18,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(19,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15888,prefix+[12334,target,O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656],A.Heap(n)),returned,cursor+1);
    assert Fetch(code,15888) == Op(129,15889,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance19(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(19,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(20,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15889,prefix+[12334,target,O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656,O.Extent(n)],A.Heap(n)),returned,cursor+1);
    assert Fetch(code,15889) == Op(82,15890,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance20(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(20,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(21,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15890,prefix+[12334,target,O.Extent(n)],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    F.Push1(code,15890);
    assert Fetch(code,15890) == Op(96,15892,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance21(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(21,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(22,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15892,prefix+[12334,target,O.Extent(n),1],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    F.Push1(code,15892);
    assert Fetch(code,15892) == Op(96,15894,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance22(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(22,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(23,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15894,prefix+[12334,target,O.Extent(n),1,1],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    F.Push1(code,15894);
    assert Fetch(code,15894) == Op(96,15896,160);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance23(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(23,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(24,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15896,prefix+[12334,target,O.Extent(n),1,1,160],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    assert Fetch(code,15896) == Op(27,15897,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
    AM.Limit();

  }
  lemma Advance24(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(24,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(25,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15897,prefix+[12334,target,O.Extent(n),1,1461501637330902918203684832716283019655932542976],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    assert Fetch(code,15897) == Op(3,15898,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance25(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(25,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(26,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15898,prefix+[12334,target,O.Extent(n),1461501637330902918203684832716283019655932542975],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    assert Fetch(code,15898) == Op(130,15899,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance26(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(26,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(27,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15899,prefix+[12334,target,O.Extent(n),1461501637330902918203684832716283019655932542975,target],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    assert Fetch(code,15899) == Op(22,15900,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    Q.FivePair(prefix,12334,target,O.Extent(n),0xffffffffffffffffffffffffffffffffffffffff,target);
    Q.FourOne(prefix,12334,target,O.Extent(n),target);
    assert frame.state == Running(15899,(prefix+[12334,target,O.Extent(n)])+[0xffffffffffffffffffffffffffffffffffffffff,target],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656));
    SC.Mask(code,15899,Destinations(),prefix+[12334,target,O.Extent(n)],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),target,true,value,data);

  }
  lemma Advance27(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(27,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(28,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15900,prefix+[12334,target,O.Extent(n),target],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    F.Push1(code,15900);
    assert Fetch(code,15900) == Op(96,15902,4);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance28(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(28,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(29,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15902,prefix+[12334,target,O.Extent(n),target,4],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    assert Fetch(code,15902) == Op(130,15903,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance29(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(29,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(30,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15903,prefix+[12334,target,O.Extent(n),target,4,O.Extent(n)],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    assert Fetch(code,15903) == Op(1,15904,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance30(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(30,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(31,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15904,prefix+[12334,target,O.Extent(n),target,O.Extent(n)+4],Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656)),returned,cursor+1);
    assert Fetch(code,15904) == Op(82,15905,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance31(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(31,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(32,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15905,prefix+[12334,target,O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    F.Push1(code,15905);
    assert Fetch(code,15905) == Op(96,15907,36);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance32(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(32,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(33,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15907,prefix+[12334,target,O.Extent(n),36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,15907) == Op(1,15908,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance33(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(33,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(34,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15908,prefix+[12334,target,O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    F.Push2(code,15908);
    assert Fetch(code,15908) == Op(97,15911,1114);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance34(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(34,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(35,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(15911,prefix+[12334,target,O.Extent(n)+36,1114],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,15911) == Op(86,15912,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance35(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(35,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(36,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1114,prefix+[12334,target,O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,1114) == Op(91,1115,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance36(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(36,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(37,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1115,prefix+[12334,target,O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    F.Push1(code,1115);
    assert Fetch(code,1115) == Op(96,1117,64);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance37(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(37,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(38,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1117,prefix+[12334,target,O.Extent(n)+36,64],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,1117) == Op(81,1118,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance38(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(38,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(39,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1118,prefix+[12334,target,O.Extent(n)+36,O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,1118) == Op(128,1119,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance39(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(39,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(40,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1119,prefix+[12334,target,O.Extent(n)+36,O.Extent(n),O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,1119) == Op(145,1120,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance40(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(40,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(41,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1120,prefix+[12334,target,O.Extent(n),O.Extent(n),O.Extent(n)+36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,1120) == Op(3,1121,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance41(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(41,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(42,next,target,n,prefix,returned,cursor,observations,self,value,data)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1121,prefix+[12334,target,O.Extent(n),36],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,1121) == Op(144,1122,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  lemma Advance42(code: seq<Byte>,frame: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(42,frame,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); next == X.Frame(Reverted(G.Encode(0x54b3288a,4)+G.Encode(target,32)),returned,cursor+1)
  { hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(n,target);
    assert frame == X.Frame(Running(1122,prefix+[12334,target,36,O.Extent(n)],Store(Store(A.Heap(n),O.Extent(n),38310824695916219107694428762891275268414464342238862995011996155895040966656),O.Extent(n)+4,target)),returned,cursor+1);
    assert Fetch(code,1122) == Op(253,1123,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();

  }
  ghost method Block0(code: seq<Byte>,initial: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(0,initial,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures Good(20,frame,target,n,prefix,returned,cursor,observations,self,value,data) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { frame := initial;trace := [frame];
    Advance0(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next0 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next0);trace := trace+[next0];frame := next0;
    Advance1(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next1 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next1);trace := trace+[next1];frame := next1;
    Advance2(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next2 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next2);trace := trace+[next2];frame := next2;
    Advance3(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next3 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next3);trace := trace+[next3];frame := next3;
    Advance4(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next4 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next4);trace := trace+[next4];frame := next4;
    Advance5(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next5 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next5);trace := trace+[next5];frame := next5;
    Advance6(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next6 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next6);trace := trace+[next6];frame := next6;
    Advance7(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next7 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next7);trace := trace+[next7];frame := next7;
    Advance8(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next8 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next8);trace := trace+[next8];frame := next8;
    Advance9(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next9 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next9);trace := trace+[next9];frame := next9;
    Advance10(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next10 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next10);trace := trace+[next10];frame := next10;
    Advance11(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next11 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next11);trace := trace+[next11];frame := next11;
    Advance12(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next12 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next12);trace := trace+[next12];frame := next12;
    Advance13(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next13 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next13);trace := trace+[next13];frame := next13;
    Advance14(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next14 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next14);trace := trace+[next14];frame := next14;
    Advance15(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next15 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next15);trace := trace+[next15];frame := next15;
    Advance16(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next16 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next16);trace := trace+[next16];frame := next16;
    Advance17(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next17 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next17);trace := trace+[next17];frame := next17;
    Advance18(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next18 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next18);trace := trace+[next18];frame := next18;
    Advance19(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next19 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next19);trace := trace+[next19];frame := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(20,initial,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures Good(40,frame,target,n,prefix,returned,cursor,observations,self,value,data) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == frame
  { frame := initial;trace := [frame];
    Advance20(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next20 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next20);trace := trace+[next20];frame := next20;
    Advance21(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next21 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next21);trace := trace+[next21];frame := next21;
    Advance22(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next22 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next22);trace := trace+[next22];frame := next22;
    Advance23(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next23 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next23);trace := trace+[next23];frame := next23;
    Advance24(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next24 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next24);trace := trace+[next24];frame := next24;
    Advance25(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next25 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next25);trace := trace+[next25];frame := next25;
    Advance26(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next26 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next26);trace := trace+[next26];frame := next26;
    Advance27(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next27 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next27);trace := trace+[next27];frame := next27;
    Advance28(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next28 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next28);trace := trace+[next28];frame := next28;
    Advance29(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next29 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next29);trace := trace+[next29];frame := next29;
    Advance30(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next30 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next30);trace := trace+[next30];frame := next30;
    Advance31(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next31 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next31);trace := trace+[next31];frame := next31;
    Advance32(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next32 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next32);trace := trace+[next32];frame := next32;
    Advance33(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next33 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next33);trace := trace+[next33];frame := next33;
    Advance34(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next34 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next34);trace := trace+[next34];frame := next34;
    Advance35(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next35 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next35);trace := trace+[next35];frame := next35;
    Advance36(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next36 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next36);trace := trace+[next36];frame := next36;
    Advance37(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next37 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next37);trace := trace+[next37];frame := next37;
    Advance38(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next38 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next38);trace := trace+[next38];frame := next38;
    Advance39(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next39 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next39);trace := trace+[next39];frame := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: X.Frame,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data) && Good(40,initial,target,n,prefix,returned,cursor,observations,self,value,data)
    ensures frame == X.Frame(Reverted(G.Encode(0x54b3288a,4)+G.Encode(target,32)),returned,cursor+1) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 4 && trace[0] == initial && trace[|trace|-1] == frame
  { frame := initial;trace := [frame];
    Advance40(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next40 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next40);trace := trace+[next40];frame := next40;
    Advance41(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next41 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next41);trace := trace+[next41];frame := next41;
    Advance42(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    var next42 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next42);trace := trace+[next42];frame := next42;
  }
  ghost method Run(code: seq<Byte>,target: Word, n: nat, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(target,n,prefix,returned,cursor,observations,self,value,data)
    ensures frame == X.Frame(Reverted(G.Encode(0x54b3288a,4)+G.Encode(target,32)),returned,cursor+1) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 44 && trace[0] == X.Frame(Running(15859,prefix+[12334,target],A.Heap(n)),returned,cursor+0) && trace[|trace|-1] == frame
  { frame := X.Frame(Running(15859,prefix+[12334,target],A.Heap(n)),returned,cursor+0);trace := [frame];reveal Good();var part: seq<X.Frame>;
    frame,part := Block0(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    frame,part := Block1(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    frame,part := Block2(code,frame,target,n,prefix,returned,cursor,observations,self,value,data);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
  }
}
