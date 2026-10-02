include "Model.dfy"
module OperationsByteBoundsSource {
  import M = OperationsByteBoundsModel
  function RangeIndex(index: int,len: int): int
    requires M.Signed(index) && 0 <= len < M.Half
    ensures 0 <= RangeIndex(index,len) <= len
  { if $RANGE_NEG$ then $RANGE_NEG_RETURN$ else $RANGE_RETURN$ }
  function StrictIndex(index: int,len: int): M.IndexOutcome
    requires M.Signed(index) && 0 <= len < M.Half
    ensures StrictIndex(index,len).Position? ==> 0 <= StrictIndex(index,len).position < len
  { if $STRICT_BAD$ then M.Invalid(index,len) else M.Position($STRICT_RETURN$) }
  function Slice(data: seq<bv8>,start: int,length: int): M.BytesOutcome
    requires M.Word(start) && M.Word(length) && |data| < M.Half
  { if $SLICE_BAD$ then M.Range(start,length,|data|) else M.Ok(data[start..$SLICE_END$]) }
  function SliceRange(data: seq<bv8>,start: int,end: int): M.BytesOutcome
    requires M.Signed(start) && M.Signed(end) && |data| < M.Half
  {
    var a := RangeIndex(start,|data|);
    var b := RangeIndex(end,|data|);
    if $RANGE_NONEMPTY$ then M.Ok(data[a..b]) else M.Ok([])
  }
  function ByteAt(data: seq<bv8>,index: int): M.BytesOutcome
    requires M.Signed(index) && |data| < M.Half
  {
    var r := StrictIndex(index,|data|);
    if r.Invalid? then M.InvalidByteIndex(index,|data|) else M.Ok(data[r.position..r.position+1])
  }
  function ByteLen(data: seq<bv8>): int { $LENGTH$ }
  function Hash(h: imap<seq<bv8>,bv256>,data: seq<bv8>): bv256
    requires data in h
  { M.Hash(h,data) }
  function HashPairSorted(h: imap<seq<bv8>,bv256>,a: int,b: int): bv256
    requires M.Word(a) && M.Word(b)
    requires M.WordBytes(a)+M.WordBytes(b) in h && M.WordBytes(b)+M.WordBytes(a) in h
  { if $SWAP$ then M.Hash(h,M.WordBytes(b)+M.WordBytes(a)) else M.Hash(h,M.WordBytes(a)+M.WordBytes(b)) }
}
