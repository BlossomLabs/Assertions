// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module ExpressionGuardedConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiShapeSemantics
  import M = ExpressionGuardedModel
  import W = ExpressionGuardedEncoding
  import Source = ExpressionGuardedSource
  import C = ExpressionCache
  import CacheSource = ExpressionCacheSource
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import O = ExpressionOracleModel
  import R = ResolutionModel
  import K = ConstraintModel

  ghost method Try(c: O.Config, types: seq<Descriptor>, original: C.Cache, index: nat,
                   reject: (nat,E.Value)->E.Error, before: K.Word, after: K.Word)
    returns (attempt: M.Outcome, result: C.GuardResult)
    requires M.Ready(c,types,original,index,reject)
    ensures attempt.Attempted?
    ensures attempt.execution.Success? ==> B.Bytes(attempt.execution.value)
    ensures attempt.execution.Failure? ==> B.Bytes(attempt.execution.error.payload)
    ensures attempt.execution.Success? ==> result.Accepted? && result.value == B.Narrow(attempt.execution.value) &&
                                           result.cache == attempt.updated && C.Valid(types,result.cache) && C.Extends(original,result.cache)
    ensures attempt.execution.Failure? ==> result.cache == original
    ensures attempt.execution.Failure? ==>
              var observed := R.Observation(true,false,B.Narrow(attempt.execution.error.payload),before,after);
              result == (if R.Exhausted(observed) then C.Exhaustion(original) else C.OrdinaryFailure(original))
  {
    attempt := Source.Evaluate(c,types,original,index,reject,c.self);
    if attempt.execution.Success? {
      var receipt := C.Succeeded(B.Narrow(attempt.execution.value),attempt.updated);
      C.GuardSuccessValid(types,index,original,receipt);
      result := CacheSource.TryResult(original,receipt);
      C.AdoptValid(types,original,attempt.updated);
    } else {
      var observed := R.Observation(true,false,B.Narrow(attempt.execution.error.payload),before,after);
      result := CacheSource.TryResult(original,C.Failed(observed,attempt.updated));
    }
  }

  lemma SuccessWire(attempt: M.Outcome)
    requires attempt.Attempted? && attempt.execution.Success? && B.Bytes(attempt.execution.value)
    requires W.WordsFit(attempt.updated)
    requires Fits(W.ReturnType(),W.ReturnValue(B.Narrow(attempt.execution.value),attempt.updated))
    ensures Validate(W.ReturnType(),Word(32)+W.Wire(B.Narrow(attempt.execution.value),attempt.updated)).Parsed?
    ensures WellTyped(W.ReturnType(),Validate(W.ReturnType(),Word(32)+W.Wire(B.Narrow(attempt.execution.value),attempt.updated)).value)
    ensures W.Project(Validate(W.ReturnType(),Word(32)+W.Wire(B.Narrow(attempt.execution.value),attempt.updated)).value) ==
            W.Pair(B.Narrow(attempt.execution.value),attempt.updated)
  { W.RoundTrip(B.Narrow(attempt.execution.value),attempt.updated); }
}
