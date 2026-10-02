// SPDX-License-Identifier: MIT
include "Modes.dfy"
include "../abi/dynamic/Body.generated.dfy"

module NavigationTerminals {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationModes

  ghost function StaticValue(data: seq<Byte>, c: Cursor): ReturnResult
    requires Admissible(c.syntax) && !Dyn(c.syntax) && Uint(c.base) && Uint(|data|)
  {
    if c.base > |data| || Width(c.syntax) > (|data|-c.base)/32
    then ReturnResult.Rejected(ReturnDataOutOfBounds(c.base/32,|data|)) else
    StaticRules(c.syntax);
    var checked := Scan(Rules(c.syntax),data,c.base);
    if checked.Invalid? then ReturnResult.Rejected(Error.InvalidValue(checked.offset))
    else BytesReturned(data[c.base..c.base+32*Width(c.syntax)])
  }

  // Bounds errors have nav's word-index payload. Dirty padding has the
  // codec's exact byte-offset payload; these outcomes are not conflated.
  function BytesSize(data: seq<Byte>, pos: nat): NumberResult
    requires Uint(|data|) && Uint(pos)
    ensures BytesSize(data,pos).Number? ==>
              pos+BytesSize(data,pos).value <= |data| && BytesSize(data,pos).value%32 == 0
  {
    var read := WordAt(data,pos);
    if read.Failed? then read else
    var n := read.value;
    var padded := n+Padding(n);
    if pos+32+padded > |data| then Failed(ReturnDataOutOfBounds(pos/32,|data|)) else
    var bad := FirstDirty(data,pos+32+n,pos+32+padded);
    if bad < pos+32+padded then Failed(Error.InvalidValue(bad)) else NavigationRuntime.Number(32+padded)
  }
}
