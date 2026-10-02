// SPDX-License-Identifier: MIT
// Raw admitted entry from PC zero, under representability/resources premises.
include "Body.dfy"
include "../iota/Prefix.generated.dfy"
include "../iota/Decoder.generated.dfy"
include "../iota/RawHead.generated.dfy"
module BytecodeIotaRawEntry {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = BytecodeIotaPrefix
  import D = BytecodeIotaDecoder
  import H = BytecodeIotaRawHead
  import B = BytecodeIotaBodyConnection
  import C = BytecodeCopyExecution
  import L = BytecodeCopyTraceLift
  predicate Matches(code: seq<S.Byte>) {
    P.Matches(code) && D.Matches(code) && H.Matches(code) && B.Matches(code)
  }
  function Destinations(): set<nat> { P.Destinations()+D.Destinations()+H.Destinations()+B.Destinations() }
  function Result(data: seq<S.Byte>): S.State {
    if |data| < 36 then S.Reverted([]) else B.Result(S.DataWord(data,4))
  }
  ghost method Run(code: seq<S.Byte>, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && P.Admitted(value,data)
    ensures state == Result(data)
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(0,[],[]) && trace[|trace|-1] == state
  {
    var selected,prefix := P.Run(code,value,data);
    L.Trace(code,P.Destinations(),value,data,prefix);
    C.WidenTrace(code,P.Destinations(),Destinations(),value,data,prefix);
    if |data| < 36 {
      var rejected,head := H.Run(code,value,data);
      L.Trace(code,H.Destinations(),value,data,head);
      C.WidenTrace(code,H.Destinations(),Destinations(),value,data,head);
      C.Join(code,Destinations(),value,data,prefix,head);
      state := rejected; trace := prefix+head[1..];
    } else {
      var decoded,head := D.Run(code,value,data);
      L.Trace(code,D.Destinations(),value,data,head);
      C.WidenTrace(code,D.Destinations(),Destinations(),value,data,head);
      C.Join(code,Destinations(),value,data,prefix,head);
      var first := prefix+head[1..];
      var terminal,body := B.Run(code,S.DataWord(data,4),value,data);
      C.WidenTrace(code,B.Destinations(),Destinations(),value,data,body);
      C.Join(code,Destinations(),value,data,first,body);
      state := terminal; trace := first+body[1..];
    }
  }
}
