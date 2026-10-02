// SPDX-License-Identifier: MIT
// Complete physical single static fixed-array suffix, including leading zeroes.
include "ArrayNumber.dfy"
include "development/array-init-v1/Character.dfy"
include "development/array-static-finish-v1/Character.dfy"
module AssertionsNavigationArrayFixedSuffix {
  import opened BytecodeScanMachine
  import N = AssertionsNavigationArrayDecimal
  import I = AssertionsNavigationArrayInit
  import D = AssertionsNavigationArrayDigit
  import C = AssertionsNavigationArrayClose
  import L = AssertionsNavigationNameLoop
  import A = AssertionsNavigationArrayNumber
  import F = AssertionsNavigationArrayStaticFinish
  import V = AssertionsNavigationArraySizeMath
  import E = AssertionsNavigationNameTrace
  import H = AssertionsNavigationNameFrame
  predicate Admitted(offset: Word,length: Word,p: Word,limit: Word,end: Word,words: Word,stop: Word,prefix: seq<Word>,data: seq<Byte>) {
    p <= end && end+1 < stop < limit <= length &&
    (offset as nat)+length <= |data| < 0x10000000000000000 && |prefix| <= 950 &&
    data[offset+end] == 91 && data[offset+stop] == 93 &&
    N.Digits(data,offset+end+1,offset+stop) && 1 <= words <= 4294967295 &&
    1 <= N.Number(data,offset+end+1,offset+stop,0) <= 4294967295 &&
    words*N.Number(data,offset+end+1,offset+stop,0) <= 4294967295
  }
  predicate Matches(code: seq<Byte>) {
    I.Matches(code) && D.Matches(code) && C.Matches(code) && F.Matches(code)
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,end: Word,words: Word,stop: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word) returns (count: Word,trace: seq<State>)
    requires Admitted(offset,length,p,limit,end,words,stop,prefix,data) && Matches(code)
    requires {3175,8882,8902,8919,8923,8955,8969,8980,8991,9005,9015,9027,9036,9047,9066,9081,9084,9105,9121,9151,9184,9195,9204,17853,18062,19262,19279,19901} <= destinations
    ensures count == N.Number(data,offset+end+1,offset+stop,0)
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8882,prefix+[ret,offset,length,p,limit,end,0,words],mem)
    ensures trace[|trace|-1] == Running(8882,prefix+[ret,offset,length,p,limit,stop+1,0,V.Product(words,count)],mem)
    ensures V.Product(words,count) == words*count
    ensures forall i {:trigger trace[i]} :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
  {
    trace := I.Run(code,destinations,ret,offset,length,p,limit,end,0,words,prefix,mem,data,value);
    assert A.Admitted(ret,offset,length,p,limit,end,0,words,end+1,0,stop,prefix,data);
    var digits: seq<State>;
    count,digits := A.Run(code,destinations,ret,offset,length,p,limit,end,0,words,end+1,0,stop,prefix,mem,data,value);
    E.Join(code,destinations,value,data,trace,digits);
    L.JoinLocal(trace,digits,code);
    trace := trace+digits[1..];
    V.ProductNatural(words,count);
    assert F.Admitted(ret,offset,length,p,limit,end,0,words,stop,count,prefix,mem,data);
    var finish := F.Run(code,destinations,ret,offset,length,p,limit,end,0,words,stop,count,prefix,mem,data,value);
    E.Join(code,destinations,value,data,trace,finish);
    L.JoinLocal(trace,finish,code);
    trace := trace+finish[1..];
  }
}
