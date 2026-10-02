// SPDX-License-Identifier: MIT
include "../receipts/Connection.dfy"
include "../admission/Model.dfy"
module ExpressionEncodedModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import A = ExpressionAdmission
  import R = ResolutionModel
  import C = ExpressionCallModel
  import W = ExpressionReceiptEncoding
  import Receipt = ExpressionReceiptConnection
  import E = ExpressionEvaluationControl

  datatype Graph = Graph(core: R.Address, nodes: seq<A.Node>, result: nat)
  datatype Decode = Malformed | Decoded(graph: Graph)
  datatype Outcome = Outcome(raw: E.Raw, history: seq<R.Request>)
  function EvaluateSelector(): seq<Byte> { [0x0d,0x93,0xbe,0xea] }
  function GuardSelector(): seq<Byte> { [0xfd,0xf5,0x47,0x63] }
  function KindId(kind: A.Kind): nat
    ensures KindId(kind) < 11
  {
    match kind
    case Literal => 0 case Parameter => 1 case Resolve => 2 case Call => 3
    case Select => 4 case Wrap => 5 case Array => 6 case Tuple => 7
    case TryOrElse => 8 case IsValid => 9 case ProbeCall => 10
  }
  function ReferencePieces(refs: seq<nat>): seq<Piece>
    decreases |refs|
  { if |refs| == 0 then [] else [Piece(false,Word(refs[0]))]+ReferencePieces(refs[1..]) }
  function NodeBody(node: A.Node): seq<Byte>
    requires |node.selector| == 4
  {
    Frame([Piece(false,Word(KindId(node.kind))),Piece(true,W.Blob(node.valueType)),Piece(true,W.Blob(node.data)),
           Piece(true,Word(|node.refs|)+Frame(ReferencePieces(node.refs))),Piece(false,node.selector+Zeros(28)),Piece(true,W.Blob(node.arguments))])
  }
  predicate Selectors(nodes: seq<A.Node>) { forall node <- nodes :: |node.selector| == 4 }
  function NodePieces(nodes: seq<A.Node>): seq<Piece>
    requires Selectors(nodes)
    decreases |nodes|
  { if |nodes| == 0 then [] else [Piece(true,NodeBody(nodes[0]))]+NodePieces(nodes[1..]) }
  function GraphBody(graph: Graph): seq<Byte>
    requires Selectors(graph.nodes)
  { Frame([Piece(false,Word(graph.core)),Piece(true,Word(|graph.nodes|)+Frame(NodePieces(graph.nodes))),Piece(false,Word(graph.result))]) }
  function ParameterPieces(parameters: seq<seq<Byte>>): seq<Piece>
    decreases |parameters|
  { if |parameters| == 0 then [] else [Piece(true,W.Blob(parameters[0]))]+ParameterPieces(parameters[1..]) }
  function CallData(graph: Graph, parameters: seq<seq<Byte>>): seq<Byte>
    requires Selectors(graph.nodes)
  { EvaluateSelector()+Frame([Piece(true,GraphBody(graph)),Piece(true,Word(|parameters|)+Frame(ParameterPieces(parameters)))]) }
  predicate Wire(graph: Graph, parameters: seq<seq<Byte>>) {
    Selectors(graph.nodes) && Uint(graph.result) &&
    (forall node <- graph.nodes :: forall r <- node.refs :: Uint(r)) && Uint(|CallData(graph,parameters)|)
  }
  lemma {:fuel HeadSize,4,5} {:fuel Heads,4,5} CallDataPrefix(graph: Graph, parameters: seq<seq<Byte>>)
    requires Selectors(graph.nodes)
    ensures CallData(graph,parameters)[..4] == EvaluateSelector()
    ensures !C.ForbiddenRequest(graph.core,graph.core,CallData(graph,parameters),GuardSelector())
    ensures CallData(graph,parameters)[4..36] == Word(64)
  {
    var pieces := [Piece(true,GraphBody(graph)),Piece(true,Word(|parameters|)+Frame(ParameterPieces(parameters)))];
    assert HeadSize(pieces) == 64;
    assert Heads(pieces,64)[..32] == Word(64);
  }
  ghost function Spec(data: seq<Byte>, parameters: seq<seq<Byte>>, self: R.Address, decode: seq<Byte>->Decode,
                      env: R.Environment, history: seq<R.Request>): Outcome
    requires decode(data).Decoded? ==> Wire(decode(data).graph,parameters)
  {
    var d := decode(data);
    if d.Malformed? then Outcome(E.Aborted(E.Error([])),history) else
    var calldata := CallData(d.graph,parameters);
    Receipt.CallFields(0,self,self,calldata,GuardSelector(),env,history);
    var called := C.Call(0,self,self,calldata,GuardSelector(),env,history);
    Outcome(if called.result.Returned? then E.Produced(called.result.data) else E.Aborted(E.Error(W.Spec(called.result.error))),called.history)
  }
}
