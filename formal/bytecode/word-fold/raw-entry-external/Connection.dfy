// SPDX-License-Identifier: MIT
// Raw decoding makes no external observation and preserves old returndata/cursor.
include "../raw-entry/Range.generated.dfy"
include "../raw-entry/Source.generated.dfy"
include "../../external-calls/Execution.dfy"
module BytecodeFoldRawEntryExternal {
  import opened BytecodeScanMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import R = BytecodeFoldRawEntryRange
  import B = BytecodeFoldRawEntrySource
  import RP = BytecodeFoldRangePrefix
  import BP = BytecodeFoldBytesPrefix
  import WP = BytecodeFoldWordsPrefix
  function Destinations(): set<nat> { R.Destinations()+B.Destinations() }
  ghost method Lift(code: seq<Byte>,small: set<nat>,data: seq<Byte>,states: seq<State>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires small <= Destinations() && S.Trace(code,small,0,data,states)
    ensures E.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    {
      assert Step(code,small,states[i],0,data) != Bad;
      reveal Step();
    }
    C.Lift(code,small,0,data,states);
    E.Lift(code,small,self,0,data,observations,states,oldReturn,cursor);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
    E.WidenTrace(code,small,Destinations(),self,0,data,observations,frames);
  }
  ghost method RunRange(code: seq<Byte>,data: seq<Byte>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires R.Matches(code) && RP.Admitted(0,data) && X.Context(self)
    ensures frame == X.Frame(if I.Fits(data,true) then Running(1069,[4057501128,604]+R.Decoded(data),Store([],64,128)) else Reverted([]),oldReturn,cursor)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace) && |trace| > 0
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    var state: State; var states: seq<State>;
    state,states := R.RunRange(code,data);
    trace := Lift(code,R.Destinations(),data,states,self,oldReturn,cursor,observations);
    frame := trace[|trace|-1];
  }
  ghost method RunBytes(code: seq<Byte>,data: seq<Byte>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires B.Matches(code) && BP.Admitted(0,data) && X.Context(self)
    ensures frame == X.Frame(if I.Fits(data,false) then Running(727,[1831135132,604]+B.Decoded(data),Store([],64,128)) else Reverted([]),oldReturn,cursor)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace) && |trace| > 0
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    var state: State; var states: seq<State>;
    state,states := B.RunBytes(code,data);
    trace := Lift(code,B.Destinations(),data,states,self,oldReturn,cursor,observations);
    frame := trace[|trace|-1];
  }
  ghost method RunWords(code: seq<Byte>,data: seq<Byte>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires B.Matches(code) && WP.Admitted(0,data) && X.Context(self)
    ensures frame == X.Frame(if I.Fits(data,false) then Running(746,[1843793072,604]+B.Decoded(data),Store([],64,128)) else Reverted([]),oldReturn,cursor)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace) && |trace| > 0
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    var state: State; var states: seq<State>;
    state,states := B.RunWords(code,data);
    trace := Lift(code,B.Destinations(),data,states,self,oldReturn,cursor,observations);
    frame := trace[|trace|-1];
  }
}
