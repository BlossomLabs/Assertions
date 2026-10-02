// SPDX-License-Identifier: MIT
include "Model.dfy"
module ExpressionPrimitiveDispatch {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened ExpressionPrimitiveModel
  import A = ExpressionAdmission
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import M = ExpressionScalarModel
  import Scalar = ExpressionScalarSource
  import R = ResolutionModel
  import C = ExpressionCallModel
  import W = ExpressionReceiptEncoding
  import RS = ExpressionReceiptConnection
  import Codec = ExpressionCodecErrorEncoding
  import Args = ArgumentsModel
  import CC = AbiConstructionContext
  import Build = AbiConstructionModel
  import Constructors = ExpressionCompoundSource
  import Resolve = ExpressionResolveModel
  import Probe = ExpressionProbeInput

  lemma BytesResult(value: seq<Byte>)
    ensures B.Bytes(value)
  {}
  lemma CallBytes(index: nat, target: R.Address, self: R.Address, data: seq<Byte>, guard: seq<Byte>, env: R.Environment, history: seq<R.Request>)
    requires Uint(index) && |guard| == 4
    ensures CallRaw(index,target,self,data,guard,env,history).Aborted? ==>
              B.Bytes(CallRaw(index,target,self,data,guard,env,history).error.payload)
  {
    RS.CallFields(index,target,self,data,guard,env,history);
    var result := C.Call(index,target,self,data,guard,env,history).result;
    if result.Failed? { BytesResult(W.Spec(result.error)); }
  }
  lemma ResolveBytes(data: seq<Byte>, index: nat, core: R.Address, self: R.Address, selector: seq<Byte>, guard: seq<Byte>,
                     decode: seq<Byte>->Resolve.Decode, env: R.Environment, history: seq<R.Request>)
    requires Uint(index) && |selector| == 4 && |guard| == 4
    ensures Resolve.Spec(data,index,core,self,selector,guard,decode,env,history).raw.Aborted? ==>
              B.Bytes(Resolve.Spec(data,index,core,self,selector,guard,decode,env,history).raw.error.payload)
  {
    var decoded := decode(data);
    if decoded.Decoded? {
      CallBytes(index,core,self,Resolve.CallData(decoded.param,selector),guard,env,history);
    }
  }
  ghost method Dispatch(node: A.Node, stage: E.Stage, values: seq<seq<Byte>>, index: nat, parameters: seq<seq<Byte>>,
                        core: R.Address, self: R.Address, resolveSelector: seq<Byte>, guard: seq<Byte>,
                        decode: seq<Byte>->Resolve.Decode, env: R.Environment, history: seq<R.Request>, boundary: R.Observation)
    returns (raw: E.Raw, after: seq<R.Request>, tuple: Args.Receipt, arrayResult: CC.Result, constructed: seq<Byte>)
    requires Shape(node,stage,values,index) && Uint(index)
    requires Uint(|node.data|) && Uint(|node.arguments|) && |node.selector| == 4
    requires Uint(|values|) && Uint(64+Build.TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> Uint(|values[i]|)
    requires |guard| == 4 && |resolveSelector| == 4
    requires stage == E.GuardFailure ==> boundary.data == values[0]
    requires stage == E.Finish && node.kind == A.Wrap ==> Uint(|values[0]|+96)
    requires stage == E.Finish && node.kind == A.ProbeCall ==> Validate(Bytes,values[1]).Parsed? && Probe.Decodable(values[1])
    requires stage == E.Finish && node.kind == A.ProbeCall ==> |env.call(history,R.Call(Target(index,values[0]),Probe.DecodeBytes(values[1]))).data|+96 < Pow256(32)
    ensures Post(node,stage,values,index,parameters,core,self,resolveSelector,guard,decode,env,history,boundary,raw,after,tuple,arrayResult,constructed)
    ensures raw.Aborted? ==> B.Bytes(raw.error.payload)
    ensures stage == E.Address && raw.Produced? ==> M.AddressSpec(index,values[0]).Addressed?
  {
    after := history; tuple := Args.NotEncoded; arrayResult := CC.Success; constructed := [];
    if stage == E.Address {
      raw := Scalar.AddressReceipt(index,values[0]);
      if raw.Aborted? { BytesResult(M.ErrorBytes(M.BadNode(index))); }
      return;
    }
    if stage == E.Boolean {
      var value := Scalar.BooleanValue(values[0] == [1]);
      raw := E.Produced(value); return;
    }
    if stage == E.GuardFailure {
      // GuardFailure's exact source predicate is already proved by the scalar
      // adapter. Use that pure specification at this ghost-composition boundary.
      raw := M.GuardSpec(boundary);
      if raw.Aborted? { BytesResult(R.Signal()); }
      return;
    }
    if stage == E.Leaf {
      if node.kind == A.Literal { raw := E.Produced(node.data); return; }
      if node.kind == A.Parameter {
        raw := Scalar.ParameterReceipt(index,node.data,parameters);
        if raw.Aborted? { BytesResult(M.ErrorBytes(M.ParameterSpec(index,node.data,parameters).error)); }
        return;
      }
      var resolved := Resolve.Spec(node.data,index,core,self,resolveSelector,guard,decode,env,history);
      ResolveBytes(node.data,index,core,self,resolveSelector,guard,decode,env,history);
      raw := resolved.raw; after := resolved.history; return;
    }
    if node.kind == A.Wrap {
      constructed := Constructors.Wrap(values[0]); raw := E.Produced(constructed); return;
    }
    if node.kind == A.Array {
      constructed,arrayResult := Constructors.Array(node.arguments,values);
      raw := Codec.Receipt(arrayResult,constructed);
      if raw.Aborted? { BytesResult(Codec.Encoded(arrayResult)); }
      return;
    }
    if node.kind == A.Tuple {
      constructed,tuple := Constructors.Tuple(node.arguments,values);
      raw := Codec.Receipt(tuple.result,constructed);
      if raw.Aborted? { BytesResult(Codec.Encoded(tuple.result)); }
      return;
    }
    var target := Target(index,values[0]);
    if node.kind == A.Call {
      assert Build.TotalBytes(values[1..]) <= Build.TotalBytes(values);
      constructed,tuple := Constructors.CallArguments(node.selector,node.arguments,values[1..]);
      if !tuple.result.Success? {
        raw := Codec.Receipt(tuple.result,[]); BytesResult(Codec.Encoded(tuple.result)); return;
      }
      raw := CallRaw(index,target,self,constructed,guard,env,history);
      after := C.Call(index,target,self,constructed,guard,env,history).history;
      CallBytes(index,target,self,constructed,guard,env,history); return;
    }
    Probe.CanonicalDecode(values[1]);
    var data := Probe.DecodeBytes(values[1]);
    RS.ProbeFields(target,self,data,guard,node.selector,env,history);
    var result := C.Probe(target,self,data,guard,node.selector,env,history).result;
    raw := ProbeRaw(target,self,data,guard,node.selector,env,history);
    after := C.Probe(target,self,data,guard,node.selector,env,history).history;
    if result.Failed? { BytesResult(W.Spec(result.error)); }
  }
}
