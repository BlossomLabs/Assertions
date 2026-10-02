include "Model.dfy"
module OperationsWordMatchSource {
  import M = OperationsWordMatchModel
  method Match(s: seq<bv8>,needle: seq<bv8>,pos: nat,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>) returns (equal: bool)
    requires pos+|needle| <= |s| && |s| < M.Half && |needle| < M.Half
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < M.Word && needleOffset+|needle|+32 < M.Word
    ensures equal == M.Matches(s,needle,pos)
  {
    equal := true;
    var n := |needle|;
    var a := $A$;
    assert a == sOffset+pos;
    var j := 0;
    while $MATCH_LOOP$
      invariant 0 <= j <= n+31
      invariant s[pos..pos+(if j < n then j else n)] == needle[..(if j < n then j else n)]
      invariant equal
      decreases n-j
    {
      assert j < n;
      var xAddress := $X_ADDRESS$;
      var yAddress := $Y_ADDRESS$;
      assert xAddress == sOffset+pos+j;
      assert yAddress == needleOffset+j;
      var xWord := M.Window(s,pos+j,outsideS);
      var yWord := M.Window(needle,j,outsideNeedle);
      var x := M.Pack(xWord);
      var y := M.Pack(yWord);
      M.PackBound(xWord); M.PackBound(yWord);
      M.BitsBytes(32); M.WordPower();
      assert M.Power(32) == M.Word;
      assert x < M.Word && y < M.Word;
      var left := $LEFT$;
      assert left == n-j && 1 <= left;
      var k := if left < 32 then left else 32;
      if $TAIL$ {
        var drop := $DROP$;
        M.Drop(left);
        assert drop == 8*(32-left);
        x := $SHIFT_X$;
        y := $SHIFT_Y$;
        M.ShiftPrefix(xWord,left); M.ShiftPrefix(yWord,left);
        assert x == M.Pack(xWord[..k]) && y == M.Pack(yWord[..k]);
      } else {
        assert k == 32;
        assert xWord[..k] == xWord && yWord[..k] == yWord;
      }
      M.WindowPrefix(s,pos+j,outsideS,k);
      M.WindowPrefix(needle,j,outsideNeedle,k);
      assert x == M.Pack(s[pos+j..pos+j+k]);
      assert y == M.Pack(needle[j..j+k]);
      if $MISMATCH$ {
        equal := false;
        assert s[pos+j..pos+j+k] != needle[j..j+k];
        M.Mismatch(s,needle,pos,j,k);
        return;
      }
      assert x == y;
      M.PackInjective(s[pos+j..pos+j+k],needle[j..j+k]);
      M.MatchedPrefix(s,needle,pos,j,k);
      var nextJ := $MATCH_NEXT$;
      assert nextJ == j+32;
      assert (if nextJ < n then nextJ else n) == j+k;
      j := nextJ;
    }
    assert j >= n;
  }
  method Contains(s: seq<bv8>,needle: seq<bv8>,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>) returns (found: bool)
    requires |s| < M.Half && |needle| < M.Half
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < M.Word && needleOffset+|needle|+32 < M.Word
    ensures found == M.Contains(s,needle)
  {
    if $EMPTY$ { assert M.Matches(s,needle,0); found := true; return; }
    if $TOO_LONG$ { found := false; return; }
    var i := 0;
    while $CONTAINS_LOOP$
      invariant 0 <= i <= |s|-|needle|+1
      invariant forall p | 0 <= p < i :: !M.Matches(s,needle,p)
      decreases |s|-|needle|+1-i
    {
      var matched := Match(s,needle,i,sOffset,needleOffset,outsideS,outsideNeedle);
      if $FOUND$ { found := true; return; }
      assert !M.Matches(s,needle,i);
      i := i+1;
    }
    found := false;
  }
}
