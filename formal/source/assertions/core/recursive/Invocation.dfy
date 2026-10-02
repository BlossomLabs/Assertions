// SPDX-License-Identifier: MIT
include "../../arguments/Source.generated.dfy"
include "../../composition/Source.generated.dfy"
include "../../control/Source.dfy"

module CoreRecursiveInvocation {
  import opened AbiFrames
  import opened AbiByteSemantics
  import R = ResolutionModel
  import K = CoreModel
  import W = CoreWords
  import Words = ResolutionWords
  import G = GuardModel
  import P = ProbeModel
  import A = ArgumentsModel
  import N = CompositionModel
  import NS = NavigationRuntime
  import Construction = AbiConstructionModel

  datatype Call = Resolve(input: R.Param)
                | AssertOne(input: R.Param, message: seq<Byte>)
                | AssertBatch(entries: seq<R.Entry>, message: seq<Byte>)
                | DefaultOne(input: R.Param) | DefaultBatch(entries: seq<R.Entry>)
                | Gather(inputs: seq<R.Param>) | Pick(input: R.Param, word: int)
                | Read(target: R.Param, selector: seq<Byte>, args: seq<R.Param>)
                | Chain(target: R.Param, calls: seq<seq<Byte>>)
                | Cond(condition: R.Param, yes: R.Param, no: R.Param)
                | OrElse(attempt: R.Param, fallback: R.Param) | IsValid(attempt: R.Param)
                | Probe(input: R.Param, selector: seq<Byte>)
                | Get(target: R.Param, selector: seq<Byte>, descriptor: seq<Byte>, args: seq<R.Param>)
                | Nav(input: R.Param, descriptor: seq<Byte>, path: seq<int>)

  datatype Reply = Resolved(resolved: R.Outcome) | Raw(raw: K.CoreOutcome)
                 | Collected(collected: K.ValuesResult) | Probed(probed: P.ProbeOutcome)
                 | Constructed(constructed: A.Outcome, receipt: A.Receipt)
                 | Navigated(navigated: N.Outcome)

  function History(reply: Reply): seq<R.Request> {
    match reply
    case Resolved(r) => r.history
    case Raw(r) => r.history
    case Collected(r) => r.history
    case Probed(r) => r.history
    case Constructed(r,_) => r.history
    case Navigated(r) => r.history
  }

  ghost predicate Ready(call: Call, env: R.Environment, history: seq<R.Request>) {
    match call
    case Pick(input,word) =>
      W.SignedIndex(word) &&
      (K.PublicResolve(input,env,history).result.Bytes? ==> |K.PublicResolve(input,env,history).result.data| < Words.Limit())
    case Read(_,selector,_) => |selector| == 4
    case Probe(_,selector) => |selector| == 4
    case Get(target,selector,t,args) =>
      |selector| == 4 && Uint(|t|) && Uint(|args|) &&
      (A.Prepare(target,args,env,history).Ready? ==>
         var values := A.Prepare(target,args,env,history).values;
         Uint(|values|) && Uint(Construction.TotalBytes(values)) &&
         forall i :: 0 <= i < |values| ==> Uint(|values[i]|))
    case Nav(input,t,path) =>
      Uint(|t|) && Uint(|path|) && (forall i :: 0 <= i < |path| ==> NS.Sint(path[i])) &&
      (K.PublicResolve(input,env,history).result.Bytes? ==> Uint(|K.PublicResolve(input,env,history).result.data|+32))
    case _ => true
  }

  ghost predicate Post(call: Call, env: G.SelfEnvironment, history: seq<R.Request>, reply: Reply)
    requires Ready(call,env.base,history)
  {
    match call
    case Resolve(input) => reply == Raw(K.PublicResolve(input,env.base,history))
    case AssertOne(input,message) => reply == Resolved(R.AssertParam(input,message,env.base,history))
    case AssertBatch(entries,message) => reply == Resolved(R.Batch(entries,message,0,env.base,history))
    case DefaultOne(input) => reply == Resolved(R.AssertParam(input,[80,65,82,65,77],env.base,history))
    case DefaultBatch(entries) => reply == Resolved(R.Batch(entries,[67,79,77,80,79,83,65,66,76,69],0,env.base,history))
    case Gather(inputs) => reply == Collected(K.Collect(inputs,0,0,env.base,history))
    case Pick(input,word) => reply == Raw(K.Pick(input,word,env.base,history))
    case Read(target,selector,args) => reply == Raw(K.ReadCall(target,selector,args,env.base,history))
    case Chain(target,calls) => reply == Raw(K.Chain(target,calls,env.base,history))
    case Cond(condition,yes,no) => reply == Raw(K.Conditional(condition,yes,no,env.base,history))
    case OrElse(attempt,fallback) => reply == Resolved(G.OrElse(attempt,fallback,env,history))
    case IsValid(attempt) => reply == Resolved(G.IsValid(attempt,env,history))
    case Probe(input,selector) => reply == Probed(P.RevertData(input,selector,env.base,history))
    case Get(target,selector,t,args) => reply.Constructed? && A.GetPost(target,selector,t,args,env.base,history,reply.constructed,reply.receipt)
    case Nav(input,t,path) => reply.Navigated? && N.NavPost(input,t,path,env.base,history,reply.navigated)
  }
}
