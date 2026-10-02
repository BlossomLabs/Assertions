module OperationsConcatModel {
  const Word: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  datatype Outcome = Bytes(data: seq<bv8>) | Panic(code: int)
  ghost predicate Total(mem: imap<int,bv8>) { forall a :: a in mem }
  ghost function Copy(mem: imap<int,bv8>,dest: int,src: seq<bv8>): imap<int,bv8>
    requires Total(mem)
    ensures Total(Copy(mem,dest,src))
  { imap a: int :: if dest <= a < dest+|src| then src[a-dest] else mem[a] }
  ghost predicate Frame(mem: imap<int,bv8>,ptr: int,data: seq<bv8>)
    requires Total(mem)
  { forall i | 0 <= i < |data| :: mem[ptr+32+i] == data[i] }
  ghost function InitialCell(ptr: int,data: seq<bv8>,a: int): bv8
  { if ptr+32 <= a < ptr+32+|data| then data[a-ptr-32] else 0 }
  ghost function Memory(ptr: int,data: seq<bv8>): imap<int,bv8>
    ensures Total(Memory(ptr,data))
    ensures Frame(Memory(ptr,data),ptr,data)
  { imap a: int :: InitialCell(ptr,data,a) }
  ghost function Read(mem: imap<int,bv8>,ptr: int,length: nat): seq<bv8>
    requires Total(mem)
    ensures |Read(mem,ptr,length)| == length
  { seq(length,i requires 0 <= i < length => mem[ptr+32+i]) }
  lemma CopyProjection(mem: imap<int,bv8>,ptr: int,dst: seq<bv8>,offset: int,src: seq<bv8>)
    requires Total(mem) && Frame(mem,ptr,dst) && 0 <= offset && offset+|src| <= |dst|
    ensures Frame(Copy(mem,ptr+32+offset,src),ptr,dst[..offset]+src+dst[offset+|src|..])
    ensures Read(Copy(mem,ptr+32+offset,src),ptr,|dst|) == dst[..offset]+src+dst[offset+|src|..]
    ensures forall a | a < ptr+32 || a >= ptr+32+|dst| :: Copy(mem,ptr+32+offset,src)[a] == mem[a]
  {
    var expected := dst[..offset]+src+dst[offset+|src|..];
    forall i | 0 <= i < |dst|
      ensures Copy(mem,ptr+32+offset,src)[ptr+32+i] == expected[i]
    { if i < offset { } else if i < offset+|src| { } else { } }
    assert Read(Copy(mem,ptr+32+offset,src),ptr,|dst|) == expected;
  }
  function Sum(parts: seq<seq<bv8>>): nat
    decreases |parts|
  { if |parts| == 0 then 0 else |parts[0]|+Sum(parts[1..]) }
  function Length(parts: seq<seq<bv8>>,delimiter: seq<bv8>): nat {
    Sum(parts)+(if |parts| > 1 then (|parts|-1)*|delimiter| else 0)
  }
  function Join(parts: seq<seq<bv8>>,delimiter: seq<bv8>): seq<bv8>
    decreases |parts|
  { if |parts| == 0 then [] else parts[0]+(if |parts| == 1 then [] else delimiter+Join(parts[1..],delimiter)) }
  function Spec(parts: seq<seq<bv8>>,delimiter: seq<bv8>): Outcome {
    if Length(parts,delimiter) >= Word then Panic(17) else Bytes(Join(parts,delimiter))
  }
  lemma SumSplit(parts: seq<seq<bv8>>,i: int)
    requires 0 <= i <= |parts|
    ensures Sum(parts) == Sum(parts[..i])+Sum(parts[i..])
    decreases i
  {
    if i > 0 {
      SumSplit(parts[1..],i-1);
      assert parts[..i][1..] == parts[1..][..i-1];
      assert parts[i..] == parts[1..][i-1..];
    }
  }
  lemma SumAppend(parts: seq<seq<bv8>>,i: int)
    requires 0 <= i < |parts|
    ensures Sum(parts[..i+1]) == Sum(parts[..i])+|parts[i]|
  {
    SumSplit(parts[..i+1],i);
    assert parts[..i+1][i..] == [parts[i]];
    assert parts[..i+1][..i] == parts[..i];
    assert Sum([parts[i]]) == |parts[i]|;
  }
  lemma ProductNonnegative(a: nat,b: nat)
    ensures a*b >= 0
  { }
  lemma ProductMonotone(a: nat,b: nat,c: nat)
    requires a <= b
    ensures a*c <= b*c
  { ProductNonnegative(b-a,c); assert b*c == a*c+(b-a)*c; }
  lemma ProductSuccessor(a: nat,b: nat)
    ensures (a+1)*b == a*b+b
  { }
  lemma JoinLength(parts: seq<seq<bv8>>,delimiter: seq<bv8>)
    ensures |Join(parts,delimiter)| == Length(parts,delimiter)
    decreases |parts|
  {
    if |parts| == 0 {
      assert Join(parts,delimiter) == [];
      assert Sum(parts) == 0;
    } else {
      var rest := parts[1..];
      assert Sum(parts) == |parts[0]|+Sum(rest);
      if |parts| == 1 {
        assert rest == [];
        assert Sum(rest) == 0;
        assert Join(parts,delimiter) == parts[0];
      } else {
        JoinLength(rest,delimiter);
        assert Join(parts,delimiter) == parts[0]+delimiter+Join(rest,delimiter);
        assert Length(rest,delimiter) == Sum(rest)+(|parts|-2)*|delimiter|;
        ProductSuccessor(|parts|-2,|delimiter|);
        calc {
          |Join(parts,delimiter)|;
          |parts[0]|+|delimiter|+|Join(rest,delimiter)|;
          |parts[0]|+|delimiter|+Sum(rest)+(|parts|-2)*|delimiter|;
          Sum(parts)+(|parts|-1)*|delimiter|;
          Length(parts,delimiter);
        }
      }
    }
  }
  lemma JoinAppend(parts: seq<seq<bv8>>,delimiter: seq<bv8>,i: int)
    requires 0 <= i < |parts|
    ensures Join(parts[..i+1],delimiter) == Join(parts[..i],delimiter)+(if i == 0 then [] else delimiter)+parts[i]
    decreases i
  {
    if i > 0 {
      JoinAppend(parts[1..],delimiter,i-1);
      assert parts[..i+1][1..] == parts[1..][..i];
      assert parts[..i][1..] == parts[1..][..i-1];
    }
  }
  lemma PrefixFits(parts: seq<seq<bv8>>,delimiter: seq<bv8>,i: int)
    requires 0 <= i <= |parts|
    ensures Length(parts[..i],delimiter) <= Length(parts,delimiter)
  {
    SumSplit(parts,i);
    if i > 1 { ProductMonotone(i-1,|parts|-1,|delimiter|); }
  }
  lemma CopyPrefix(dst: seq<bv8>,offset: int,src: seq<bv8>)
    requires 0 <= offset && offset+|src| <= |dst|
    ensures (dst[..offset]+src+dst[offset+|src|..])[..offset+|src|] == dst[..offset]+src
  { }
}
