// SPDX-License-Identifier: MIT
// Complete tuple parsing through accepted previous/last children then exact separator error.
include "../tuple-prefix/Loop.dfy"
include "../tuple-child-update/UpdateStatic.generated.dfy"
include "../tuple-child-update/UpdateDynamic.generated.dfy"
include "../tuple-rejection/AtLimit.generated.dfy"
include "../tuple-rejection/WrongSeparator.generated.dfy"
module BytecodeCollectionsTupleSeparatorRejection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import D = BytecodeCollectionsDecimalLoop
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import TP = BytecodeCollectionsTuplePrefixBounds
  import Prefix = BytecodeCollectionsTuplePrefix
  import P = BytecodeCollectionsTypeParser
  import US = BytecodeCollectionsTupleUpdateStatic
  import UD = BytecodeCollectionsTupleUpdateDynamic
  import Limit = BytecodeCollectionsTupleRejectionAtLimit
  import Wrong = BytecodeCollectionsTupleRejectionWrongSeparator
  import H = BytecodeCollectionsDescriptorErrorMemory
  predicate Syntax(data: seq<Byte>,offset: Word,p: Word,limit: Word,previous: seq<T.Descriptor>,last: T.Descriptor) {
    TP.Children(data,offset,p,limit,previous) && limit < 0x10000000000000000 &&
    (TP.Admission(data,offset,p,limit,previous);B.Syntax(data,offset,TP.Next(p,previous),limit,last)) &&
    (last.shape.pos == limit || (D.DataByte(data,offset,last.shape.pos) != 44 && D.DataByte(data,offset,last.shape.pos) != 41))
  }
  predicate Matches(code: seq<Byte>) { Prefix.Matches(code) && US.Matches(code) && UD.Matches(code) && Limit.Matches(code) && Wrong.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { Prefix.Destinations(returnPc)+P.Destinations(13958)+US.Destinations(returnPc)+UD.Destinations(returnPc)+Limit.Destinations()+Wrong.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,previous: seq<T.Descriptor>,last: T.Descriptor,fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires Syntax(data,offset,p,limit,previous,last)
    requires (forall i :: 0 <= i < |previous| ==> T.StackFits(|prefix|+13,previous[i])) && T.StackFits(|prefix|+13,last)
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures (TP.Admission(data,offset,p,limit,previous);B.Admission(data,offset,TP.Next(p,previous),limit,last);state == Reverted(H.Bytes(last.shape.pos)))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
  {
    reveal Matches();TP.Admission(data,offset,p,limit,previous);
    var q: Word := TP.Next(p,previous);B.Admission(data,offset,q,limit,last);
    var sum: Word := T.Sum(previous);var dyn: Word := T.Flags(previous);
    var end: Word := last.shape.pos;var childDyn: Word := last.shape.dynamic;var childWords: Word := last.shape.span;
    assert sum <= 0xffffffff*(q-p) && childWords <= 0xffffffff*(end-q);
    assert sum+childWords <= 0xffffffff*(end-p) <= 0xffffffff*limit < G.Modulus();
    state,trace := Prefix.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,previous,value);
    X.WidenTrace(code,Prefix.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    var before := state;var part: seq<State>;
    var childPrefix := prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0];
    state,part := P.Run(code,data,mem,childPrefix,13958,offset,length,q,limit,last,value);
    X.WidenTrace(code,P.Destinations(13958),Destinations(returnPc),value,data,part);assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    if childDyn == 0 {
      state,part := US.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,0,value);
      X.WidenTrace(code,US.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else {
      state,part := UD.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,0,value);
      X.WidenTrace(code,UD.Destinations(returnPc),Destinations(returnPc),value,data,part);
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    var total: Word := sum+childWords;if childDyn == 1 { dyn := 1; }
    before := state;
    if end == limit {
      state,part := Limit.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,total,end,childDyn,childWords,0,fp,value);
      X.WidenTrace(code,Limit.Destinations(),Destinations(returnPc),value,data,part);
    } else {
      var b := D.DataByte(data,offset,end);Z.FirstByte(data,offset+end);
      state,part := Wrong.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,total,end,childDyn,childWords,b,fp,value);
      X.WidenTrace(code,Wrong.Destinations(),Destinations(returnPc),value,data,part);
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
