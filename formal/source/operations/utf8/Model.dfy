include "../byte-bounds/Connection.dfy"
module OperationsUtf8Model {
  import B = OperationsByteBoundsModel
  datatype Check = Good | Bad(position: int)
  datatype Outcome = Bytes(data: seq<bv8>) | InvalidUtf8(position: int) | InvalidIndex(index: int,total: int)
  predicate Continuation(c: bv8) { 128 <= (c as int) <= 191 }
  function Count(c: int): int {
    if 194 <= c <= 223 then 1 else if 224 <= c <= 239 then 2 else if 240 <= c <= 244 then 3 else 0
  }
  predicate Second(first: int,second: int) {
    !(first == 224 && second < 160) && !(first == 237 && second >= 160) &&
    !(first == 240 && second < 144) && !(first == 244 && second >= 144)
  }
  function Tails(s: seq<bv8>,i: int,count: int,j: int): Check
    requires 0 <= i < |s| && 1 <= count <= 3 && i+count < |s| && 1 <= j <= count+1
    decreases count+1-j
  { if j > count then Good else if !Continuation(s[i+j]) then Bad(i+j) else Tails(s,i,count,j+1) }
  lemma GoodByte(s: seq<bv8>,i: int,count: int,j: int,k: int)
    requires 0 <= i < |s| && 1 <= count <= 3 && i+count < |s| && 1 <= j <= k <= count
    requires Tails(s,i,count,j).Good?
    ensures Continuation(s[i+k])
    decreases count+1-j
  { if k > j { GoodByte(s,i,count,j+1,k); } }
  lemma BadByte(s: seq<bv8>,i: int,count: int,j: int)
    requires 0 <= i < |s| && 1 <= count <= 3 && i+count < |s| && 1 <= j <= count+1
    ensures Tails(s,i,count,j).Bad? ==> i+j <= Tails(s,i,count,j).position <= i+count && !Continuation(s[Tails(s,i,count,j).position])
    decreases count+1-j
  { if j <= count && Continuation(s[i+j]) { BadByte(s,i,count,j+1); } }
  lemma TailsGood(s: seq<bv8>,i: int,count: int,j: int)
    requires 0 <= i < |s| && 1 <= count <= 3 && i+count < |s| && 1 <= j <= count+1
    ensures Tails(s,i,count,j).Good? <==> (forall p {:trigger Continuation(s[p])} | i+j <= p <= i+count :: Continuation(s[p]))
  {
    if Tails(s,i,count,j).Good? {
      forall p {:trigger Continuation(s[p])} | i+j <= p <= i+count
        ensures Continuation(s[p])
      { GoodByte(s,i,count,j,p-i); }
    } else {
      BadByte(s,i,count,j);
      var p := Tails(s,i,count,j).position-i;
      assert j <= p <= count && !Continuation(s[i+p]);
      assert !(forall p {:trigger Continuation(s[p])} | i+j <= p <= i+count :: Continuation(s[p]));
    }
  }
  function Validate(s: seq<bv8>,i: int): Check
    requires 0 <= i <= |s|
    decreases |s|-i
  {
    if i == |s| then Good
    else if (s[i] as int) < 128 then Validate(s,i+1)
    else if Count(s[i] as int) == 0 || |s|-i <= Count(s[i] as int) then Bad(i)
    else if !Second(s[i] as int,s[i+1] as int) then Bad(i+1)
    else if !Tails(s,i,Count(s[i] as int),1).Good? then Tails(s,i,Count(s[i] as int),1)
    else Validate(s,i+Count(s[i] as int)+1)
  }
  predicate Utf8(s: seq<bv8>)
    decreases |s|
  {
    |s| == 0 ||
    (if (s[0] as int) < 128 then Utf8(s[1..]) else
     Count(s[0] as int) > 0 && |s| > Count(s[0] as int) && Second(s[0] as int,s[1] as int) &&
     (forall k | 1 <= k <= Count(s[0] as int) :: Continuation(s[k])) && Utf8(s[Count(s[0] as int)+1..]))
  }
  lemma ValidateUtf8(s: seq<bv8>,i: int)
    requires 0 <= i <= |s|
    ensures Validate(s,i).Good? <==> Utf8(s[i..])
    decreases |s|-i
  {
    if i < |s| {
      if (s[i] as int) < 128 {
        ValidateUtf8(s,i+1);
        assert s[i..][1..] == s[i+1..];
      } else if Count(s[i] as int) > 0 && |s|-i > Count(s[i] as int) {
        var count := Count(s[i] as int);
        TailsGood(s,i,count,1);
        if Second(s[i] as int,s[i+1] as int) && Tails(s,i,count,1).Good? {
          ValidateUtf8(s,i+count+1);
          assert s[i..][count+1..] == s[i+count+1..];
        }
      }
    }
  }
  lemma Mask(c: bv8)
    ensures (c & 192) == 128 <==> Continuation(c)
  { }
  predicate Boundary(s: seq<bv8>,p: int)
    requires 0 <= p <= |s|
  { p == |s| || !Continuation(s[p]) }
  function Width(s: seq<bv8>): int
    requires Utf8(s) && |s| > 0
    ensures 1 <= Width(s) <= |s|
    ensures Utf8(s[Width(s)..])
    ensures forall k {:trigger Continuation(s[k])} | 1 <= k < Width(s) :: Continuation(s[k])
  { if (s[0] as int) < 128 then 1 else Count(s[0] as int)+1 }
  function Scalar(s: seq<bv8>): int
    requires Utf8(s) && |s| > 0
  {
    var first := s[0] as int;
    if first < 128 then first
    else if Count(first) == 1 then (first-192)*64+(s[1] as int)-128
    else if Count(first) == 2 then (first-224)*4096+((s[1] as int)-128)*64+(s[2] as int)-128
    else (first-240)*262144+((s[1] as int)-128)*4096+((s[2] as int)-128)*64+(s[3] as int)-128
  }
  lemma ScalarValid(s: seq<bv8>)
    requires Utf8(s) && |s| > 0
    ensures 0 <= Scalar(s) <= 1114111
    ensures Scalar(s) < 55296 || Scalar(s) > 57343
    ensures Width(s) == 1 ==> Scalar(s) < 128
    ensures Width(s) == 2 ==> 128 <= Scalar(s) <= 2047
    ensures Width(s) == 3 ==> 2048 <= Scalar(s) <= 65535
    ensures Width(s) == 4 ==> 65536 <= Scalar(s)
  {
    var w := Width(s);
    if w > 1 { assert Continuation(s[1]); }
    if w > 2 { assert Continuation(s[2]); }
    if w > 3 { assert Continuation(s[3]); }
  }
  lemma UnitPrefix(s: seq<bv8>)
    requires Utf8(s) && |s| > 0
    ensures Utf8(s[..Width(s)])
  {
    var w := Width(s);
    if w > 1 {
      forall k | 1 <= k < w
        ensures Continuation(s[..w][k])
      { }
    }
  }
  lemma UnitAppend(head: seq<bv8>,tail: seq<bv8>)
    requires Utf8(head) && |head| > 0 && |head| == Width(head) && Utf8(tail)
    ensures Utf8(head+tail)
  {
    if (head[0] as int) >= 128 {
      forall k | 1 <= k < |head|
        ensures Continuation((head+tail)[k])
      { }
    }
    assert (head+tail)[|head|..] == tail;
  }
  lemma SliceValid(s: seq<bv8>,a: int,b: int)
    requires Utf8(s) && 0 <= a <= b <= |s| && Boundary(s,a) && Boundary(s,b)
    ensures Utf8(s[a..b])
    decreases |s|
  {
    if a < b {
      var w := Width(s);
      var tail := s[w..];
      if 0 < a < w { assert Continuation(s[a]); }
      if 0 < b < w { assert Continuation(s[b]); }
      assert b >= w;
      if a > 0 {
        assert a >= w;
        assert Boundary(tail,a-w) && Boundary(tail,b-w);
        SliceValid(tail,a-w,b-w);
        assert s[a..b] == tail[a-w..b-w];
      } else {
        assert Boundary(tail,0) && Boundary(tail,b-w);
        SliceValid(tail,0,b-w);
        UnitPrefix(s);
        assert Width(s[..w]) == w;
        UnitAppend(s[..w],tail[..b-w]);
        assert s[..b] == s[..w]+tail[..b-w];
      }
    }
  }
  function Slice(s: seq<bv8>,start: int,end: int): Outcome
    requires B.Signed(start) && B.Signed(end)
  {
    var r := Validate(s,0);
    var a := B.Clamp(start,|s|);
    var b := B.Clamp(end,|s|);
    if r.Bad? then InvalidUtf8(r.position)
    else if b <= a then Bytes([])
    else if !Boundary(s,a) then InvalidUtf8(a)
    else if !Boundary(s,b) then InvalidUtf8(b)
    else Bytes(s[a..b])
  }
  function At(s: seq<bv8>,index: int): Outcome
    requires B.Signed(index)
  {
    var r := Validate(s,0);
    var p := if index < 0 then |s|+index else index;
    if r.Bad? then InvalidUtf8(r.position)
    else if p < 0 || p >= |s| then InvalidIndex(index,|s|)
    else if (s[p] as int) >= 128 then InvalidUtf8(p)
    else Bytes([s[p]])
  }
}
