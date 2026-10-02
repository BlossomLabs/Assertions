// SPDX-License-Identifier: MIT
include "Loops.dfy"

module CollectionsTraversalProperties {
  import opened AbiFrames
  import opened CollectionsTraversalModel

  function Calls(history: seq<Request>): seq<nat>
    decreases |history|
  {
    if |history| == 0 then [] else
    Calls(history[..|history|-1]) +
    (if history[|history|-1].Call? || history[|history|-1].Predicate? then [history[|history|-1].index] else [])
  }
  lemma AppendCall(history: seq<Request>, request: Request)
    ensures Calls(history+[request]) == Calls(history)+(if request.Call? || request.Predicate? then [request.index] else [])
  {
    assert (history+[request])[..|history|] == history;
  }
  function Range(start: nat, end: nat): seq<nat>
    requires start <= end
  { seq(end-start,i requires 0 <= i < end-start => start+i) }
  lemma RangeStep(start: nat, end: nat)
    requires start < end
    ensures Range(start,end) == [start]+Range(start+1,end)
  {
    assert Range(start,end)[0] == start;
    assert Range(start,end)[1..] == Range(start+1,end);
  }
  lemma StepFacts(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, value: seq<Byte>, index: nat, acc: seq<Byte>, c: Context, env: Environment)
    ensures c.history <= Step(mode,inputType,outputType,value,index,acc,c,env).context.history
    ensures var out := Step(mode,inputType,outputType,value,index,acc,c,env);
            Calls(out.context.history) == Calls(c.history) || Calls(out.context.history) == Calls(c.history)+[index]
    ensures var out := Step(mode,inputType,outputType,value,index,acc,c,env);
            out.Success? ==> Calls(out.context.history) == Calls(c.history)+[index]
    ensures var out := Step(mode,inputType,outputType,value,index,acc,c,env);
            out.Success? && mode != Fold ==> out.accumulator == acc
    ensures var out := Step(mode,inputType,outputType,value,index,acc,c,env);
            out.Success? && mode == Map ==> |out.values| == 1
    ensures var out := Step(mode,inputType,outputType,value,index,acc,c,env);
            out.Success? && mode == Filter ==> out.values == [] || out.values == [value]
    ensures var out := Step(mode,inputType,outputType,value,index,acc,c,env);
            out.Success? && mode == Fold ==> out.values == []
  {
    var q1 := Validate(inputType,value);
    var first := Ask(q1,c,env);
    AppendCall(c.history,q1);
    if first.reply.Error? { return; }
    var q2 := if mode == Filter then Predicate(value,[],false,index,0) else
    if mode == Map then Call(value,[],false,index,0) else Call(acc,value,true,index,0);
    var second := Ask(q2,first.context,env);
    AppendCall(first.context.history,q2);
    if second.reply.Error? || mode == Filter { return; }
    AppendCall(second.context.history,ValidateResult(outputType,second.reply.value,index));
  }

  ghost method TailFacts(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, index: nat, acc: seq<Byte>, c: Context, env: Environment)
    returns (out: Outcome, positions: seq<nat>, stop: nat)
    requires index <= |values|
    ensures out == Tail(mode,inputType,outputType,values,index,acc,c,env)
    ensures index <= stop <= |values|
    ensures c.history <= out.context.history
    ensures Calls(out.context.history) == Calls(c.history)+Range(index,stop)
    ensures out.Success? ==> stop == |values|
    ensures out.Success? && mode == Map ==> |out.values| == |values|-index && out.accumulator == acc
    ensures out.Success? && mode == Fold ==> out.values == []
    ensures out.Success? && mode == Filter ==> out.accumulator == acc && |positions| == |out.values| &&
                                               (forall j :: 0 <= j < |positions| ==> index <= positions[j] < |values| && out.values[j] == values[positions[j]]) &&
                                               (forall j :: 0 <= j < |positions|-1 ==> positions[j] < positions[j+1])
    decreases |values|-index
  {
    out := Tail(mode,inputType,outputType,values,index,acc,c,env);
    positions := [];
    stop := index;
    if index == |values| { return; }
    var next := Step(mode,inputType,outputType,values[index],index,acc,c,env);
    StepFacts(mode,inputType,outputType,values[index],index,acc,c,env);
    if next.Failure? {
      if Calls(next.context.history) != Calls(c.history) {
        stop := index+1;
        RangeStep(index,stop);
      }
      return;
    }
    var suffix,kept,last := TailFacts(mode,inputType,outputType,values,index+1,next.accumulator,next.context,env);
    stop := last;
    RangeStep(index,stop);
    if out.Success? && mode == Filter {
      if |next.values| == 0 { positions := kept; } else {
        positions := [index]+kept;
        assert out.values == [values[index]]+suffix.values;
        forall j | 0 <= j < |positions|
          ensures index <= positions[j] < |values| && out.values[j] == values[positions[j]]
        {
          if j > 0 { assert positions[j] == kept[j-1]; }
        }
        forall j | 0 <= j < |positions|-1
          ensures positions[j] < positions[j+1]
        {
          if j > 0 { assert positions[j] == kept[j-1] && positions[j+1] == kept[j]; }
        }
      }
    }
  }
}
