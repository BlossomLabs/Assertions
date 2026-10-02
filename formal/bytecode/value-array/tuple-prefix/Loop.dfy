// SPDX-License-Identifier: MIT
// Exact tuple initialization and finite accepted comma-separated child prefix.
include "Bounds.dfy"
include "../type-parser/Parser.dfy"
module BytecodeCollectionsTuplePrefix {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import T = BytecodeCollectionsTypeSemantics
  import TP = BytecodeCollectionsTuplePrefixBounds
  import P = BytecodeCollectionsTypeParser
  import I = BytecodeCollectionsTupleInitial
  import CS = BytecodeCollectionsTupleCommaStatic
  import CD = BytecodeCollectionsTupleCommaDynamic
  predicate Matches(code: seq<Byte>) { P.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { P.Destinations(returnPc)+P.Destinations(13958) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,children: seq<T.Descriptor>,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000 && |prefix| <= 1004
    requires TP.Children(data,offset,p,limit,children)
    requires forall i :: 0 <= i < |children| ==> T.StackFits(|prefix|+13,children[i])
    ensures (TP.Admission(data,offset,p,limit,children);state == Running(13839,prefix+[returnPc,offset,length,p,limit,0,T.Flags(children),0,TP.Next(p,children),T.Sum(children),0,0,0,13958,offset,length,TP.Next(p,children),limit],mem))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
  {
    TP.Admission(data,offset,p,limit,children);reveal Matches();reveal P.Matches();
    Z.FirstByte(data,offset+p);
    state,trace := I.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,40,value);
    X.WidenTrace(code,I.Destinations(),Destinations(returnPc),value,data,trace);
    reveal CS.Matches();assert 13958 < |code| && code[13958] == 0x5b;
    var index: nat := 0;var dyn: Word := 0;var sum: Word := 0;var q: Word := p+1;
    while index < |children|
      invariant 0 <= index <= |children|
      invariant dyn == T.Flags(children[..index]) && sum == T.Sum(children[..index])
      invariant q == (if index == 0 then p+1 else children[index-1].shape.pos+1)
      invariant p < q <= limit
      invariant index < |children| ==> q == T.Start(p,children,index) && q < limit
      invariant state == Running(13839,prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0,13958,offset,length,q,limit],mem)
      invariant E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
      decreases |children|-index
    {
      var child := children[index];var childPrefix := prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0];
      var before := state;var part: seq<State>;
      state,part := P.Run(code,data,mem,childPrefix,13958,offset,length,q,limit,child,value);
      X.WidenTrace(code,P.Destinations(13958),Destinations(returnPc),value,data,part);assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
      var end: Word := child.shape.pos;var childDyn: Word := child.shape.dynamic;var childWords: Word := child.shape.span;
      T.Forward(data,offset,q,limit,child);T.SumPrefix(children,index+1);T.Extend(children,index);assert sum+childWords < G.Modulus();
      Z.FirstByte(data,offset+end);before := state;
      if childDyn == 0 {
        state,part := CS.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,44,value);
        X.WidenTrace(code,CS.Destinations(returnPc),Destinations(returnPc),value,data,part);
      } else {
        state,part := CD.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,44,value);
        X.WidenTrace(code,CD.Destinations(returnPc),Destinations(returnPc),value,data,part);
      }
      assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
      q := end+1;sum := sum+childWords;if childDyn == 1 { dyn := 1; }index := index+1;
    }
  }
}
