include "Model.dfy"
module OperationsConcatSource {
  import M = OperationsConcatModel
  ghost method Copy(mem: imap<int,bv8>,dst: int,dstOffset: int,src: seq<bv8>,capacity: int) returns (out: imap<int,bv8>)
    requires M.Total(mem) && 0 <= dst && 0 <= dstOffset && dstOffset+|src| <= capacity
    requires dst+32+capacity < M.Word
    ensures out == M.Copy(mem,dst+32+dstOffset,src)
    ensures forall a | a < dst+32 || a >= dst+32+capacity :: out[a] == mem[a]
  {
    var len := |src|;
    var destination := ((((dst + 32) % M.Word) + dstOffset) % M.Word);
    out := M.Copy(mem,destination,src[..len]);
  }
  ghost method CopyBytes(dst: seq<bv8>,offset: int,src: seq<bv8>,ptr: int) returns (out: seq<bv8>)
    requires 0 <= ptr && ptr+32+|dst| < M.Word && 0 <= offset && offset+|src| <= |dst|
    ensures out == dst[..offset]+src+dst[offset+|src|..]
  {
    var mem := M.Memory(ptr,dst);
    mem := Copy(mem,ptr,offset,src,|dst|);
    M.CopyProjection(M.Memory(ptr,dst),ptr,dst,offset,src);
    out := M.Read(mem,ptr,|dst|);
  }
  ghost method Concat(parts: seq<seq<bv8>>,delimiter: seq<bv8>,ptr: int) returns (out: M.Outcome)
    requires |parts| < M.Word && |delimiter| < M.Word
    requires forall i | 0 <= i < |parts| :: |parts[i]| < M.Word
    requires 128 <= ptr && ptr % 32 == 0
    requires M.Length(parts,delimiter) < M.Word ==> ptr+64+M.Length(parts,delimiter) < M.Word
    ensures out == M.Spec(parts,delimiter)
  {
    var length := 0;
    var i := 0;
    while (i < |parts|)
      invariant 0 <= i <= |parts|
      invariant length == M.Sum(parts[..i]) && 0 <= length < M.Word
      decreases |parts|-i
    {
      M.SumAppend(parts,i); M.SumSplit(parts,i+1);
      var next := (length + |parts[i]|);
      if next >= M.Word { out := M.Panic(17); return; }
      length := next;
      i := i+1;
    }
    assert i == |parts|;
    assert parts[..i] == parts;
    assert length == M.Sum(parts);
    if (|parts| > 1) {
      var product := ((|parts| - 1) * |delimiter|);
      if product >= M.Word { out := M.Panic(17); return; }
      var total := length+product;
      if total >= M.Word { out := M.Panic(17); return; }
      length := total;
    }
    assert length == M.Length(parts,delimiter);
    assert 0 <= length < M.Word;
    var buf := seq(length, j => 0 as bv8);
    var offset := 0;
    i := 0;
    while (i < |parts|)
      invariant 0 <= i <= |parts|
      invariant |buf| == M.Length(parts,delimiter)
      invariant 0 <= offset <= |buf|
      invariant buf[..offset] == M.Join(parts[..i],delimiter)
      invariant offset == M.Length(parts[..i],delimiter)
      decreases |parts|-i
    {
      M.JoinAppend(parts,delimiter,i);
      M.JoinLength(parts[..i],delimiter); M.JoinLength(parts[..i+1],delimiter);
      M.PrefixFits(parts,delimiter,i+1);
      if (i != 0) {
        var previous := buf;
        buf := CopyBytes(buf,offset,delimiter,ptr);
        M.CopyPrefix(previous,offset,delimiter);
        offset := offset+|delimiter|;
      }
      var previous := buf;
      buf := CopyBytes(buf,offset,parts[i],ptr);
      M.CopyPrefix(previous,offset,parts[i]);
      offset := offset+|parts[i]|;
      i := i+1;
    }
    assert offset == |buf|;
    out := M.Bytes(buf);
  }
}
