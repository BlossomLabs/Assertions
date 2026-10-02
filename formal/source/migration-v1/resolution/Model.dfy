// SPDX-License-Identifier: MIT
include "Words.dfy"
module ResolutionModel {
  import opened ConstraintModel
  import opened ResolutionWords

  type Address = a: nat | a < AddressLimit() witness 0
  datatype Route = TARGET | VALUE | CALL_DATA
  datatype Fetcher = RAW_BYTES | STATIC_CALL | BALANCE
  datatype Param = Param(route: Route, fetcher: Fetcher, data: seq<Byte>, constraints: seq<Constraint>)
  datatype Entry = Entry(selector: seq<Byte>, params: seq<Param>, outputs: nat)
  datatype CallDecode = MalformedCall | DecodedCall(target: Address, data: seq<Byte>)
  // Requests record attempted calls (including the code-presence check), not
  // just successful EVM calls. Equal requests at different histories can differ.
  datatype Request = Call(target: Address, data: seq<Byte>) | NativeBalance(account: Address)
  datatype Observation = Observation(codePresent: bool, success: bool, data: seq<Byte>, gasBefore: Word, gasAfter: Word)
  datatype Environment = Environment(call: (seq<Request>, Request) -> Observation,
                                     balance: (seq<Request>, Address) -> Word,
                                     decodeCall: seq<Byte> -> CallDecode,
                                     decodeOr: seq<Byte> -> Decoded)
  datatype Error = ConstraintError(detail: ConstraintModel.Error)
                 | CallFailed(target: Address, data: seq<Byte>) | SubcallOutOfGas
                 | InvalidBalanceData(entry: nat, param: nat, length: nat)
                 | ReturnDataOutOfBounds(wordIndex: int, length: nat)
                 | InvalidAddressWord(index: nat, word: Word)
                 | BareRevert | OutputParamsNotSupported(entry: nat)
                 | ValueParamNotSupported(entry: nat, param: nat)
                 | DuplicateTargetParam(entry: nat) | BalanceCannotBeTarget(entry: nat, param: nat)
  datatype ValueResult = Value(bytes: seq<Byte>) | Failed(error: Error)
  datatype Outcome = Outcome(result: ValueResult, history: seq<Request>)
  datatype Build = Build(target: Address, hasTarget: bool, data: seq<Byte>)
  datatype Routed = Built(build: Build, history: seq<Request>) | RouteFailed(error: Error, history: seq<Request>)

  function Signal(): seq<Byte> { [0xd2,0x71,0x06,0x0e] }
  function BalanceSelector(): seq<Byte> { [0x70,0xa0,0x82,0x31] }
  function AddressOf(data: seq<Byte>): Address
    requires |data| == 20
  { PackedAddress(data) % AddressLimit() }
  function BalanceCall(account: Address): seq<Byte> {
    assert AddressLimit() < Limit();
    BalanceSelector() + EncodeWord(account)
  }

  predicate Exhausted(observation: Observation) {
    observation.gasAfter <= observation.gasBefore/63 || observation.data == Signal()
  }

  function CallSpec(target: Address, data: seq<Byte>, env: Environment, history: seq<Request>): Outcome {
    var request := Call(target,data);
    var observed := env.call(history,request);
    var after := history+[request];
    Outcome(if !observed.codePresent then Failed(CallFailed(target,data))
            else if observed.success then Value(observed.data)
            else if Exhausted(observed) then Failed(SubcallOutOfGas)
            else Failed(CallFailed(target,data)),after)
  }

  function FirstWord(data: seq<Byte>): ValueResult {
    if |data| < 32 then Failed(Error.ReturnDataOutOfBounds(0,|data|)) else Value(EncodeWord(Read(data[..32])))
  }

  function AddressResult(data: seq<Byte>, index: nat): ValueResult {
    if |data| < 32 then Failed(Error.ReturnDataOutOfBounds(0,|data|)) else
    var w := Read(data[..32]);
    if w >= AddressLimit() then Failed(InvalidAddressWord(index,w)) else Value(EncodeWord(w))
  }

  function Fetch(param: Param, context: Context, env: Environment, history: seq<Request>): Outcome {
    match param.fetcher
    case RAW_BYTES => Outcome(Value(param.data),history)
    case STATIC_CALL =>
      match env.decodeCall(param.data) {
        case MalformedCall => Outcome(Failed(Error.BareRevert),history)
        case DecodedCall(target,data) => CallSpec(target,data,env,history)
      }
    case BALANCE =>
      if |param.data| != 40 then Outcome(Failed(InvalidBalanceData(context.entry,context.param,|param.data|)),history) else
      var token := AddressOf(param.data[..20]);
      var account := AddressOf(param.data[20..]);
      if token == 0 then Outcome(Value(EncodeWord(env.balance(history,account))),history+[NativeBalance(account)]) else
      var called := CallSpec(token,BalanceCall(account),env,history);
      if called.result.Failed? then called else Outcome(FirstWord(called.result.bytes),called.history)
  }

  function Resolve(param: Param, context: Context, env: Environment, history: seq<Request>): Outcome {
    var fetched := Fetch(param,context,env,history);
    if fetched.result.Failed? then fetched else
    var verdict := Execute(Validate(param.constraints,fetched.result.bytes,env.decodeOr),context);
    if verdict.Accepted? then fetched else Outcome(Failed(ConstraintError(verdict.error)),fetched.history)
  }

