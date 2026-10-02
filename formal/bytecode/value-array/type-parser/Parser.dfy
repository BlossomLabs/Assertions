// SPDX-License-Identifier: MIT
// Full finite successful recursive named/tuple parser through its actual return.
include "Bounds.dfy"
include "../tuple-initial/Initial.generated.dfy"
include "../tuple-continuations/CommaStatic.generated.dfy"
include "../tuple-continuations/CommaDynamic.generated.dfy"
include "../tuple-continuations/CloseStatic.generated.dfy"
include "../tuple-continuations/CloseParentDynamic.generated.dfy"
include "../tuple-continuations/CloseChildDynamic.generated.dfy"
module BytecodeCollectionsTypeParser {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import D = BytecodeCollectionsDecimalLoop
  import N = BytecodeCollectionsNamedParser
  import S = BytecodeCollectionsSuffixSemantics
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import C = BytecodeCollectionsSuffixChain
  import I = BytecodeCollectionsTupleInitial
  import CS = BytecodeCollectionsTupleCommaStatic
  import CD = BytecodeCollectionsTupleCommaDynamic
  import SS = BytecodeCollectionsTupleCloseStatic
  import DS = BytecodeCollectionsTupleCloseParentDynamic
  import DD = BytecodeCollectionsTupleCloseChildDynamic
  predicate Matches(code: seq<Byte>) {
    N.Matches(code) && C.Matches(code) && I.Matches(code) && CS.Matches(code) && CD.Matches(code) && SS.Matches(code) && DS.Matches(code) && DD.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    {13958}+N.Destinations(returnPc)+C.Destinations(returnPc)+I.Destinations()+CS.Destinations(returnPc)+CD.Destinations(returnPc)+SS.Destinations(returnPc)+DS.Destinations(returnPc)+DD.Destinations(returnPc)
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,tree: T.Descriptor,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires returnPc < |code| && code[returnPc] == 0x5b
    requires B.Syntax(data,offset,p,limit,tree) && T.StackFits(|prefix|,tree)
    ensures (B.Admission(data,offset,p,limit,tree); state == Running(returnPc,prefix+[tree.shape.pos,tree.shape.dynamic,tree.shape.span],mem))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
    decreases tree
  {
    B.Admission(data,offset,p,limit,tree);
    reveal Matches();
    if tree.Named? {
      var result: S.Shape;
      result,state,trace := N.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,tree.nameEnd,tree.suffixes,value);
      X.WidenTrace(code,N.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    } else {
      Z.FirstByte(data,offset+p);
      state,trace := I.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,40,value);
      X.WidenTrace(code,I.Destinations(),Destinations(returnPc),value,data,trace);
      reveal CS.Matches();assert 13958 < |code| && code[13958] == 0x5b;
      var children := tree.children;
      assert forall i :: 0 <= i < |children| ==> children[i].shape.span >= 1;
      assert forall i :: 0 <= i < |children| ==>
                           T.Start(p,children,i) < limit &&
                           B.Syntax(data,offset,T.Start(p,children,i),limit,children[i]) &&
                           T.Valid(data,offset,T.Start(p,children,i),limit,children[i]) &&
                           T.StackFits(|prefix|+13,children[i]) &&
                           S.Fits(children[i].shape,limit) && children[i].shape.pos < limit &&
                           D.DataByte(data,offset,children[i].shape.pos) == (if i+1 < |children| then 44 else 41);
      assert |prefix| <= 1004;
      assert T.Sum(children) < G.Modulus();
      assert S.Valid(data,offset,limit,T.Base(data,offset,p,tree),tree.suffixes);
      assert tree.shape == S.Final(data,offset,limit,T.Base(data,offset,p,tree),tree.suffixes);
      hide B.Syntax();hide T.Valid();hide T.StackFits();
      var index: nat := 0;var dyn: Word := 0;var sum: Word := 0;var q: Word := p+1;
      while index < |children|
        invariant 0 <= index <= |children| && |children| > 0
        invariant dyn == T.Flags(children[..index]) && sum == T.Sum(children[..index])
        invariant index < |children| ==> q == T.Start(p,children,index)
        invariant index < |children| ==> p < q < limit
        invariant state == (if index < |children| then Running(13839,prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0,13958,offset,length,q,limit],mem) else Running(14279,prefix+[returnPc,offset,length,p,limit,T.Base(data,offset,p,tree).pos,T.Base(data,offset,p,tree).dynamic,T.Base(data,offset,p,tree).span],mem))
        invariant E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
        decreases |children|-index
      {
        var child := children[index];
        var childPrefix := prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0];
        var before := state;var part: seq<State>;
        state,part := Run(code,data,mem,childPrefix,13958,offset,length,q,limit,child,value);
        X.WidenTrace(code,Destinations(13958),Destinations(returnPc),value,data,part);
        assert part[0] == before;
        X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
        var end: Word := child.shape.pos;var childDyn: Word := child.shape.dynamic;var childWords: Word := child.shape.span;
        T.Forward(data,offset,q,limit,child);
        assert q < end;
        T.SumPrefix(children,index+1);T.Extend(children,index);
        assert sum+childWords < G.Modulus();
        Z.FirstByte(data,offset+end);
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
      var result: S.Shape;var part: seq<State>;var before := state;
      result,state,part := C.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,T.Base(data,offset,p,tree),tree.suffixes,value);
      X.WidenTrace(code,C.Destinations(returnPc),Destinations(returnPc),value,data,part);
      assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    }
  }
}
