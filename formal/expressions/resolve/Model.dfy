// SPDX-License-Identifier: MIT
include "../receipts/Connection.dfy"
include "../../core/Source.generated.dfy"
module ExpressionResolveModel {
  import opened AbiFrames
  import R = ResolutionModel
  import K = ConstraintModel
  import C = ExpressionCallModel
  import W = ExpressionReceiptEncoding
  import ReceiptSource = ExpressionReceiptConnection
  import E = ExpressionEvaluationControl

  datatype Decode = Malformed | Decoded(param: R.Param)
  datatype Outcome = Outcome(raw: E.Raw, history: seq<R.Request>)
  function RouteId(route: R.Route): nat { match route case TARGET => 0 case VALUE => 1 case CALL_DATA => 2 }
  function FetcherId(fetcher: R.Fetcher): nat { match fetcher case RAW_BYTES => 0 case STATIC_CALL => 1 case BALANCE => 2 }
  function KindId(kind: K.Kind): nat {
    match kind
    case EQ => 0 case GTE => 1 case LTE => 2 case IN => 3
    case GTE_SIGNED => 4 case LTE_SIGNED => 5 case OR => 6 case SKIP => 7 case IN_SIGNED => 8
  }
  function ConstraintBody(c: K.Constraint): seq<Byte> {
    Frame([Piece(false,Word(KindId(c.kind))),Piece(true,W.Blob(c.data))])
  }
  function ConstraintPieces(cs: seq<K.Constraint>): seq<Piece>
    decreases |cs|
  { if |cs| == 0 then [] else [Piece(true,ConstraintBody(cs[0]))]+ConstraintPieces(cs[1..]) }
  function ParamEncoding(p: R.Param): seq<Byte> {
    Word(32)+Frame([Piece(false,Word(RouteId(p.route))),Piece(false,Word(FetcherId(p.fetcher))),
                    Piece(true,W.Blob(p.data)),Piece(true,Word(|p.constraints|)+Frame(ConstraintPieces(p.constraints)))])
  }
  function CallData(p: R.Param, selector: seq<Byte>): seq<Byte>
    requires |selector| == 4
  { selector+ParamEncoding(p) }
  lemma CallDataPrefix(p: R.Param, selector: seq<Byte>)
    requires |selector| == 4
    ensures CallData(p,selector)[..4] == selector
    ensures CallData(p,selector)[4..36] == Word(32)
    ensures RouteId(p.route) < 3 && FetcherId(p.fetcher) < 3
    ensures forall c <- p.constraints :: KindId(c.kind) < 9
  {}
  ghost function Spec(data: seq<Byte>, index: nat, core: R.Address, self: R.Address,
                      resolveSelector: seq<Byte>, guardSelector: seq<Byte>, decode: seq<Byte>->Decode,
                      env: R.Environment, history: seq<R.Request>): Outcome
    requires |resolveSelector| == 4 && |guardSelector| == 4 && index < Pow256(32)
  {
    var d := decode(data);
    if d.Malformed? then Outcome(E.Aborted(E.Error([])),history) else
    var calldata := CallData(d.param,resolveSelector);
    ReceiptSource.CallFields(index,core,self,calldata,guardSelector,env,history);
    var out := C.Call(index,core,self,calldata,guardSelector,env,history);
    Outcome(if out.result.Returned? then E.Produced(out.result.data) else E.Aborted(E.Error(W.Spec(out.result.error))),out.history)
  }
}
