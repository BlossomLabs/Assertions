// SPDX-License-Identifier: MIT
// Exact arbitrary finite successful named-type parser through the suffix entry.
include "../type-name-invocation/Invocation.generated.dfy"
include "../name-scanner-v2/Loop.dfy"
include "../named-type/Cleanup.generated.dfy"
include "../named-type/SubtractCall.generated.dfy"
include "../named-type/Ordinary.generated.dfy"
include "../named-type/Five.generated.dfy"
include "../named-type/Six.generated.dfy"
include "../checked-subtract/Subtract.generated.dfy"
include "../parser-execution/Execution.dfy"
module BytecodeCollectionsNamedShapeConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import X = BytecodeCollectionsParserExecution
  import I = BytecodeCollectionsTypeNameInvocation
  import L = BytecodeCollectionsScanNameLoop
  import C = BytecodeCollectionsNamedTypeCleanup
  import S = BytecodeCollectionsNamedTypeSubtractCall
  import O = BytecodeCollectionsNamedTypeOrdinary
  import F = BytecodeCollectionsNamedTypeFive
  import T = BytecodeCollectionsNamedTypeSix
  import A = BytecodeCollectionsCheckedSubtract
  predicate Matches(code: seq<Byte>) {
    I.Matches(code) && L.Matches(code) && C.Matches(code) && S.Matches(code) &&
    O.Matches(code) && F.Matches(code) && T.Matches(code) && A.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    I.Destinations()+L.Destinations()+C.Destinations(14157)+S.Destinations(returnPc)+
    O.Destinations(returnPc)+F.Destinations(returnPc)+T.Destinations(returnPc)+A.Destinations(14205)
  }
  opaque function Dynamic(data: seq<Byte>,descriptorOffset: Word,p: Word,q: Word): Word
    requires descriptorOffset < 0x10000000000000000 && p < 0x10000000000000000
  {
    if (q-p == 5 && ShiftRight(DataWord(data,descriptorOffset+p),216) == 422944466291) ||
       (q-p == 6 && ShiftRight(DataWord(data,descriptorOffset+p),208) == 126943972912743) then 1 else 0
  }
  lemma Definition(data: seq<Byte>,descriptorOffset: Word,p: Word,q: Word)
    requires descriptorOffset < 0x10000000000000000 && p < 0x10000000000000000
    ensures Dynamic(data,descriptorOffset,p,q) == (if (q-p == 5 && ShiftRight(DataWord(data,descriptorOffset+p),216) == 422944466291) || (q-p == 6 && ShiftRight(DataWord(data,descriptorOffset+p),208) == 126943972912743) then 1 else 0)
  { hide ShiftRight();reveal Dynamic(); }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,value: Word) returns (q: Word,state: State,trace: seq<State>)
    requires Matches(code) && descriptorOffset < 0x10000000000000000 && p < limit <= descriptorLength < 0x10000000000000000 && |prefix| <= 1004
    requires L.Allowed(L.DataByte(data,descriptorOffset,p))
    ensures p < q <= limit && (q == limit || !L.Allowed(L.DataByte(data,descriptorOffset,q)))
    ensures forall i {:trigger L.DataByte(data,descriptorOffset,i)} :: p <= i < q ==> L.Allowed(L.DataByte(data,descriptorOffset,i))
    ensures state == Running(14279,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,q,Dynamic(data,descriptorOffset,p,q),1],mem)
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem) && trace[|trace|-1] == state
  {
    hide ShiftRight();reveal Matches();
    var b := L.DataByte(data,descriptorOffset,p);
    Z.FirstByte(data,descriptorOffset+p);
    assert b == B.ByteWord(0,DataWord(data,descriptorOffset+p)) && b != 40;
    state,trace := I.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,b,value);
    X.WidenTrace(code,I.Destinations(),Destinations(returnPc),value,data,trace);
    var scannerPrefix := prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,0,0,0,0];
    var part: seq<State>;
    var before := state;
    q,state,part := L.Run(code,data,mem,scannerPrefix,14157,descriptorOffset,descriptorLength,p,limit,value);
    assert part[0] == before;
    X.WidenTrace(code,L.Destinations(),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    if q == p { assert q < limit && L.Allowed(L.DataByte(data,descriptorOffset,q)); }
    assert p < q;
    reveal S.Matches();assert 14157 < |code| && code[14157] == 0x5b;
    before := state;
    state,part := C.Run(code,data,mem,scannerPrefix,14157,descriptorOffset,descriptorLength,p,limit,q,value);
    assert part[0] == before;
    X.LiftScan(code,C.Destinations(14157),value,data,part);
    X.WidenTrace(code,C.Destinations(14157),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    state,part := S.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,value);
    assert part[0] == before;
    X.LiftScan(code,S.Destinations(returnPc),value,data,part);
    X.WidenTrace(code,S.Destinations(returnPc),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    var arithmeticPrefix := prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,0,0,0,q,0];
    reveal O.Matches();assert 14205 < |code| && code[14205] == 0x5b;
    before := state;
    state,part := A.Run(code,data,mem,arithmeticPrefix,14205,q,p,value);
    assert part[0] == before;
    X.LiftScan(code,A.Destinations(14205),value,data,part);
    X.WidenTrace(code,A.Destinations(14205),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    Definition(data,descriptorOffset,p,q);
    if q-p == 5 {
      state,part := F.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,value);
      F.DynamicDefinition(data,descriptorOffset,p);
      X.LiftScan(code,F.Destinations(returnPc),value,data,part);
      X.WidenTrace(code,F.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else if q-p == 6 {
      state,part := T.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,value);
      T.DynamicDefinition(data,descriptorOffset,p);
      X.LiftScan(code,T.Destinations(returnPc),value,data,part);
      X.WidenTrace(code,T.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else {
      state,part := O.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q,value);
      X.LiftScan(code,O.Destinations(returnPc),value,data,part);
      X.WidenTrace(code,O.Destinations(returnPc),Destinations(returnPc),value,data,part);
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
