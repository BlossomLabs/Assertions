include "Model.dfy"
include "Matcher.generated.dfy"
module OperationsReplaceSource {
  import M = OperationsReplaceModel
  import W = OperationsWordMatchModel
  import O = OperationsOccurrenceModel
  import S = OperationsReplaceMatcherSource
  import C = OperationsConcatSource
  ghost method Replace(s: seq<bv8>,needle: seq<bv8>,repl: seq<bv8>,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>,ptr: nat) returns (out: M.Outcome)
    requires |s|+1 < W.Half && |needle| < W.Half && |repl| < W.Word
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < W.Word && needleOffset+|needle|+32 < W.Word
    requires 128 <= ptr && ptr%32 == 0
    requires |needle| > 0 && M.Length(s,needle,repl) < W.Word ==> ptr+64+M.Length(s,needle,repl) < W.Word
    ensures out == M.Spec(s,needle,repl)
  {
    if $EMPTY$ { out := M.EmptyNeedle; return; }
    O.PositionsBounds(s,needle,0);
    M.PositionsValid(s,needle,0);
    var capacity := $CAPACITY$;
    M.FloorBound(|s|,|needle|,|O.Positions(s,needle,0)|);
    var matches := seq(capacity,i => 0);
    var count := 0;
    var p := 0;
    ghost var hits: seq<nat> := [];
    while $SCAN_LOOP$
      invariant 0 <= p <= |s|
      invariant count == |hits| && count <= capacity && |matches| == capacity
      invariant matches[..count] == hits
      invariant O.Positions(s,needle,0) == hits+O.Positions(s,needle,p)
      decreases |s|-p
    {
      var matched := S.Match(s,needle,p,sOffset,needleOffset,outsideS,outsideNeedle);
      O.ScanStep(s,needle,p,hits);
      if $FOUND$ {
        assert count < capacity;
        matches := matches[count := p];
        assert matches[..count+1] == hits+[p];
        hits := hits+[p];
        assert count+1 < W.Word;
        count := count+1;
        p := $SCAN_NEXT$;
      } else { p := p+1; }
    }
    assert O.Positions(s,needle,p) == [];
    assert hits == O.Positions(s,needle,0);
    if $NONE$ { out := M.Bytes(s); return; }
    var removed := count*|needle|;
    assert removed <= |s|;
    var added := count*|repl|;
    if added >= W.Word { out := M.Panic(17); return; }
    var length := $SIZE$;
    assert length == M.Length(s,needle,repl);
    if length >= W.Word { out := M.Panic(17); return; }
    var buf := seq(length,i => 0 as bv8);
    var start := 0;
    var dest := 0;
    var i := 0;
    ghost var expected := M.Render(s,|needle|,repl,0,hits);
    M.RenderLength(s,|needle|,repl,0,hits);
    while $WRITE_LOOP$
      invariant 0 <= i <= count && count == |hits|
      invariant 0 <= start <= |s| && 0 <= dest <= length && |buf| == length
      invariant matches[..count] == hits
      invariant M.Valid(|s|,|needle|,start,hits[i..])
      invariant expected == buf[..dest]+M.Render(s,|needle|,repl,start,hits[i..])
      invariant |expected| == length
      decreases count-i
    {
      p := matches[i];
      assert p == hits[i];
      assert start <= p && p+|needle| <= |s|;
      var tail := M.Render(s,|needle|,repl,p+|needle|,hits[i+1..]);
      assert M.Render(s,|needle|,repl,start,hits[i..]) == s[start..p]+repl+tail;
      assert dest+(p-start)+|repl| <= length;
      buf := C.CopyBytes(buf,dest,$GAP_BYTES$,ptr);
      assert buf[..dest+(p-start)] == expected[..dest+(p-start)];
      dest := $GAP_NEXT$;
      buf := C.CopyBytes(buf,dest,$REPL_BYTES$,ptr);
      assert buf[..dest+|repl|] == expected[..dest+|repl|];
      dest := $REPL_NEXT$;
      start := $START_NEXT$;
      assert expected == buf[..dest]+tail;
      i := i+1;
    }
    assert hits[i..] == [];
    assert M.Render(s,|needle|,repl,start,hits[i..]) == s[start..];
    assert dest+|s[start..]| == length;
    buf := C.CopyBytes(buf,dest,$TAIL_BYTES$,ptr);
    assert buf == expected;
    out := M.Bytes(buf);
  }
  method SizeWitness()
  {
    var s: seq<bv8> := [97,97,97,97];
    var needle: seq<bv8> := [97,97];
    var repl: seq<bv8> := [120];
    var count := 2;
    var length := $SIZE$;
    assert length == 2;
  }
  method CopyOperandWitness()
  {
    var needle: seq<bv8> := [97,97];
    var repl: seq<bv8> := [120];
    var actual := $REPL_BYTES$;
    assert actual == [120];
  }

}
