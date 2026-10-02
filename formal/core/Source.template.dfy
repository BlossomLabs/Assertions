// SPDX-License-Identifier: MIT
// Gated Assertions.sol source SHA-256: $HASH
include "Model.dfy"
include "../resolution/Source.generated.dfy"
module CoreSource {
  import opened ConstraintModel
  import opened ResolutionWords
  import opened ResolutionModel
  import opened CoreWords
  import opened CoreModel
  import Resolver = ResolutionSource

  ghost method ResolveRaw(param: Param, env: Environment, history: seq<Request>) returns (out: CoreOutcome)
    ensures out == PublicResolve(param,env,history)
  {
    var resolved := Resolver.ResolveSource(param,Context([],0,0),env,history);
    out := FromResolver(resolved);
  }

  ghost method CleanAddress(data: seq<Byte>, index: nat) returns (out: CoreModel.AddressResult)
    ensures out == AddressFrom(data,index)
  {
    var first := Resolver.First(data);
    if first.Failed? { out := BadAddress(Base(first.error)); return; }
    var word := Read(data[..32]);
    if $DIRTY_ADDRESS { out := BadAddress(Base(InvalidAddressWord(index,word))); return; }
    out := Addressed(word);
  }

  ghost method WordAt(data: seq<Byte>, index: int) returns (r: WordResult)
    requires |data| < Limit() && SignedIndex(index)
    ensures r == SelectWord(data,index)
  {
    var words := |data|/32;
    assert words < Half();
    var wanted: nat;
    if index < 0 {
      if index < -(words as int) { r := OutOfBounds(index,|data|); return; }
      assert -(Half() as int) < index;
      wanted := $NEGATIVE_INDEX;
    } else {
      if index >= words { r := OutOfBounds(index,|data|); return; }
      wanted := index;
    }
    assert 32*wanted+32 <= |data|;
    r := Got(Read(data[32*wanted..32*wanted+32]));
  }

  ghost method PickWord(param: Param, index: int, env: Environment, history: seq<Request>) returns (out: CoreOutcome)
    requires SignedIndex(index)
    requires PublicResolve(param,env,history).result.Bytes? ==> |PublicResolve(param,env,history).result.data| < Limit()
    ensures out == Pick(param,index,env,history)
  {
    var resolved := ResolveRaw(param,env,history);
    if resolved.result.Failed? { out := resolved; return; }
    var word := WordAt(resolved.result.data,index);
    out := CoreOutcome(if word.Got? then Bytes(EncodeWord(word.word)) else CoreResult.Failed(Base(ResolutionModel.Error.ReturnDataOutOfBounds(index,|resolved.result.data|))),resolved.history);
  }

  // The gather loop is instantiated at offset zero. Other consumers must
  // establish their own source connection before using this generalized helper.
  ghost method CollectValues(params: seq<Param>, offset: nat, env: Environment, history: seq<Request>) returns (out: ValuesResult)
    ensures out == Collect(params,0,offset,env,history)
  {
    var i := 0;
    var after := history;
    var values: seq<seq<Byte>> := [];
    while i < |params|
      invariant 0 <= i <= |params|
      invariant |values| == i
      invariant Collect(params,0,offset,env,history) == Prepend(values,Collect(params,i,offset,env,after))
    {
      var resolved := Resolver.ResolveSource(params[i],Context([],0,i+offset),env,after);
      if resolved.result.Failed? { out := ValuesFailed(Base(resolved.result.error),resolved.history); return; }
      values := values+[resolved.result.bytes];
      after := resolved.history;
      i := i+1;
    }
    out := Values(values,after);
  }

  ghost method Gather(params: seq<Param>, env: Environment, history: seq<Request>) returns (out: ValuesResult)
    ensures out == Collect(params,0,0,env,history)
  { out := CollectValues(params,0,env,history); }

  ghost method ReadSegments(target: Param, selector: seq<Byte>, args: seq<Param>, env: Environment, history: seq<Request>) returns (out: CoreOutcome)
    ensures out == ReadCall(target,selector,args,env,history)
  {
    var resolved := ResolveRaw(target,env,history);
    if resolved.result.Failed? { out := resolved; return; }
    var address := CleanAddress(resolved.result.data,0);
    if address.BadAddress? { out := CoreOutcome(CoreResult.Failed(address.error),resolved.history); return; }
    var data := selector;
    var after := resolved.history;
    var i := 0;
    while i < |args|
      invariant 0 <= i <= |args|
      invariant Segments(selector,Collect(args,0,1,env,resolved.history)) == Segments(data,Collect(args,i,1,env,after))
    {
      var value := Resolver.ResolveSource(args[i],Context([],0,$READ_INDEX),env,after);
      if value.result.Failed? { out := FromResolver(value); return; }
      SegmentStep(data,value.result.bytes,Collect(args,i+1,1,env,value.history));
      data := data+value.result.bytes;
      after := value.history;
      i := i+1;
    }
    assert Collect(args,i,1,env,after) == Values([],after);
    assert Concat([]) == [];
    EmptySegments(data,after);
    assert Segments(selector,Collect(args,0,1,env,resolved.history)) == CoreOutcome(Bytes(data),after);
    assert Collect(args,0,1,env,resolved.history).Values?;
    var called := Resolver.StaticCall(address.address,data,env,after);
    out := FromResolver(called);
  }

  ghost method CallChain(target: Param, calls: seq<seq<Byte>>, env: Environment, history: seq<Request>) returns (out: CoreOutcome)
    ensures out == Chain(target,calls,env,history)
  {
    if |calls| == 0 { out := CoreOutcome(CoreResult.Failed(EmptyCallChain),history); return; }
    var resolved := ResolveRaw(target,env,history);
    if resolved.result.Failed? { out := resolved; return; }
    var address := CleanAddress(resolved.result.data,0);
    if address.BadAddress? { out := CoreOutcome(CoreResult.Failed(address.error),resolved.history); return; }
    var current := address.address;
    var after := resolved.history;
    var last := |calls|-1;
    var i := 0;
    while i < last
      invariant 0 <= i <= last < |calls|
      invariant Hops(address.address,calls,0,env,resolved.history) == Hops(current,calls,i,env,after)
    {
      var called := Resolver.StaticCall(current,calls[i],env,after);
      if called.result.Failed? { out := FromResolver(called); return; }
      var next := CleanAddress(called.result.bytes,$HOP_INDEX);
      if next.BadAddress? { out := CoreOutcome(CoreResult.Failed(next.error),called.history); return; }
      current := next.address;
      after := called.history;
      i := i+1;
    }
    var finalCall := Resolver.StaticCall(current,calls[last],env,after);
    out := FromResolver(finalCall);
  }

  ghost method Cond(condition: Param, yes: Param, no: Param, env: Environment, history: seq<Request>) returns (out: CoreOutcome)
    ensures out == Conditional(condition,yes,no,env,history)
  {
    var resolved := ResolveRaw(condition,env,history);
    if resolved.result.Failed? { out := resolved; return; }
    var first := Resolver.First(resolved.result.data);
    if first.Failed? { out := CoreOutcome(CoreResult.Failed(Base(first.error)),resolved.history); return; }
    var chosen := Read(resolved.result.data[..32]) != 0;
    var branch := Resolver.ResolveSource(if chosen then yes else no,Context([],0,if chosen then 1 else 2),env,resolved.history);
    out := FromResolver(branch);
  }
}
