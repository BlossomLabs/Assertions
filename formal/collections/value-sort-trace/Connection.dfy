// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsValueSortTraceConnection {
  import opened AbiFrames
  import opened CollectionsValueSortTraceModel
  import S = CollectionsValueSortTraceSource
  import C = CollectionsSortModel
  import R = CollectionsSortRanges
  ghost method Run(n: nat,env: Environment,le: (nat,nat)->bool) returns (out: Outcome)
    requires CountRoom(n)
    ensures out == Sort(C.Range(0,n),1,[],env)
    ensures Extends([],out.trace,env) && Stopped(out)
    ensures out.Success? ==> |out.ids| == n && multiset(out.ids) == multiset(C.Range(0,n))
    ensures out.Success? ==> (forall i :: 0 <= i < |out.ids| ==> out.ids[i] < n)
    ensures out.Success? ==> (forall i,j :: 0 <= i < j < |out.ids| ==> out.ids[i] != out.ids[j])
    ensures out.Success? && Coherent(out.trace,le) && C.Order(n,le) ==>
              (forall i,j :: 0 <= i < j < |out.ids| ==> le(out.ids[i],out.ids[j]) && (le(out.ids[j],out.ids[i]) ==> out.ids[i] < out.ids[j]))
    ensures out.Failure? ==> |out.trace| > 0 && Clear(out.trace[..|out.trace|-1]) && out.trace[|out.trace|-1].choice == Rejected(out.reason)
    ensures n < 2 ==> out == Success(C.Range(0,n),[])
  {
    out := S.Sort(n,env,le);
    if out.Success? { R.Verdict(n,le,out.ids); }
  }
  ghost method {:fuel Sort, 5} {:fuel Pass, 6} {:fuel Merge, 6} LaterFailure(reason: seq<Byte>) returns (out: Outcome)
    ensures out == Failure(reason,[Row(Request(0,1,0,1),Chosen(false)),Row(Request(2,3,2,3),Chosen(false)),Row(Request(0,2,1,3),Rejected(reason))])
  {
    var env := (trace: seq<Row>,q: Request) => if |trace| < 2 then Chosen(false) else Rejected(reason);
    out := S.Sort(4,env,(a: nat,b: nat) => a <= b);
    assert C.Range(0,4) == [0,1,2,3];
  }
  ghost method {:fuel Sort, 3} {:fuel Pass, 4} {:fuel Merge, 4} Inconsistent() returns (out: Outcome)
    ensures out.Success? && out.ids == [1,0]
    ensures !Coherent(out.trace,(a: nat,b: nat) => a <= b)
  {
    out := S.Sort(2,(trace: seq<Row>,q: Request) => Chosen(false),(a: nat,b: nat) => a <= b);
    assert C.Range(0,2) == [0,1];
  }
}
