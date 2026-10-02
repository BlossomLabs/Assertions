// SPDX-License-Identifier: MIT
// Source 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6; context projection certified by construction/generate.py.
include "Validation.dfy"

module AbiConstructionContext {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiDynamicValidation

  datatype Kind = ValueKind | CallbackKind | ComponentKind
  datatype Context = Context(kind: Kind, operation: nat, index: nat, other: nat, target: nat)
  datatype Result = Success | InvalidValue(offset: nat)
                  | InvalidComponentValue(index: nat, offset: nat)
                  | InvalidCallbackResult(operation: nat, index: nat, other: nat, target: nat)
                  | InvalidComponentEnvelope(index: nat, length: nat, head: nat)
                  | InvalidComponentLength(index: nat, expected: nat, actual: nat)
                  | ComponentCountMismatch(expected: nat, actual: nat)
                  | InvalidDescriptor(at: nat) | Panic(code: nat)

  function Failure(offset: nat, c: Context): Result
  {
    if c.kind == CallbackKind then InvalidCallbackResult(c.operation,c.index,c.other,c.target)
    else if c.kind == ComponentKind then InvalidComponentValue(c.index,offset)
    else InvalidValue(offset)
  }

  ghost method RequireValue(valid: bool, offset: nat, c: Context) returns (r: Result)
    ensures r == (if valid then Success else Failure(offset,c))
  {
    if valid { r := Success; return; }
    if c.kind == CallbackKind { r := InvalidCallbackResult(c.operation,c.index,c.other,c.target); return; }
    if c.kind == ComponentKind { r := InvalidComponentValue(c.index,offset); return; }
    r := InvalidValue(offset);
  }

  function Route(o: Outcome, c: Context): Result
  { if o.Ok? then Success else if o.Invalid? then Failure(o.offset,c) else Result.Panic(o.code) }

  function RouteValidation(o: ValidationResult, c: Context): Result
  {
    if o.Accepted? then Success else if o.ValueFailure? then Failure(o.at,c)
    else if o.DescriptorFailure? then InvalidDescriptor(o.at) else Result.Panic(o.code)
  }

  lemma ContextPreservesVerdict(o: Outcome, c: Context)
    ensures Route(o,c).Success? == o.Ok?
    ensures Route(o,c).Panic? == o.Panic?
    ensures o.Panic? ==> Route(o,c) == Result.Panic(o.code)
  {}
}
