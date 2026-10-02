// SPDX-License-Identifier: MIT
// Exact arbitrary valid suffix, bound to independent complete digit-span semantics.
include "Number.dfy"
include "../shape-suffix-boundary/Open.generated.dfy"
include "../suffix-close/Empty.generated.dfy"
include "../suffix-close/Dynamic.generated.dfy"
include "../suffix-close/Static.generated.dfy"
module BytecodeCollectionsSuffixConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import Z = BytecodeCollectionsArrayByteScalar
  import D = BytecodeCollectionsDecimalLoop
  import N = BytecodeCollectionsDecimalNumber
  import O = BytecodeCollectionsShapeSuffixOpen
  import Empty = BytecodeCollectionsSuffixCloseEmpty
  import Dynamic = BytecodeCollectionsSuffixCloseDynamic
  import Static = BytecodeCollectionsSuffixCloseStatic
  predicate Matches(code: seq<Byte>) {
    O.Matches(code) && D.Matches(code) && Empty.Matches(code) && Dynamic.Matches(code) && Static.Matches(code)
  }
  function Destinations(returnPc: Word): set<nat> {
    O.Destinations(returnPc)+D.Destinations(returnPc)+Empty.Destinations(returnPc)+Dynamic.Destinations(returnPc)+Static.Destinations(returnPc)
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,descriptorOffset: Word,descriptorLength: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,digitEnd: Word,value: Word) returns (k: Word,state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= 1004 && descriptorOffset < 0x10000000000000000 && end+1 <= digitEnd < limit <= descriptorLength < 0x10000000000000000
    requires dyn <= 1 && words >= 1 && (dyn == 0 || words == 1)
    requires D.DataByte(data,descriptorOffset,end) == 91 && D.DataByte(data,descriptorOffset,digitEnd) == 93
    requires forall i {:trigger D.DataByte(data,descriptorOffset,i)} :: end+1 <= i < digitEnd ==> D.Digit(D.DataByte(data,descriptorOffset,i))
    requires 0 <= D.Number(data,descriptorOffset,end+1,digitEnd) <= 0xffffffff
    requires digitEnd > end+1 ==> D.Number(data,descriptorOffset,end+1,digitEnd) >= 1
    requires dyn == 0 && digitEnd > end+1 ==> words*D.Number(data,descriptorOffset,end+1,digitEnd) <= 0xffffffff
    ensures k == D.Number(data,descriptorOffset,end+1,digitEnd)
    ensures state == Running(14279,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,digitEnd+1,if digitEnd == end+1 then 1 else dyn,if digitEnd == end+1 then 1 else if dyn == 1 then words else words*k],mem)
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(14279,prefix+[returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words],mem) && trace[|trace|-1] == state
  {
    reveal Matches();
    Z.FirstByte(data,descriptorOffset+end);
    state,trace := O.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,91,value);
    X.WidenTrace(code,O.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    var before := state;
    var part: seq<State>;
    var q: Word;
    q,k,state,part := D.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,value);
    assert part[0] == before;
    X.WidenTrace(code,D.Destinations(returnPc),Destinations(returnPc),value,data,part);
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    if q > digitEnd {
      assert end+1 <= digitEnd < q;
      assert D.Digit(D.DataByte(data,descriptorOffset,digitEnd));
      assert false;
    }
    assert q <= digitEnd;
    N.PrefixBound(data,descriptorOffset,end+1,q,digitEnd);
    assert k <= 0xffffffff;
    if q < digitEnd {
      assert q < limit && D.Digit(D.DataByte(data,descriptorOffset,q));
      assert false;
    }
    assert q == digitEnd && k == D.Number(data,descriptorOffset,end+1,digitEnd);
    Z.FirstByte(data,descriptorOffset+q);
    before := state;
    if digitEnd == end+1 {
      assert k == 0;
      state,part := Empty.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,93,value);
      X.WidenTrace(code,Empty.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else if dyn == 1 {
      state,part := Dynamic.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,93,value);
      X.WidenTrace(code,Dynamic.Destinations(returnPc),Destinations(returnPc),value,data,part);
    } else {
      assert dyn == 0 && words*k <= 0xffffffff;
      state,part := Static.Run(code,data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,93,value);
      X.WidenTrace(code,Static.Destinations(returnPc),Destinations(returnPc),value,data,part);
    }
    assert part[0] == before;
    X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
  }
}
