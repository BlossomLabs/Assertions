// SPDX-License-Identifier: MIT
// Authored exact five-instruction guard invocation, retaining complete caller stack.
include "../../external-calls/Execution.dfy"
include "../../scans/Fetch.dfy"
module BytecodeApplyCallbackExhaustionInvoke {
  import opened BytecodeScanMachine
  import X = BytecodeExternalMachine
  import C = BytecodeCopyMachine
  import E = BytecodeExternalExecution
  import F = BytecodeScanFetch
  opaque predicate Matches(code: seq<Byte>) {
    |code| == 24560 && code[17008] == 0x61 && code[17009] == 0x42 && code[17010] == 0x79 &&
    code[17011] == 0x83 && code[17012] == 0x82 && code[17013] == 0x61 && code[17014] == 0x3e &&
    code[17015] == 0xeb && code[17016] == 0x56 && code[16107] == 0x5b
  }
  function Destinations(): set<nat> { {16107} }
  function Tail(target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word): seq<Word>
  { [12484,target,ptr,index,0,gasBefore,0,receipt] }
  function At(id: nat,prefix: seq<Word>,mem: seq<Byte>,returned: seq<Byte>,cursor: nat,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word): X.Frame
    requires id <= 5
  {
    X.Frame(Running(if id == 0 then 17008 else if id == 1 then 17011 else if id == 2 then 17012 else if id == 3 then 17013 else if id == 4 then 17016 else 16107,
                    prefix+Tail(target,ptr,index,gasBefore,receipt)+(if id == 0 then [] else if id == 1 then [17017] else if id == 2 then [17017,gasBefore] else if id == 4 then [17017,gasBefore,receipt,16107] else [17017,gasBefore,receipt]),mem),returned,cursor)
  }
  lemma Initial(prefix: seq<Word>,mem: seq<Byte>,returned: seq<Byte>,cursor: nat,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word)
    ensures At(0,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt) == X.Frame(Running(17008,prefix+Tail(target,ptr,index,gasBefore,receipt),mem),returned,cursor)
  {
    hide Tail(); reveal At();
    var frame := At(0,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt);
    var tail := Tail(target,ptr,index,gasBefore,receipt);
    assert (prefix+tail)+[] == prefix+tail;
    assert frame.state == Running(17008,prefix+tail,mem);
    assert frame.returned == returned && frame.cursor == cursor;
    assert frame == X.Frame(Running(17008,prefix+tail,mem),returned,cursor);
  }
  lemma Advance(code: seq<Byte>,frame: X.Frame,id: nat,prefix: seq<Word>,mem: seq<Byte>,returned: seq<Byte>,cursor: nat,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,self: Word,value: Word,data: seq<Byte>,observations: seq<X.Observation>)
    requires Matches(code) && id < 5 && |prefix| <= 1012
    requires frame == At(id,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations) == At(id+1,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
  {
    reveal Matches();
    if id == 0 { F.Push2(code,17008); } else if id == 3 { F.Push2(code,17013); }
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  ghost method Run(code: seq<Byte>,prefix: seq<Word>,mem: seq<Byte>,returned: seq<Byte>,cursor: nat,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,self: Word,value: Word,data: seq<Byte>,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && |prefix| <= 1012
    ensures frame == At(5,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 6 && trace[0] == At(0,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt) && trace[5] == frame
  {
    hide E.Trace();
    frame := At(0,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt);trace := [frame];
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by { reveal E.Trace(); }
    var id: nat := 0;
    while id < 5
      invariant id <= 5 && |trace| == id+1 && trace[|trace|-1] == frame
      invariant trace[0] == At(0,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt)
      invariant E.Trace(code,Destinations(),self,value,data,observations,trace)
      invariant frame == At(id,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt)
      decreases 5-id
    {
      Advance(code,frame,id,prefix,mem,returned,cursor,target,ptr,index,gasBefore,receipt,self,value,data,observations);
      var next := X.Step(code,Destinations(),frame,self,value,data,observations);
      E.Extend(code,Destinations(),self,value,data,observations,trace,next);
      trace := trace+[next];frame := next;id := id+1;
    }
  }
}
