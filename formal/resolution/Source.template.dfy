// SPDX-License-Identifier: MIT
// Gated production source translation; Assertions.sol SHA-256: $HASH
include "Model.dfy"
include "../constraints/Engine.generated.dfy"
module ResolutionSource {
  import opened ConstraintModel
  import opened ResolutionWords
  import opened ResolutionModel
  import Constraints = ConstraintEngine

  ghost method StaticCall(target: Address, data: seq<Byte>, env: Environment, history: seq<Request>) returns (out: Outcome)
    ensures out == CallSpec(target,data,env,history)
  {
    var request := Call(target,data);
    var observed := env.call(history,request);
    var after := history+[request];
    if !observed.codePresent { out := Outcome(Failed(CallFailed(target,data)),after); return; }
    if !observed.success {
      var head := if |observed.data| == 4 then observed.data else [0,0,0,0];
      if $EXHAUSTED { out := Outcome(Failed(SubcallOutOfGas),after); return; }
      out := Outcome(Failed(CallFailed(target,data)),after); return;
    }
    out := Outcome(Value(observed.data),after);
  }

  ghost method First(data: seq<Byte>) returns (out: ValueResult)
    ensures out == FirstWord(data)
  {
    if $SHORT_WORD { out := Failed(ResolutionModel.Error.ReturnDataOutOfBounds(0,|data|)); return; }
    var word := Read(data[..32]);
    out := Value(EncodeWord(word));
  }

  ghost method ResolveSource(param: Param, context: Context, env: Environment, history: seq<Request>) returns (out: Outcome)
    ensures out == Resolve(param,context,env,history)
  {
    var value: seq<Byte>;
    var after := history;
    if param.fetcher == RAW_BYTES {
      value := param.data;
    } else if param.fetcher == STATIC_CALL {
      var decoded := env.decodeCall(param.data);
      if decoded.MalformedCall? { out := Outcome(Failed(ResolutionModel.Error.BareRevert),history); return; }
      var called := StaticCall(decoded.target,decoded.data,env,history);
      if called.result.Failed? { out := called; return; }
      value := called.result.bytes;
      after := called.history;
    } else {
      if $BALANCE_LENGTH { out := Outcome(Failed(InvalidBalanceData(context.entry,context.param,|param.data|)),history); return; }
      AddressFits(param.data[..20]); AddressFits(param.data[20..]);
      var token := AddressOf(param.data[..20]);
      var account := AddressOf(param.data[20..]);
      if token == 0 {
        value := EncodeWord(env.balance(history,account));
        after := history+[NativeBalance(account)];
      } else {
        var called := StaticCall(token,BalanceCall(account),env,history);
        if called.result.Failed? { out := called; return; }
        var first := First(called.result.bytes);
        if first.Failed? { out := Outcome(first,called.history); return; }
        value := first.bytes;
        after := called.history;
      }
    }
    assert Fetch(param,context,env,history) == Outcome(Value(value),after);
    var checked := Constraints.JudgeResolved(param.constraints,value,env.decodeOr,context);
    if checked.Reverted? { out := Outcome(Failed(ConstraintError(checked.error)),after); return; }
    out := Outcome(Value(value),after);
  }

  ghost method RouteParams(params: seq<Param>, message: seq<Byte>, entry: nat, initial: Build, env: Environment, history: seq<Request>) returns (out: Routed)
    ensures out == RouteAll(params,message,entry,0,initial,env,history)
  {
    var build := initial;
    var after := history;
    var j := 0;
    while j < |params|
      invariant 0 <= j <= |params|
      invariant RouteAll(params,message,entry,0,initial,env,history) == RouteAll(params,message,entry,j,build,env,after)
    {
      var param := params[j];
      if param.route == VALUE { out := RouteFailed(ValueParamNotSupported(entry,j),after); return; }
      var next: Build;
      var nextHistory: seq<Request>;
      if param.route == TARGET {
        if build.hasTarget { out := RouteFailed(DuplicateTargetParam(entry),after); return; }
        if param.fetcher == BALANCE { out := RouteFailed(BalanceCannotBeTarget(entry,j),after); return; }
        var resolved := ResolveSource(param,Context(message,entry,j),env,after);
        if resolved.result.Failed? { out := RouteFailed(resolved.result.error,resolved.history); return; }
        var value := resolved.result.bytes;
        var first := First(value);
        if first.Failed? { out := RouteFailed(first.error,resolved.history); return; }
        var word := Read(value[..32]);
        if $DIRTY_ADDRESS { out := RouteFailed(InvalidAddressWord(j,word),resolved.history); return; }
        next := Build(word,true,build.data);
        nextHistory := resolved.history;
      } else {
        var resolved := ResolveSource(param,Context(message,entry,j),env,after);
        if resolved.result.Failed? { out := RouteFailed(resolved.result.error,resolved.history); return; }
        next := Build(build.target,build.hasTarget,build.data+resolved.result.bytes);
        nextHistory := resolved.history;
      }
      assert RouteOne(param,message,entry,j,build,env,after) == Built(next,nextHistory);
      build := next;
      after := nextHistory;
      j := j+1;
    }
    out := Built(build,after);
  }

  ghost method EntrySource(entry: Entry, message: seq<Byte>, index: nat, env: Environment, history: seq<Request>) returns (out: Outcome)
    ensures out == JudgeEntry(entry,message,index,env,history)
  {
    if entry.outputs != 0 { out := Outcome(Failed(OutputParamsNotSupported(index)),history); return; }
    var routed := RouteParams(entry.params,message,index,Build(0,false,entry.selector),env,history);
    if routed.RouteFailed? { out := Outcome(Failed(routed.error),routed.history); return; }
    if $HAS_CALL {
      var called := StaticCall(routed.build.target,routed.build.data,env,routed.history);
      if called.result.Failed? { out := called; return; }
      out := Outcome(Value([]),called.history); return;
    }
    out := Outcome(Value([]),routed.history);
  }

  ghost method JudgeBatch(entries: seq<Entry>, message: seq<Byte>, env: Environment, history: seq<Request>) returns (out: Outcome)
    ensures out == Batch(entries,message,0,env,history)
  {
    var i := 0;
    var after := history;
    while i < |entries|
      invariant 0 <= i <= |entries|
      invariant Batch(entries,message,0,env,history) == Batch(entries,message,i,env,after)
    {
      var entry := EntrySource(entries[i],message,i,env,after);
      if entry.result.Failed? { out := entry; return; }
      after := entry.history;
      i := i+1;
    }
    out := Outcome(Value([]),after);
  }

  ghost method AssertOne(param: Param, message: seq<Byte>, env: Environment, history: seq<Request>) returns (out: Outcome)
    ensures out == AssertParam(param,message,env,history)
  {
    var resolved := ResolveSource(param,Context(message,0,0),env,history);
    out := if resolved.result.Failed? then resolved else Outcome(Value([]),resolved.history);
  }
  ghost method DefaultParam(param: Param, env: Environment, history: seq<Request>) returns (out: Outcome)
    ensures out == AssertParam(param,[80,65,82,65,77],env,history)
  {
    out := AssertOne(param,$PARAM_MESSAGE,env,history);
  }

  ghost method DefaultBatch(entries: seq<Entry>, env: Environment, history: seq<Request>) returns (out: Outcome)
    ensures out == Batch(entries,[67,79,77,80,79,83,65,66,76,69],0,env,history)
  {
    out := JudgeBatch(entries,$BATCH_MESSAGE,env,history);
  }

}
