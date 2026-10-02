// SPDX-License-Identifier: MIT
// Complete successful named-type parser and arbitrary suffix chain with independent shape semantics.
include "../named-shape-connection/Connection.dfy"
include "../name-representation/Representation.dfy"
include "../suffix-chain/Loop.dfy"
module BytecodeCollectionsNamedParser {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import L = BytecodeCollectionsScanNameLoop
  import N = BytecodeCollectionsNamedShapeConnection
  import R = BytecodeCollectionsNameRepresentation
  import S = BytecodeCollectionsSuffixSemantics
  import C = BytecodeCollectionsSuffixChain
  predicate Name(data: seq<Byte>,offset: Word,p: Word,limit: Word,end: Word) {
    p < end <= limit &&
    (forall i {:trigger L.DataByte(data,offset,i)} :: p <= i < end ==> L.Allowed(L.DataByte(data,offset,i))) &&
    (end == limit || !L.Allowed(L.DataByte(data,offset,end)))
  }
  function Dynamic(data: seq<Byte>,offset: Word,p: Word,end: Word): Word {
    if (end-p == 5 && Window(data,offset+p,5) == [98,121,116,101,115]) ||
       (end-p == 6 && Window(data,offset+p,6) == [115,116,114,105,110,103]) then 1 else 0
  }
  predicate Matches(code: seq<Byte>) { N.Matches(code) && C.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { N.Destinations(returnPc)+C.Destinations(returnPc) }
  lemma UniqueName(data: seq<Byte>,offset: Word,p: Word,limit: Word,a: Word,b: Word)
    requires Name(data,offset,p,limit,a) && Name(data,offset,p,limit,b)
    ensures a == b
  {
    if a < b { assert p <= a < b; assert L.Allowed(L.DataByte(data,offset,a)); }
    else if b < a { assert p <= b < a; assert L.Allowed(L.DataByte(data,offset,b)); }
  }
  lemma Classification(data: seq<Byte>,offset: Word,p: Word,end: Word)
    requires offset < 0x10000000000000000 && p < 0x10000000000000000
    ensures N.Dynamic(data,offset,p,end) == Dynamic(data,offset,p,end)
  {
    hide ShiftRight();N.Definition(data,offset,p,end);
    if end-p == 5 { R.BytesName(data,offset+p); }
    else if end-p == 6 { R.StringName(data,offset+p); }
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,nameEnd: Word,closings: seq<nat>,value: Word) returns (result: S.Shape,state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && offset < 0x10000000000000000 && p < limit <= length < 0x10000000000000000
    requires returnPc < |code| && code[returnPc] == 0x5b
    requires Name(data,offset,p,limit,nameEnd)
    requires S.Valid(data,offset,limit,S.Shape(nameEnd,Dynamic(data,offset,p,nameEnd),1),closings)
    ensures result == S.Final(data,offset,limit,S.Shape(nameEnd,Dynamic(data,offset,p,nameEnd),1),closings) && S.Fits(result,limit)
    ensures state == Running(returnPc,prefix+[result.pos,result.dynamic,result.span],mem)
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
  {
    reveal Matches();
    assert L.Allowed(L.DataByte(data,offset,p));
    var q: Word;
    q,state,trace := N.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,value);
    X.WidenTrace(code,N.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    assert Name(data,offset,p,limit,q);
    UniqueName(data,offset,p,limit,q,nameEnd);Classification(data,offset,p,nameEnd);
    var shape := S.Shape(nameEnd,Dynamic(data,offset,p,nameEnd),1);
    var before := state;var part: seq<State>;
    result,state,part := C.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,shape,closings,value);
    X.WidenTrace(code,C.Destinations(returnPc),Destinations(returnPc),value,data,part);
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
