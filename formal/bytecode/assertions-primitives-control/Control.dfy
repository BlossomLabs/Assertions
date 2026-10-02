// SPDX-License-Identifier: MIT
// Exact segments await composition with fully proved resolver/decoder traces.
include "CondStart.generated.dfy"
include "CondFirstWord.generated.dfy"
include "CondFalse.generated.dfy"
include "CondTrue.generated.dfy"
include "CondFalseReturn.generated.dfy"
include "ResolveStart.generated.dfy"
include "PickStart.generated.dfy"
include "PickWord.generated.dfy"
include "PickExit.generated.dfy"
include "RawReturn.generated.dfy"
include "ExternalLift.dfy"
module AssertionsPrimitiveControlConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import R = AssertionsControlRawReturn
  ghost method RawReturn(code: seq<Byte>, scratch: Word, ptr: Word, length: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires R.Matches(code) && R.Admitted(code,0,scratch,0,0,ptr,length,0,free,prefix,mem)
    ensures state == Returned(mem[ptr+32..ptr+32+length])
    ensures E.Trace(code,R.Destinations(0),value,data,trace)
    ensures trace[0] == Running(1017,prefix+[scratch,ptr],mem) && trace[|trace|-1] == state
  {
    state,trace := R.Run(code,0,scratch,0,0,ptr,length,0,free,prefix,mem,value,data);
    assert ptr+32+length <= |mem| < G.Modulus();
    assert G.Grow(mem,ptr+32+length) == mem;
  }
}
