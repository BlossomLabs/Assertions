// SPDX-License-Identifier: MIT
include "Connection.dfy"
include "../self-call/Connection.dfy"

module ExpressionPublicEncoded {
  import opened AbiFrames
  import opened AbiByteSemantics
  import R = ResolutionModel
  import O = ExpressionOracleModel
  import Entry = ExpressionEntryConnection
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import Bounds = ExpressionAdmissionErrorBounds
  import Encoded = ExpressionEncodedModel
  import Wrapper = ExpressionEncodedConnection
  import Link = ExpressionSelfCallConnection
  import Public = ExpressionPublicConnection
  import M = ExpressionPublicModel
  import Guards = ExpressionPublicGuards
  import Memory = ExpressionReturnMemory
  import Return = ExpressionReturnSource

  datatype Inner = NoGraph | Evaluated(out: Entry.Outcome, raw: E.Raw,
                                       evidence: M.Evidence, guards: seq<Guards.Record>)

  // One explicit modeled self-call observation connects the already-proved
  // encoded source wrapper to the public graph evaluation. Gas is observed,
  // and caller/static/memory projections remain separate EVM premises.
  ghost method Compose(c: O.Config, result: nat, hash: seq<Byte>->nat,
                       data: seq<Byte>, decode: seq<Byte>->Encoded.Decode, gas: Link.Gas,
                       base: R.Environment, history: seq<R.Request>)
    returns (inner: Inner, outer: Encoded.Outcome, linked: R.Environment)
    requires decode(data).Decoded? ==> Bounds.WordNodes(c.nodes) && Uint(result) &&
                                       decode(data).graph == Encoded.Graph(c.core,c.nodes,result) &&
                                       Encoded.Wire(Encoded.Graph(c.core,c.nodes,result),c.parameters)
    ensures inner.NoGraph? <==> decode(data).Malformed?
    ensures inner.NoGraph? ==> outer == Encoded.Outcome(E.Aborted(E.Error([])),history) && linked == base
    ensures outer == Encoded.Spec(data,c.parameters,c.self,decode,linked,history)
    ensures inner.Evaluated? ==> M.EntryResult(c,result,inner.out) && inner.raw == M.Raw(inner.out) &&
                                 M.Certified(c,result,inner.out,inner.evidence)
    ensures inner.Evaluated? && inner.evidence.Complete? ==>
              |inner.guards| == |inner.evidence.frames| &&
              forall j :: 0 <= j < |inner.guards| ==> Guards.Certified(c,result,inner.out,inner.evidence,j,inner.guards[j])
    ensures inner.Evaluated? ==> Link.ByteRaw(inner.raw)
    ensures inner.Evaluated? ==>
              linked == Link.Install(base,history,R.Call(c.self,Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters)),Link.Observe(inner.raw,gas)) &&
              outer.history == history+[R.Call(c.self,Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters))] &&
              outer.raw == Link.Verdict(inner.raw,Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters),c.self,gas)
    ensures outer.raw.Produced? <==> inner.Evaluated? && inner.raw.Produced?
    ensures outer.raw.Produced? ==> outer.raw == inner.raw
  {
    linked := base;
    if decode(data).Malformed? {
      inner := NoGraph;
      outer := Encoded.Spec(data,c.parameters,c.self,decode,linked,history);
      return;
    }
    var out,raw,evidence,guards := Public.Evaluate(c,result,hash);
    inner := Evaluated(out,raw,evidence,guards);
    var callData := Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters);
    linked := Link.Install(base,history,R.Call(c.self,callData),Link.Observe(raw,gas));
    Link.InstalledCall(base,history,R.Call(c.self,callData),Link.Observe(raw,gas));
    outer := Encoded.Spec(data,c.parameters,c.self,decode,linked,history);
    Wrapper.Outcomes(data,c.parameters,c.self,decode,linked,history);
    if raw.Produced? { assert B.Narrow(raw.value) == raw.value; }
  }

  ghost method ReturnBytes(outer: Encoded.Outcome, memory: seq<Byte>, pointer: nat)
    returns (returned: E.Raw)
    requires outer.raw.Produced? ==> B.Bytes(outer.raw.value) && Memory.Object(memory,pointer,B.Narrow(outer.raw.value))
    ensures returned == outer.raw
  {
    returned := outer.raw;
    if outer.raw.Produced? {
      var value := Return.EncodedReturn(memory,pointer,B.Narrow(outer.raw.value));
      returned := E.Produced(value);
    }
  }
}
