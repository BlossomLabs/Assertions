// SPDX-License-Identifier: MIT
include "../navigation/Correspondence.dfy"
include "../resolution/Model.dfy"
module CompositionModel {
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
  import NavigationCorrespondence

  datatype Result = ResolverFailed(error: R.Error) | Navigated(result: ReturnResult)
  datatype Outcome = Outcome(result: Result, history: seq<R.Request>)

  ghost predicate NavigationPost(t: seq<Byte>, data: seq<Byte>, path: seq<int>, r: ReturnResult)
    requires Uint(|t|) && Uint(|data|+32) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
  {
    (|path| == 0 ==> r == BytesReturned(data)) &&
    (LastMode(path) == LengthMode ==> r == LengthNavigation(t,data,path[..|path|-1])) &&
    (LastMode(path) == PayloadMode ==> r == PayloadNavigation(t,data,path[..|path|-1])) &&
    (|path| > 0 && LastMode(path) == ValueMode ==>
       (var c := Navigation(t,data,path);
        if c.Stopped? then r == ReturnResult.Rejected(c.error) else
        WellFormed(TypeOf(c.cursor.syntax)) &&
        (!Dyn(c.cursor.syntax) ==> r == StaticValue(data,c.cursor)) &&
        (r.Rejected? && r.error.Panic? ==> r.error.code == 17 && !CursorRoom(c.cursor.syntax,|data|)) &&
        (!(r.Rejected? && r.error.Panic?) ==>
           r.BytesReturned? == (c.cursor.base <= |data| && Walk(TypeOf(c.cursor.syntax),data[c.cursor.base..]).Parsed?)) &&
        (r.BytesReturned? ==> r.bytes == (if Dyn(c.cursor.syntax) then Word(32) else [])+
                                         data[c.cursor.base..c.cursor.base+Walk(TypeOf(c.cursor.syntax),data[c.cursor.base..]).used])))
  }

  ghost predicate NavPost(a: R.Param, t: seq<Byte>, path: seq<int>, env: R.Environment, history: seq<R.Request>, out: Outcome)
    requires Uint(|t|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires R.Resolve(a,C.Context([],0,0),env,history).result.Value? ==>
               Uint(|R.Resolve(a,C.Context([],0,0),env,history).result.bytes|+32)
  {
    var resolved := R.Resolve(a,C.Context([],0,0),env,history);
    out.history == resolved.history &&
    (if resolved.result.Failed? then out.result == ResolverFailed(resolved.result.error)
     else out.result.Navigated? && NavigationPost(t,resolved.result.bytes,path,out.result.result))
  }
}
