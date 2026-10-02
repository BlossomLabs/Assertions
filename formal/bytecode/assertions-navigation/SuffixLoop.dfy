// SPDX-License-Identifier: MIT
// Arbitrary-length physical suffix scanner for a valid bracketed descriptor tail.
include "Suffix.dfy"
include "development/suffix-init-v1/Init.dfy"
include "development/suffix-digit-v6/Digit.dfy"
include "development/suffix-exit-v6/Exit.dfy"
module AssertionsNavigationSuffixLoop {
  import opened BytecodeScanMachine
  import T = AssertionsNavigationSuffix
  import A = AssertionsNavigationSuffixInit
  import D = AssertionsNavigationSuffixDigit
  import X = AssertionsNavigationSuffixExit
  import E = BytecodeScanExecution
  import H = AssertionsNavigationFrame
  type Bytes = seq<Byte>
  predicate Admitted(data: Bytes,offset: Word,length: Word,ts: Word,te: Word,opening: Word,prefix: seq<Word>) {
    (offset as nat)+length <= |data| < 0x10000000000000000 &&
    ts < opening && te <= length && |prefix| <= 980 &&
    T.Suffix(data[offset..offset+length],ts,te,opening)
  }
  lemma DigitAdmission(ret: Word,offset: Word,length: Word,ts: Word,te: Word,opening: Word,j: Word,prefix: seq<Word>,mem: Bytes,data: Bytes)
    requires Admitted(data,offset,length,ts,te,opening,prefix)
    requires opening < j <= te-2
    ensures D.Admitted(ret,offset,length,ts,te,j,prefix,mem,data)
  {
    var descriptor := data[offset..offset+length];
    assert descriptor[j] == data[offset+j];
    assert T.Digit(descriptor[j]);
  }
  lemma ExitAdmission(ret: Word,offset: Word,length: Word,ts: Word,te: Word,opening: Word,prefix: seq<Word>,mem: Bytes,data: Bytes)
    requires Admitted(data,offset,length,ts,te,opening,prefix)
    ensures X.Admitted(ret,offset,length,ts,te,opening,prefix,mem,data)
  {
    var descriptor := data[offset..offset+length];
    assert descriptor[opening] == data[offset+opening];
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
  ghost method Run(code: Bytes,destinations: set<nat>,ret: Word,offset: Word,length: Word,ts: Word,te: Word,opening: Word,prefix: seq<Word>,mem: Bytes,data: Bytes,value: Word) returns (state: State,trace: seq<State>)
    requires Admitted(data,offset,length,ts,te,opening,prefix)
    requires A.Matches(code) && D.Matches(code) && X.Matches(code)
    requires {3175,8231,17922,8234,8267,8290,8320,8343,8358,8366,19880,19894,8384,3967} <= destinations
    requires ret in destinations && ret < |code| && code[ret] == 91
    ensures state == Running(ret,prefix+[opening],mem)
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8219,prefix+[ret,offset,length,ts,te],mem) && trace[|trace|-1] == state
    ensures forall k {:trigger trace[k]} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
  {
    state,trace := A.Run(code,destinations,ret,offset,length,ts,te,prefix,mem,value,data);
    var j: Word := te-2;
    while j > opening
      invariant opening <= j <= te-2
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(8219,prefix+[ret,offset,length,ts,te],mem) && trace[|trace|-1] == state
      invariant state == Running(8234,prefix+[ret,offset,length,ts,te,j],mem)
      invariant forall k {:trigger trace[k]} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
      decreases j-opening
    {
      DigitAdmission(ret,offset,length,ts,te,opening,j,prefix,mem,data);
      var next,segment := D.Run(code,destinations,ret,offset,length,ts,te,j,prefix,mem,data,value);
      E.Join(code,destinations,value,data,trace,segment);
      JoinLocal(trace,segment,code);
      trace := trace+segment[1..];state := next;j := j-1;
    }
    ExitAdmission(ret,offset,length,ts,te,opening,prefix,mem,data);
    var last,tail := X.Run(code,destinations,ret,offset,length,ts,te,opening,prefix,mem,data,value);
    E.Join(code,destinations,value,data,trace,tail);
    JoinLocal(trace,tail,code);
    trace := trace+tail[1..];state := last;
  }
}
