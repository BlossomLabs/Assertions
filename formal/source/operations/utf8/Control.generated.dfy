include "Model.dfy"
module OperationsUtf8Source {
  import M = OperationsUtf8Model
  import B = OperationsByteBoundsModel
  import Index = OperationsByteBoundsSource
  import IndexProof = OperationsByteBoundsConnection
  method Validate(data: seq<bv8>) returns (out: M.Check)
    requires |data| < B.Half
    ensures out == M.Validate(data,0)
    ensures out.Good? <==> M.Utf8(data)
  {
    M.ValidateUtf8(data,0);
    var i := 0;
    while (i < |data|)
      invariant 0 <= i <= |data|
      invariant M.Validate(data,0) == M.Validate(data,i)
      decreases |data|-i
    {
      var first := data[i] as int;
      if (first < 128) { i := i+1; continue; }
      var count := 0;
      if ((first >= 194) && (first <= 223)) { count := 1; }
      else if ((first >= 224) && (first <= 239)) { count := 2; }
      else if ((first >= 240) && (first <= 244)) { count := 3; }
      else { out := M.Bad(i); return; }
      assert count == M.Count(first);
      if ((|data| - i) <= count) { out := M.Bad(i); return; }
      var second := data[i+1] as int;
      if (((((first == 224) && (second < 160)) || ((first == 237) && (second >= 160))) || ((first == 240) && (second < 144))) || ((first == 244) && (second >= 144))) { out := M.Bad(i+1); return; }
      assert M.Second(first,second);
      var j := 1;
      while (j <= count)
        invariant 1 <= j <= count+1
        invariant M.Tails(data,i,count,1) == M.Tails(data,i,count,j)
        decreases count+1-j
      {
        M.Mask(data[i+j]);
        if ((data[(i + j)] & 192) != 128) { out := M.Bad(i+j); return; }
        j := j+1;
      }
      assert M.Tails(data,i,count,1).Good?;
      assert M.Validate(data,i) == M.Validate(data,i+count+1);
      i := i+count+1;
    }
    out := M.Good;
    M.ValidateUtf8(data,0);
  }
  method Slice(data: seq<bv8>,start: int,end: int) returns (out: M.Outcome)
    requires |data| < B.Half && B.Signed(start) && B.Signed(end)
    ensures out == M.Slice(data,start,end)
  {
    var valid := Validate(data);
    if valid.Bad? { out := M.InvalidUtf8(valid.position); return; }
    var a := Index.RangeIndex(start,|data|);
    var b := Index.RangeIndex(end,|data|);
    IndexProof.RangeIndex(start,|data|); IndexProof.RangeIndex(end,|data|);
    if (b <= a) { out := M.Bytes([]); return; }
    if a < |data| { M.Mask(data[a]); }
    if b < |data| { M.Mask(data[b]); }
    if ((a < |data|) && ((data[a] & 192) == 128)) { out := M.InvalidUtf8(a); return; }
    if ((b < |data|) && ((data[b] & 192) == 128)) { out := M.InvalidUtf8(b); return; }
    out := M.Bytes(data[a..b]);
  }
  method At(data: seq<bv8>,index: int) returns (out: M.Outcome)
    requires |data| < B.Half && B.Signed(index)
    ensures out == M.At(data,index)
  {
    var valid := Validate(data);
    if valid.Bad? { out := M.InvalidUtf8(valid.position); return; }
    var r := Index.StrictIndex(index,|data|);
    IndexProof.StrictIndex(index,|data|);
    if r.Invalid? { out := M.InvalidIndex(index,|data|); return; }
    var position := r.position;
    if ((data[position] as int) >= 128) { out := M.InvalidUtf8(position); return; }
    out := M.Bytes(data[position..position+1]);
    assert data[position..position+1] == [data[position]];
  }
}
