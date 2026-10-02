// SPDX-License-Identifier: MIT
// Authored complete three-instruction callback flag dispatch.
include "../../external-calls/Execution.dfy"
include "../../scans/Fetch.dfy"
module BytecodeApplyCallbackFlagDispatch {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  opaque predicate Matches(code: seq<Byte>) {
    |code| == 24560 && code[17003] == 0x81 && code[17004] == 0x61 &&
    code[17005] == 0x42 && code[17006] == 0xa9 && code[17007] == 0x57 && code[17065] == 0x5b
  }
  function Destinations(): set<nat> { {17065} }
  function Tail(target: Word,ptr: Word,index: Word,gasBefore: Word,success: bool,receipt: Word): seq<Word>
  { [12484,target,ptr,index,0,gasBefore,if success then 1 else 0,receipt] }
  lemma Advance(code: seq<Byte>,frame: X.Frame,self: Word,value: Word,data: seq<Byte>,observations: seq<X.Observation>,prefix: seq<Word>,mem: seq<Byte>,returned: seq<Byte>,cursor: nat,target: Word,ptr: Word,index: Word,gasBefore: Word,success: bool,receipt: Word,id: nat)
    requires Matches(code) && X.Context(self) && |prefix| <= 1014 && id < 3
    requires var tail := Tail(target,ptr,index,gasBefore,success,receipt);
             frame == X.Frame(Running(if id == 0 then 17003 else if id == 1 then 17004 else 17007,
                                      prefix+tail+(if id == 0 then [] else if id == 1 then [if success then 1 else 0] else [if success then 1 else 0,17065]),mem),returned,cursor)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var tail := Tail(target,ptr,index,gasBefore,success,receipt);
            X.Step(code,Destinations(),frame,self,value,data,observations) == X.Frame(Running(if id == 0 then 17004 else if id == 1 then 17007 else if success then 17065 else 17008,
                                                                                              prefix+tail+(if id == 0 then [if success then 1 else 0] else if id == 1 then [if success then 1 else 0,17065] else []),mem),returned,cursor)
  {
    reveal Matches();
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    if id == 1 { F.Push2(code,17004); }
    reveal Step();
  }
  ghost method Run(code: seq<Byte>,self: Word,value: Word,data: seq<Byte>,observations: seq<X.Observation>,prefix: seq<Word>,mem: seq<Byte>,returned: seq<Byte>,cursor: nat,target: Word,ptr: Word,index: Word,gasBefore: Word,success: bool,receipt: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && X.Context(self) && |prefix| <= 1014
    ensures frame == X.Frame(Running(if success then 17065 else 17008,prefix+Tail(target,ptr,index,gasBefore,success,receipt),mem),returned,cursor)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 4 && trace[0] == X.Frame(Running(17003,prefix+Tail(target,ptr,index,gasBefore,success,receipt),mem),returned,cursor) && trace[3] == frame
  {
    hide E.Trace();
    frame := X.Frame(Running(17003,prefix+Tail(target,ptr,index,gasBefore,success,receipt),mem),returned,cursor);
    trace := [frame];
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by { reveal E.Trace(); }
    assert prefix+Tail(target,ptr,index,gasBefore,success,receipt)+[] == prefix+Tail(target,ptr,index,gasBefore,success,receipt);
    var id: nat := 0;
    while id < 3
      invariant id <= 3 && |trace| == id+1 && trace[|trace|-1] == frame
      invariant trace[0] == X.Frame(Running(17003,prefix+Tail(target,ptr,index,gasBefore,success,receipt),mem),returned,cursor)
      invariant E.Trace(code,Destinations(),self,value,data,observations,trace)
      invariant frame == X.Frame(Running(if id == 0 then 17003 else if id == 1 then 17004 else if id == 2 then 17007 else if success then 17065 else 17008,
                                         prefix+Tail(target,ptr,index,gasBefore,success,receipt)+(if id == 0 || id == 3 then [] else if id == 1 then [if success then 1 else 0] else [if success then 1 else 0,17065]),mem),returned,cursor)
      decreases 3-id
    {
      Advance(code,frame,self,value,data,observations,prefix,mem,returned,cursor,target,ptr,index,gasBefore,success,receipt,id);
      var next := X.Step(code,Destinations(),frame,self,value,data,observations);
      E.Extend(code,Destinations(),self,value,data,observations,trace,next);
      trace := trace+[next];frame := next;id := id+1;
    }
  }
}
