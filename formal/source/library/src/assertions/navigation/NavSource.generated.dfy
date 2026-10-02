// SPDX-License-Identifier: MIT
// Navigation after operand resolution; Assertions.sol SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
include "Entry.dfy"
include "ValueSource.generated.dfy"
include "ModesSource.generated.dfy"

module NavigationSource {
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

  ghost method LengthModeCall(t: seq<Byte>, data: seq<Byte>, path: seq<int>) returns (r: ReturnResult)
    requires Uint(|t|) && Uint(|data|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures r == LengthNavigation(t,data,path)
  {
    if |path| == 0 { r := ReturnResult.Rejected(InvalidNavigation(0)); return; }
    var c := NavigationTraverseSource.Navigate(t,data,path);
    if c.Stopped? { r := ReturnResult.Rejected(c.error); return; }
    var length := NavigationModeSource.LengthAt(t,data,c.cursor);
    if length.Failed? { r := ReturnResult.Rejected(length.error); return; }
    r := BytesReturned(Word(length.value));
  }

  ghost method PayloadModeCall(t: seq<Byte>, data: seq<Byte>, path: seq<int>) returns (r: ReturnResult)
    requires Uint(|t|) && Uint(|data|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures r == PayloadNavigation(t,data,path)
  {
    if |path| == 0 { r := ReturnResult.Rejected(InvalidNavigation(0)); return; }
    var c := NavigationTraverseSource.Navigate(t,data,path);
    if c.Stopped? { r := ReturnResult.Rejected(c.error); return; }
    r := NavigationModeSource.PayloadAt(t,data,c.cursor);
  }

  // The full source gate pins one _resolve(a,"",0,0) call before this boundary.
  // Its failures escape unchanged. Arbitrary producer/resolver correctness is
  // not assumed to follow from correctness of navigation on resolved bytes.
  ghost method {:isolate_assertions} NavResolved(t: seq<Byte>, data: seq<Byte>, path: seq<int>)
    returns (r: ReturnResult)
    requires Uint(|t|) && Uint(|data|+32) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures |path| == 0 ==> r == BytesReturned(data)
    ensures LastMode(path) == LengthMode ==> r == LengthNavigation(t,data,path[..|path|-1])
    ensures LastMode(path) == PayloadMode ==> r == PayloadNavigation(t,data,path[..|path|-1])
    ensures |path| > 0 && LastMode(path) == ValueMode ==>
              (var c := Navigation(t,data,path);
               if c.Stopped? then r == ReturnResult.Rejected(c.error) else
               WellFormed(TypeOf(c.cursor.syntax)) &&
               (!Dyn(c.cursor.syntax) ==> r == StaticValue(data,c.cursor)) &&
               (r.Rejected? && r.error.Panic? ==> r.error.code == 17 && !CursorRoom(c.cursor.syntax,|data|)) &&
               (!(r.Rejected? && r.error.Panic?) ==>
                  r.BytesReturned? == (c.cursor.base <= |data| && Walk(TypeOf(c.cursor.syntax),data[c.cursor.base..]).Parsed?)) &&
               (r.BytesReturned? ==> r.bytes == (if Dyn(c.cursor.syntax) then Word(32) else [])+
                                                data[c.cursor.base..c.cursor.base+Walk(TypeOf(c.cursor.syntax),data[c.cursor.base..]).used]))
  {
    if |path| == 0 { r := BytesReturned(data); return; }
    if path[|path|-1] == LenSentinel() {
      r := LengthModeCall(t,data,path[..|path|-1]); return;
    }
    if path[|path|-1] == PayloadSentinel() {
      r := PayloadModeCall(t,data,path[..|path|-1]); return;
    }
    var c := NavigationTraverseSource.Navigate(t,data,path);
    if c.Stopped? { r := ReturnResult.Rejected(c.error); return; }
    r := NavigationValueSource.ValueAt(t,data,c.cursor);
  }
}
