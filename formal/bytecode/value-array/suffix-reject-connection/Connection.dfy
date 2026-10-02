// SPDX-License-Identifier: MIT
// Exact arbitrary invalid suffix from opening through complete error REVERT.
include "Semantics.dfy"
include "../shape-suffix-boundary/Open.generated.dfy"
include "../suffix-footprint/Empty.generated.dfy"
include "../suffix-footprint/Dynamic.generated.dfy"
include "../suffix-footprint/Static.generated.dfy"
include "../suffix-rejection/AtLimit.generated.dfy"
include "../suffix-rejection/WrongClose.generated.dfy"
include "../suffix-rejection/Wide.generated.dfy"
include "../suffix-rejection/Zero.generated.dfy"
module BytecodeCollectionsSuffixRejectConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import D = BytecodeCollectionsDecimalLoop
  import Q = BytecodeCollectionsSuffixRejectSemantics
  import W = BytecodeCollectionsSuffixFootprintScalar
  import O = BytecodeCollectionsShapeSuffixOpen
  import Empty = BytecodeCollectionsSuffixFootprintEmpty
  import Dynamic = BytecodeCollectionsSuffixFootprintDynamic
  import Static = BytecodeCollectionsSuffixFootprintStatic
  import AtLimit = BytecodeCollectionsSuffixRejectionAtLimit
  import WrongClose = BytecodeCollectionsSuffixRejectionWrongClose
  import Wide = BytecodeCollectionsSuffixRejectionWide
  import Zero = BytecodeCollectionsSuffixRejectionZero
  import H = BytecodeCollectionsDescriptorErrorMemory
  predicate Matches(code: seq<Byte>) {
    O.Matches(code) && D.Matches(code) && Empty.Matches(code) && Dynamic.Matches(code) && Static.Matches(code) &&
    AtLimit.Matches(code) && WrongClose.Matches(code) && Wide.Matches(code) && Zero.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    O.Destinations(returnPc)+D.Destinations(returnPc)+Empty.Destinations(returnPc)+Dynamic.Destinations(returnPc)+Static.Destinations(returnPc)+
    AtLimit.Destinations()+WrongClose.Destinations()+Wide.Destinations()+Zero.Destinations()
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,q: Word,k: Word,fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && descriptorOffset < 0x10000000000000000 && p < end < limit <= descriptorLength < 0x10000000000000000
    requires dyn <= 1 && words >= 1 && words <= 0xffffffff*(end-p) && (dyn == 0 || words == 1)
    requires D.DataByte(data,descriptorOffset,end) == 91
    requires Q.Witness(data,descriptorOffset,end+1,limit,q,k)
    requires (W.ProductFits(words,k,p,end); Q.Rejected(data,descriptorOffset,end,limit,dyn,words,q,k))
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures state == Reverted(H.Bytes(q))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14279,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words],mem) && trace[|trace|-1] == state
  {
    reveal Matches();W.ProductFits(words,k,p,end);
    Z.FirstByte(data,descriptorOffset+end);
    state,trace := O.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,91,value);
    X.WidenTrace(code,O.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    var before := state;var part: seq<State>;var actualQ: Word;var actualK: Word;
    actualQ,actualK,state,part := D.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,value);
    assert Q.ExecutionFacts(data,descriptorOffset,end+1,limit,actualQ,actualK);
    Q.Unique(data,descriptorOffset,end+1,limit,q,k,actualQ,actualK);
    assert part[0] == before;
    X.WidenTrace(code,D.Destinations(returnPc),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    before := state;
    if q == end+1 {
      assert k == 0;
      state,part := Empty.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,value);
      X.WidenTrace(code,Empty.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else if dyn == 1 {
      state,part := Dynamic.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,value);
      X.WidenTrace(code,Dynamic.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else {
      assert dyn == 0;
      state,part := Static.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,value);
      X.WidenTrace(code,Static.Destinations(returnPc),Destinations(returnPc),value,data,part);
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    var nextDyn := Q.UpdatedDynamic(end,q,dyn);var nextWords := Q.UpdatedWords(end,q,dyn,words,k);
    before := state;
    if q >= limit {
      state,part := AtLimit.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,nextDyn,nextWords,q,k,0,fp,value);
      X.WidenTrace(code,AtLimit.Destinations(),Destinations(returnPc),value,data,part);
    } else {
      var b := D.DataByte(data,descriptorOffset,q);Z.FirstByte(data,descriptorOffset+q);
      if b != 93 {
        state,part := WrongClose.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,nextDyn,nextWords,q,k,b,fp,value);
        X.WidenTrace(code,WrongClose.Destinations(),Destinations(returnPc),value,data,part);
      } else if k > Q.Max() || nextWords > Q.Max() {
        state,part := Wide.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,nextDyn,nextWords,q,k,b,fp,value);
        X.WidenTrace(code,Wide.Destinations(),Destinations(returnPc),value,data,part);
      } else {
        assert k == 0 && q != end+1;
        state,part := Zero.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,nextDyn,nextWords,q,k,b,fp,value);
        X.WidenTrace(code,Zero.Destinations(),Destinations(returnPc),value,data,part);
      }
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
