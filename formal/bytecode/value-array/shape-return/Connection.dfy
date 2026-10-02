// SPDX-License-Identifier: MIT
// Complete successful descriptor shape call through actual generic final return.
include "../shape-type-call/Call.generated.dfy"
include "../type-parser/Parser.dfy"
include "Success.generated.dfy"
module BytecodeCollectionsShapeConnection {
  import opened BytecodeScanMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import C = BytecodeCollectionsShapeTypeCall
  import P = BytecodeCollectionsTypeParser
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import R = BytecodeCollectionsShapeReturnSuccess
  predicate Matches(code: seq<Byte>) { C.Matches(code) && P.Matches(code) && R.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { C.Destinations()+P.Destinations(9908)+R.Destinations(returnPc) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,tree: T.Descriptor,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && descriptorOffset < 0x10000000000000000 && descriptorLength < 0x10000000000000000
    requires returnPc < |code| && code[returnPc] == 0x5b
    requires B.Syntax(data,descriptorOffset,0,descriptorLength,tree) && T.StackFits(|prefix|+6,tree) && tree.shape.pos == descriptorLength
    ensures (B.Admission(data,descriptorOffset,0,descriptorLength,tree); state == Running(returnPc,prefix+[tree.shape.dynamic,tree.shape.span],mem))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(9893,prefix+[returnPc,descriptorOffset,descriptorLength],mem) && trace[|trace|-1] == state
  {
    B.Admission(data,descriptorOffset,0,descriptorLength,tree);reveal Matches();
    state,trace := C.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,value);
    X.LiftScan(code,C.Destinations(),value,data,trace);X.WidenTrace(code,C.Destinations(),Destinations(returnPc),value,data,trace);
    reveal R.Matches();assert 9908 < |code| && code[9908] == 0x5b;
    var before := state;var part: seq<State>;var childPrefix := prefix+[returnPc,descriptorOffset,descriptorLength,0,0,0];
    state,part := P.Run(code,data,mem,childPrefix,9908,descriptorOffset,descriptorLength,0,descriptorLength,tree,value);
    X.WidenTrace(code,P.Destinations(9908),Destinations(returnPc),value,data,part);
    assert part[0] == before;X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    state,part := R.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,tree.shape.pos,tree.shape.dynamic,tree.shape.span,0,value);
    X.LiftScan(code,R.Destinations(returnPc),value,data,part);X.WidenTrace(code,R.Destinations(returnPc),Destinations(returnPc),value,data,part);
    assert part[0] == before;X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
