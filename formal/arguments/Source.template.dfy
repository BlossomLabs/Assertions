// SPDX-License-Identifier: MIT
// Gated Assertions.sol $HASH
include "Model.dfy"
include "Tuple.generated.dfy"
module ArgumentsSource {
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
  import C = ConstraintModel
  import K = CoreModel
  import CoreSource
  import Resolver = ResolutionSource
  import AbiLayoutSource
  import AbiLayoutSoundness
  import ArgumentsTuple
  import opened ArgumentsModel

  ghost method PrepareSource(target: R.Param, args: seq<R.Param>, env: R.Environment, history: seq<R.Request>) returns (out: Preparation)
    requires Uint(|args|)
    ensures out == Prepare(target,args,env,history)
  {
    var targetValue := CoreSource.ResolveRaw(target,env,history);
    if targetValue.result.Failed? { out := PreparationFailed(targetValue.result.error,targetValue.history); return; }
    var address := CoreSource.CleanAddress(targetValue.result.data,0);
    if address.BadAddress? { out := PreparationFailed(address.error,targetValue.history); return; }
    var values: seq<seq<Byte>> := [];
    var after := targetValue.history;
    var i := 0;
    while i < |args|
      invariant 0 <= i <= |args|
      invariant |values| == i
      invariant K.Collect(args,0,1,env,targetValue.history) == K.Prepend(values,K.Collect(args,i,1,env,after))
    {
      var value := Resolver.ResolveSource(args[i],C.Context([],0,$ARG_INDEX),env,after);
      if value.result.Failed? { out := PreparationFailed(K.Base(value.result.error),value.history); return; }
      values := values+[value.result.bytes]; after := value.history;
      i := i+1;
    }
    out := Ready(address.address,values,after);
  }

  ghost method EncodeSource(t: seq<Byte>, args: seq<seq<Byte>>) returns (receipt: Receipt)
    requires Uint(|t|) && Uint(|args|) && Uint(TotalBytes(args))
    requires forall i :: 0 <= i < |args| ==> Uint(|args[i]|)
    ensures CodecPost(t,args,receipt)
  {
    if |t| == 2 && t[0] == 40 && t[1] == 41 && $EMPTY_COUNT {
      assert t == [40,41]; receipt := Encoded([],Success,[]); return;
    }
    var plan := AbiLayoutSource.Layout(t);
    if plan.BadLayout? { receipt := Encoded([],InvalidDescriptor(plan.at),[]); return; }
    if plan.LayoutPanic? { receipt := Encoded([],AbiConstructionContext.Result.Panic(17),[]); return; }
    var fs := AbiLayoutSoundness.LayoutWitness(t);
    var data,r := ArgumentsTuple.TupleChecked(plan,t,args,fs);
    receipt := Encoded(data,r,fs);
  }

  ghost method Get(target: R.Param, selector: seq<Byte>, t: seq<Byte>, args: seq<R.Param>, env: R.Environment, history: seq<R.Request>) returns (out: ArgumentsModel.Outcome, receipt: Receipt)
    requires |selector| == 4 && Uint(|t|) && Uint(|args|)
    requires Prepare(target,args,env,history).Ready? ==>
               Uint(|Prepare(target,args,env,history).values|) && Uint(TotalBytes(Prepare(target,args,env,history).values)) &&
               (forall i :: 0 <= i < |Prepare(target,args,env,history).values| ==> Uint(|Prepare(target,args,env,history).values[i]|))
    ensures GetPost(target,selector,t,args,env,history,out,receipt)
  {
    receipt := NotEncoded;
    var prepared := PrepareSource(target,args,env,history);
    if prepared.PreparationFailed? { out := ArgumentsModel.Outcome(CoreFailure(prepared.error),prepared.history); return; }
    receipt := EncodeSource(t,prepared.values);
    if !receipt.result.Success? { out := ArgumentsModel.Outcome(CodecFailure(receipt.result),prepared.history); return; }
    var called := Resolver.StaticCall(prepared.address,selector+receipt.data,env,prepared.history);
    out := ArgumentsModel.Outcome(if called.result.Value? then Returned(called.result.bytes) else CoreFailure(K.Base(called.result.error)),called.history);
  }
}
