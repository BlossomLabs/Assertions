include "../word-match/Connection.dfy"
module OperationsOccurrenceModel {
  import W = OperationsWordMatchModel
  function Positions(s: seq<bv8>,needle: seq<bv8>,p: nat): seq<nat>
    requires |needle| > 0 && p <= |s|
    decreases |s|-p
  {
    if p+|needle| > |s| then []
    else if W.Matches(s,needle,p) then [p]+Positions(s,needle,p+|needle|)
    else Positions(s,needle,p+1)
  }
  function Index(s: seq<bv8>,needle: seq<bv8>,occurrence: int): nat {
    if |needle| == 0 then
      var wanted := if occurrence >= 0 then occurrence else |s|+1+occurrence;
      if 0 <= wanted <= |s| then wanted else |s|
    else
      var positions := Positions(s,needle,0);
      var wanted := if occurrence >= 0 then occurrence else |positions|+occurrence;
      if 0 <= wanted < |positions| then positions[wanted] else |s|
  }
  lemma PositionsBounds(s: seq<bv8>,needle: seq<bv8>,p: nat)
    requires |needle| > 0 && p <= |s|
    ensures |Positions(s,needle,p)|*|needle| <= |s|-p
    ensures |Positions(s,needle,p)| <= |s|-p
    ensures forall i | 0 <= i < |Positions(s,needle,p)| :: p <= Positions(s,needle,p)[i] && Positions(s,needle,p)[i]+|needle| <= |s| && W.Matches(s,needle,Positions(s,needle,p)[i])
    ensures forall i | 0 <= i && i+1 < |Positions(s,needle,p)| :: Positions(s,needle,p)[i]+|needle| <= Positions(s,needle,p)[i+1]
    decreases |s|-p
  {
    if p+|needle| <= |s| {
      if W.Matches(s,needle,p) {
        PositionsBounds(s,needle,p+|needle|);
        assert (1+|Positions(s,needle,p+|needle|)|)*|needle| == |needle|+|Positions(s,needle,p+|needle|)|*|needle|;
      } else { PositionsBounds(s,needle,p+1); }
    }
  }
  lemma IndexBounds(s: seq<bv8>,needle: seq<bv8>,occurrence: int)
    ensures Index(s,needle,occurrence) <= |s|
  { if |needle| > 0 { PositionsBounds(s,needle,0); } }
  lemma ScanStep(s: seq<bv8>,needle: seq<bv8>,p: nat,hits: seq<nat>)
    requires |needle| > 0 && p+|needle| <= |s|
    requires Positions(s,needle,0) == hits+Positions(s,needle,p)
    ensures W.Matches(s,needle,p) ==> Positions(s,needle,0) == (hits+[p])+Positions(s,needle,p+|needle|)
    ensures !W.Matches(s,needle,p) ==> Positions(s,needle,0) == hits+Positions(s,needle,p+1)
    ensures W.Matches(s,needle,p) ==> |hits| < |Positions(s,needle,0)| && Positions(s,needle,0)[|hits|] == p
  { }
}
