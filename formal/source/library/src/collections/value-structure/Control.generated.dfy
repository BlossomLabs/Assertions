// SPDX-License-Identifier: MIT
// Generated from the complete compiler bodies; edit the template/generator only.
include "Model.dfy"
module CollectionsValueStructureControl {
  import opened AbiFrames
  import opened AbiByteSemantics
  import M = CollectionsValueStructureModel
  function ToSigned(value: int): int { (value+M.SignedLimit())%Pow256(32)-M.SignedLimit() }
  function ToUnsigned(value: int): nat { value%Pow256(32) }
  predicate IndexNegative(index: int) { (index < 0) }
  function NegativeResult(index: int,length: nat): int { (if (index < -(ToSigned(length))) then 0 else ToUnsigned((ToSigned(length) + index))) }
  function PositiveResult(index: int,length: nat): int { (if (ToUnsigned(index) > length) then length else ToUnsigned(index)) }
  predicate ReverseLoop(i: nat,length: nat) { (i < length) }
  function ReverseValidate(i: nat): int { i }
  function ReverseValue(i: nat): int { i }
  function ReverseDest(i: nat,length: nat): int { ((length - i) - 1) }
  function SliceSize(a: nat,b: nat): int { (if (b > a) then (b - a) else 0) }
  predicate SliceLoop(i: nat,size: nat) { (i < size) }
  function SliceValidate(a: nat,i: nat): int { (a + i) }
  function SliceValue(a: nat,i: nat): int { (a + i) }
  function SliceDest(i: nat): int { i }
  predicate CountLoop(i: nat,length: nat) { (i < length) }
  function CountAdd(rowLength: nat): int { rowLength }
  predicate FlatLoop(i: nat,length: nat) { (i < length) }
  predicate RowLoop(j: nat,rowLength: nat) { (j < rowLength) }
  function FlatValidateRow(i: nat): int { i }
  function FlatValidateCol(j: nat): int { j }
  function FlatValueRow(i: nat): int { i }
  function FlatValueCol(j: nat): int { j }
}
