// SPDX-License-Identifier: MIT
include "../core/Source.generated.dfy"
include "../../abi/construction/Endpoints.dfy"
module ArgumentsModel {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiLayoutSpec
  import opened AbiLayoutCanonical
  import opened AbiConstructionModel
  import opened AbiConstructionContext
  import opened AbiConstructionComponent
  import opened AbiConstructionAssembly

  import R = ResolutionModel
  import K = CoreModel
  import C = ConstraintModel

  datatype Preparation = Ready(address: R.Address, values: seq<seq<Byte>>, history: seq<R.Request>)
                       | PreparationFailed(error: K.CoreError, history: seq<R.Request>)
  datatype Receipt = NotEncoded | Encoded(data: seq<Byte>, result: AbiConstructionContext.Result, fields: seq<Descriptor>)
  datatype Result = Returned(data: seq<Byte>) | CoreFailure(error: K.CoreError) | CodecFailure(codecError: AbiConstructionContext.Result)
  datatype Outcome = Outcome(result: Result, history: seq<R.Request>)

  function Prepare(target: R.Param, args: seq<R.Param>, env: R.Environment, history: seq<R.Request>): Preparation {
    var targetValue := K.PublicResolve(target,env,history);
    if targetValue.result.Failed? then PreparationFailed(targetValue.result.error,targetValue.history) else
    var address := K.AddressFrom(targetValue.result.data,0);
    if address.BadAddress? then PreparationFailed(address.error,targetValue.history) else
    var values := K.Collect(args,0,1,env,targetValue.history);
    if values.ValuesFailed? then PreparationFailed(values.error,values.history)
    else Ready(address.address,values.values,values.history)
  }

  predicate EmptyArguments(t: seq<Byte>, args: seq<seq<Byte>>) {
    t == [40,41] && |args| == 0
  }

  ghost predicate CodecPost(t: seq<Byte>, args: seq<seq<Byte>>, receipt: Receipt)
    requires Uint(|t|)
  {
    receipt.Encoded? &&
    (if EmptyArguments(t,args) then receipt.data == [] && receipt.result.Success? else
     var r := receipt.result;
     var fs := receipt.fields;
     if Reference(t).BadLayout? then r == InvalidDescriptor(Reference(t).at) else
     if Reference(t).LayoutPanic? then r == AbiConstructionContext.Result.Panic(17) else
     Admissible(Group(fs)) && t == Render(Group(fs)) &&
     (r.ComponentCountMismatch? <==> |fs| != |args|) &&
     (r.ComponentCountMismatch? ==> r.expected == |fs| && r.actual == |args|) &&
     (!r.Panic? ==> r.Success? == ValidInputs(fs,args)) &&
     (r.Success? ==> WellTyped(TypeOf(Group(fs)),Items(Decoded(fs,args))) &&
                     receipt.data == Body(TypeOf(Group(fs)),Items(Decoded(fs,args)))) &&
     ((r.InvalidComponentEnvelope? || r.InvalidComponentLength? || r.InvalidComponentValue?) ==>
        |fs| == |args| && r.index < |fs| && !ValidInput(fs[r.index],args[r.index]) &&
        (forall j :: 0 <= j < r.index ==> ValidInput(fs[j],args[j]))) &&
     (r.InvalidComponentEnvelope? ==> r.length == |args[r.index]| &&
                                      r.head == (if |args[r.index]| >= 32 then ReadNat(args[r.index][..32]) else 0)) &&
     (r.InvalidComponentLength? ==> r.expected == 32*Width(fs[r.index]) && r.actual == |args[r.index]|) &&
     !r.InvalidValue? && !r.InvalidCallbackResult? && !r.InvalidDescriptor?)
  }

  function Finish(p: Preparation, selector: seq<Byte>, receipt: Receipt, env: R.Environment): Outcome
    requires p.Ready? && receipt.Encoded?
  {
    if !receipt.result.Success? then Outcome(CodecFailure(receipt.result),p.history) else
    var called := R.CallSpec(p.address,selector+receipt.data,env,p.history);
    Outcome(if called.result.Value? then Returned(called.result.bytes) else CoreFailure(K.Base(called.result.error)),called.history)
  }

  ghost predicate GetPost(target: R.Param, selector: seq<Byte>, t: seq<Byte>, args: seq<R.Param>, env: R.Environment, history: seq<R.Request>, out: Outcome, receipt: Receipt)
    requires Uint(|t|)
  {
    var p := Prepare(target,args,env,history);
    if p.PreparationFailed? then receipt.NotEncoded? && out == Outcome(CoreFailure(p.error),p.history) else
    receipt.Encoded? && CodecPost(t,p.values,receipt) && out == Finish(p,selector,receipt,env)
  }
}
