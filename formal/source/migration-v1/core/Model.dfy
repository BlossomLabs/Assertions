// SPDX-License-Identifier: MIT
include "Words.dfy"
include "../../foundations/v5/Flatten.dfy"
include "../resolution/Model.dfy"
module CoreModel {
  import opened ConstraintModel
  import F = SourceFlattenV5
  import opened ResolutionWords
  import opened ResolutionModel
  import opened CoreWords

  datatype CoreError = Base(error: ResolutionModel.Error) | EmptyCallChain
  datatype CoreResult = Bytes(data: seq<Byte>) | Failed(error: CoreError)
  datatype CoreOutcome = CoreOutcome(result: CoreResult, history: seq<Request>)
  datatype AddressResult = Addressed(address: Address) | BadAddress(error: CoreError)
  datatype ValuesResult = Values(values: seq<seq<Byte>>, history: seq<Request>) | ValuesFailed(error: CoreError, history: seq<Request>)

  function FromResolver(out: Outcome): CoreOutcome {
    CoreOutcome(if out.result.Value? then Bytes(out.result.bytes) else CoreResult.Failed(Base(out.result.error)),out.history)
  }

  function AddressFrom(data: seq<Byte>, index: nat): AddressResult {
    if |data| < 32 then BadAddress(Base(ResolutionModel.Error.ReturnDataOutOfBounds(0,|data|))) else
    var word := Read(data[..32]);
    if word >= AddressLimit() then BadAddress(Base(InvalidAddressWord(index,word))) else Addressed(word)
  }

  function PublicResolve(param: Param, env: Environment, history: seq<Request>): CoreOutcome {
    FromResolver(Resolve(param,Context([],0,0),env,history))
  }

  function Pick(param: Param, index: int, env: Environment, history: seq<Request>): CoreOutcome {
    var resolved := Resolve(param,Context([],0,0),env,history);
    if resolved.result.Failed? then FromResolver(resolved) else
    var word := SelectWord(resolved.result.bytes,index);
    CoreOutcome(if word.Got? then Bytes(EncodeWord(word.word)) else CoreResult.Failed(Base(ResolutionModel.Error.ReturnDataOutOfBounds(index,|resolved.result.bytes|))),resolved.history)
  }

  function Prepend(prefix: seq<seq<Byte>>, out: ValuesResult): ValuesResult {
    if out.ValuesFailed? then out else Values(prefix+out.values,out.history)
  }

  function Collect(params: seq<Param>, start: nat, offset: nat, env: Environment, history: seq<Request>): ValuesResult
    requires start <= |params|
    decreases |params|-start
  {
    if start == |params| then Values([],history) else
    var first := Resolve(params[start],Context([],0,start+offset),env,history);
    if first.result.Failed? then ValuesFailed(Base(first.result.error),first.history)
    else Prepend([first.result.bytes],Collect(params,start+1,offset,env,first.history))
  }

  function Concat(values: seq<seq<Byte>>): seq<Byte>
    decreases |values|
  { if |values| == 0 then [] else values[0]+Concat(values[1..]) }

  function Segments(prefix: seq<Byte>, out: ValuesResult): CoreOutcome {
    CoreOutcome(if out.ValuesFailed? then CoreResult.Failed(out.error) else Bytes(prefix+Concat(out.values)),out.history)
  }

  lemma EmptySegments(prefix: seq<Byte>, history: seq<Request>)
    ensures Segments(prefix,Values([],history)) == CoreOutcome(Bytes(prefix),history)
  {
    var empty := Values([],history);
    assert empty.Values?;
    assert empty.values == [] && empty.history == history;
    assert Concat(empty.values) == [];
    assert prefix+Concat(empty.values) == prefix;
    assert Segments(prefix,empty) == CoreOutcome(Bytes(prefix+Concat(empty.values)),empty.history);
  }

