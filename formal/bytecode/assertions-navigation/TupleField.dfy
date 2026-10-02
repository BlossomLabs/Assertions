// SPDX-License-Identifier: MIT
// Exact successful field merge, comma continuation, and tuple closure.
include "development/tuple-comma-v1/Character.dfy"
include "development/tuple-dynamic-comma-v1/Character.dfy"
include "development/tuple-close-v1/Character.dfy"
include "development/tuple-mixed-close-v1/Character.dfy"
include "development/tuple-dynamic-close-v1/Character.dfy"
module AssertionsNavigationTupleField {
  import opened BytecodeScanMachine
  import B = AssertionsByteMachine
  import H = AssertionsNavigationNameFrame
  import E = AssertionsNavigationNameTrace
  import C = AssertionsNavigationTupleComma
  import D = AssertionsNavigationTupleDynamicComma
  import S = AssertionsNavigationTupleClose
  import M = AssertionsNavigationTupleMixedClose
  import X = AssertionsNavigationTupleDynamicClose
  predicate Matches(code: seq<Byte>) { C.Matches(code) && D.Matches(code) && S.Matches(code) && M.Matches(code) && X.Matches(code) }
  predicate Admitted(ret: Word,offset: Word,length: Word,p: Word,limit: Word,q: Word,end: Word,dyn: Word,words: Word,sum: Word,childEnd: Word,childDyn: Word,childWords: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>) {
    p < q <= childEnd < limit <= length && dyn <= 1 && childDyn <= 1 &&
    (sum as nat)+childWords < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
    (offset as nat)+length <= |data| < 0x10000000000000000 && |prefix| <= 930 &&
    data[offset+childEnd] in {41,44}
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,q: Word,end: Word,dyn: Word,words: Word,sum: Word,childEnd: Word,childDyn: Word,childWords: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word) returns (trace: seq<State>)
    requires Matches(code) && Admitted(ret,offset,length,p,limit,q,end,dyn,words,sum,childEnd,childDyn,childWords,prefix,mem,data)
    requires {3175,8546,8578,8588,8625,8651,8662,8685,8696,8724,8735,8738,8882,17853} <= destinations
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8561,prefix+[ret,offset,length,p,limit,end,dyn,words,q,sum,0,0,0,childEnd,childDyn,childWords],mem)
    ensures data[offset+childEnd] == 44 ==> trace[|trace|-1] == Running(8546,prefix+[ret,offset,length,p,limit,end,(if childDyn==1 then 1 else dyn),words,childEnd+1,sum+childWords],mem)
    ensures data[offset+childEnd] == 41 ==> trace[|trace|-1] == Running(8882,prefix+[ret,offset,length,p,limit,childEnd+1,(if childDyn==1 then 1 else dyn),(if childDyn==1 || dyn==1 then 1 else sum+childWords)],mem)
    ensures forall k {:trigger trace[k]} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
  {
    if data[offset+childEnd] == 44 {
      if childDyn == 0 { trace := C.Run(code,destinations,ret,offset,length,p,limit,q,end,dyn,words,sum,childEnd,childDyn,childWords,prefix,mem,data,value); }
      else { trace := D.Run(code,destinations,ret,offset,length,p,limit,q,end,dyn,words,sum,childEnd,childDyn,childWords,prefix,mem,data,value); }
    } else if childDyn == 1 { trace := X.Run(code,destinations,ret,offset,length,p,limit,q,end,dyn,words,sum,childEnd,childDyn,childWords,prefix,mem,data,value); }
    else if dyn == 1 { trace := M.Run(code,destinations,ret,offset,length,p,limit,q,end,dyn,words,sum,childEnd,childDyn,childWords,prefix,mem,data,value); }
    else { trace := S.Run(code,destinations,ret,offset,length,p,limit,q,end,dyn,words,sum,childEnd,childDyn,childWords,prefix,mem,data,value); }
  }
}
