// SPDX-License-Identifier: MIT
include "../word-memory/Connection.dfy"
module CollectionsWordLayoutModel {
  import opened AbiFrames
  import Mem = CollectionsWordMemoryModel
  datatype Kind = Iota | Reverse | Zip | Unzip
  datatype Config = Config(kind: Kind,n: nat,a: seq<Byte>,b: seq<Byte>,lane: nat)
  datatype Outcome = Returned(values: seq<nat>) | Failed(reason: seq<Byte>)
  predicate Basic(k: Config) { Mem.Fits(k.n) && Mem.Fits(|k.a|) && Mem.Fits(|k.b|) && Mem.Fits(k.lane) }
  predicate Aligned(s: seq<Byte>) { |s| % 32 == 0 }
  function Count(s: seq<Byte>): nat { |s|/32 }
  function Element(s: seq<Byte>,i: nat): nat
    requires i < Count(s)
  { ReadNat(s[32*i..32*i+32]) }
  function LaneCount(count: nat,lane: nat): nat { if lane == 0 then (count+1)/2 else count/2 }
  function Values(k: Config): seq<nat>
    requires k.kind == Zip ==> |k.a| == |k.b|
    requires k.kind == Unzip ==> k.lane <= 1
  {
    if k.kind == Iota then seq<nat>(k.n,i requires 0 <= i < k.n => i as nat) else
    if k.kind == Reverse then seq<nat>(Count(k.a),i requires 0 <= i < Count(k.a) => Element(k.a,Count(k.a)-1-i)) else
    if k.kind == Zip then seq<nat>(2*Count(k.a),i requires 0 <= i < 2*Count(k.a) => if i%2 == 0 then Element(k.a,i/2) else Element(k.b,i/2)) else
    seq<nat>(LaneCount(Count(k.a),k.lane),i requires 0 <= i < LaneCount(Count(k.a),k.lane) => Element(k.a,2*i+k.lane))
  }
  function Zero(n: nat): seq<Byte> { seq(n,i => 0 as Byte) }
  function Bytes(values: seq<nat>): seq<Byte>
    decreases |values|
  { if |values| == 0 then [] else Word(values[0])+Bytes(values[1..]) }
  function Panic(): seq<Byte> { [78,72,123,113]+Word(17) }
  predicate Admitted(k: Config) {
    if k.kind == Iota then 32*k.n < Pow256(32) else
    Aligned(k.a) && (k.kind != Zip || (Aligned(k.b) && |k.a| == |k.b| && 2*|k.a| < Pow256(32))) &&
    (k.kind != Unzip || k.lane <= 1)
  }
  function Size(k: Config): nat {
    if k.kind == Iota then 32*k.n else if k.kind == Reverse then |k.a| else
    if k.kind == Zip then 2*|k.a| else 32*LaneCount(Count(k.a),k.lane)
  }
  predicate Budget(k: Config,memory: seq<Byte>,base: nat) {
    Admitted(k) ==> Mem.Fits(|memory|) && Mem.Frame(memory,base,Zero(Size(k)))
  }
}