  function RouteOne(param: Param, message: seq<Byte>, entry: nat, index: nat, build: Build, env: Environment, history: seq<Request>): Routed {
    if param.route == VALUE then RouteFailed(ValueParamNotSupported(entry,index),history) else
    if param.route == TARGET && build.hasTarget then RouteFailed(DuplicateTargetParam(entry),history) else
    if param.route == TARGET && param.fetcher == BALANCE then RouteFailed(BalanceCannotBeTarget(entry,index),history) else
    var resolved := Resolve(param,Context(message,entry,index),env,history);
    if resolved.result.Failed? then RouteFailed(resolved.result.error,resolved.history) else
    if param.route == CALL_DATA then Built(Build(build.target,build.hasTarget,build.data+resolved.result.bytes),resolved.history) else
    var value := resolved.result.bytes;
    if |value| < 32 then RouteFailed(Error.ReturnDataOutOfBounds(0,|value|),resolved.history) else
    var word := Read(value[..32]);
    if word >= AddressLimit() then RouteFailed(InvalidAddressWord(index,word),resolved.history) else
    Built(Build(word,true,build.data),resolved.history)
  }

  function RouteAll(params: seq<Param>, message: seq<Byte>, entry: nat, start: nat, build: Build, env: Environment, history: seq<Request>): Routed
    requires start <= |params|
    decreases |params|-start
  {
    if start == |params| then Built(build,history) else
    var step := RouteOne(params[start],message,entry,start,build,env,history);
    if step.RouteFailed? then step else RouteAll(params,message,entry,start+1,step.build,env,step.history)
  }

  function JudgeEntry(entry: Entry, message: seq<Byte>, index: nat, env: Environment, history: seq<Request>): Outcome {
    if entry.outputs != 0 then Outcome(Failed(OutputParamsNotSupported(index)),history) else
    var routed := RouteAll(entry.params,message,index,0,Build(0,false,entry.selector),env,history);
    if routed.RouteFailed? then Outcome(Failed(routed.error),routed.history) else
    if routed.build.target == 0 then Outcome(Value([]),routed.history) else
    var called := CallSpec(routed.build.target,routed.build.data,env,routed.history);
    if called.result.Failed? then called else Outcome(Value([]),called.history)
  }

  function Batch(entries: seq<Entry>, message: seq<Byte>, start: nat, env: Environment, history: seq<Request>): Outcome
    requires start <= |entries|
    decreases |entries|-start
  {
    if start == |entries| then Outcome(Value([]),history) else
    var next := JudgeEntry(entries[start],message,start,env,history);
    if next.result.Failed? then next else Batch(entries,message,start+1,env,next.history)
  }

  function AssertParam(param: Param, message: seq<Byte>, env: Environment, history: seq<Request>): Outcome {
    var resolved := Resolve(param,Context(message,0,0),env,history);
    if resolved.result.Failed? then resolved else Outcome(Value([]),resolved.history)
  }

  // Independent acceptance characterization for the resolver: fetch success
  // plus every positional predicate, not an assumption of constraint success.
  lemma ResolveSuccess(param: Param, context: Context, env: Environment, history: seq<Request>)
    ensures Resolve(param,context,env,history).result.Value? <==>
            Fetch(param,context,env,history).result.Value? &&
            |param.constraints| <= |Fetch(param,context,env,history).result.bytes|/32 &&
            (forall i :: 0 <= i < |param.constraints| ==>
                           Judge(Read(Fetch(param,context,env,history).result.bytes[32*i..32*i+32]),param.constraints[i],env.decodeOr) == Yes)
  {
    var fetched := Fetch(param,context,env,history);
    if fetched.result.Value? && |param.constraints| <= |fetched.result.bytes|/32 {
      FirstFailure(param.constraints,fetched.result.bytes,env.decodeOr,0);
      FailureFields(param.constraints,fetched.result.bytes,env.decodeOr,0);
    }
  }
  function BatchResults(entries: seq<Entry>, message: seq<Byte>, start: nat, env: Environment, history: seq<Request>): seq<Outcome>
    requires start <= |entries|
    ensures |BatchResults(entries,message,start,env,history)| <= |entries|-start
    ensures start < |entries| ==> |BatchResults(entries,message,start,env,history)| > 0
    decreases |entries|-start
  {
    if start == |entries| then [] else
    var first := JudgeEntry(entries[start],message,start,env,history);
    if first.result.Failed? then [first] else [first]+BatchResults(entries,message,start+1,env,first.history)
  }

  lemma BatchFirstFailure(entries: seq<Entry>, message: seq<Byte>, start: nat, env: Environment, history: seq<Request>)
    requires start <= |entries|
    ensures start < |entries| ==> Batch(entries,message,start,env,history) ==
                                  BatchResults(entries,message,start,env,history)[|BatchResults(entries,message,start,env,history)|-1]
    ensures forall j :: 0 <= j < |BatchResults(entries,message,start,env,history)|-1 ==>
                          BatchResults(entries,message,start,env,history)[j].result.Value?
    ensures Batch(entries,message,start,env,history).result.Value? <==>
            |BatchResults(entries,message,start,env,history)| == |entries|-start &&
            (forall j :: 0 <= j < |BatchResults(entries,message,start,env,history)| ==>
                           BatchResults(entries,message,start,env,history)[j].result.Value?)
    decreases |entries|-start
  {
    if start < |entries| {
      var first := JudgeEntry(entries[start],message,start,env,history);
      if first.result.Value? {
        BatchFirstFailure(entries,message,start+1,env,first.history);
      }
    }
  }

}
