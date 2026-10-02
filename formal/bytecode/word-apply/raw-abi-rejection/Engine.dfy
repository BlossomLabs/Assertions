// SPDX-License-Identifier: MIT
include "../raw-source-rejections/HeadShort.generated.dfy"
include "../raw-source-rejections/SourceOffsetLarge.generated.dfy"
include "../raw-source-rejections/SourceHeaderShort.generated.dfy"
include "../raw-source-rejections/SourceLengthLarge.generated.dfy"
include "../raw-source-rejections/SourceTailShort.generated.dfy"
include "../raw-decoder/BadAddress.generated.dfy"
include "../raw-decoder/TemplateOffsetLarge.generated.dfy"
include "../raw-decoder/TemplateHeaderShort.generated.dfy"
include "../raw-decoder/TemplateLengthLarge.generated.dfy"
include "../raw-decoder/TemplateTailShort.generated.dfy"
include "../raw-decoder/ArrayOffsetLarge.generated.dfy"
include "../raw-decoder/ArrayHeaderShort.generated.dfy"
include "../raw-decoder/ArrayCountLarge.generated.dfy"
include "../raw-decoder/ArrayTailShort.generated.dfy"
include "../map-prefix/Prefix.generated.dfy"
include "../filter-prefix/Prefix.generated.dfy"
include "../decoder-invocation/Map.generated.dfy"
include "../decoder-invocation/Filter.generated.dfy"
include "../raw-element-read/Connection.dfy"
module BytecodeApplyRawAbiRejection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import X = BytecodeExternalMachine
  import XE = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import MI = BytecodeApplyDecodeInvokeMap
  import FI = BytecodeApplyDecodeInvokeFilter
  import L = BytecodeApplyRawFirstElement
  import P0 = BytecodeApplyRawHeadShort
  import P1 = BytecodeApplyRawSourceOffsetLarge
  import P2 = BytecodeApplyRawSourceHeaderShort
  import P3 = BytecodeApplyRawSourceLengthLarge
  import P4 = BytecodeApplyRawSourceTailShort
  import P5 = BytecodeApplyDecoderBadAddress
  import P6 = BytecodeApplyDecoderTemplateOffsetLarge
  import P7 = BytecodeApplyDecoderTemplateHeaderShort
  import P8 = BytecodeApplyDecoderTemplateLengthLarge
  import P9 = BytecodeApplyDecoderTemplateTailShort
  import P10 = BytecodeApplyDecoderArrayOffsetLarge
  import P11 = BytecodeApplyDecoderArrayHeaderShort
  import P12 = BytecodeApplyDecoderArrayCountLarge
  import P13 = BytecodeApplyDecoderArrayTailShort
  predicate LeafMatches(code: seq<Byte>) { P0.Matches(code) && P1.Matches(code) && P2.Matches(code) && P3.Matches(code) && P4.Matches(code) && P5.Matches(code) && P6.Matches(code) && P7.Matches(code) && P8.Matches(code) && P9.Matches(code) && P10.Matches(code) && P11.Matches(code) && P12.Matches(code) && P13.Matches(code) }
  function LeafDestinations(): set<nat> { P0.Destinations()+P1.Destinations()+P2.Destinations()+P3.Destinations()+P4.Destinations()+P5.Destinations()+P6.Destinations()+P7.Destinations()+P8.Destinations()+P9.Destinations()+P10.Destinations()+P11.Destinations()+P12.Destinations()+P13.Destinations() }
  predicate Rejected(data: seq<Byte>) { P0.Admitted(data) || P1.Admitted(data) || P2.Admitted(data) || P3.Admitted(data) || P4.Admitted(data) || P5.Admitted(data) || P6.Admitted(data) || P7.Admitted(data) || P8.Admitted(data) || P9.Admitted(data) || P10.Admitted(data) || P11.Admitted(data) || P12.Admitted(data) || P13.Admitted(data) }
  predicate Matches(code: seq<Byte>) { LeafMatches(code) && MP.Matches(code) && FP.Matches(code) && MI.Matches(code) && FI.Matches(code) }
  function Destinations(): set<nat> { LeafDestinations()+MP.Destinations()+FP.Destinations()+MI.Destinations()+FI.Destinations() }
  lemma Partition(data: seq<Byte>)
    requires 4 <= |data| < I.U64()
    ensures I.Fits(data) || Rejected(data)
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();
    if |data| < 132 { assert P0.Admitted(data); }
    else if I.SourceHead(data) >= I.U64() { assert P1.Admitted(data); }
    else if I.SourceHead(data)+36 > |data| { assert P2.Admitted(data); }
    else if I.SourceLength(data) >= I.U64() { assert P3.Admitted(data); }
    else if I.SourceHead(data)+36+I.SourceLength(data) > |data| { assert P4.Admitted(data); }
    else if I.Target(data) >= I.AddressBound() { assert P5.Admitted(data); }
    else if I.TemplateHead(data) >= I.U64() { assert P6.Admitted(data); }
    else if I.TemplateHead(data)+36 > |data| { assert P7.Admitted(data); }
    else if I.TemplateLength(data) >= I.U64() { assert P8.Admitted(data); }
    else if I.TemplateHead(data)+36+I.TemplateLength(data) > |data| { assert P9.Admitted(data); }
    else if I.ArrayHead(data) >= I.U64() { assert P10.Admitted(data); }
    else if I.ArrayHead(data)+36 > |data| { assert P11.Admitted(data); }
    else if I.Count(data) >= I.U64() { assert P12.Admitted(data); }
    else if I.ArrayHead(data)+36+32*I.Count(data) > |data| { assert P13.Admitted(data); }
    else { assert I.Fits(data); }
  }
  ghost method Leaf(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,value: Word) returns (state: State,trace: seq<State>)
    requires LeafMatches(code) && Rejected(data) && I.ValidReturn(returnPc) && |prefix| <= 1004
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| > 0 && trace[0] == Running(22579,prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide E.Trace();
    if P0.Admitted(data) {
      state,trace := P0.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P0.Destinations(),Destinations(),value,data,trace);
    } else if P1.Admitted(data) {
      state,trace := P1.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P1.Destinations(),Destinations(),value,data,trace);
    } else if P2.Admitted(data) {
      state,trace := P2.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P2.Destinations(),Destinations(),value,data,trace);
    } else if P3.Admitted(data) {
      state,trace := P3.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P3.Destinations(),Destinations(),value,data,trace);
    } else if P4.Admitted(data) {
      state,trace := P4.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P4.Destinations(),Destinations(),value,data,trace);
    } else if P5.Admitted(data) {
      state,trace := P5.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P5.Destinations(),Destinations(),value,data,trace);
    } else if P6.Admitted(data) {
      state,trace := P6.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P6.Destinations(),Destinations(),value,data,trace);
    } else if P7.Admitted(data) {
      state,trace := P7.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P7.Destinations(),Destinations(),value,data,trace);
    } else if P8.Admitted(data) {
      state,trace := P8.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P8.Destinations(),Destinations(),value,data,trace);
    } else if P9.Admitted(data) {
      state,trace := P9.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P9.Destinations(),Destinations(),value,data,trace);
    } else if P10.Admitted(data) {
      state,trace := P10.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P10.Destinations(),Destinations(),value,data,trace);
    } else if P11.Admitted(data) {
      state,trace := P11.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P11.Destinations(),Destinations(),value,data,trace);
    } else if P12.Admitted(data) {
      state,trace := P12.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P12.Destinations(),Destinations(),value,data,trace);
    } else {
      assert P13.Admitted(data);
      state,trace := P13.Run(code,data,mem,prefix,returnPc,value);
      E.WidenTrace(code,P13.Destinations(),Destinations(),value,data,trace);
    }
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool) returns (state: State,trace: seq<State>)
    requires Matches(code) && Rejected(data)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),0,data,trace)
    ensures |trace| > 0 && trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide E.Trace();
    var part: seq<State>;var selector: Word := if filter then 2005396296 else 3983393726;var returnPc: Word := if filter then 784 else 1050;
    if filter { state,trace := FP.Run(code,0,data);E.WidenTrace(code,FP.Destinations(),Destinations(),0,data,trace); }
    else { state,trace := MP.Run(code,0,data);E.WidenTrace(code,MP.Destinations(),Destinations(),0,data,trace); }
    if filter { state,part := FI.Run(code,data,Store([],64,128),[selector],0);E.WidenTrace(code,FI.Destinations(),Destinations(),0,data,part); }
    else { state,part := MI.Run(code,data,Store([],64,128),[selector],0);E.WidenTrace(code,MI.Destinations(),Destinations(),0,data,part); }
    assert trace[|trace|-1] == part[0];E.Join(code,Destinations(),0,data,trace,part);trace := trace+part[1..];
    state,part := Leaf(code,data,Store([],64,128),[selector,518],returnPc,0);
    assert trace[|trace|-1] == part[0];E.Join(code,Destinations(),0,data,trace,part);trace := trace+part[1..];
  }
  ghost method ExternalRun(code: seq<Byte>,data: seq<Byte>,filter: bool,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Rejected(data) && X.Context(self)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    ensures frame == X.Frame(Reverted([]),oldReturn,cursor) && XE.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    var state: State;var states: seq<State>;
    state,states := Run(code,data,filter);
    L.Lift(code,Destinations(),data,states,self,oldReturn,cursor,observations);
    trace := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));frame := trace[|trace|-1];
  }
}