  lemma SegmentStep(prefix: seq<Byte>, value: seq<Byte>, rest: ValuesResult)
    ensures Segments(prefix,Prepend([value],rest)) == Segments(prefix+value,rest)
  {
    if rest.Values? {
      assert ([value]+rest.values)[1..] == rest.values;
      assert Concat([value]+rest.values) == value+Concat(rest.values);
      assert Prepend([value],rest) == Values([value]+rest.values,rest.history);
      var next := Prepend([value],rest);
      assert next.Values?;
      assert next.values == [value]+rest.values && next.history == rest.history;
      assert Segments(prefix,next) == CoreOutcome(Bytes(prefix+Concat(next.values)),next.history);
      assert prefix+Concat(next.values) == prefix+value+Concat(rest.values);
      assert Segments(prefix,Prepend([value],rest)) == CoreOutcome(Bytes(prefix+value+Concat(rest.values)),rest.history);
      assert Segments(prefix+value,rest) == CoreOutcome(Bytes(prefix+value+Concat(rest.values)),rest.history);
    }
  }

  lemma FlattenAgreement(values: seq<seq<Byte>>)
    ensures Concat(values) == F.Flatten(values)
    decreases |values|
  { if |values| > 0 { FlattenAgreement(values[1..]); } }

  lemma ConcatAppend(a: seq<seq<Byte>>, b: seq<seq<Byte>>)
    ensures Concat(a+b) == Concat(a)+Concat(b)
    decreases |a|
  {
    FlattenAgreement(a); FlattenAgreement(b); FlattenAgreement(a+b);
    F.Append(a,b);
  }

  function ReadCall(target: Param, selector: seq<Byte>, args: seq<Param>, env: Environment, history: seq<Request>): CoreOutcome {
    var resolved := PublicResolve(target,env,history);
    if resolved.result.Failed? then resolved else
    var address := AddressFrom(resolved.result.data,0);
    if address.BadAddress? then CoreOutcome(CoreResult.Failed(address.error),resolved.history) else
    var values := Collect(args,0,1,env,resolved.history);
    if values.ValuesFailed? then CoreOutcome(CoreResult.Failed(values.error),values.history) else
    FromResolver(CallSpec(address.address,selector+Concat(values.values),env,values.history))
  }

  function Hops(current: Address, calls: seq<seq<Byte>>, start: nat, env: Environment, history: seq<Request>): CoreOutcome
    requires start < |calls|
    decreases |calls|-start
  {
    var called := FromResolver(CallSpec(current,calls[start],env,history));
    if called.result.Failed? || start+1 == |calls| then called else
    var address := AddressFrom(called.result.data,start+1);
    if address.BadAddress? then CoreOutcome(CoreResult.Failed(address.error),called.history)
    else Hops(address.address,calls,start+1,env,called.history)
  }

  function Chain(target: Param, calls: seq<seq<Byte>>, env: Environment, history: seq<Request>): CoreOutcome {
    if |calls| == 0 then CoreOutcome(CoreResult.Failed(EmptyCallChain),history) else
    var resolved := PublicResolve(target,env,history);
    if resolved.result.Failed? then resolved else
    var address := AddressFrom(resolved.result.data,0);
    if address.BadAddress? then CoreOutcome(CoreResult.Failed(address.error),resolved.history)
    else Hops(address.address,calls,0,env,resolved.history)
  }

  function Conditional(condition: Param, yes: Param, no: Param, env: Environment, history: seq<Request>): CoreOutcome {
    var resolved := PublicResolve(condition,env,history);
    if resolved.result.Failed? then resolved else
    if |resolved.result.data| < 32 then CoreOutcome(CoreResult.Failed(Base(ResolutionModel.Error.ReturnDataOutOfBounds(0,|resolved.result.data|))),resolved.history) else
    var choose := Read(resolved.result.data[..32]) != 0;
    FromResolver(Resolve(if choose then yes else no,Context([],0,if choose then 1 else 2),env,resolved.history))
  }

  lemma CollectionLength(params: seq<Param>, start: nat, offset: nat, env: Environment, history: seq<Request>)
    requires start <= |params|
    ensures Collect(params,start,offset,env,history).Values? ==>
              |Collect(params,start,offset,env,history).values| == |params|-start
    decreases |params|-start
  {
    if start < |params| {
      var resolved := Resolve(params[start],Context([],0,start+offset),env,history);
      if resolved.result.Value? { CollectionLength(params,start+1,offset,env,resolved.history); }
    }
  }
}
