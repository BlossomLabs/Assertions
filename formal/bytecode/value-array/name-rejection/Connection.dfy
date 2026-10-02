// SPDX-License-Identifier: MIT
// Exact non-tuple invalid first byte from typeShape entry through error REVERT.
include "../type-name-invocation/Invocation.generated.dfy"
include "../name-scanner-v2/Loop.dfy"
include "../named-type/Cleanup.generated.dfy"
include "../descriptor-error-foundation/NameEmpty.generated.dfy"
include "../parser-execution/Execution.dfy"
module BytecodeCollectionsDescriptorNameRejection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import X = BytecodeCollectionsParserExecution
  import I = BytecodeCollectionsTypeNameInvocation
  import L = BytecodeCollectionsScanNameLoop
  import C = BytecodeCollectionsNamedTypeCleanup
  import R = BytecodeCollectionsDescriptorNameEmpty
  import H = BytecodeCollectionsDescriptorErrorMemory
  predicate Matches(code: seq<Byte>) {
    I.Matches(code) && L.Matches(code) && C.Matches(code) && R.Matches(code)
  }
  function Destinations(): set<nat> {
    I.Destinations()+L.Destinations()+C.Destinations(14157)+R.Destinations()
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && descriptorOffset < 0x10000000000000000 && p < limit <= descriptorLength < 0x10000000000000000 && |prefix| <= 1004
    requires !L.Allowed(L.DataByte(data,descriptorOffset,p)) && L.DataByte(data,descriptorOffset,p) != 40
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures state == Reverted(H.Bytes(p))
    ensures E.Trace(code,Destinations(),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit],mem) && trace[|trace|-1] == state
  {
    reveal Matches();
    var b := L.DataByte(data,descriptorOffset,p);
    Z.FirstByte(data,descriptorOffset+p);
    assert b == B.ByteWord(0,DataWord(data,descriptorOffset+p));
    state,trace := I.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,b,value);
    X.WidenTrace(code,I.Destinations(),Destinations(),value,data,trace);
    var scannerPrefix := prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,0,0,0,0];
    var part: seq<State>;var before := state;var q: Word;
    q,state,part := L.Run(code,data,mem,scannerPrefix,14157,descriptorOffset,descriptorLength,p,limit,value);
    if q > p { assert L.Allowed(L.DataByte(data,descriptorOffset,p)); }
    assert q == p;
    assert part[0] == before;
    X.WidenTrace(code,L.Destinations(),Destinations(),value,data,part);
    X.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    reveal R.Matches();assert 14157 < |code| && code[14157] == 0x5b;
    before := state;
    state,part := C.Run(code,data,mem,scannerPrefix,14157,descriptorOffset,descriptorLength,p,limit,q,value);
    assert part[0] == before;
    X.LiftScan(code,C.Destinations(14157),value,data,part);
    X.WidenTrace(code,C.Destinations(14157),Destinations(),value,data,part);
    X.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    before := state;
    state,part := R.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,fp,value);
    assert part[0] == before;
    X.LiftScan(code,R.Destinations(),value,data,part);
    X.WidenTrace(code,R.Destinations(),Destinations(),value,data,part);
    X.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
