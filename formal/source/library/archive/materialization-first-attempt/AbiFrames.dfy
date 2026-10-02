// SPDX-License-Identifier: MIT
// Independent mathematical model. No Solidity/bytecode equivalence is claimed.
module AbiFrames {
  type Byte = x: int | 0 <= x < 256 witness 0

  function Pow256(n: nat): nat
    ensures Pow256(n) > 0
    decreases n
  { if n == 0 then 1 else 256 * Pow256(n - 1) }

  // Big-endian, fixed-width serialization. Fit is an explicit proof precondition.
  function NatBytes(n: nat, width: nat): seq<Byte>
    ensures |NatBytes(n, width)| == width
    decreases width
  { if width == 0 then [] else NatBytes(n / 256, width - 1) + [n % 256] }

  function ReadNat(bs: seq<Byte>): nat
    decreases |bs|
  { if |bs| == 0 then 0 else ReadNat(bs[..|bs|-1]) * 256 + bs[|bs|-1] }

  function Word(n: nat): seq<Byte> { NatBytes(n, 32) }

  lemma NatBytesRoundTrip(n: nat, width: nat)
    requires n < Pow256(width)
    ensures ReadNat(NatBytes(n, width)) == n
    decreases width
  {
    if width > 0 {
      assert n / 256 < Pow256(width - 1);
      NatBytesRoundTrip(n / 256, width - 1);
    }
  }

  // The reverse direction applies to arbitrary input bytes, not just output
  // previously constructed by NatBytes.
  lemma BytesNatRoundTrip(bs: seq<Byte>)
    ensures ReadNat(bs) < Pow256(|bs|)
    ensures NatBytes(ReadNat(bs), |bs|) == bs
    decreases |bs|
  {
    if |bs| > 0 {
      var prefix := bs[..|bs|-1];
      var last := bs[|bs|-1];
      BytesNatRoundTrip(prefix);
      assert ReadNat(bs) / 256 == ReadNat(prefix);
      assert ReadNat(bs) % 256 == last;
      assert bs == prefix + [last];
    }
  }

  function Padding(n: nat): nat
    ensures Padding(n) < 32
    ensures (n + Padding(n)) % 32 == 0
  { if n % 32 == 0 then 0 else 32 - n % 32 }

  function Zeros(n: nat): seq<Byte>
    ensures |Zeros(n)| == n
    ensures forall i :: 0 <= i < n ==> Zeros(n)[i] == 0
  { seq(n, i => 0) }

  function Padded(payload: seq<Byte>): seq<Byte>
  { payload + Zeros(Padding(|payload|)) }

  lemma PaddingLayout(payload: seq<Byte>)
    ensures |Padded(payload)| % 32 == 0
    ensures Padded(payload)[..|payload|] == payload
    ensures |payload| <= |Padded(payload)| < |payload| + 32
    ensures forall i :: |payload| <= i < |Padded(payload)| ==> Padded(payload)[i] == 0
  {}

  // data is a BODY for a dynamic piece, a complete encoding for a static piece.
  datatype Piece = Piece(dynamic: bool, data: seq<Byte>)

  predicate ValidPieces(ps: seq<Piece>) {
    forall i :: 0 <= i < |ps| ==> |ps[i].data| > 0 && |ps[i].data| % 32 == 0
  }

  function HeadSize(ps: seq<Piece>): nat
    decreases |ps|
  { if |ps| == 0 then 0 else (if ps[0].dynamic then 32 else |ps[0].data|) + HeadSize(ps[1..]) }

  function TailSize(ps: seq<Piece>): nat
    decreases |ps|
  { if |ps| == 0 then 0 else (if ps[0].dynamic then |ps[0].data| else 0) + TailSize(ps[1..]) }

  function Heads(ps: seq<Piece>, tail: nat): seq<Byte>
    decreases |ps|
  {
    if |ps| == 0 then []
    else if ps[0].dynamic then Word(tail) + Heads(ps[1..], tail + |ps[0].data|)
    else ps[0].data + Heads(ps[1..], tail)
  }

  function Tails(ps: seq<Piece>): seq<Byte>
    decreases |ps|
  { if |ps| == 0 then [] else (if ps[0].dynamic then ps[0].data else []) + Tails(ps[1..]) }

  function Frame(ps: seq<Piece>): seq<Byte>
  { Heads(ps, HeadSize(ps)) + Tails(ps) }

  lemma Sizes(ps: seq<Piece>, tail: nat)
    ensures |Heads(ps, tail)| == HeadSize(ps)
    ensures |Tails(ps)| == TailSize(ps)
    ensures |Frame(ps)| == HeadSize(ps) + TailSize(ps)
    decreases |ps|
  {
    if |ps| > 0 {
      Sizes(ps[1..], tail + (if ps[0].dynamic then |ps[0].data| else 0));
      Sizes(ps[1..], HeadSize(ps) + (if ps[0].dynamic then |ps[0].data| else 0));
    }
  }

