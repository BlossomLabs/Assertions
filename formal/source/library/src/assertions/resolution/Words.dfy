// SPDX-License-Identifier: MIT
include "../constraints/Model.dfy"
include "../../abi/Frames.dfy"
module ResolutionWords {
  import opened ConstraintModel
  import Frames = AbiFrames

  function Limit(): nat { 0x10000000000000000000000000000000000000000000000000000000000000000 }
  function AddressLimit(): nat { 0x10000000000000000000000000000000000000000 }

  lemma {:fuel Frames.Pow256, 34} PowerConstants()
    ensures Frames.Pow256(32) == Limit()
    ensures Frames.Pow256(20) == AddressLimit()
  {}

  lemma PowerMonotone(a: nat, b: nat)
    requires a <= b
    ensures Frames.Pow256(a) <= Frames.Pow256(b)
    decreases b-a
  {
    if a < b { PowerMonotone(a,b-1); }
  }

  lemma ReadBridge(data: seq<Byte>)
    requires |data| <= 32
    ensures Read(data) == Frames.ReadNat(data)
    ensures Read(data) < Frames.Pow256(|data|)
    decreases |data|
  {
    reveal Read();
    PowerConstants();
    PowerMonotone(|data|,32);
    Frames.BytesNatRoundTrip(data);
    if |data| > 0 { ReadBridge(data[..|data|-1]); }
  }

  function EncodeWord(w: Word): seq<Byte>
    ensures |EncodeWord(w)| == 32
  { Frames.Word(w) }

  lemma EncodedWord(w: Word)
    ensures Read(EncodeWord(w)) == w
    ensures |EncodeWord(w)| == 32
  {
    PowerConstants();
    Frames.NatBytesRoundTrip(w,32);
    ReadBridge(EncodeWord(w));
  }

  function PackedAddress(data: seq<Byte>): nat
    requires |data| == 20
  { Read(data) }

  lemma AddressFits(data: seq<Byte>)
    requires |data| == 20
    ensures PackedAddress(data) < AddressLimit()
  { ReadBridge(data); PowerConstants(); }
}
