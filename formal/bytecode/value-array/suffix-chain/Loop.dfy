// SPDX-License-Identifier: MIT
// Exact full arbitrary successful suffix loop, including the actual terminal return.
include "Semantics.dfy"
include "../suffix-connection/Connection.dfy"
include "../shape-suffix-boundary/End.generated.dfy"
include "../shape-suffix-boundary/Other.generated.dfy"
module BytecodeCollectionsSuffixChain {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import D = BytecodeCollectionsDecimalLoop
  import S = BytecodeCollectionsSuffixSemantics
  import C = BytecodeCollectionsSuffixConnection
  import End = BytecodeCollectionsShapeSuffixEnd
  import Other = BytecodeCollectionsShapeSuffixOther
  predicate Matches(code: seq<Byte>) {
    C.Matches(code) && End.Matches(code) && Other.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    C.Destinations(returnPc)+End.Destinations(returnPc)+Other.Destinations(returnPc)
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,shape: S.Shape,closings: seq<nat>,value: Word) returns (result: S.Shape,state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires returnPc < |code| && code[returnPc] == 0x5b
    requires S.Valid(data,offset,limit,shape,closings)
    ensures result == S.Final(data,offset,limit,shape,closings) && S.Fits(result,limit)
    ensures state == Running(returnPc,prefix+[result.pos,result.dynamic,result.span],mem)
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14279,prefix+[returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span],mem) && trace[|trace|-1] == state
    decreases |closings|
  {
    reveal Matches();
    if |closings| == 0 {
      result := shape;
      if shape.pos >= limit {
        state,trace := End.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span,0,value);
        X.WidenTrace(code,End.Destinations(returnPc),Destinations(returnPc),value,data,trace);
      } else {
        var b := D.DataByte(data,offset,shape.pos);
        Z.FirstByte(data,offset+shape.pos);
        state,trace := Other.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span,b,value);
        X.WidenTrace(code,Other.Destinations(returnPc),Destinations(returnPc),value,data,trace);
      }
    } else {
      var close := closings[0];
      var k: Word;
      k,state,trace := C.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span,close,value);
      X.WidenTrace(code,C.Destinations(returnPc),Destinations(returnPc),value,data,trace);
      var next := S.Next(data,offset,shape,close);
      assert S.Valid(data,offset,limit,next,closings[1..]);
      var before := state;
      var part: seq<State>;
      result,state,part := Run(code,data,mem,prefix,returnPc,offset,length,p,limit,next,closings[1..],value);
      assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    }
  }
}
