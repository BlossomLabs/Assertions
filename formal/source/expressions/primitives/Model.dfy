// SPDX-License-Identifier: MIT
include "../resolve/Connection.dfy"
include "../codec-errors/Connection.dfy"
include "../probe-input/Connection.dfy"
module ExpressionPrimitiveModel {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import AbiConnectionModel
  import ResolutionWords
  import AbiParserSpec
  import AbiShapeSemantics
  import A = ExpressionAdmission
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import M = ExpressionScalarModel
  import R = ResolutionModel
  import C = ExpressionCallModel
  import W = ExpressionReceiptEncoding
  import RS = ExpressionReceiptConnection
  import Codec = ExpressionCodecErrorEncoding
  import Args = ArgumentsModel
  import CC = AbiConstructionContext
  import Build = AbiConstructionModel
  import Resolve = ExpressionResolveModel
  import Probe = ExpressionProbeInput

  predicate Shape(node: A.Node, stage: E.Stage, values: seq<seq<Byte>>, index: nat) {
    match stage
    case Leaf => node.kind in {A.Literal,A.Parameter,A.Resolve} && |values| == 0
    case Address => node.kind in {A.Call,A.ProbeCall} && |values| == 1
    case Boolean => node.kind == A.IsValid && |values| == 1 && values[0] in {[0],[1]}
    case GuardFailure => node.kind in {A.TryOrElse,A.IsValid} && |values| == 1
    case Finish =>
      |values| == |node.refs| &&
      (match node.kind
       case Wrap => |values| == 1
       case Array => true
       case Tuple => true
       case Call => |values| >= 1 && M.AddressSpec(index,values[0]).Addressed?
       case ProbeCall => |values| == 2 && M.AddressSpec(index,values[0]).Addressed?
       case _ => false)
  }
  ghost function Target(index: nat, value: seq<Byte>): R.Address
    requires M.AddressSpec(index,value).Addressed?
    ensures Target(index,value) == M.AddressSpec(index,value).address
  {
    ResolutionWords.PowerConstants();
    M.AddressSpec(index,value).address
  }
  ghost function CallRaw(index: nat, target: R.Address, self: R.Address, data: seq<Byte>, guard: seq<Byte>, env: R.Environment, history: seq<R.Request>): E.Raw
    requires Uint(index) && |guard| == 4
  {
    RS.CallFields(index,target,self,data,guard,env,history);
    var r := C.Call(index,target,self,data,guard,env,history).result;
    if r.Returned? then E.Produced(r.data) else E.Aborted(E.Error(W.Spec(r.error)))
  }
  ghost function ProbeRaw(target: R.Address, self: R.Address, data: seq<Byte>, guard: seq<Byte>, expected: seq<Byte>, env: R.Environment, history: seq<R.Request>): E.Raw
    requires |guard| == 4 && |expected| == 4
  {
    RS.ProbeFields(target,self,data,guard,expected,env,history);
    var r := C.Probe(target,self,data,guard,expected,env,history).result;
    if r.Returned? then E.Produced(Encode(Bytes,Buffer(r.data))) else E.Aborted(E.Error(W.Spec(r.error)))
  }
  ghost predicate ArrayPost(t: seq<Byte>, values: seq<seq<Byte>>, result: CC.Result, data: seq<Byte>)
    requires Uint(|t|)
  {
    (result.Success? ==> AbiParserSpec.Whole(t).Shaped? && Build.ValidInputs(AbiConnectionModel.Copies(AbiParserSpec.Whole(t).syntax,|values|),values)) &&
    (AbiParserSpec.Whole(t).Shaped? && !result.Panic? ==> result.Success? == Build.ValidInputs(AbiConnectionModel.Copies(AbiParserSpec.Whole(t).syntax,|values|),values)) &&
    (result.Success? ==> WellTyped(Array(AbiConnectionModel.TypeOf(AbiParserSpec.Whole(t).syntax)),Items(Build.Decoded(AbiConnectionModel.Copies(AbiParserSpec.Whole(t).syntax,|values|),values))) &&
                         data == Encode(Array(AbiConnectionModel.TypeOf(AbiParserSpec.Whole(t).syntax)),Items(Build.Decoded(AbiConnectionModel.Copies(AbiParserSpec.Whole(t).syntax,|values|),values)))) &&
    (AbiParserSpec.Whole(t).BadDescriptor? ==> result == CC.InvalidDescriptor(AbiParserSpec.Whole(t).at)) &&
    (AbiParserSpec.Whole(t).ArithmeticPanic? ==> result == CC.Panic(17))
  }
  ghost predicate Post(node: A.Node, stage: E.Stage, values: seq<seq<Byte>>, index: nat, parameters: seq<seq<Byte>>,
                       core: R.Address, self: R.Address, resolveSelector: seq<Byte>, guard: seq<Byte>,
                       decode: seq<Byte>->Resolve.Decode, env: R.Environment, history: seq<R.Request>, boundary: R.Observation,
                       raw: E.Raw, after: seq<R.Request>, tuple: Args.Receipt, arrayResult: CC.Result, constructed: seq<Byte>)
    requires Shape(node,stage,values,index) && Uint(index)
    requires |guard| == 4 && |resolveSelector| == 4 && |node.selector| == 4
    requires Uint(|node.arguments|)
    requires stage == E.Finish && node.kind == A.ProbeCall ==> Probe.Decodable(values[1])
  {
    match stage
    case Leaf =>
      if node.kind == A.Literal then raw == E.Produced(node.data) && after == history else
      if node.kind == A.Parameter then raw == M.Receipt(M.ParameterSpec(index,node.data,parameters)) && after == history else
      var result := Resolve.Spec(node.data,index,core,self,resolveSelector,guard,decode,env,history);
      raw == result.raw && after == result.history
    case Address => raw == (if M.AddressSpec(index,values[0]).Addressed? then E.Produced(values[0]) else E.Aborted(E.Error(M.ErrorBytes(M.BadNode(index))))) && after == history
    case Boolean => raw == E.Produced(Word(if values[0] == [1] then 1 else 0)) && after == history
    case GuardFailure => raw == M.GuardSpec(boundary) && after == history
    case Finish =>
      if node.kind == A.Wrap then raw == E.Produced(Encode(Bytes,Buffer(values[0]))) && after == history else
      if node.kind == A.Tuple then
        Args.CodecPost(node.arguments,values,tuple) && raw == Codec.Receipt(tuple.result,constructed) && after == history &&
        (tuple.result.Success? ==> if Args.EmptyArguments(node.arguments,values) then constructed == [] else
           constructed == Encode(AbiConnectionModel.TypeOf(AbiShapeSemantics.Group(tuple.fields)),Items(Build.Decoded(tuple.fields,values)))) else
      if node.kind == A.Array then ArrayPost(node.arguments,values,arrayResult,constructed) && raw == Codec.Receipt(arrayResult,constructed) && after == history else
      if node.kind == A.Call then
        Args.CodecPost(node.arguments,values[1..],tuple) &&
        (if !tuple.result.Success? then raw == Codec.Receipt(tuple.result,[]) && after == history else
         var target := Target(index,values[0]);
         constructed == node.selector+tuple.data && raw == CallRaw(index,target,self,constructed,guard,env,history) &&
         after == C.Call(index,target,self,constructed,guard,env,history).history) else
        var target := Target(index,values[0]);
        var data := Probe.DecodeBytes(values[1]);
        raw == ProbeRaw(target,self,data,guard,node.selector,env,history) &&
        after == C.Probe(target,self,data,guard,node.selector,env,history).history
  }
}
