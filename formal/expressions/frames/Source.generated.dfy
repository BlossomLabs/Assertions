// SPDX-License-Identifier: MIT
// Recursive source control from Expressions.sol dc53eb78d3550ded3d9dce3f61172a9a16e103a6be33cea95b1de04701c7124d.
// Primitive receipts, memory projection and manual lowering remain explicit assumptions.
include "Model.dfy"
module ExpressionFramesSource {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import F = ExpressionFramesModel
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

  ghost method Run(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                   oracle: (Request,seq<Request>)->Raw, index: nat,
                   memo: map<nat,Value>, history: seq<Request>, guardOwner: int) returns (out: Result, frames: seq<F.Frame>)
    requires Program(nodes) && index < |nodes| && Good(nodes,valid,memo)
    requires F.Origin(nodes,index,guardOwner)
    ensures Good(nodes,valid,out.memo) && Extends(memo,out.memo) && Footprint(memo,out.memo,index)
    ensures out.Success? ==> index in out.memo && out.memo[index] == out.value && valid(index,out.value)
    ensures index in memo ==> out == Success(memo[index],memo,history)
    ensures history <= out.history
    ensures out == S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,history)
    ensures frames == F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,guardOwner)
    ensures F.Safe(nodes,valid,memo,history,index,frames)
    ensures |frames| > 0 && frames[0] == F.Frame(index,memo,history,guardOwner)
    decreases index
  {
    frames := [F.Frame(index,memo,history,guardOwner)];
    if index in memo { out := Success(memo[index],memo,history); return; }
    var expected := S.Body(nodes,valid,truth,reject,oracle,index,memo,history);
    var node := nodes[index];
    var working := memo;
    var seen := history;
    var values: seq<Value> := [];
    var value: Value := [];
    if node.kind == Select {
      var cond,condFrames := Run(nodes,valid,truth,reject,oracle,node.refs[0],working,seen,-1);
      F.Append(nodes,valid,memo,history,index,frames,working,seen,node.refs[0],condFrames);
      frames := frames+condFrames;
      if cond.Failure? { out := cond; return; }
      var branch := Choose(cond.value,truth,node.refs);
      var selected,selectedFrames := Run(nodes,valid,truth,reject,oracle,branch,cond.memo,cond.history,-1);
      F.Append(nodes,valid,memo,history,index,frames,cond.memo,cond.history,branch,selectedFrames);
      frames := frames+selectedFrames;
      Compose(memo,cond.memo,selected.memo,index);
      if selected.Failure? { out := selected; return; }
      working := selected.memo; seen := selected.history; value := selected.value;
    } else if node.kind == TryOrElse || node.kind == IsValid {
      var attempted,attemptedFrames := Run(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,index);
      F.Append(nodes,valid,memo,history,index,frames,memo,history,node.refs[0],attemptedFrames);
      frames := frames+attemptedFrames;
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
        var fallback,fallbackFrames := Run(nodes,valid,truth,reject,oracle,node.refs[1],working,seen,-1);
        F.Append(nodes,valid,memo,history,index,frames,working,seen,node.refs[1],fallbackFrames);
        frames := frames+fallbackFrames;
        if fallback.Failure? { out := fallback; return; }
        working := fallback.memo; seen := fallback.history; value := fallback.value;
      }
    } else {
      var pos: nat := 0;
      while pos < |node.refs|
        invariant 0 <= pos <= |node.refs|
        invariant |values| == pos
        invariant frames+F.GatherTrace(nodes,valid,truth,reject,oracle,index,pos,working,seen) == F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,guardOwner)
        invariant F.Safe(nodes,valid,memo,history,index,frames)
        invariant |frames| > 0 && frames[0] == F.Frame(index,memo,history,guardOwner)
        invariant Good(nodes,valid,working) && Extends(memo,working) && Footprint(memo,working,index)
        invariant index !in working
        invariant history <= seen
        invariant S.Gather(nodes,valid,truth,reject,oracle,index,pos,values,working,seen) == S.Gather(nodes,valid,truth,reject,oracle,index,0,[],memo,history)
      {
        var remaining := S.Gather(nodes,valid,truth,reject,oracle,index,pos,values,working,seen);
        var childIndex := if node.kind == Call && pos > 0 then node.refs[pos - 1 + 1] else node.refs[pos];
        var child,childFrames := Run(nodes,valid,truth,reject,oracle,childIndex,working,seen,-1);
        F.Append(nodes,valid,memo,history,index,frames,working,seen,childIndex,childFrames);
        frames := frames+childFrames;
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
    assert expected == Success(value,working,seen);
    assert index !in working;
    if true && !valid(index,value) {
      // The actual validation rejection is supplied by the codec receipt adapter.
      out := Failure(reject(index,value),working,seen); return;
    }
    var updated := working[index := value];
    out := Success(value,updated,seen);
  }
}
