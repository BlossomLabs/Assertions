// SPDX-License-Identifier: MIT
include "Modes.dfy"

module NavigationEntry {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened NavigationModel
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import opened NavigationModes

  function LenSentinel(): int { -(Half() as int) }
  function PayloadSentinel(): int { LenSentinel()+1 }

  function LastMode(path: seq<int>): Mode {
    if |path| == 0 then ValueMode else
    if path[|path|-1] == LenSentinel() then LengthMode else
    if path[|path|-1] == PayloadSentinel() then PayloadMode else ValueMode
  }

  ghost function LengthNavigation(t: seq<Byte>, data: seq<Byte>, path: seq<int>): ReturnResult
    requires Uint(|t|) && Uint(|data|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
  {
    if |path| == 0 then Rejected(InvalidNavigation(0)) else
    var c := Navigation(t,data,path);
    if c.Stopped? then Rejected(c.error) else
    var length := CursorLength(data,c.cursor);
    if length.Failed? then Rejected(length.error) else BytesReturned(Word(length.value))
  }

  ghost function PayloadNavigation(t: seq<Byte>, data: seq<Byte>, path: seq<int>): ReturnResult
    requires Uint(|t|) && Uint(|data|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
  {
    if |path| == 0 then Rejected(InvalidNavigation(0)) else
    var c := Navigation(t,data,path);
    if c.Stopped? then Rejected(c.error) else CursorPayload(data,c.cursor)
  }
}
