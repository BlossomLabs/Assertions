// SPDX-License-Identifier: MIT
// Generated from all four complete public compiler ASTs.
include "Model.dfy"
module CollectionsWordLayoutControl {
  import opened AbiFrames
  import Mem = CollectionsWordMemoryModel
  function Sub(a: nat,b: nat): nat { (a+Pow256(32)-(b%Pow256(32)))%Pow256(32) }
  function IotaBytes(n: nat): nat { $IOTA_BYTES$ }
  function IotaLoop(i: nat,n: nat): bool { $IOTA_LOOP$ }
  function IotaValue(i: nat): nat { $IOTA_VALUE$ }
  function ReverseUnaligned(length: nat): bool { $R_ALIGNMENT$ }
  function ReverseCount(length: nat): nat { $R_COUNT$ }
  function ReverseLoop(i: nat,count: nat): bool { $R_LOOP$ }
  function ReverseAddress(base: nat,count: nat,i: nat): nat { $R_ADDRESS$ }
  function ZipAUnaligned(aLength: nat): bool { $Z_A_ALIGNMENT$ }
  function ZipBUnaligned(bLength: nat): bool { $Z_B_ALIGNMENT$ }
  function ZipMismatch(aLength: nat,bLength: nat): bool { $Z_MISMATCH$ }
  function ZipCount(aLength: nat): nat { $Z_COUNT$ }
  function ZipBytes(aLength: nat): nat { $Z_BYTES$ }
  function ZipLoop(i: nat,count: nat): bool { $Z_LOOP$ }
  function ZipLeftAddress(base: nat,i: nat): nat { $Z_LEFT_ADDRESS$ }
  function ZipRightAddress(base: nat,i: nat): nat { $Z_RIGHT_ADDRESS$ }
  function UnzipUnaligned(length: nat): bool { $U_ALIGNMENT$ }
  function UnzipInvalid(lane: nat): bool { $U_INVALID$ }
  function UnzipCount(length: nat): nat { $U_COUNT$ }
  function UnzipLaneCount(count: nat,lane: nat): nat { $U_LANE_COUNT$ }
  function UnzipBytes(laneCount: nat): nat { $U_BYTES$ }
  function UnzipLoop(i: nat,laneCount: nat): bool { $U_LOOP$ }
  function UnzipAddress(base: nat,i: nat): nat { $U_ADDRESS$ }
  function UnalignedSelector(): seq<Byte> { $UnalignedWords$ }
  function MismatchSelector(): seq<Byte> { $WordCountMismatch$ }
  function InvalidLaneSelector(): seq<Byte> { $InvalidLane$ }
}
