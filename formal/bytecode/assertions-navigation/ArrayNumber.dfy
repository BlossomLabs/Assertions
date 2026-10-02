// SPDX-License-Identifier: MIT
// Arbitrary-length physical decimal array-size scan through its closing bracket.
include "ArrayDecimal.dfy"
include "NameLoop.dfy"
include "development/array-digit-v1/Character.dfy"
include "development/array-close-v1/Character.dfy"
module AssertionsNavigationArrayNumber {
  import opened BytecodeScanMachine
  import N = AssertionsNavigationArrayDecimal
  import D = AssertionsNavigationArrayDigit
  import C = AssertionsNavigationArrayClose
  import L = AssertionsNavigationNameLoop
  import E = AssertionsNavigationNameTrace
  import H = AssertionsNavigationNameFrame
  predicate Admitted(ret: Word,offset: Word,length: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,q: Word,k: Word,stop: Word,prefix: seq<Word>,data: seq<Byte>) {
    p <= end < q <= stop < limit <= length &&
    (offset as nat)+length <= |data| < 0x10000000000000000 &&
    dyn <= 1 && words <= 4294967295 && |prefix| <= 950 &&
    N.Digits(data,offset+q,offset+stop) &&
    N.Number(data,offset+q,offset+stop,k) <= 4294967295 && data[offset+stop] == 93
  }
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,q: Word,k: Word,stop: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word) returns (number: Word,trace: seq<State>)
    requires Admitted(ret,offset,length,p,limit,end,dyn,words,q,k,stop,prefix,data)
    requires D.Matches(code) && C.Matches(code)
    requires {3175,8923,8955,8969,8980,8991,9005,9015,9027,9036,9047,17853,18062,19262,19279,19901} <= destinations
    ensures number == N.Number(data,offset+q,offset+stop,k)
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8923,prefix+[ret,offset,length,p,limit,end,dyn,words,q,k],mem)
    ensures trace[|trace|-1] == Running(9047,prefix+[ret,offset,length,p,limit,end,dyn,words,stop,number,end+1],mem)
    ensures forall i {:trigger trace[i]} :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
  {
    var current := q;
    number := k;
    N.Monotone(data,offset+q,offset+stop,k);
    trace := [Running(8923,prefix+[ret,offset,length,p,limit,end,dyn,words,current,number],mem)];
    while current < stop
      invariant q <= current <= stop
      invariant N.Digits(data,offset+current,offset+stop)
      invariant N.Number(data,offset+current,offset+stop,number) == N.Number(data,offset+q,offset+stop,k)
      invariant number <= 4294967295
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(8923,prefix+[ret,offset,length,p,limit,end,dyn,words,q,k],mem)
      invariant trace[|trace|-1] == Running(8923,prefix+[ret,offset,length,p,limit,end,dyn,words,current,number],mem)
      invariant forall i {:trigger trace[i]} :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
      decreases stop-current
    {
      N.Advance(data,offset+current,offset+stop,number);
      assert D.Admitted(ret,offset,length,p,limit,end,dyn,words,current,number,prefix,mem,data);
      var segment := D.Run(code,destinations,ret,offset,length,p,limit,end,dyn,words,current,number,prefix,mem,data,value);
      E.Join(code,destinations,value,data,trace,segment);
      L.JoinLocal(trace,segment,code);
      trace := trace+segment[1..];
      number := number*10+data[offset+current]-48;
      current := current+1;
    }
    assert number == N.Number(data,offset+q,offset+stop,k);
    assert C.Admitted(ret,offset,length,p,limit,end,dyn,words,stop,number,prefix,mem,data);
    var tail := C.Run(code,destinations,ret,offset,length,p,limit,end,dyn,words,stop,number,prefix,mem,data,value);
    E.Join(code,destinations,value,data,trace,tail);
    L.JoinLocal(trace,tail,code);
    trace := trace+tail[1..];
  }
}
