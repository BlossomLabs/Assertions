// SPDX-License-Identifier: MIT
// Gated Assertions.sol SHA-256: $HASH
include "Model.dfy"
include "../resolution/Source.generated.dfy"
module CompositionSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics
  import opened NavigationModel
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import opened NavigationModes
  import opened NavigationTerminals
  import opened NavigationEntry
  import NavigationTraverseSource
  import NavigationModeSource
  import NavigationValueSource

  import C = ConstraintModel
  import R = ResolutionModel
  import Resolver = ResolutionSource
  import NavigationSource
  import NavigationCorrespondence
  import opened CompositionModel

  ghost method Nav(a: R.Param, t: seq<Byte>, path: seq<int>, env: R.Environment, history: seq<R.Request>) returns (out: CompositionModel.Outcome)
    requires Uint(|t|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires R.Resolve(a,C.Context([],0,0),env,history).result.Value? ==>
               Uint(|R.Resolve(a,C.Context([],0,0),env,history).result.bytes|+32)
    ensures NavPost(a,t,path,env,history,out)
  {
    var resolved := Resolver.ResolveSource(a,C.Context([],$ENTRY,$PARAM),env,history);
    if resolved.result.Failed? {
      out := CompositionModel.Outcome(ResolverFailed(resolved.result.error),resolved.history); return;
    }
    var navigated := NavigationSource.NavResolved(t,resolved.result.bytes,path);
    out := CompositionModel.Outcome(Navigated(navigated),resolved.history);
  }

  // Specializes the same source wrapper to canonical producer bytes. The
  // existing CanonicalQuery implementation invokes NavResolved and proves
  // correspondence to the independent recursive Query specification.
  ghost method CanonicalNav(a: R.Param, s: Descriptor, v: Value, path: seq<int>, mode: NavigationModel.Mode, env: R.Environment, history: seq<R.Request>) returns (out: CompositionModel.Outcome)
    requires Admissible(s) && s.Group? && WellTyped(TypeOf(s),v) && Fits(TypeOf(s),v)
    requires Uint(|Render(s)|) && Uint(|Body(TypeOf(s),v)|+32*0x100000000*|Render(s)|)
    requires Uint(|path|+1) && forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires mode == ValueMode ==> LastMode(path) == ValueMode
    requires R.Resolve(a,C.Context([],0,0),env,history).result.Value? ==>
               R.Resolve(a,C.Context([],0,0),env,history).result.bytes == Body(TypeOf(s),v)
    ensures out.history == R.Resolve(a,C.Context([],0,0),env,history).history
    ensures R.Resolve(a,C.Context([],0,0),env,history).result.Failed? ==>
              out.result == ResolverFailed(R.Resolve(a,C.Context([],0,0),env,history).result.error)
    ensures R.Resolve(a,C.Context([],0,0),env,history).result.Value? ==>
              out.result.Navigated? && NavigationCorrespondence.AnswerOf(out.result.result) == Query(TypeOf(s),v,path,mode)
  {
    var resolved := Resolver.ResolveSource(a,C.Context([],$ENTRY,$PARAM),env,history);
    if resolved.result.Failed? {
      out := CompositionModel.Outcome(ResolverFailed(resolved.result.error),resolved.history); return;
    }
    var navigated := NavigationCorrespondence.CanonicalQuery(s,v,path,mode);
    out := CompositionModel.Outcome(Navigated(navigated),resolved.history);
  }
}
