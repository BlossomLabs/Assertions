include "../occurrence-index/Connection.dfy"
module OperationsSplitModel {
  import W = OperationsWordMatchModel
  import O = OperationsOccurrenceModel
  datatype Outcome = Parts(data: seq<seq<bv8>>) | EmptyNeedle
  function Tail(s: seq<bv8>,delimiter: seq<bv8>,start: nat,p: nat): seq<seq<bv8>>
    requires |delimiter| > 0 && start <= p <= |s|
    decreases |s|-p
  {
    if p+|delimiter| > |s| then [s[start..]]
    else if W.Matches(s,delimiter,p) then [s[start..p]]+Tail(s,delimiter,p+|delimiter|,p+|delimiter|)
    else Tail(s,delimiter,start,p+1)
  }
  function Join(parts: seq<seq<bv8>>,delimiter: seq<bv8>): seq<bv8>
    decreases |parts|
  { if |parts| == 0 then [] else parts[0]+(if |parts| == 1 then [] else delimiter+Join(parts[1..],delimiter)) }
  function Spec(s: seq<bv8>,delimiter: seq<bv8>): Outcome
  { if |delimiter| == 0 then EmptyNeedle else Parts(Tail(s,delimiter,0,0)) }
  lemma TailProperties(s: seq<bv8>,delimiter: seq<bv8>,start: nat,p: nat)
    requires |delimiter| > 0 && start <= p <= |s|
    ensures |Tail(s,delimiter,start,p)| == 1+|O.Positions(s,delimiter,p)|
    ensures Join(Tail(s,delimiter,start,p),delimiter) == s[start..]
    decreases |s|-p
  {
    if p+|delimiter| <= |s| {
      if W.Matches(s,delimiter,p) {
        TailProperties(s,delimiter,p+|delimiter|,p+|delimiter|);
        assert s[p..p+|delimiter|] == delimiter;
        assert s[start..] == s[start..p]+s[p..p+|delimiter|]+s[p+|delimiter|..];
      } else { TailProperties(s,delimiter,start,p+1); }
    }
  }
}
