// SPDX-License-Identifier: MIT
// Exact [] physical suffix over arbitrary positive prior tuple footprint.
include "development/array-init-wide-v1/Character.dfy"
include "development/array-close-wide-v1/Character.dfy"
include "development/array-empty-finish-wide-v1/Character.dfy"
include "NameLoop.dfy"
module AssertionsNavigationArrayEmptyWide {
  import opened BytecodeScanMachine
  import I = AssertionsNavigationArrayInitWide
  import C = AssertionsNavigationArrayCloseWide
  import Z = AssertionsNavigationArrayEmptyFinishWide
  import E = AssertionsNavigationNameTrace
  import L = AssertionsNavigationNameLoop
  import H = AssertionsNavigationNameFrame
  predicate Admitted(offset: Word,length: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,prefix: seq<Word>,data: seq<Byte>) {
    p <= end && end+1 < limit <= length && dyn <= 1 && words >= 1 &&
    (offset as nat)+length <= |data| < 0x10000000000000000 && |prefix| <= 950 &&
    data[offset+end] == 91 && data[offset+end+1] == 93
  }
  predicate Matches(code: seq<Byte>) { I.Matches(code) && C.Matches(code) && Z.Matches(code) }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word) returns (trace: seq<State>)
    requires Admitted(offset,length,p,limit,end,dyn,words,prefix,data) && Matches(code)
    requires {3175,8882,8902,8919,8923,8955,8969,8980,9036,9047,9066,9081,9084,9105,9121,9147,9151,9184,9195,9204,17853,18062,19262,19279,19901} <= destinations
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8882,prefix+[ret,offset,length,p,limit,end,dyn,words],mem)
    ensures trace[|trace|-1] == Running(8882,prefix+[ret,offset,length,p,limit,end+2,1,1],mem)
    ensures forall i :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
  {
    trace := I.Run(code,destinations,ret,offset,length,p,limit,end,dyn,words,prefix,mem,data,value);
    var close := C.Run(code,destinations,ret,offset,length,p,limit,end,dyn,words,end+1,0,prefix,mem,data,value);
    E.Join(code,destinations,value,data,trace,close); L.JoinLocal(trace,close,code);
    trace := trace+close[1..];
    var finish := Z.Run(code,destinations,ret,offset,length,p,limit,end,dyn,words,end+1,0,prefix,mem,data,value);
    E.Join(code,destinations,value,data,trace,finish); L.JoinLocal(trace,finish,code);
    trace := trace+finish[1..];
  }
}
