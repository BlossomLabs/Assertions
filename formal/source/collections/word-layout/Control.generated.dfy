// SPDX-License-Identifier: MIT
// Generated from all four complete public compiler ASTs.
include "Model.dfy"
module CollectionsWordLayoutControl {
  import opened AbiFrames
  import Mem = CollectionsWordMemoryModel
  function Sub(a: nat,b: nat): nat { (a+Pow256(32)-(b%Pow256(32)))%Pow256(32) }
  function IotaBytes(n: nat): nat { (n * 32) }
  function IotaLoop(i: nat,n: nat): bool { (i < n) }
  function IotaValue(i: nat): nat { i }
  function ReverseUnaligned(length: nat): bool { ((length % 32) != 0) }
  function ReverseCount(length: nat): nat { (length / 32) }
  function ReverseLoop(i: nat,count: nat): bool { (i < count) }
  function ReverseAddress(base: nat,count: nat,i: nat): nat { Mem.Add(Mem.Add(base,32),Mem.Mul(Sub(Sub(count,1),i),32)) }
  function ZipAUnaligned(aLength: nat): bool { ((aLength % 32) != 0) }
  function ZipBUnaligned(bLength: nat): bool { ((bLength % 32) != 0) }
  function ZipMismatch(aLength: nat,bLength: nat): bool { (aLength != bLength) }
  function ZipCount(aLength: nat): nat { (aLength / 32) }
  function ZipBytes(aLength: nat): nat { (aLength * 2) }
  function ZipLoop(i: nat,count: nat): bool { (i < count) }
  function ZipLeftAddress(base: nat,i: nat): nat { Mem.Add(Mem.Add(base,32),Mem.Mul(Mem.Mul(i,2),32)) }
  function ZipRightAddress(base: nat,i: nat): nat { Mem.Add(Mem.Add(base,32),Mem.Mul(Mem.Add(Mem.Mul(i,2),1),32)) }
  function UnzipUnaligned(length: nat): bool { ((length % 32) != 0) }
  function UnzipInvalid(lane: nat): bool { (lane > 1) }
  function UnzipCount(length: nat): nat { (length / 32) }
  function UnzipLaneCount(count: nat,lane: nat): nat { (if (lane == 0) then (((count + 1)) / 2) else (count / 2)) }
  function UnzipBytes(laneCount: nat): nat { (laneCount * 32) }
  function UnzipLoop(i: nat,laneCount: nat): bool { (i < laneCount) }
  function UnzipAddress(base: nat,i: nat): nat { Mem.Add(Mem.Add(base,32),Mem.Mul(i,32)) }
  function UnalignedSelector(): seq<Byte> { [169, 73, 210, 133] }
  function MismatchSelector(): seq<Byte> { [27, 16, 99, 106] }
  function InvalidLaneSelector(): seq<Byte> { [28, 19, 56, 3] }
}
