include "Control.generated.dfy"
module OperationsByteBoundsConnection {
  import M = OperationsByteBoundsModel
  import S = OperationsByteBoundsSource
  lemma RangeIndex(index: int,len: int)
    requires M.Signed(index) && 0 <= len < M.Half
    ensures S.RangeIndex(index,len) == M.Clamp(index,len)
  { }
  lemma StrictIndex(index: int,len: int)
    requires M.Signed(index) && 0 <= len < M.Half
    ensures S.StrictIndex(index,len) == (if index < -len || index >= len then M.Invalid(index,len) else M.Position(if index < 0 then len+index else index))
  { }
  lemma Slice(data: seq<bv8>,start: int,length: int)
    requires M.Word(start) && M.Word(length) && |data| < M.Half
    ensures start+length > |data| ==> S.Slice(data,start,length) == M.Range(start,length,|data|)
    ensures start+length <= |data| ==> S.Slice(data,start,length) == M.Ok(data[start..start+length])
  { }
  lemma SliceRange(data: seq<bv8>,start: int,end: int)
    requires M.Signed(start) && M.Signed(end) && |data| < M.Half
    ensures S.SliceRange(data,start,end) == M.Ok(if M.Clamp(end,|data|) > M.Clamp(start,|data|) then data[M.Clamp(start,|data|)..M.Clamp(end,|data|)] else [])
  { RangeIndex(start,|data|); RangeIndex(end,|data|); }
  lemma ByteAt(data: seq<bv8>,index: int)
    requires M.Signed(index) && |data| < M.Half
    ensures index < -|data| || index >= |data| ==> S.ByteAt(data,index) == M.InvalidByteIndex(index,|data|)
    ensures -|data| <= index < |data| ==> S.ByteAt(data,index) == M.Ok([data[if index < 0 then |data|+index else index]])
  {
    StrictIndex(index,|data|);
    if -|data| <= index < |data| {
      var p := if index < 0 then |data|+index else index;
      assert data[p..p+1] == [data[p]];
    }
  }
  lemma ByteLen(data: seq<bv8>)
    ensures S.ByteLen(data) == |data|
  { }
  lemma Hash(h: imap<seq<bv8>,bv256>,data: seq<bv8>)
    requires data in h
    ensures S.Hash(h,data) == h[data]
  { }
  lemma HashPairSorted(h: imap<seq<bv8>,bv256>,a: int,b: int)
    requires M.Word(a) && M.Word(b)
    requires M.WordBytes(a)+M.WordBytes(b) in h && M.WordBytes(b)+M.WordBytes(a) in h
    ensures S.HashPairSorted(h,a,b) == h[M.WordBytes(if a <= b then a else b)+M.WordBytes(if a <= b then b else a)]
  { }
}
