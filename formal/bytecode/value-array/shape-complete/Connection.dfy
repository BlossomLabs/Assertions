// SPDX-License-Identifier: MIT
// Classify original descriptor input, then follow its exact complete shape call.
include "../type-complete/Parser.dfy"
include "../shape-type-call/Call.generated.dfy"
include "../shape-return/Success.generated.dfy"
include "../shape-return/Trailing.generated.dfy"
module BytecodeCollectionsCompleteShape {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Call = BytecodeCollectionsShapeTypeCall
  import Parse = BytecodeCollectionsCompleteTypeParser
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import R = BytecodeCollectionsTypeRejectSemantics
  import Success = BytecodeCollectionsShapeReturnSuccess
  import Trailing = BytecodeCollectionsShapeReturnTrailing
  import H = BytecodeCollectionsDescriptorErrorMemory
  predicate Matches(code: seq<Byte>) {
    Call.Matches(code) && Parse.Matches(code) && Success.Matches(code) && Trailing.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    Call.Destinations()+Parse.Destinations(9908)+Success.Destinations(returnPc)+Trailing.Destinations(returnPc)
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,fp: Word,value: Word)
    returns (resourceFits: bool,typeRejected: bool,tree: T.Descriptor,problem: R.Rejection,state: State,trace: seq<State>)
    requires Matches(code) && offset < 0x10000000000000000 && length < 0x10000000000000000
    requires returnPc < |code| && code[returnPc] == 0x5b
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures typeRejected ==> R.Syntax(data,offset,0,length,problem)
    ensures !typeRejected ==> B.Syntax(data,offset,0,length,tree)
    ensures resourceFits == (if typeRejected then R.StackFits(|prefix|+6,problem) else T.StackFits(|prefix|+6,tree))
    ensures resourceFits ==> E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(9893,prefix+[returnPc,offset,length],mem) && trace[|trace|-1] == state
    ensures resourceFits && typeRejected ==> state == Reverted(H.Bytes(R.Position(data,offset,0,length,problem)))
    ensures resourceFits && !typeRejected ==> (B.Admission(data,offset,0,length,tree); if tree.shape.pos == length then state == Running(returnPc,prefix+[tree.shape.dynamic,tree.shape.span],mem) else state == Reverted(H.Bytes(tree.shape.pos)))
  {
    reveal Matches();
    reveal Success.Matches(); assert 9908 < |code| && code[9908] == 0x5b;
    var childPrefix := prefix+[returnPc,offset,length,0,0,0];
    var parsedState: State; var parsedTrace: seq<State>;
    resourceFits,typeRejected,tree,problem,parsedState,parsedTrace := Parse.Run(code,data,mem,childPrefix,9908,offset,length,0,length,fp,value);
    state := Bad; trace := [];
    if !resourceFits { return; }
    assert |prefix| <= 998;
    state,trace := Call.Run(code,data,mem,prefix,returnPc,offset,length,value);
    X.LiftScan(code,Call.Destinations(),value,data,trace);
    X.WidenTrace(code,Call.Destinations(),Destinations(returnPc),value,data,trace);
    X.WidenTrace(code,Parse.Destinations(9908),Destinations(returnPc),value,data,parsedTrace);
    assert parsedTrace[0] == state;
    X.Join(code,Destinations(returnPc),value,data,trace,parsedTrace); trace := trace+parsedTrace[1..];
    state := parsedState;
    var before: State; var part: seq<State>;
    if typeRejected { return; }
    B.Admission(data,offset,0,length,tree);
    before := state;
    if tree.shape.pos == length {
      state,part := Success.Run(code,data,mem,prefix,returnPc,offset,length,tree.shape.pos,tree.shape.dynamic,tree.shape.span,fp,value);
      X.LiftScan(code,Success.Destinations(returnPc),value,data,part);
      X.WidenTrace(code,Success.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else {
      state,part := Trailing.Run(code,data,mem,prefix,returnPc,offset,length,tree.shape.pos,tree.shape.dynamic,tree.shape.span,fp,value);
      X.LiftScan(code,Trailing.Destinations(returnPc),value,data,part);
      X.WidenTrace(code,Trailing.Destinations(returnPc),Destinations(returnPc),value,data,part);
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part); trace := trace+part[1..];
  }
}
