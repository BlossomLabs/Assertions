// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module ExpressionResolveConnection {
  import opened AbiFrames
  import M = ExpressionResolveModel
  import Source = ExpressionResolveSource
  import R = ResolutionModel
  import K = ConstraintModel
  import Core = CoreModel
  import CoreSource
  import C = ExpressionCallModel
  import E = ExpressionEvaluationControl

  // The actual outer call must execute the proved core in the callee's own
  // context. Its history is distinct from the evaluator's request history.
  predicate CoreObservation(param: R.Param, env: R.Environment, history: seq<R.Request>, observed: R.Observation) {
    var result := Core.PublicResolve(param,env,history).result;
    observed.codePresent && observed.success == result.Bytes? &&
    (result.Bytes? ==> observed.data == result.data)
  }
  method ResolveAgainstCore(data: seq<Byte>, param: R.Param, index: nat, core: R.Address, self: R.Address,
                            resolveSelector: seq<Byte>, guardSelector: seq<Byte>, decode: seq<Byte>->M.Decode,
                            outerEnv: R.Environment, outerHistory: seq<R.Request>,
                            coreEnv: R.Environment, coreHistory: seq<R.Request>)
    returns (ghost out: M.Outcome, ghost resolved: Core.CoreOutcome)
    requires |resolveSelector| == 4 && |guardSelector| == 4 && resolveSelector != guardSelector
    requires index < Pow256(32) && decode(data) == M.Decoded(param)
    requires CoreObservation(param,coreEnv,coreHistory,outerEnv.call(outerHistory,R.Call(core,M.CallData(param,resolveSelector))))
    ensures resolved == Core.PublicResolve(param,coreEnv,coreHistory)
    ensures out == M.Spec(data,index,core,self,resolveSelector,guardSelector,decode,outerEnv,outerHistory)
    ensures out.raw.Produced? == resolved.result.Bytes?
    ensures out.raw.Produced? ==> out.raw.value == resolved.result.data
    ensures out.history == outerHistory+[R.Call(core,M.CallData(param,resolveSelector))]
    ensures out.raw.Produced? <==>
            R.Fetch(param,K.Context([],0,0),coreEnv,coreHistory).result.Value? &&
            |param.constraints| <= |R.Fetch(param,K.Context([],0,0),coreEnv,coreHistory).result.bytes|/32 &&
            (forall i :: 0 <= i < |param.constraints| ==>
                           K.Judge(K.Read(R.Fetch(param,K.Context([],0,0),coreEnv,coreHistory).result.bytes[32*i..32*i+32]),param.constraints[i],coreEnv.decodeOr) == K.Yes)
  {
    resolved := CoreSource.ResolveRaw(param,coreEnv,coreHistory);
    M.CallDataPrefix(param,resolveSelector);
    assert !C.ForbiddenRequest(core,self,M.CallData(param,resolveSelector),guardSelector);
    out := Source.Resolve(data,index,core,self,resolveSelector,guardSelector,decode,outerEnv,outerHistory);
    R.ResolveSuccess(param,K.Context([],0,0),coreEnv,coreHistory);
  }
}
