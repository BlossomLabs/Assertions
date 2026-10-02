// SPDX-License-Identifier: MIT
include "../recursive/Dispatch.dfy"

module CoreFrameWire {
  import opened AbiFrames
  import opened AbiByteSemantics
  import I = CoreRecursiveInvocation
  import R = ResolutionModel
  import K = CoreModel
  import P = ProbeModel
  import A = AbiConstructionContext
  import N = NavigationRuntime
  import ConstraintModel

  // These functions are ABI projections, not selectable execution outcomes.
  // Faithfulness to the deployed ABI encoder is a separate boundary premise.
  datatype Encoding = Encoding(resolution: R.Error -> seq<Byte>,
                               emptyChain: seq<Byte>,
                               probe: P.Error -> seq<Byte>,
                               codec: A.Result -> seq<Byte>,
                               navigation: N.Error -> seq<Byte>,
                               gathered: seq<seq<Byte>> -> seq<Byte>)
  datatype Raw = Returned(data: seq<Byte>) | Reverted(data: seq<Byte>)

  function ResolverError(e: R.Error, encoding: Encoding): seq<Byte> {
    if e == R.SubcallOutOfGas then R.Signal() else
    if e == R.BareRevert then [] else encoding.resolution(e)
  }
  function CoreError(e: K.CoreError, encoding: Encoding): seq<Byte> {
    if e.Base? then ResolverError(e.error,encoding) else encoding.emptyChain
  }
  function ProbeError(e: P.Error, encoding: Encoding): seq<Byte> {
    match e
    case ResolutionError(error) => ResolverError(error,encoding)
    case _ => encoding.probe(e)
  }
  function Serialize(reply: I.Reply, encoding: Encoding): Raw {
    match reply
    case Resolved(out) =>
      if out.result.Value? then Returned(out.result.bytes) else Reverted(ResolverError(out.result.error,encoding))
    case Raw(out) =>
      if out.result.Bytes? then Returned(out.result.data) else Reverted(CoreError(out.result.error,encoding))
    case Collected(out) =>
      if out.Values? then Returned(encoding.gathered(out.values)) else Reverted(CoreError(out.error,encoding))
    case Probed(out) =>
      if out.result.Reason? then Returned(out.result.bytes) else Reverted(ProbeError(out.result.error,encoding))
    case Constructed(out,_) =>
      if out.result.Returned? then Returned(out.result.data) else
      if out.result.CoreFailure? then Reverted(CoreError(out.result.error,encoding)) else Reverted(encoding.codec(out.result.codecError))
    case Navigated(out) =>
      if out.result.ResolverFailed? then Reverted(ResolverError(out.result.error,encoding)) else
      if out.result.result.BytesReturned? then Returned(out.result.result.bytes) else Reverted(encoding.navigation(out.result.result.error))
  }
  function Observe(raw: Raw, before: ConstraintModel.Word, after: ConstraintModel.Word): R.Observation {
    R.Observation(true,raw.Returned?,raw.data,before,after)
  }
}
