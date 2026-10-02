// SPDX-License-Identifier: MIT
// Complete raw nonempty admission through the first reached callback failure.
include "../first-failure-repair-v2/Loop.dfy"
include "../raw-loop-connection-repair-v3/Connection.dfy"
module BytecodeFoldRawFirstFailure {
  import opened BytecodeScanMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import W = BytecodeFoldRawWindows
  import RT = BytecodeFoldRawTarget
  import T = BytecodeFoldRawTemplate
  import P = BytecodeFoldRawLoopReadyV2
  import B = BytecodeFoldRawLoopConnectionV3
  import L = BytecodeFoldLoopModelV2
  import M = BytecodeFoldFirstFailureModel
  import F = BytecodeFoldFailedIteration
  import C = BytecodeFoldFirstFailureLoop
  import RP = BytecodeFoldRangePrefix
  import BP = BytecodeFoldBytesPrefix
  import WP = BytecodeFoldWordsPrefix
  import CL = BytecodeFoldCallbackLengthScalar
  predicate Matches(code: seq<Byte>) { T.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+C.Destinations() }
  lemma Selector(data: seq<Byte>,domain: nat)
    requires RT.Admitted(data,domain)
    ensures ShiftRight(DataWord(data,0),224) == CL.Selector(domain)
  {
    hide DataWord();hide ShiftRight();
    if domain == 0 { reveal RP.SelectorAdmitted(); }
    else if domain == 1 { reveal BP.SelectorAdmitted(); }
    else { reveal WP.SelectorAdmitted(); }
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,domain: nat,self: Word,codeSize: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>,prefix: seq<L.Receipt>,failure: F.Receipt) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && RT.Admitted(data,domain) && X.Context(self) && codeSize > 0
    requires cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    requires M.Resources(data,T.LoopMemory(data,domain),P.Config(data,domain),0,prefix,failure)
    requires M.Truthful(data,T.LoopMemory(data,domain),P.Config(data,domain),0,prefix,failure,self,cursor+1,observations)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures frame == X.Frame(Reverted(M.Error(data,T.LoopMemory(data,domain),P.Config(data,domain),0,prefix,failure)),failure.returned,cursor+1+3*|prefix|+(if failure.success then 3 else 4))
  {
    hide DataWord();hide ShiftRight();hide E.Trace();hide M.Error();hide T.LoopMemory();hide P.Config();
    P.Ready(data,domain);B.CallerBounds(data,domain);B.Initial(data,domain,oldReturn,cursor+1);Selector(data,domain);
    assert P.Config(data,domain).domain == domain by { reveal P.Config(); }
    frame,trace := T.Run(code,data,domain,self,codeSize,oldReturn,cursor,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    var part: seq<X.Frame>;
    frame,part := C.Run(code,data,T.LoopMemory(data,domain),W.BodyPrefix(data,domain)+[128],P.Config(data,domain),0,prefix,failure,self,0,oldReturn,cursor+1,observations);
    E.WidenTrace(code,C.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
  }
}
