// SPDX-License-Identifier: MIT
include "Errors.dfy"

module CoreSerializationBounds {
  import opened AbiFrames
  import I = CoreRecursiveInvocation
  import T = CoreRawTree
  import E = CoreSerializationEncoding
  import Errors = CoreSerializationErrors
  import ABI = AbiEncoding
  import Words = ResolutionWords
  import V = AbiValidation

  ghost predicate ReplyFits(reply: I.Reply) {
    match reply
    case Resolved(out) =>
      if out.result.Value? then |out.result.bytes| < Words.Limit() else E.Fits(Errors.Resolution(out.result.error))
    case Raw(out) =>
      if out.result.Bytes? then |out.result.data| < Words.Limit() else E.Fits(Errors.Core(out.result.error))
    case Collected(out) =>
      if out.Values? then
        ABI.WellTyped(ABI.Array(ABI.Bytes),ABI.Items(E.Buffers(out.values))) &&
        ABI.Fits(ABI.Array(ABI.Bytes),ABI.Items(E.Buffers(out.values)))
      else E.Fits(Errors.Core(out.error))
    case Probed(out) =>
      if out.result.Reason? then |out.result.bytes| < Words.Limit() else E.Fits(Errors.Probe(out.result.error))
    case Constructed(out,_) =>
      if out.result.Returned? then |out.result.data| < Words.Limit() else
      if out.result.CoreFailure? then E.Fits(Errors.Core(out.result.error)) else
      !out.result.codecError.Success? && E.Fits(Errors.Codec(out.result.codecError))
    case Navigated(out) =>
      if out.result.ResolverFailed? then E.Fits(Errors.Resolution(out.result.error)) else
      if out.result.result.BytesReturned? then |out.result.result.bytes| < Words.Limit() else E.Fits(Errors.Navigation(out.result.result.error))
  }
  lemma GatherValidated(values: seq<seq<Byte>>)
    requires ABI.WellTyped(ABI.Array(ABI.Bytes),ABI.Items(E.Buffers(values)))
    requires ABI.Fits(ABI.Array(ABI.Bytes),ABI.Items(E.Buffers(values)))
    ensures V.Validate(ABI.Array(ABI.Bytes),E.Gather(values)) == V.Parsed(ABI.Items(E.Buffers(values)),|E.Gather(values)|)
  {
    E.GatherCanonical(values);
    V.ValidationComplete(ABI.Array(ABI.Bytes),ABI.Items(E.Buffers(values)));
  }
  ghost predicate TreeFits(r: T.Receipt) {
    !r.state.Unready? && (r.state.Ran? ==> ReplyFits(r.state.reply)) && ForestFits(r.children)
  }
  ghost predicate ForestFits(rs: T.Receipts) {
    match rs
    case None => true
    case More(_,_,_,_,child,tail) => TreeFits(child) && ForestFits(tail)
  }
}
