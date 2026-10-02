// SPDX-License-Identifier: MIT
include "Raw.generated.dfy"
module AssertionsRawResolveConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolve
  import P = AssertionsRawResolveMemory
  import X = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  type Word = S.Word
  type Byte = S.Byte
  ghost method Run(code: seq<Byte>, destinations: set<nat>, ret: Word,
                   paramPointer: Word, assertion: Word, entry: Word, param: Word,
                   bytesRelative: Word, constraintsRelative: Word, length: Word, free: Word,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>,
                   returned: seq<Byte>, cursor: nat, self: Word, value: Word,
                   observations: seq<M.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires R.Matches(code,ret)
    requires R.Admitted(ret,paramPointer,assertion,entry,param,bytesRelative,constraintsRelative,length,free,prefix,mem,data)
    requires R.Destinations(ret) <= destinations
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(3393,prefix+[ret,paramPointer,assertion,entry,param],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame == E.Frame(S.Running(ret,prefix+[free],P.Construct(mem,free,R.PayloadOffset(paramPointer,bytesRelative),length,data)),returned,cursor)
    ensures S.Load(frame.state.memory,free) == length
    ensures frame.state.memory[free+32..free+32+length] == data[R.PayloadOffset(paramPointer,bytesRelative)..R.PayloadOffset(paramPointer,bytesRelative)+length]
  {
    var state, states := R.Run(code,ret,paramPointer,assertion,entry,param,bytesRelative,constraintsRelative,length,free,prefix,mem,data,value);
    X.WidenTrace(code,R.Destinations(ret),destinations,value,data,states);
    Q.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,states);
    frame := E.Frame(state,returned,cursor); frames := Q.Lift(states,returned,cursor);
  }
}
