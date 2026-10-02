// SPDX-License-Identifier: MIT
// Exact decoded wrapper to alignment and finite valid-window admission trace.
include "../invocation/Map.generated.dfy"
include "../invocation/Filter.generated.dfy"
include "../alignment/Aligned.generated.dfy"
include "../windows/Engine.dfy"
module BytecodeApplyDecodedAdmission {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import P = BytecodeApplyInvokeMap
  import F = BytecodeApplyInvokeFilter
  import A = BytecodeApplyAlignmentAligned
  import W = BytecodeApplyWindowInputs
  import C = BytecodeApplyWindowEngine
  predicate Matches(code: seq<Byte>) { P.Matches(code) && F.Matches(code) && A.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+F.Destinations()+A.Destinations()+C.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,filter: bool,value: Word)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && sourceLength%32 == 0 && W.Valid(templateLength,arrayOffset,count,data)
    requires |prefix| <= 994
    ensures var fields: seq<Word> := [sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count];
            state == Running(12235,prefix+fields+[96,5526]+fields+[if filter then 1 else 0,96],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(if filter then 784 else 1050,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
    ensures trace[|trace|-1] == state && |trace| == 69+53*(count as nat)
  {
    var fields: seq<Word> := [sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count];
    var mode: Word := if filter then 1 else 0;
    if filter {
      state,trace := F.Run(code,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
      E.WidenTrace(code,F.Destinations(),Destinations(),value,data,trace);
    } else {
      state,trace := P.Run(code,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
      E.WidenTrace(code,P.Destinations(),Destinations(),value,data,trace);
    }
    var next: State;
    var part: seq<State>;
    next,part := A.Run(code,data,mem,prefix+fields+[96],5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    E.WidenTrace(code,A.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..]; state := next;
    next,part := C.Run(code,data,mem,prefix+fields+[96,5526]+fields+[mode,96],templateOffset,templateLength,arrayOffset,count,value);
    E.WidenTrace(code,C.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..]; state := next;
  }
}
