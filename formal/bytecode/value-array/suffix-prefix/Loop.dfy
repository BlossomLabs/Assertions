// SPDX-License-Identifier: MIT
// Exact successful suffix prefixes end at the next real suffix-loop entry.
include "Semantics.dfy"
include "../suffix-connection/Connection.dfy"
module BytecodeCollectionsSuffixPrefix {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import S = BytecodeCollectionsSuffixSemantics
  import P = BytecodeCollectionsSuffixPrefixSemantics
  import C = BytecodeCollectionsSuffixConnection
  predicate Matches(code: seq<Byte>) { C.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { C.Destinations(returnPc) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,shape: S.Shape,closings: seq<nat>,value: Word) returns (result: S.Shape,state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires P.Valid(data,offset,limit,shape,closings) && p < shape.pos && shape.span <= 0xffffffff*(shape.pos-p)
    ensures (P.Admission(data,offset,p,limit,shape,closings); result == P.Final(data,offset,limit,shape,closings) && S.Fits(result,limit))
    ensures (P.Admission(data,offset,p,limit,shape,closings); state == Running(14279,prefix+[returnPc,offset,length,p,limit,result.pos,result.dynamic,result.span],mem))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14279,prefix+[returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span],mem) && trace[|trace|-1] == state
    decreases |closings|
  {
    P.Admission(data,offset,p,limit,shape,closings);reveal Matches();
    if |closings| == 0 {
      result := shape;state := Running(14279,prefix+[returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span],mem);trace := [state];
      reveal E.Trace();
    } else {
      var close := closings[0];var k: Word;
      k,state,trace := C.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span,close,value);
      var next := S.Next(data,offset,shape,close);
      assert next.pos > shape.pos && next.span <= 0xffffffff && next.span <= 0xffffffff*(next.pos-p);
      var before := state;var part: seq<State>;
      result,state,part := Run(code,data,mem,prefix,returnPc,offset,length,p,limit,next,closings[1..],value);
      assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    }
  }
}
