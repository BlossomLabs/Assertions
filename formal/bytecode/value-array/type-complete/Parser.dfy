// SPDX-License-Identifier: MIT
// Input-derived descriptor classification plus exact execution in the original stack budget.
include "../type-classification/Parser.dfy"
include "../type-rejection/Parser.dfy"
module BytecodeCollectionsCompleteTypeParser {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import C = BytecodeCollectionsTypeClassification
  import R = BytecodeCollectionsTypeRejectSemantics
  import Error = BytecodeCollectionsTypeRejectParser
  import P = BytecodeCollectionsTypeParser
  import H = BytecodeCollectionsDescriptorErrorMemory
  predicate Matches(code: seq<Byte>) { P.Matches(code) && Error.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { P.Destinations(returnPc)+Error.Destinations(returnPc) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,fp: Word,value: Word) returns (resourceFits: bool,rejected: bool,tree: T.Descriptor,problem: R.Rejection,state: State,trace: seq<State>)
    requires Matches(code) && offset < 0x10000000000000000 && p <= limit <= length < 0x10000000000000000
    requires returnPc < |code| && code[returnPc] == 0x5b
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures rejected ==> R.Syntax(data,offset,p,limit,problem)
    ensures !rejected ==> B.Syntax(data,offset,p,limit,tree)
    ensures resourceFits == (if rejected then R.StackFits(|prefix|,problem) else T.StackFits(|prefix|,tree))
    ensures resourceFits ==> E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
    ensures resourceFits && rejected ==> state == Reverted(H.Bytes(R.Position(data,offset,p,limit,problem)))
    ensures resourceFits && !rejected ==> (B.Admission(data,offset,p,limit,tree);state == Running(returnPc,prefix+[tree.shape.pos,tree.shape.dynamic,tree.shape.span],mem))
  {
    rejected,tree,problem := C.Parse(data,offset,p,limit);
    resourceFits := if rejected then R.StackFits(|prefix|,problem) else T.StackFits(|prefix|,tree);
    state := Bad;trace := [];
    if !resourceFits { return; }
    reveal Matches();
    if rejected {
      state,trace := Error.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,problem,fp,value);
      X.WidenTrace(code,Error.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    } else {
      state,trace := P.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,tree,value);
      X.WidenTrace(code,P.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    }
  }
}