  lemma SizesAppend(a: seq<Piece>, b: seq<Piece>)
    ensures HeadSize(a+b) == HeadSize(a) + HeadSize(b)
    ensures TailSize(a+b) == TailSize(a) + TailSize(b)
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0];
      assert (a+b)[1..] == a[1..]+b;
      SizesAppend(a[1..], b);
    } else { assert a == []; assert a+b == b; }
  }

  lemma HeadsAppend(a: seq<Piece>, b: seq<Piece>, tail: nat)
    ensures Heads(a+b, tail) == Heads(a, tail) + Heads(b, tail + TailSize(a))
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0];
      assert (a+b)[1..] == a[1..]+b;
      HeadsAppend(a[1..], b, tail + (if a[0].dynamic then |a[0].data| else 0));
    } else { assert a == []; assert a+b == b; }
  }

  lemma TailsAppend(a: seq<Piece>, b: seq<Piece>)
    ensures Tails(a+b) == Tails(a) + Tails(b)
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0];
      assert (a+b)[1..] == a[1..]+b;
      TailsAppend(a[1..], b);
    } else { assert a == []; assert a+b == b; }
  }

  lemma FrameAligned(ps: seq<Piece>)
    requires ValidPieces(ps)
    ensures HeadSize(ps) % 32 == 0
    ensures TailSize(ps) % 32 == 0
    ensures |Frame(ps)| % 32 == 0
    decreases |ps|
  {
    Sizes(ps, HeadSize(ps));
    if |ps| > 0 { FrameAligned(ps[1..]); }
  }

  lemma MinimumHead(ps: seq<Piece>)
    requires ValidPieces(ps)
    ensures 32 * |ps| <= HeadSize(ps)
    decreases |ps|
  {
    if |ps| > 0 {
      assert |ps[0].data| >= 32;
      MinimumHead(ps[1..]);
    }
  }

  // Pins actual encoded bytes, not merely an independently calculated offset.
  lemma ComponentLayout(ps: seq<Piece>, i: nat)
    requires i < |ps|
    ensures HeadSize(ps[..i]) + (if ps[i].dynamic then 32 else |ps[i].data|) <= |Frame(ps)|
    ensures ps[i].dynamic ==> HeadSize(ps)+TailSize(ps[..i])+|ps[i].data| <= |Frame(ps)|
    ensures ps[i].dynamic ==>
              Frame(ps)[HeadSize(ps[..i])..HeadSize(ps[..i])+32] == Word(HeadSize(ps) + TailSize(ps[..i]))
    ensures !ps[i].dynamic ==>
              Frame(ps)[HeadSize(ps[..i])..HeadSize(ps[..i])+|ps[i].data|] == ps[i].data
    ensures ps[i].dynamic ==>
              Frame(ps)[HeadSize(ps)+TailSize(ps[..i])..HeadSize(ps)+TailSize(ps[..i])+|ps[i].data|] == ps[i].data
  {
    assert ps == ps[..i] + ps[i..];
    SizesAppend(ps[..i], ps[i..]);
    HeadsAppend(ps[..i], ps[i..], HeadSize(ps));
    TailsAppend(ps[..i], ps[i..]);
    Sizes(ps, HeadSize(ps));
    Sizes(ps[..i], HeadSize(ps));
    Sizes(ps[i..], HeadSize(ps)+TailSize(ps[..i]));
    Sizes(ps[i+1..], HeadSize(ps)+TailSize(ps[..i])+(if ps[i].dynamic then |ps[i].data| else 0));
    assert ps[i..][0] == ps[i];
    assert ps[i..][1..] == ps[i+1..];
  }

  lemma TightOffsets(ps: seq<Piece>, i: nat)
    requires i < |ps| && ps[i].dynamic
    requires HeadSize(ps) + TailSize(ps) < Pow256(32)
    ensures HeadSize(ps[..i])+32 <= |Frame(ps)|
    ensures ReadNat(Frame(ps)[HeadSize(ps[..i])..HeadSize(ps[..i])+32])
         == HeadSize(ps) + TailSize(ps[..i])
    ensures HeadSize(ps) + TailSize(ps[..i+1])
         == HeadSize(ps) + TailSize(ps[..i]) + |ps[i].data|
  {
    ComponentLayout(ps, i);
    assert ps == ps[..i] + ps[i..];
    SizesAppend(ps[..i], ps[i..]);
    assert ps[..i+1] == ps[..i] + [ps[i]];
    SizesAppend(ps[..i], [ps[i]]);
    NatBytesRoundTrip(HeadSize(ps) + TailSize(ps[..i]), 32);
  }

  // Bodies are frame-relative: arbitrary surroundings do not change target bytes.
  lemma Relocation(ps: seq<Piece>, i: nat, prefix: seq<Byte>, suffix: seq<Byte>)
    requires i < |ps| && ps[i].dynamic
    requires HeadSize(ps) + TailSize(ps) < Pow256(32)
    ensures HeadSize(ps[..i])+32 <= |Frame(ps)|
    ensures HeadSize(ps)+TailSize(ps[..i])+|ps[i].data| <= |Frame(ps)|
    ensures (prefix+Frame(ps)+suffix)[|prefix|..|prefix|+|Frame(ps)|] == Frame(ps)
    ensures ReadNat((prefix+Frame(ps)+suffix)
                    [|prefix|+HeadSize(ps[..i])..|prefix|+HeadSize(ps[..i])+32])
         == HeadSize(ps)+TailSize(ps[..i])
    ensures (prefix+Frame(ps)+suffix)
            [|prefix|+HeadSize(ps)+TailSize(ps[..i])..|prefix|+HeadSize(ps)+TailSize(ps[..i])+|ps[i].data|]
         == ps[i].data
  {
    ComponentLayout(ps, i);
    TightOffsets(ps, i);
    var h := HeadSize(ps[..i]);
    var o := HeadSize(ps)+TailSize(ps[..i]);
    assert (prefix+Frame(ps)+suffix)[|prefix|+h..|prefix|+h+32] == Frame(ps)[h..h+32];
    assert (prefix+Frame(ps)+suffix)[|prefix|+o..|prefix|+o+|ps[i].data|] == Frame(ps)[o..o+|ps[i].data|];
  }
}
