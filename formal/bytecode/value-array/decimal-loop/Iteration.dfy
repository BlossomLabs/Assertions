// SPDX-License-Identifier: MIT
// Exact successful digit iteration including all four actual checked routines.
include "../decimal-guards/DigitCall.generated.dfy"
include "../decimal-guards/ByteToMultiply.generated.dfy"
include "../decimal-guards/MultiplyToAdd.generated.dfy"
include "../decimal-guards/AddToIncrement.generated.dfy"
include "../decimal-guards/IncrementBack.generated.dfy"
include "../checked-byte-subtract/ByteSubtract.generated.dfy"
include "../checked-multiply/Multiply.generated.dfy"
include "../checked-add/Add.generated.dfy"
include "../checked-increment/Increment.generated.dfy"
include "../parser-execution/Execution.dfy"
module BytecodeCollectionsDecimalIteration {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import D = BytecodeCollectionsDecimalDigitCall
  import BM = BytecodeCollectionsDecimalByteToMultiply
  import MA = BytecodeCollectionsDecimalMultiplyToAdd
  import AI = BytecodeCollectionsDecimalAddToIncrement
  import IB = BytecodeCollectionsDecimalIncrementBack
  import BS = BytecodeCollectionsCheckedByteSubtract
  import M = BytecodeCollectionsCheckedByteSubtractScalar
  import MU = BytecodeCollectionsCheckedMultiply
  import AD = BytecodeCollectionsCheckedAdd
  import IN = BytecodeCollectionsCheckedIncrement
  predicate Matches(code: seq<Byte>) {
    D.Matches(code) && BM.Matches(code) && MA.Matches(code) && AI.Matches(code) && IB.Matches(code) &&
    BS.Matches(code) && MU.Matches(code) && AD.Matches(code) && IN.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    D.Destinations(returnPc)+BM.Destinations(returnPc)+MA.Destinations(returnPc)+AI.Destinations(returnPc)+IB.Destinations(returnPc)+
    BS.Destinations(14388)+MU.Destinations(14402)+AD.Destinations(14412)+IN.Destinations(14424)
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,q: Word,k: Word,b: Byte,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1005 && descriptorOffset < 0x10000000000000000 && q < limit <= descriptorLength < 0x10000000000000000
    requires b == B.ByteWord(0,DataWord(data,descriptorOffset+q)) && 48 <= b <= 57 && k <= 0xffffffff
    ensures state == Running(14320,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q+1,k*10+b-48],mem)
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14320,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k],mem) && trace[|trace|-1] == state
  {
    reveal Matches();
    var fields := [returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k];
    state,trace := D.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
    X.WidenTrace(code,D.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    var part: seq<State>;
    var before := state;
    M.ByteIdentity(b);M.ByteIdentity(48);
    reveal BM.Matches();assert 14388 < |code| && code[14388] == 0x5b;
    state,part := BS.Run(code,data,mem,prefix+fields+[b],14388,b,48,value);
    assert part[0] == before;
    X.LiftScan(code,BS.Destinations(14388),value,data,part);
    X.WidenTrace(code,BS.Destinations(14388),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    state,part := BM.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
    assert part[0] == before;
    X.WidenTrace(code,BM.Destinations(returnPc),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    reveal MA.Matches();assert 14402 < |code| && code[14402] == 0x5b;
    state,part := MU.Run(code,data,mem,prefix+fields+[b,b-48],14402,k,10,value);
    assert part[0] == before;
    X.LiftScan(code,MU.Destinations(14402),value,data,part);
    X.WidenTrace(code,MU.Destinations(14402),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    state,part := MA.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
    assert part[0] == before;
    X.WidenTrace(code,MA.Destinations(returnPc),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    reveal AI.Matches();assert 14412 < |code| && code[14412] == 0x5b;
    state,part := AD.Run(code,data,mem,prefix+fields+[b],14412,b-48,k*10,value);
    assert part[0] == before;
    X.LiftScan(code,AD.Destinations(14412),value,data,part);
    X.WidenTrace(code,AD.Destinations(14412),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    state,part := AI.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
    assert part[0] == before;
    X.WidenTrace(code,AI.Destinations(returnPc),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    var incrementPrefix := prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k*10+b-48,b,q];
    reveal IB.Matches();assert 14424 < |code| && code[14424] == 0x5b;
    state,part := IN.Run(code,data,mem,incrementPrefix,14424,q,value);
    assert part[0] == before;
    X.LiftScan(code,IN.Destinations(14424),value,data,part);
    X.WidenTrace(code,IN.Destinations(14424),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    state,part := IB.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,value);
    assert part[0] == before;
    X.WidenTrace(code,IB.Destinations(returnPc),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
