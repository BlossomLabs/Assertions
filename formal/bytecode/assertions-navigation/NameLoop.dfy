// SPDX-License-Identifier: MIT
// Arbitrary-length physical scanName, including empty and nonstandard names.
include "NameInit.dfy"
include "development/name-character-v3/Character.dfy"
include "development/name-exit-v1/Character.dfy"
include "development/name-limit-v1/Character.dfy"
module AssertionsNavigationNameLoop {
  import opened BytecodeScanMachine
  import N = AssertionsNavigationName
  import I = AssertionsNavigationNameInit
  import C = AssertionsNavigationNameCharacter
  import X = AssertionsNavigationNameExit
  import L = AssertionsNavigationNameLimit
  import E = AssertionsNavigationNameTrace
  import H = AssertionsNavigationNameFrame
  type Bytes = seq<Byte>
  predicate Admitted(data: Bytes,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>) {
    p <= limit <= length && (offset as nat)+length <= |data| < 0x10000000000000000 && |prefix| <= 980
  }
  lemma JoinLocal(left: seq<State>,right: seq<State>,code: Bytes)
    requires |left| > 0 && |right| > 0 && left[|left|-1] == right[0]
    requires forall k {:trigger left[k]} :: 0 <= k < |left|-1 ==> H.Local(code,left[k])
    requires forall k {:trigger right[k]} :: 0 <= k < |right|-1 ==> H.Local(code,right[k])
    ensures forall k {:trigger (left+right[1..])[k]} :: 0 <= k < |left+right[1..]|-1 ==> H.Local(code,(left+right[1..])[k])
  {
    forall k {:trigger (left+right[1..])[k]} | 0 <= k < |left+right[1..]|-1
      ensures H.Local(code,(left+right[1..])[k])
    {
      if k < |left|-1 { assert (left+right[1..])[k] == left[k]; }
      else {
        var n := k-(|left|-1);
        assert 0 <= n < |right|-1;
        assert (left+right[1..])[k] == right[n];
      }
    }
  }
  ghost method Run(code: Bytes,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,prefix: seq<Word>,mem: Bytes,data: Bytes,value: Word) returns (q: Word,trace: seq<State>)
    requires Admitted(data,offset,length,p,limit,prefix)
    requires I.Matches(code) && C.Matches(code) && X.Matches(code) && L.Matches(code)
    requires {3967,12522,12565} <= destinations
    requires ret in destinations && ret < |code| && code[ret] == 91
    ensures p <= q <= limit
    ensures offset+q == N.End(data,offset+p,offset+limit)
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(12520,prefix+[ret,offset,length,p,limit],mem)
    ensures trace[|trace|-1] == Running(ret,prefix+[q],mem)
    ensures forall k {:trigger trace[k]} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
  {
    trace := I.Run(code,destinations,ret,offset,length,p,limit,prefix,mem,data,value);
    q := p;
    while q < limit && N.Character(data[offset+q])
      invariant p <= q <= limit
      invariant N.Prefix(data,offset+p,offset+q,offset+limit)
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(12520,prefix+[ret,offset,length,p,limit],mem)
      invariant trace[|trace|-1] == Running(12522,prefix+[ret,offset,length,p,limit,q],mem)
      invariant forall k {:trigger trace[k]} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
      decreases limit-q
    {
      assert C.Admitted(ret,offset,length,p,limit,q,prefix,mem,data);
      var segment := C.Run(code,destinations,ret,offset,length,p,limit,q,prefix,mem,data,value);
      E.Join(code,destinations,value,data,trace,segment);
      JoinLocal(trace,segment,code);
      N.Advance(data,offset+p,offset+q,offset+limit);
      trace := trace+segment[1..]; q := q+1;
    }
    N.Unique(data,offset+p,offset+q,offset+limit);
    var tail: seq<State>;
    if q == limit {
      assert L.Admitted(ret,offset,length,p,limit,q,prefix,mem,data);
      tail := L.Run(code,destinations,ret,offset,length,p,limit,q,prefix,mem,data,value);
    } else {
      assert X.Admitted(ret,offset,length,p,limit,q,prefix,mem,data);
      tail := X.Run(code,destinations,ret,offset,length,p,limit,q,prefix,mem,data,value);
    }
    E.Join(code,destinations,value,data,trace,tail);
    JoinLocal(trace,tail,code);
    trace := trace+tail[1..];
  }
}
