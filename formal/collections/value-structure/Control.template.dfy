// SPDX-License-Identifier: MIT
// Generated from the complete compiler bodies; edit the template/generator only.
include "Model.dfy"
module CollectionsValueStructureControl {
  import opened AbiFrames
  import opened AbiByteSemantics
  import M = CollectionsValueStructureModel
  function ToSigned(value: int): int { (value+M.SignedLimit())%Pow256(32)-M.SignedLimit() }
  function ToUnsigned(value: int): nat { value%Pow256(32) }
  predicate IndexNegative(index: int) { $INDEX_NEGATIVE$ }
  function NegativeResult(index: int,length: nat): int { $NEGATIVE_RESULT$ }
  function PositiveResult(index: int,length: nat): int { $POSITIVE_RESULT$ }
  predicate ReverseLoop(i: nat,length: nat) { $REVERSE_LOOP$ }
  function ReverseValidate(i: nat): int { $REVERSE_VALIDATE$ }
  function ReverseValue(i: nat): int { $REVERSE_VALUE$ }
  function ReverseDest(i: nat,length: nat): int { $REVERSE_DEST$ }
  function SliceSize(a: nat,b: nat): int { $SLICE_SIZE$ }
  predicate SliceLoop(i: nat,size: nat) { $SLICE_LOOP$ }
  function SliceValidate(a: nat,i: nat): int { $SLICE_VALIDATE$ }
  function SliceValue(a: nat,i: nat): int { $SLICE_VALUE$ }
  function SliceDest(i: nat): int { $SLICE_DEST$ }
  predicate CountLoop(i: nat,length: nat) { $COUNT_LOOP$ }
  function CountAdd(rowLength: nat): int { $COUNT_ADD$ }
  predicate FlatLoop(i: nat,length: nat) { $FLAT_LOOP$ }
  predicate RowLoop(j: nat,rowLength: nat) { $ROW_LOOP$ }
  function FlatValidateRow(i: nat): int { $FLAT_VALIDATE_ROW$ }
  function FlatValidateCol(j: nat): int { $FLAT_VALIDATE_COL$ }
  function FlatValueRow(i: nat): int { $FLAT_VALUE_ROW$ }
  function FlatValueCol(j: nat): int { $FLAT_VALUE_COL$ }
}
