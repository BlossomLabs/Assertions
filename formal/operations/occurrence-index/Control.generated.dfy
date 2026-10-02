include "Model.dfy"
module OperationsOccurrenceSource {
  import M = OperationsOccurrenceModel
  import W = OperationsWordMatchModel
  import S = OperationsWordMatchSource
  method Count(s: seq<bv8>,needle: seq<bv8>,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>) returns (count: nat)
    requires 0 < |needle| && |s|+1 < W.Half && |needle| < W.Half
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < W.Word && needleOffset+|needle|+32 < W.Word
    ensures count == |M.Positions(s,needle,0)|
  {
    M.PositionsBounds(s,needle,0);
    count := 0;
    var p := 0;
    ghost var hits: seq<nat> := [];
    while ((p + |needle|) <= |s|)
      invariant 0 <= p <= |s|
      invariant count == |hits|
      invariant M.Positions(s,needle,0) == hits+M.Positions(s,needle,p)
      decreases |s|-p
    {
      assert p+|needle| < W.Word;
      var matched := S.Match(s,needle,p,sOffset,needleOffset,outsideS,outsideNeedle);
      M.ScanStep(s,needle,p,hits);
      if matched {
        assert count+1 < W.Word;
        count := count+1;
        hits := hits+[p];
        p := (p + |needle|);
      } else { p := p+1; }
    }
    assert M.Positions(s,needle,p) == [];
  }
  method Index(s: seq<bv8>,needle: seq<bv8>,occurrence: int,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>) returns (out: nat)
    requires -W.Half <= occurrence < W.Half
    requires |s|+1 < W.Half && |needle| < W.Half
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < W.Word && needleOffset+|needle|+32 < W.Word
    ensures out == M.Index(s,needle,occurrence)
  {
    if (|needle| == 0) {
      var positions := (|s| + 1);
      if (occurrence >= 0) { out := (if (occurrence < positions) then occurrence else |s|); return; }
      if (occurrence < -(positions)) { out := |s|; return; }
      assert occurrence > -W.Half;
      out := (positions - -(occurrence));
      return;
    }
    M.PositionsBounds(s,needle,0);
    var wanted := 0;
    if (occurrence < 0) {
      var count := Count(s,needle,sOffset,needleOffset,outsideS,outsideNeedle);
      if (occurrence < -(count)) { out := |s|; return; }
      assert occurrence > -W.Half;
      wanted := (count - -(occurrence));
    } else { wanted := occurrence; }
    assert wanted == (if occurrence >= 0 then occurrence else |M.Positions(s,needle,0)|+occurrence);
    var seen := 0;
    var p := 0;
    ghost var hits: seq<nat> := [];
    while ((p + |needle|) <= |s|)
      invariant 0 <= p <= |s|
      invariant seen == |hits|
      invariant M.Positions(s,needle,0) == hits+M.Positions(s,needle,p)
      invariant seen <= wanted
      decreases |s|-p
    {
      assert p+|needle| < W.Word;
      var matched := S.Match(s,needle,p,sOffset,needleOffset,outsideS,outsideNeedle);
      M.ScanStep(s,needle,p,hits);
      if matched {
        if (seen == wanted) { out := p; return; }
        assert seen+1 < W.Word;
        seen := seen+1;
        hits := hits+[p];
        p := (p + |needle|);
      } else { p := p+1; }
    }
    assert M.Positions(s,needle,p) == [];
    assert wanted >= |M.Positions(s,needle,0)|;
    out := |s|;
  }
}
