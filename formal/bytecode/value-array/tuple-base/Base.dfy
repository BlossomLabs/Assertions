// SPDX-License-Identifier: MIT
// Complete tuple base parser without assuming a successful following suffix.
include "Bounds.dfy"
include "../type-parser/Parser.dfy"
module BytecodeCollectionsTupleBase {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import T = BytecodeCollectionsTypeSemantics
  import TB = BytecodeCollectionsTupleBaseBounds
  import P = BytecodeCollectionsTypeParser
  import I = BytecodeCollectionsTupleInitial
  import CS = BytecodeCollectionsTupleCommaStatic
  import CD = BytecodeCollectionsTupleCommaDynamic
  import SS = BytecodeCollectionsTupleCloseStatic
  import DS = BytecodeCollectionsTupleCloseParentDynamic
  import DD = BytecodeCollectionsTupleCloseChildDynamic
  import B = BytecodeCollectionsTypeBounds
  import S = BytecodeCollectionsSuffixSemantics
  import D = BytecodeCollectionsDecimalLoop
  predicate Matches(code: seq<Byte>) { P.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { P.Destinations(returnPc)+P.Destinations(13958) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,children: seq<T.Descriptor>,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires TB.Children(data,offset,p,limit,children) && |prefix| <= 1004
    requires forall i :: 0 <= i < |children| ==> T.StackFits(|prefix|+13,children[i])
    ensures (TB.Admission(data,offset,p,limit,children); state == Running(14279,prefix+[returnPc,offset,length,p,limit,TB.Base(p,children).pos,TB.Base(p,children).dynamic,TB.Base(p,children).span],mem))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
  {
    TB.Admission(data,offset,p,limit,children);reveal Matches();reveal P.Matches();
    Z.FirstByte(data,offset+p);
    state,trace := I.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,40,value);
    X.WidenTrace(code,I.Destinations(),Destinations(returnPc),value,data,trace);
    reveal CS.Matches();assert 13958 < |code| && code[13958] == 0x5b;

    assert forall i :: 0 <= i < |children| ==> children[i].shape.span >= 1;
    assert forall i :: 0 <= i < |children| ==>
                         T.Start(p,children,i) < limit && B.Syntax(data,offset,T.Start(p,children,i),limit,children[i]) &&
                         T.Valid(data,offset,T.Start(p,children,i),limit,children[i]) &&
                         T.StackFits(|prefix|+13,children[i]) && S.Fits(children[i].shape,limit) &&
                         children[i].shape.pos < limit &&
                         D.DataByte(data,offset,children[i].shape.pos) == (if i+1 < |children| then 44 else 41);
    assert T.Sum(children) < G.Modulus();
    hide TB.Children();hide B.Syntax();hide T.Valid();hide T.StackFits();
    var index: nat := 0;var dyn: Word := 0;var sum: Word := 0;var q: Word := p+1;
    assert q == T.Start(p,children,0);
    while index < |children|
      invariant 0 <= index <= |children| && |children| > 0
      invariant dyn == T.Flags(children[..index]) && sum == T.Sum(children[..index])
      invariant index < |children| ==> q == T.Start(p,children,index)
      invariant index < |children| ==> p < q < limit
      invariant state == (if index < |children| then Running(13839,prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0,13958,offset,length,q,limit],mem) else Running(14279,prefix+[returnPc,offset,length,p,limit,TB.Base(p,children).pos,TB.Base(p,children).dynamic,TB.Base(p,children).span],mem))
      invariant E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
      decreases |children|-index
    {
      var child := children[index];
      var childPrefix := prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0];
      var before := state;var part: seq<State>;
      state,part := P.Run(code,data,mem,childPrefix,13958,offset,length,q,limit,child,value);
      X.WidenTrace(code,P.Destinations(13958),Destinations(returnPc),value,data,part);
      assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
      var end: Word := child.shape.pos;var childDyn: Word := child.shape.dynamic;var childWords: Word := child.shape.span;
      T.Forward(data,offset,q,limit,child);
      assert q < end;
      T.SumPrefix(children,index+1);T.Extend(children,index);
      assert sum+childWords < G.Modulus();
      Z.FirstByte(data,offset+end);
      if index+1 == |children| {
        assert children[..index+1] == children;
        assert TB.Base(p,children) == S.Shape(end+1,if childDyn == 1 then 1 else dyn,
                                              if childDyn == 1 || dyn == 1 then 1 else sum+childWords);
      }
      before := state;
      if index+1 < |children| {
        if childDyn == 0 {
          state,part := CS.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,44,value);
          X.WidenTrace(code,CS.Destinations(returnPc),Destinations(returnPc),value,data,part);
        } else {
          state,part := CD.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,44,value);
          X.WidenTrace(code,CD.Destinations(returnPc),Destinations(returnPc),value,data,part);
        }
        q := end+1;
        assert q == T.Start(p,children,index+1);
      } else if childDyn == 1 {
        state,part := DD.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,41,value);
        X.WidenTrace(code,DD.Destinations(returnPc),Destinations(returnPc),value,data,part);
      } else if dyn == 1 {
        state,part := DS.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,41,value);
        X.WidenTrace(code,DS.Destinations(returnPc),Destinations(returnPc),value,data,part);
      } else {
        state,part := SS.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,dyn,q,sum,end,childDyn,childWords,41,value);
        X.WidenTrace(code,SS.Destinations(returnPc),Destinations(returnPc),value,data,part);
      }
      assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
      sum := sum+childWords;if childDyn == 1 { dyn := 1; }index := index+1;
    }

  }
}
