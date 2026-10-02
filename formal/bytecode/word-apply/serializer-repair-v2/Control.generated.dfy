// SPDX-License-Identifier: MIT
// Generated actual shared dynamic bytes serializer instructions.
include "Memory.dfy"
include "../../iota-return/MaskOpcode.dfy"
include "SubOpcode.dfy"
include "../../scans/Fetch.dfy"
module BytecodeApplyBytesReturnControl {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import M = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import R = BytecodeApplyBytesReturnMemory
  import RM = BytecodeIotaReturnMaskOpcode
  import RS = BytecodeApplyReturnSubOpcode
  import SC = BytecodeIotaAllocationScalar
  predicate Admitted(mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>) { R.Fits(mem,free,n,payload) }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[490] == 91 &&
                                              code[491] == 96 &&
                                              code[492] == 64 &&
                                              code[493] == 81 &&
                                              code[494] == 128 &&
                                              code[495] == 145 &&
                                              code[496] == 3 &&
                                              code[497] == 144 &&
                                              code[498] == 243 &&
                                              code[518] == 91 &&
                                              code[519] == 96 &&
                                              code[520] == 64 &&
                                              code[521] == 81 &&
                                              code[522] == 97 &&
                                              code[523] == 1 &&
                                              code[524] == 234 &&
                                              code[525] == 145 &&
                                              code[526] == 144 &&
                                              code[527] == 97 &&
                                              code[528] == 82 &&
                                              code[529] == 219 &&
                                              code[530] == 86 &&
                                              code[8389] == 91 &&
                                              code[8390] == 147 &&
                                              code[8391] == 146 &&
                                              code[8392] == 80 &&
                                              code[8393] == 80 &&
                                              code[8394] == 80 &&
                                              code[8395] == 86 &&
                                              code[20951] == 91 &&
                                              code[20952] == 95 &&
                                              code[20953] == 129 &&
                                              code[20954] == 81 &&
                                              code[20955] == 128 &&
                                              code[20956] == 132 &&
                                              code[20957] == 82 &&
                                              code[20958] == 128 &&
                                              code[20959] == 96 &&
                                              code[20960] == 32 &&
                                              code[20961] == 132 &&
                                              code[20962] == 1 &&
                                              code[20963] == 96 &&
                                              code[20964] == 32 &&
                                              code[20965] == 134 &&
                                              code[20966] == 1 &&
                                              code[20967] == 94 &&
                                              code[20968] == 95 &&
                                              code[20969] == 96 &&
                                              code[20970] == 32 &&
                                              code[20971] == 130 &&
                                              code[20972] == 134 &&
                                              code[20973] == 1 &&
                                              code[20974] == 1 &&
                                              code[20975] == 82 &&
                                              code[20976] == 96 &&
                                              code[20977] == 32 &&
                                              code[20978] == 96 &&
                                              code[20979] == 31 &&
                                              code[20980] == 25 &&
                                              code[20981] == 96 &&
                                              code[20982] == 31 &&
                                              code[20983] == 131 &&
                                              code[20984] == 1 &&
                                              code[20985] == 22 &&
                                              code[20986] == 133 &&
                                              code[20987] == 1 &&
                                              code[20988] == 1 &&
                                              code[20989] == 145 &&
                                              code[20990] == 80 &&
                                              code[20991] == 80 &&
                                              code[20992] == 146 &&
                                              code[20993] == 145 &&
                                              code[20994] == 80 &&
                                              code[20995] == 80 &&
                                              code[20996] == 86 &&
                                              code[21211] == 91 &&
                                              code[21212] == 96 &&
                                              code[21213] == 32 &&
                                              code[21214] == 129 &&
                                              code[21215] == 82 &&
                                              code[21216] == 95 &&
                                              code[21217] == 97 &&
                                              code[21218] == 32 &&
                                              code[21219] == 197 &&
                                              code[21220] == 96 &&
                                              code[21221] == 32 &&
                                              code[21222] == 131 &&
                                              code[21223] == 1 &&
                                              code[21224] == 132 &&
                                              code[21225] == 97 &&
                                              code[21226] == 81 &&
                                              code[21227] == 215 &&
                                              code[21228] == 86
  }
  function Destinations(): set<nat> { {490,8389,20951,21211} }
  opaque predicate Good(id: nat, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word) { Admitted(mem,free,n,payload) && (
                                                                                                                            if id == 0 then state == Running(518,[selector,128],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 1 then state == Running(519,[selector,128],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 2 then state == Running(521,[selector,128,64],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 3 then state == Running(522,[selector,128,free],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 4 then state == Running(525,[selector,128,free,490],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 5 then state == Running(526,[selector,490,free,128],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 6 then state == Running(527,[selector,490,128,free],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 7 then state == Running(530,[selector,490,128,free,21211],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 8 then state == Running(21211,[selector,490,128,free],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 9 then state == Running(21212,[selector,490,128,free],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 10 then state == Running(21214,[selector,490,128,free,32],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 11 then state == Running(21215,[selector,490,128,free,32,free],R.Stage(mem,free,n,payload,0))
                                                                                                                            else if id == 12 then state == Running(21216,[selector,490,128,free],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 13 then state == Running(21217,[selector,490,128,free,0],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 14 then state == Running(21220,[selector,490,128,free,0,8389],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 15 then state == Running(21222,[selector,490,128,free,0,8389,32],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 16 then state == Running(21223,[selector,490,128,free,0,8389,32,free],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 17 then state == Running(21224,[selector,490,128,free,0,8389,(free+32)],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 18 then state == Running(21225,[selector,490,128,free,0,8389,(free+32),128],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 19 then state == Running(21228,[selector,490,128,free,0,8389,(free+32),128,20951],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 20 then state == Running(20951,[selector,490,128,free,0,8389,(free+32),128],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 21 then state == Running(20952,[selector,490,128,free,0,8389,(free+32),128],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 22 then state == Running(20953,[selector,490,128,free,0,8389,(free+32),128,0],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 23 then state == Running(20954,[selector,490,128,free,0,8389,(free+32),128,0,128],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 24 then state == Running(20955,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 25 then state == Running(20956,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 26 then state == Running(20957,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,(free+32)],R.Stage(mem,free,n,payload,1))
                                                                                                                            else if id == 27 then state == Running(20958,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 28 then state == Running(20959,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 29 then state == Running(20961,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,32],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 30 then state == Running(20962,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,32,128],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 31 then state == Running(20963,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 32 then state == Running(20965,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160,32],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 33 then state == Running(20966,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160,32,(free+32)],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 34 then state == Running(20967,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160,((free+32)+32)],R.Stage(mem,free,n,payload,2))
                                                                                                                            else if id == 35 then state == Running(20968,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,3))
                                                                                                                            else if id == 36 then state == Running(20969,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0],R.Stage(mem,free,n,payload,3))
                                                                                                                            else if id == 37 then state == Running(20971,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32],R.Stage(mem,free,n,payload,3))
                                                                                                                            else if id == 38 then state == Running(20972,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32,n*32],R.Stage(mem,free,n,payload,3))
                                                                                                                            else if id == 39 then state == Running(20973,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32,n*32,(free+32)],R.Stage(mem,free,n,payload,3))
                                                                                                                            else if id == 40 then state == Running(20974,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32,((free+32)+n*32)],R.Stage(mem,free,n,payload,3))
                                                                                                                            else if id == 41 then state == Running(20975,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,3))
                                                                                                                            else if id == 42 then state == Running(20976,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 43 then state == Running(20978,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 44 then state == Running(20980,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,31],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 45 then state == Running(20981,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 46 then state == Running(20983,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 47 then state == Running(20984,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31,n*32],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 48 then state == Running(20985,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,n*32+31],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 49 then state == Running(20986,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,n*32],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 50 then state == Running(20987,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,n*32,(free+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 51 then state == Running(20988,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,((free+32)+n*32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 52 then state == Running(20989,[selector,490,128,free,0,8389,(free+32),128,0,n*32,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 53 then state == Running(20990,[selector,490,128,free,0,8389,(free+32),128,(((free+32)+n*32)+32),n*32,0],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 54 then state == Running(20991,[selector,490,128,free,0,8389,(free+32),128,(((free+32)+n*32)+32),n*32],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 55 then state == Running(20992,[selector,490,128,free,0,8389,(free+32),128,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 56 then state == Running(20993,[selector,490,128,free,0,(((free+32)+n*32)+32),(free+32),128,8389],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 57 then state == Running(20994,[selector,490,128,free,0,(((free+32)+n*32)+32),8389,128,(free+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 58 then state == Running(20995,[selector,490,128,free,0,(((free+32)+n*32)+32),8389,128],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 59 then state == Running(20996,[selector,490,128,free,0,(((free+32)+n*32)+32),8389],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 60 then state == Running(8389,[selector,490,128,free,0,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 61 then state == Running(8390,[selector,490,128,free,0,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 62 then state == Running(8391,[selector,(((free+32)+n*32)+32),128,free,0,490],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 63 then state == Running(8392,[selector,(((free+32)+n*32)+32),490,free,0,128],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 64 then state == Running(8393,[selector,(((free+32)+n*32)+32),490,free,0],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 65 then state == Running(8394,[selector,(((free+32)+n*32)+32),490,free],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 66 then state == Running(8395,[selector,(((free+32)+n*32)+32),490],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 67 then state == Running(490,[selector,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 68 then state == Running(491,[selector,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 69 then state == Running(493,[selector,(((free+32)+n*32)+32),64],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 70 then state == Running(494,[selector,(((free+32)+n*32)+32),free],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 71 then state == Running(495,[selector,(((free+32)+n*32)+32),free,free],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 72 then state == Running(496,[selector,free,free,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 73 then state == Running(497,[selector,free,((((free+32)+n*32)+32)-free)],R.Stage(mem,free,n,payload,4))
                                                                                                                            else if id == 74 then state == Running(498,[selector,((((free+32)+n*32)+32)-free),free],R.Stage(mem,free,n,payload,4))
                                                                                                                            else false) }
  lemma Advance0(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(0,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(1,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(518,[selector,128],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,518) == Op(91,519,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance1(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(1,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(2,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(519,[selector,128],R.Stage(mem,free,n,payload,0));
    F.Push1(code,519);
    assert Fetch(code,519) == Op(96,521,64);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance2(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(2,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(3,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(521,[selector,128,64],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,521) == Op(81,522,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance3(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(3,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(4,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(522,[selector,128,free],R.Stage(mem,free,n,payload,0));
    F.Push2(code,522);
    assert Fetch(code,522) == Op(97,525,490);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance4(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(4,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(5,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(525,[selector,128,free,490],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,525) == Op(145,526,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance5(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(5,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(6,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(526,[selector,490,free,128],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,526) == Op(144,527,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance6(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(6,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(7,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(527,[selector,490,128,free],R.Stage(mem,free,n,payload,0));
    F.Push2(code,527);
    assert Fetch(code,527) == Op(97,530,21211);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance7(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(7,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(8,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(530,[selector,490,128,free,21211],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,530) == Op(86,531,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance8(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(8,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(9,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(21211,[selector,490,128,free],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,21211) == Op(91,21212,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance9(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(9,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(10,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(21212,[selector,490,128,free],R.Stage(mem,free,n,payload,0));
    F.Push1(code,21212);
    assert Fetch(code,21212) == Op(96,21214,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance10(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(10,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(11,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(21214,[selector,490,128,free,32],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,21214) == Op(129,21215,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance11(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(11,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(12,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,0); R.Headers(mem,free,n,payload,0);
    assert state == Running(21215,[selector,490,128,free,32,free],R.Stage(mem,free,n,payload,0));
    assert Fetch(code,21215) == Op(82,21216,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
    R.FirstStore(mem,free,n,payload);
  }
  lemma Advance12(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(12,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(13,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21216,[selector,490,128,free],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,21216) == Op(95,21217,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance13(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(13,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(14,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21217,[selector,490,128,free,0],R.Stage(mem,free,n,payload,1));
    F.Push2(code,21217);
    assert Fetch(code,21217) == Op(97,21220,8389);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance14(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(14,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(15,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21220,[selector,490,128,free,0,8389],R.Stage(mem,free,n,payload,1));
    F.Push1(code,21220);
    assert Fetch(code,21220) == Op(96,21222,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance15(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(15,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(16,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21222,[selector,490,128,free,0,8389,32],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,21222) == Op(131,21223,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance16(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(16,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(17,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21223,[selector,490,128,free,0,8389,32,free],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,21223) == Op(1,21224,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance17(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(17,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(18,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21224,[selector,490,128,free,0,8389,(free+32)],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,21224) == Op(132,21225,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance18(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(18,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(19,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21225,[selector,490,128,free,0,8389,(free+32),128],R.Stage(mem,free,n,payload,1));
    F.Push2(code,21225);
    assert Fetch(code,21225) == Op(97,21228,20951);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance19(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(19,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(20,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(21228,[selector,490,128,free,0,8389,(free+32),128,20951],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,21228) == Op(86,21229,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance20(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(20,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(21,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(20951,[selector,490,128,free,0,8389,(free+32),128],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,20951) == Op(91,20952,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance21(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(21,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(22,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(20952,[selector,490,128,free,0,8389,(free+32),128],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,20952) == Op(95,20953,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance22(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(22,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(23,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(20953,[selector,490,128,free,0,8389,(free+32),128,0],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,20953) == Op(129,20954,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance23(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(23,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(24,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(20954,[selector,490,128,free,0,8389,(free+32),128,0,128],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,20954) == Op(81,20955,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance24(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(24,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(25,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(20955,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,20955) == Op(128,20956,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance25(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(25,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(26,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(20956,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,20956) == Op(132,20957,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance26(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(26,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(27,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,1); R.Headers(mem,free,n,payload,1);
    assert state == Running(20957,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,(free+32)],R.Stage(mem,free,n,payload,1));
    assert Fetch(code,20957) == Op(82,20958,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
    R.SecondStore(mem,free,n,payload);
  }
  lemma Advance27(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(27,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(28,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20958,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,2));
    assert Fetch(code,20958) == Op(128,20959,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance28(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(28,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(29,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20959,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32],R.Stage(mem,free,n,payload,2));
    F.Push1(code,20959);
    assert Fetch(code,20959) == Op(96,20961,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance29(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(29,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(30,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20961,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,32],R.Stage(mem,free,n,payload,2));
    assert Fetch(code,20961) == Op(132,20962,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance30(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(30,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(31,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20962,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,32,128],R.Stage(mem,free,n,payload,2));
    assert Fetch(code,20962) == Op(1,20963,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance31(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(31,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(32,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20963,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160],R.Stage(mem,free,n,payload,2));
    F.Push1(code,20963);
    assert Fetch(code,20963) == Op(96,20965,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance32(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(32,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(33,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20965,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160,32],R.Stage(mem,free,n,payload,2));
    assert Fetch(code,20965) == Op(134,20966,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance33(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(33,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(34,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20966,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160,32,(free+32)],R.Stage(mem,free,n,payload,2));
    assert Fetch(code,20966) == Op(1,20967,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance34(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(34,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(35,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,2); R.Headers(mem,free,n,payload,2);
    assert state == Running(20967,[selector,490,128,free,0,8389,(free+32),128,0,n*32,n*32,160,((free+32)+32)],R.Stage(mem,free,n,payload,2));
    assert Fetch(code,20967) == Op(94,20968,0);
    assert state == Running(20967,[selector,490,128,free,0,8389,(free+32),128,0,n*32]+[n*32,160,free+64],R.Stage(mem,free,n,payload,2));
    R.ActualCopy(code,mem,free,n,payload,[selector,490,128,free,0,8389,(free+32),128,0,n*32],value,data);
    assert M.Step(code,{},state,value,data) == Running(20968,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,3));
    E.WidenStep(code,{},Destinations(),state,value,data);
  }
  lemma Advance35(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(35,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(36,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,3); R.Headers(mem,free,n,payload,3);
    assert state == Running(20968,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,3));
    assert Fetch(code,20968) == Op(95,20969,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance36(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(36,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(37,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,3); R.Headers(mem,free,n,payload,3);
    assert state == Running(20969,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0],R.Stage(mem,free,n,payload,3));
    F.Push1(code,20969);
    assert Fetch(code,20969) == Op(96,20971,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance37(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(37,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(38,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,3); R.Headers(mem,free,n,payload,3);
    assert state == Running(20971,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32],R.Stage(mem,free,n,payload,3));
    assert Fetch(code,20971) == Op(130,20972,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance38(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(38,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(39,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,3); R.Headers(mem,free,n,payload,3);
    assert state == Running(20972,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32,n*32],R.Stage(mem,free,n,payload,3));
    assert Fetch(code,20972) == Op(134,20973,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance39(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(39,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(40,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,3); R.Headers(mem,free,n,payload,3);
    assert state == Running(20973,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32,n*32,(free+32)],R.Stage(mem,free,n,payload,3));
    assert Fetch(code,20973) == Op(1,20974,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance40(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(40,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(41,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,3); R.Headers(mem,free,n,payload,3);
    assert state == Running(20974,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,32,((free+32)+n*32)],R.Stage(mem,free,n,payload,3));
    assert Fetch(code,20974) == Op(1,20975,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance41(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(41,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(42,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,3); R.Headers(mem,free,n,payload,3);
    assert state == Running(20975,[selector,490,128,free,0,8389,(free+32),128,0,n*32,0,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,3));
    assert Fetch(code,20975) == Op(82,20976,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
    R.FinalStore(mem,free,n,payload);
  }
  lemma Advance42(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(42,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(43,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20976,[selector,490,128,free,0,8389,(free+32),128,0,n*32],R.Stage(mem,free,n,payload,4));
    F.Push1(code,20976);
    assert Fetch(code,20976) == Op(96,20978,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance43(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(43,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(44,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20978,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32],R.Stage(mem,free,n,payload,4));
    F.Push1(code,20978);
    assert Fetch(code,20978) == Op(96,20980,31);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance44(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(44,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(45,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20980,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,31],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20980) == Op(25,20981,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
    SC.Not31();
  }
  lemma Advance45(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(45,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(46,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20981,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904],R.Stage(mem,free,n,payload,4));
    F.Push1(code,20981);
    assert Fetch(code,20981) == Op(96,20983,31);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance46(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(46,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(47,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20983,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20983) == Op(131,20984,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance47(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(47,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(48,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20984,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,31,n*32],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20984) == Op(1,20985,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance48(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(48,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(49,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20985,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,115792089237316195423570985008687907853269984665640564039457584007913129639904,n*32+31],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20985) == Op(22,20986,0);
    assert state == Running(20985,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32]+[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,n*32+31],R.Stage(mem,free,n,payload,4));
    RM.Step(code,Destinations(),[selector,490,128,free,0,8389,(free+32),128,0,n*32,32],R.Stage(mem,free,n,payload,4),n,value,data);
    assert S.Step(code,Destinations(),state,value,data) == Running(20986,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32]+[n*32],R.Stage(mem,free,n,payload,4));
    M.Delegate(code,Destinations(),state,value,data);
  }
  lemma Advance49(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(49,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(50,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20986,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,n*32],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20986) == Op(133,20987,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance50(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(50,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(51,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20987,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,n*32,(free+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20987) == Op(1,20988,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance51(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(51,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(52,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20988,[selector,490,128,free,0,8389,(free+32),128,0,n*32,32,((free+32)+n*32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20988) == Op(1,20989,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance52(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(52,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(53,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20989,[selector,490,128,free,0,8389,(free+32),128,0,n*32,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20989) == Op(145,20990,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance53(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(53,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(54,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20990,[selector,490,128,free,0,8389,(free+32),128,(((free+32)+n*32)+32),n*32,0],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20990) == Op(80,20991,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance54(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(54,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(55,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20991,[selector,490,128,free,0,8389,(free+32),128,(((free+32)+n*32)+32),n*32],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20991) == Op(80,20992,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance55(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(55,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(56,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20992,[selector,490,128,free,0,8389,(free+32),128,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20992) == Op(146,20993,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance56(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(56,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(57,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20993,[selector,490,128,free,0,(((free+32)+n*32)+32),(free+32),128,8389],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20993) == Op(145,20994,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance57(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(57,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(58,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20994,[selector,490,128,free,0,(((free+32)+n*32)+32),8389,128,(free+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20994) == Op(80,20995,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance58(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(58,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(59,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20995,[selector,490,128,free,0,(((free+32)+n*32)+32),8389,128],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20995) == Op(80,20996,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance59(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(59,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(60,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(20996,[selector,490,128,free,0,(((free+32)+n*32)+32),8389],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,20996) == Op(86,20997,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance60(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(60,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(61,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(8389,[selector,490,128,free,0,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,8389) == Op(91,8390,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance61(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(61,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(62,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(8390,[selector,490,128,free,0,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,8390) == Op(147,8391,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance62(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(62,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(63,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(8391,[selector,(((free+32)+n*32)+32),128,free,0,490],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,8391) == Op(146,8392,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance63(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(63,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(64,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(8392,[selector,(((free+32)+n*32)+32),490,free,0,128],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,8392) == Op(80,8393,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance64(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(64,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(65,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(8393,[selector,(((free+32)+n*32)+32),490,free,0],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,8393) == Op(80,8394,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance65(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(65,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(66,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(8394,[selector,(((free+32)+n*32)+32),490,free],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,8394) == Op(80,8395,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance66(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(66,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(67,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(8395,[selector,(((free+32)+n*32)+32),490],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,8395) == Op(86,8396,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance67(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(67,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(68,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(490,[selector,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,490) == Op(91,491,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance68(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(68,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(69,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(491,[selector,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4));
    F.Push1(code,491);
    assert Fetch(code,491) == Op(96,493,64);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance69(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(69,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(70,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(493,[selector,(((free+32)+n*32)+32),64],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,493) == Op(81,494,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance70(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(70,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(71,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(494,[selector,(((free+32)+n*32)+32),free],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,494) == Op(128,495,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance71(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(71,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(72,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(495,[selector,(((free+32)+n*32)+32),free,free],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,495) == Op(145,496,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance72(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(72,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(73,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(496,[selector,free,free,(((free+32)+n*32)+32)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,496) == Op(3,497,0);
    assert state == Running(496,[selector,free]+[free,free+64+n*32],R.Stage(mem,free,n,payload,4));
    RS.Step(code,Destinations(),[selector,free],R.Stage(mem,free,n,payload,4),free,n,value,data);
    assert S.Step(code,Destinations(),state,value,data) == Running(497,[selector,free]+[64+n*32],R.Stage(mem,free,n,payload,4));
    M.Delegate(code,Destinations(),state,value,data);
  }
  lemma Advance73(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(73,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(74,next,mem,free,n,payload,selector)
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(497,[selector,free,((((free+32)+n*32)+32)-free)],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,497) == Op(144,498,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal S.Step();
  }
  lemma Advance74(code: seq<Byte>, state: State, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(mem,free,n,payload) && Good(74,state,mem,free,n,payload,selector)
    ensures state.Running? && |state.stack| <= 14 && |state.memory| < R.Bound()
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); next == Returned(R.Bytes(n,payload))
  {
    reveal Matches(); reveal Good();
    R.Sizes(mem,free,n,payload,4); R.Headers(mem,free,n,payload,4);
    assert state == Running(498,[selector,((((free+32)+n*32)+32)-free),free],R.Stage(mem,free,n,payload,4));
    assert Fetch(code,498) == Op(243,499,0);
    assert state == Running(498,[selector]+[64+n*32,free],R.Stage(mem,free,n,payload,4));
    R.Return(code,mem,free,n,payload,[selector],value,data);
    assert M.Step(code,{},state,value,data) == Returned(R.Bytes(n,payload));
    E.WidenStep(code,{},Destinations(),state,value,data);
  }
  lemma Start(mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word)
    requires Admitted(mem,free,n,payload)
    ensures Good(0,Running(518,[selector,128],mem),mem,free,n,payload,selector)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, mem: seq<Byte>, free: Word, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(mem,free,n,payload)
    ensures state == Returned(R.Bytes(n,payload))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 76 && trace[0] == Running(518,[selector,128],mem) && trace[|trace|-1] == state
  {
    Start(mem,free,n,payload,selector); state := Running(518,[selector,128],mem); trace := [state];
    Advance0(code,state,mem,free,n,payload,selector,value,data);
    var next0 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next0;
    Advance1(code,state,mem,free,n,payload,selector,value,data);
    var next1 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next1;
    Advance2(code,state,mem,free,n,payload,selector,value,data);
    var next2 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next2;
    Advance3(code,state,mem,free,n,payload,selector,value,data);
    var next3 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next3;
    Advance4(code,state,mem,free,n,payload,selector,value,data);
    var next4 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next4;
    Advance5(code,state,mem,free,n,payload,selector,value,data);
    var next5 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next5;
    Advance6(code,state,mem,free,n,payload,selector,value,data);
    var next6 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next6;
    Advance7(code,state,mem,free,n,payload,selector,value,data);
    var next7 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next7;
    Advance8(code,state,mem,free,n,payload,selector,value,data);
    var next8 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next8;
    Advance9(code,state,mem,free,n,payload,selector,value,data);
    var next9 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next9;
    Advance10(code,state,mem,free,n,payload,selector,value,data);
    var next10 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next10;
    Advance11(code,state,mem,free,n,payload,selector,value,data);
    var next11 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next11;
    Advance12(code,state,mem,free,n,payload,selector,value,data);
    var next12 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next12;
    Advance13(code,state,mem,free,n,payload,selector,value,data);
    var next13 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next13;
    Advance14(code,state,mem,free,n,payload,selector,value,data);
    var next14 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next14;
    Advance15(code,state,mem,free,n,payload,selector,value,data);
    var next15 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next15;
    Advance16(code,state,mem,free,n,payload,selector,value,data);
    var next16 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next16;
    Advance17(code,state,mem,free,n,payload,selector,value,data);
    var next17 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next17;
    Advance18(code,state,mem,free,n,payload,selector,value,data);
    var next18 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next18;
    Advance19(code,state,mem,free,n,payload,selector,value,data);
    var next19 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next19;
    Advance20(code,state,mem,free,n,payload,selector,value,data);
    var next20 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next20;
    Advance21(code,state,mem,free,n,payload,selector,value,data);
    var next21 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next21;
    Advance22(code,state,mem,free,n,payload,selector,value,data);
    var next22 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next22;
    Advance23(code,state,mem,free,n,payload,selector,value,data);
    var next23 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next23;
    Advance24(code,state,mem,free,n,payload,selector,value,data);
    var next24 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next24;
    Advance25(code,state,mem,free,n,payload,selector,value,data);
    var next25 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next25;
    Advance26(code,state,mem,free,n,payload,selector,value,data);
    var next26 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next26;
    Advance27(code,state,mem,free,n,payload,selector,value,data);
    var next27 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next27;
    Advance28(code,state,mem,free,n,payload,selector,value,data);
    var next28 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next28;
    Advance29(code,state,mem,free,n,payload,selector,value,data);
    var next29 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next29;
    Advance30(code,state,mem,free,n,payload,selector,value,data);
    var next30 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next30;
    Advance31(code,state,mem,free,n,payload,selector,value,data);
    var next31 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next31;
    Advance32(code,state,mem,free,n,payload,selector,value,data);
    var next32 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next32;
    Advance33(code,state,mem,free,n,payload,selector,value,data);
    var next33 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next33;
    Advance34(code,state,mem,free,n,payload,selector,value,data);
    var next34 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next34;
    Advance35(code,state,mem,free,n,payload,selector,value,data);
    var next35 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next35;
    Advance36(code,state,mem,free,n,payload,selector,value,data);
    var next36 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next36;
    Advance37(code,state,mem,free,n,payload,selector,value,data);
    var next37 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next37;
    Advance38(code,state,mem,free,n,payload,selector,value,data);
    var next38 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);
    trace := trace+[next38];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next38;
    Advance39(code,state,mem,free,n,payload,selector,value,data);
    var next39 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);
    trace := trace+[next39];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next39;
    Advance40(code,state,mem,free,n,payload,selector,value,data);
    var next40 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);
    trace := trace+[next40];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next40;
    Advance41(code,state,mem,free,n,payload,selector,value,data);
    var next41 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);
    trace := trace+[next41];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next41;
    Advance42(code,state,mem,free,n,payload,selector,value,data);
    var next42 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);
    trace := trace+[next42];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next42;
    Advance43(code,state,mem,free,n,payload,selector,value,data);
    var next43 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);
    trace := trace+[next43];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next43;
    Advance44(code,state,mem,free,n,payload,selector,value,data);
    var next44 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);
    trace := trace+[next44];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next44;
    Advance45(code,state,mem,free,n,payload,selector,value,data);
    var next45 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);
    trace := trace+[next45];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next45;
    Advance46(code,state,mem,free,n,payload,selector,value,data);
    var next46 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);
    trace := trace+[next46];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next46;
    Advance47(code,state,mem,free,n,payload,selector,value,data);
    var next47 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);
    trace := trace+[next47];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next47;
    Advance48(code,state,mem,free,n,payload,selector,value,data);
    var next48 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);
    trace := trace+[next48];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next48;
    Advance49(code,state,mem,free,n,payload,selector,value,data);
    var next49 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);
    trace := trace+[next49];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next49;
    Advance50(code,state,mem,free,n,payload,selector,value,data);
    var next50 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);
    trace := trace+[next50];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next50;
    Advance51(code,state,mem,free,n,payload,selector,value,data);
    var next51 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);
    trace := trace+[next51];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next51;
    Advance52(code,state,mem,free,n,payload,selector,value,data);
    var next52 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);
    trace := trace+[next52];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next52;
    Advance53(code,state,mem,free,n,payload,selector,value,data);
    var next53 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);
    trace := trace+[next53];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next53;
    Advance54(code,state,mem,free,n,payload,selector,value,data);
    var next54 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);
    trace := trace+[next54];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next54;
    Advance55(code,state,mem,free,n,payload,selector,value,data);
    var next55 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55);
    trace := trace+[next55];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next55;
    Advance56(code,state,mem,free,n,payload,selector,value,data);
    var next56 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56);
    trace := trace+[next56];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next56;
    Advance57(code,state,mem,free,n,payload,selector,value,data);
    var next57 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57);
    trace := trace+[next57];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next57;
    Advance58(code,state,mem,free,n,payload,selector,value,data);
    var next58 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58);
    trace := trace+[next58];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next58;
    Advance59(code,state,mem,free,n,payload,selector,value,data);
    var next59 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59);
    trace := trace+[next59];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next59;
    Advance60(code,state,mem,free,n,payload,selector,value,data);
    var next60 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next60);
    trace := trace+[next60];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next60;
    Advance61(code,state,mem,free,n,payload,selector,value,data);
    var next61 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next61);
    trace := trace+[next61];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next61;
    Advance62(code,state,mem,free,n,payload,selector,value,data);
    var next62 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next62);
    trace := trace+[next62];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next62;
    Advance63(code,state,mem,free,n,payload,selector,value,data);
    var next63 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next63);
    trace := trace+[next63];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next63;
    Advance64(code,state,mem,free,n,payload,selector,value,data);
    var next64 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next64);
    trace := trace+[next64];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next64;
    Advance65(code,state,mem,free,n,payload,selector,value,data);
    var next65 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next65);
    trace := trace+[next65];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next65;
    Advance66(code,state,mem,free,n,payload,selector,value,data);
    var next66 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next66);
    trace := trace+[next66];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next66;
    Advance67(code,state,mem,free,n,payload,selector,value,data);
    var next67 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next67);
    trace := trace+[next67];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next67;
    Advance68(code,state,mem,free,n,payload,selector,value,data);
    var next68 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next68);
    trace := trace+[next68];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next68;
    Advance69(code,state,mem,free,n,payload,selector,value,data);
    var next69 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next69);
    trace := trace+[next69];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next69;
    Advance70(code,state,mem,free,n,payload,selector,value,data);
    var next70 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next70);
    trace := trace+[next70];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next70;
    Advance71(code,state,mem,free,n,payload,selector,value,data);
    var next71 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next71);
    trace := trace+[next71];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next71;
    Advance72(code,state,mem,free,n,payload,selector,value,data);
    var next72 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next72);
    trace := trace+[next72];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next72;
    Advance73(code,state,mem,free,n,payload,selector,value,data);
    var next73 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next73);
    trace := trace+[next73];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next73;
    Advance74(code,state,mem,free,n,payload,selector,value,data);
    var next74 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next74);
    trace := trace+[next74];
    assert trace[0] == Running(518,[selector,128],mem);
    state := next74;
  }
}
