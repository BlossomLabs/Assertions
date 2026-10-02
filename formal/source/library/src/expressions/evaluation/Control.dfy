// SPDX-License-Identifier: MIT
// Recursive control invariant. Primitive/codec correspondence is a separate obligation.
include "../../foundations/SourceMemoOrderV3.dfy"
module ExpressionEvaluationControl {
  import F = SourceMemoOrderV3
  type Value = seq<int>
  datatype Kind = Literal | Parameter | Resolve | Call | Select | Wrap | Array | Tuple | TryOrElse | IsValid | ProbeCall
  datatype Node = Node(kind: Kind, refs: seq<nat>)
  datatype Error = Error(payload: Value)
  datatype Stage = Leaf | Address | Finish | Boolean | GuardFailure
  datatype Request = Request(node: nat, stage: Stage, arguments: seq<Value>)
  datatype Raw = Produced(value: Value) | Aborted(error: Error)
  datatype Result = Success(value: Value, memo: map<nat,Value>, history: seq<Request>)
                  | Failure(error: Error, memo: map<nat,Value>, history: seq<Request>)

  predicate Program(nodes: seq<Node>) {
    forall i | 0 <= i < |nodes| ::
      (forall j | 0 <= j < |nodes[i].refs| :: nodes[i].refs[j] < i) &&
      (match nodes[i].kind
       case Literal => |nodes[i].refs| == 0
       case Parameter => |nodes[i].refs| == 0
       case Resolve => |nodes[i].refs| == 0
       case Select => |nodes[i].refs| == 3
       case TryOrElse => |nodes[i].refs| == 2
       case IsValid => |nodes[i].refs| == 1
       case Wrap => |nodes[i].refs| == 1
       case ProbeCall => |nodes[i].refs| == 2
       case Call => |nodes[i].refs| >= 1
       case _ => true)
  }

  predicate Good(nodes: seq<Node>, valid: (nat,Value)->bool, memo: map<nat,Value>) {
    forall i | i in memo :: i < |nodes| && valid(i,memo[i])
  }

  predicate Extends(a: map<nat,Value>, b: map<nat,Value>) {
    a.Keys <= b.Keys && forall i | i in a :: b[i] == a[i]
  }

  predicate Footprint(a: map<nat,Value>, b: map<nat,Value>, bound: nat) {
    forall i | i in b && i !in a :: i <= bound
  }

  lemma Compose(a: map<nat,Value>, b: map<nat,Value>, c: map<nat,Value>, bound: nat)
    requires Extends(a,b) && Extends(b,c)
    requires Footprint(a,b,bound) && Footprint(b,c,bound)
    ensures Extends(a,c) && Footprint(a,c,bound)
  {
    F.ExtensionsCompose(a,b,c);
    F.FootprintsCompose(a,b,c,bound);
  }

  ghost method Choose(condition: Value, truth: Value->bool, refs: seq<nat>) returns (selected: nat)
    requires |refs| == 3
    ensures selected == refs[if truth(condition) then 1 else 2]
  { selected := refs[if truth(condition) then 1 else 2]; }

  ghost method GuardCache(original: map<nat,Value>, attempted: Result) returns (working: map<nat,Value>)
    ensures working == (if attempted.Success? then attempted.memo else original)
  {
    working := original;
    if attempted.Success? { working := attempted.memo; }
  }

  ghost method Run(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                   oracle: (Request,seq<Request>)->Raw, index: nat,
                   memo: map<nat,Value>, history: seq<Request>) returns (out: Result)
    requires Program(nodes) && index < |nodes| && Good(nodes,valid,memo)
    ensures Good(nodes,valid,out.memo) && Extends(memo,out.memo) && Footprint(memo,out.memo,index)
    ensures out.Success? ==> index in out.memo && out.memo[index] == out.value && valid(index,out.value)
    ensures index in memo ==> out == Success(memo[index],memo,history)
    ensures history <= out.history
    decreases index
  {
    if index in memo { out := Success(memo[index],memo,history); return; }
    var node := nodes[index];
    var working := memo;
    var seen := history;
    var values: seq<Value> := [];
    var value: Value := [];
    if node.kind == Select {
      var cond := Run(nodes,valid,truth,oracle,node.refs[0],working,seen);
      if cond.Failure? { out := cond; return; }
      var branch := Choose(cond.value,truth,node.refs);
      var selected := Run(nodes,valid,truth,oracle,branch,cond.memo,cond.history);
      Compose(memo,cond.memo,selected.memo,index);
      if selected.Failure? { out := selected; return; }
      working := selected.memo; seen := selected.history; value := selected.value;
    } else if node.kind == TryOrElse || node.kind == IsValid {
      var attempted := Run(nodes,valid,truth,oracle,node.refs[0],memo,history);
      seen := attempted.history;
      if attempted.Failure? {
        // Classify this boundary's sampled gas and revert bytes, not merely
        // the error's origin. The primitive adapter supplies that receipt.
        var request := Request(index,GuardFailure,[attempted.error.payload]);
        var raw := oracle(request,seen); seen := seen+[request];
        if raw.Aborted? { out := Failure(raw.error,memo,seen); return; }
      }
      working := GuardCache(memo,attempted);
      // Ordinary failure deliberately leaves working equal to the original memo.
      if node.kind == IsValid {
        var request := Request(index,Boolean,[if attempted.Success? then [1] else [0]]);
        var raw := oracle(request,seen); seen := seen+[request];
        if raw.Aborted? { out := Failure(raw.error,working,seen); return; }
        value := raw.value;
      } else if attempted.Success? {
        value := attempted.value;
      } else {
        assert working == memo;
        var fallback := Run(nodes,valid,truth,oracle,node.refs[1],working,seen);
        if fallback.Failure? { out := fallback; return; }
        working := fallback.memo; seen := fallback.history; value := fallback.value;
      }
    } else {
      var pos: nat := 0;
      while pos < |node.refs|
        invariant 0 <= pos <= |node.refs|
        invariant |values| == pos
        invariant Good(nodes,valid,working)
        invariant Extends(memo,working)
        invariant Footprint(memo,working,index)
        invariant index !in working
        invariant history <= seen
      {
        var child := Run(nodes,valid,truth,oracle,node.refs[pos],working,seen);
        assert index !in child.memo;
        Compose(memo,working,child.memo,index);
        working := child.memo; seen := child.history;
        if child.Failure? { out := child; return; }
        values := values+[child.value];
        if pos == 0 && node.kind in {Call,ProbeCall} {
          // Address decoding precedes evaluation of remaining argument/calldata nodes.
          var request := Request(index,Address,[child.value]);
          var raw := oracle(request,seen); seen := seen+[request];
          if raw.Aborted? { out := Failure(raw.error,working,seen); return; }
        }
        pos := pos+1;
      }
      var stage := if node.kind in {Literal,Parameter,Resolve} then Leaf else Finish;
      var request := Request(index,stage,values);
      var raw := oracle(request,seen); seen := seen+[request];
      if raw.Aborted? { out := Failure(raw.error,working,seen); return; }
      value := raw.value;
    }
    assert index !in working;
    if !valid(index,value) {
      // Abstract validation error; exact codec payload remains a bridge obligation.
      out := Failure(Error([index]),working,seen); return;
    }
    var updated := working[index := value];
    out := Success(value,updated,seen);
  }
}
