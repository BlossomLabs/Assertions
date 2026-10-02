// SPDX-License-Identifier: MIT
include "Invocation.dfy"

module CoreRecursiveDispatch {
  import opened CoreRecursiveInvocation
  import R = ResolutionModel
  import G = GuardModel
  import Resolver = ResolutionSource
  import Core = CoreSource
  import Guard = GuardSource
  import Probe = ProbeSource
  import Arguments = ArgumentsSource
  import Navigation = CompositionSource

  // Each branch invokes the actual previously proved source adapter. Codec
  // witnesses remain the adapter's returned receipts, not chosen inputs.
  ghost method Run(call: Call, env: G.SelfEnvironment, history: seq<R.Request>) returns (reply: Reply)
    requires Ready(call,env.base,history)
    ensures Post(call,env,history,reply)
  {
    match call {
      case Resolve(input) =>
        var out := Core.ResolveRaw(input,env.base,history);
        reply := Raw(out);
      case AssertOne(input,message) =>
        var out := Resolver.AssertOne(input,message,env.base,history);
        reply := Resolved(out);
      case AssertBatch(entries,message) =>
        var out := Resolver.JudgeBatch(entries,message,env.base,history);
        reply := Resolved(out);
      case DefaultOne(input) =>
        var out := Resolver.DefaultParam(input,env.base,history);
        reply := Resolved(out);
      case DefaultBatch(entries) =>
        var out := Resolver.DefaultBatch(entries,env.base,history);
        reply := Resolved(out);
      case Gather(inputs) =>
        var out := Core.Gather(inputs,env.base,history);
        reply := Collected(out);
      case Pick(input,word) =>
        var out := Core.PickWord(input,word,env.base,history);
        reply := Raw(out);
      case Read(target,selector,args) =>
        var out := Core.ReadSegments(target,selector,args,env.base,history);
        reply := Raw(out);
      case Chain(target,calls) =>
        var out := Core.CallChain(target,calls,env.base,history);
        reply := Raw(out);
      case Cond(condition,yes,no) =>
        var out := Core.Cond(condition,yes,no,env.base,history);
        reply := Raw(out);
      case OrElse(attempt,fallback) =>
        var out := Guard.OrElseSource(attempt,fallback,env,history);
        reply := Resolved(out);
      case IsValid(attempt) =>
        var out := Guard.IsValidSource(attempt,env,history);
        reply := Resolved(out);
      case Probe(input,selector) =>
        var out := Probe.RevertDataSource(input,selector,env.base,history);
        reply := Probed(out);
      case Get(target,selector,t,args) =>
        var out,receipt := Arguments.Get(target,selector,t,args,env.base,history);
        reply := Constructed(out,receipt);
      case Nav(input,t,path) =>
        var out := Navigation.Nav(input,t,path,env.base,history);
        reply := Navigated(out);
    }
  }
}
