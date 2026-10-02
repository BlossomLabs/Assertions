// SPDX-License-Identifier: MIT
include "Encoding.dfy"

module CoreSerializationErrors {
  import opened AbiFrames
  import opened CoreSerializationEncoding
  import S = CoreSerializationSignatures
  import C = ConstraintModel
  import R = ResolutionModel
  import K = CoreModel
  import P = ProbeModel
  import A = AbiConstructionContext
  import N = NavigationRuntime

  function Kind(k: C.Kind): nat {
    match k
    case EQ => 0 case GTE => 1 case LTE => 2 case IN => 3
    case GTE_SIGNED => 4 case LTE_SIGNED => 5 case OR => 6 case SKIP => 7 case IN_SIGNED => 8
  }
  function Fetcher(f: R.Fetcher): nat {
    match f case RAW_BYTES => 0 case STATIC_CALL => 1 case BALANCE => 2
  }
  function Constraint(e: C.Error): Packet {
    match e
    case ReturnDataOutOfBounds(i,n) => Error(S.ReturnDataOutOfBounds,[I(i),U(n)])
    case ConstraintFailed(c,i,k,actual,reference) => Error(S.ConstraintFailed,[Text(c.assertion),U(c.entry),U(c.param),U(i),Enum(Kind(k)),Word(actual),Blob(reference)])
    case InvalidConstraintData(e,p,i,n) => Error(S.InvalidConstraintData,[U(e),U(p),U(i),U(n)])
    case InvalidConstraintRange(e,p,i) => Error(S.InvalidConstraintRange,[U(e),U(p),U(i)])
    case InvalidOrConstraint(e,p,i) => Error(S.InvalidOrConstraint,[U(e),U(p),U(i)])
    case BareRevert => Bare
  }
  function Resolution(e: R.Error): Packet {
    match e
    case ConstraintError(e) => Constraint(e)
    case CallFailed(t,d) => Error(S.CallFailed,[Address(t),Blob(d)])
    case SubcallOutOfGas => Error(S.SubcallOutOfGas,[])
    case InvalidBalanceData(e,p,n) => Error(S.InvalidBalanceData,[U(e),U(p),U(n)])
    case ReturnDataOutOfBounds(i,n) => Error(S.ReturnDataOutOfBounds,[I(i),U(n)])
    case InvalidAddressWord(i,w) => Error(S.InvalidAddressWord,[U(i),Word(w)])
    case BareRevert => Bare
    case OutputParamsNotSupported(e) => Error(S.OutputParamsNotSupported,[U(e)])
    case ValueParamNotSupported(e,p) => Error(S.ValueParamNotSupported,[U(e),U(p)])
    case DuplicateTargetParam(e) => Error(S.DuplicateTargetParam,[U(e)])
    case BalanceCannotBeTarget(e,p) => Error(S.BalanceCannotBeTarget,[U(e),U(p)])
  }
  function Core(e: K.CoreError): Packet {
    match e
    case Base(e) => Resolution(e)
    case EmptyCallChain => Error(S.EmptyCallChain,[])
  }
  function Probe(e: P.Error): Packet {
    match e
    case ResolutionError(e) => Resolution(e)
    case DidNotRevert(t,d) => Error(S.DidNotRevert,[Address(t),Blob(d)])
    case UnexpectedRevertData(e,a) => Error(S.UnexpectedRevertData,[Four(e),Four(a)])
    case RevertProbeNotACall(f) => Error(S.RevertProbeNotACall,[Enum(Fetcher(f))])
    case RevertProbeConstrained(n) => Error(S.RevertProbeConstrained,[U(n)])
  }
  function Codec(e: A.Result): Packet {
    match e
    case Success => Bare // totalization; a successful encoder is not an error
    case InvalidValue(n) => Error(S.InvalidValue,[U(n)])
    case InvalidComponentValue(i,n) => Error(S.InvalidComponentValue,[U(i),U(n)])
    case InvalidCallbackResult(op,i,o,t) => Error(S.InvalidCallbackResult,[Four(NatBytes(op,4)),U(i),U(o),Address(t)])
    case InvalidComponentEnvelope(i,n,h) => Error(S.InvalidComponentEnvelope,[U(i),U(n),Word(h)])
    case InvalidComponentLength(i,e,a) => Error(S.InvalidComponentLength,[U(i),U(e),U(a)])
    case ComponentCountMismatch(e,a) => Error(S.ComponentCountMismatch,[U(e),U(a)])
    case InvalidDescriptor(i) => Error(S.InvalidTypeDescriptor,[U(i)])
    case Panic(c) => Error(S.Panic,[U(c)])
  }
  function Navigation(e: N.Error): Packet {
    match e
    case InvalidNavigation(i) => Error(S.InvalidNavigation,[U(i)])
    case ReturnDataOutOfBounds(i,n) => Error(S.ReturnDataOutOfBounds,[I(i),U(n)])
    case InvalidTypeDescriptor(i) => Error(S.InvalidTypeDescriptor,[U(i)])
    case InvalidValue(i) => Error(S.InvalidValue,[U(i)])
    case ElementIndexOutOfBounds(i,n) => Error(S.ElementIndexOutOfBounds,[I(i),U(n)])
    case Panic(c) => Error(S.Panic,[U(c)])
  }
  lemma ConstraintShape(e: C.Error)
    ensures Shape(Constraint(e))
  {}
  lemma ResolutionShape(e: R.Error)
    ensures Shape(Resolution(e))
  { if e.ConstraintError? { ConstraintShape(e.detail); } }
  lemma CoreShape(e: K.CoreError)
    ensures Shape(Core(e))
  { if e.Base? { ResolutionShape(e.error); } }
  lemma ProbeShape(e: P.Error)
    ensures Shape(Probe(e))
  {
    match e
    case ResolutionError(error) => ResolutionShape(error);
    case _ =>
  }
  lemma CodecShape(e: A.Result)
    ensures Shape(Codec(e))
  {}
  lemma NavigationShape(e: N.Error)
    ensures Shape(Navigation(e))
  {}
}
