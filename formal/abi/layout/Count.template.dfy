// SPDX-License-Identifier: MIT
// Source-derived tupleLayout pre-scan; Solidity SHA256: $HASH
include "Scan.dfy"

module AbiLayoutCountSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiSuffixSemantics
  import opened AbiLayoutScan

  ghost method Open(depth: nat) returns (next: nat)
    requires Uint(depth+1)
    ensures next == depth+1
  { next := $OPEN; }

  ghost method Close(depth: nat) returns (next: nat)
    requires Uint(depth) && depth > 0
    ensures next == depth-1
  {
    assert 0 <= depth-1 < Limit();
    NoWrap(depth-1);
    next := $CLOSE;
  }

  ghost method Comma(count: nat) returns (next: nat)
    requires Uint(count+1)
    ensures next == count+1
  { next := $COMMA; }

  ghost method Advance(i: nat) returns (next: nat)
    requires Uint(i+1)
    ensures next == i+1
  { next := $ADVANCE; }

  ghost method Count(t: seq<Byte>) returns (r: ScanResult)
    requires Uint(|t|) && |t| >= 2
    ensures r == Scan(t,1,|t|-1,0,1)
    ensures r.Counted? ==> 0 < r.count < |t| && r.depth <= |t|-2
  {
    var limit := |t|-1;
    var count: nat := 1;
    var depth: nat := 0;
    var i: nat := 1;
    while i < limit
      invariant 1 <= i <= limit && depth <= i-1 && 1 <= count <= i
      invariant Scan(t,1,limit,0,1) == Scan(t,i,limit,depth,count)
      decreases limit-i
    {
      Step(t,i,limit,depth,count);
      var c := t[i];
      if c == 40 { depth := Open(depth); }
      else if c == 41 {
        // Source records stray=i, forces loop exit and later reverts. The
        // subsequent wrapped decrement is unobservable on that error path.
        if depth == 0 { r := Stray(i); return; }
        depth := Close(depth);
      } else if c == 44 && depth == 0 { count := Comma(count); }
      i := Advance(i);
    }
    Empty(t,limit,depth,count);
    r := Counted(depth,count);
  }
}
