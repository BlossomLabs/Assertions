// SPDX-License-Identifier: MIT
// Complete named or tuple type base, accepted suffix prefix, and rejected next suffix.
include "../tuple-base/Base.dfy"
include "../suffix-prefix/Loop.dfy"
include "../suffix-reject-connection/Connection.dfy"
module BytecodeCollectionsParserSuffixRejection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import S = BytecodeCollectionsSuffixSemantics
  import P = BytecodeCollectionsSuffixPrefixSemantics
  import L = BytecodeCollectionsSuffixPrefix
  import D = BytecodeCollectionsDecimalLoop
  import Q = BytecodeCollectionsSuffixRejectSemantics
  import C = BytecodeCollectionsSuffixRejectConnection
  import W = BytecodeCollectionsSuffixFootprintScalar
  import N = BytecodeCollectionsNamedParser
  import NC = BytecodeCollectionsNamedShapeConnection
  import T = BytecodeCollectionsTypeSemantics
  import TB = BytecodeCollectionsTupleBaseBounds
  import Tuple = BytecodeCollectionsTupleBase
  import H = BytecodeCollectionsDescriptorErrorMemory
  predicate Invalid(data: seq<Byte>,offset: Word,p: Word,limit: Word,shape: S.Shape,closings: seq<nat>,q: Word,k: Word) {
    P.Valid(data,offset,limit,shape,closings) && p < shape.pos && limit < 0x10000000000000000 &&
    shape.span <= 0xffffffff*(shape.pos-p) &&
    var final := P.Final(data,offset,limit,shape,closings);
    final.pos < limit && D.DataByte(data,offset,final.pos) == 91 &&
    Q.Witness(data,offset,final.pos+1,limit,q,k) &&
    (P.Admission(data,offset,p,limit,shape,closings);W.ProductFits(final.span,k,p,final.pos);Q.Rejected(data,offset,final.pos,limit,final.dynamic,final.span,q,k))
  }
  predicate Matches(code: seq<Byte>) { NC.Matches(code) && Tuple.Matches(code) && L.Matches(code) && C.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { NC.Destinations(returnPc)+Tuple.Destinations(returnPc)+L.Destinations(returnPc)+C.Destinations(returnPc) }
  ghost method Finish(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,shape: S.Shape,closings: seq<nat>,q: Word,k: Word,fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires Invalid(data,offset,p,limit,shape,closings,q,k)
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures state == Reverted(H.Bytes(q))
    ensures (P.Admission(data,offset,p,limit,shape,closings);E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14279,prefix+[returnPc,offset,length,p,limit,shape.pos,shape.dynamic,shape.span],mem) && trace[|trace|-1] == state)
  {
    reveal Matches();P.Admission(data,offset,p,limit,shape,closings);
    var final: S.Shape;
    final,state,trace := L.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,shape,closings,value);
    X.WidenTrace(code,L.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    assert final.pos >= shape.pos > p;
    var before := state;var part: seq<State>;
    state,part := C.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,final.pos,final.dynamic,final.span,q,k,fp,value);
    X.WidenTrace(code,C.Destinations(returnPc),Destinations(returnPc),value,data,part);assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
  ghost method Named(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,nameEnd: Word,closings: seq<nat>,q: Word,k: Word,fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && offset < 0x10000000000000000 && p < limit <= length < 0x10000000000000000
    requires N.Name(data,offset,p,limit,nameEnd)
    requires Invalid(data,offset,p,limit,S.Shape(nameEnd,N.Dynamic(data,offset,p,nameEnd),1),closings,q,k)
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures state == Reverted(H.Bytes(q))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
  {
    reveal Matches();var actualNameEnd: Word;
    actualNameEnd,state,trace := NC.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,value);
    assert N.Name(data,offset,p,limit,actualNameEnd);N.UniqueName(data,offset,p,limit,actualNameEnd,nameEnd);N.Classification(data,offset,p,nameEnd);
    X.WidenTrace(code,NC.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    var before := state;var part: seq<State>;
    state,part := Finish(code,data,mem,prefix,returnPc,offset,length,p,limit,S.Shape(nameEnd,N.Dynamic(data,offset,p,nameEnd),1),closings,q,k,fp,value);assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
  ghost method TupleType(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,children: seq<T.Descriptor>,closings: seq<nat>,q: Word,k: Word,fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires TB.Children(data,offset,p,limit,children) && (forall i :: 0 <= i < |children| ==> T.StackFits(|prefix|+13,children[i]))
    requires Invalid(data,offset,p,limit,TB.Base(p,children),closings,q,k)
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures state == Reverted(H.Bytes(q))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
  {
    reveal Matches();TB.Admission(data,offset,p,limit,children);
    state,trace := Tuple.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,children,value);
    X.WidenTrace(code,Tuple.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    var before := state;var part: seq<State>;
    state,part := Finish(code,data,mem,prefix,returnPc,offset,length,p,limit,TB.Base(p,children),closings,q,k,fp,value);assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
