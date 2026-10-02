// SPDX-License-Identifier: MIT
// Independent lazy-control call-frame specifications before operand resolution.
include "Control.dfy"
module AssertionsPrimitivePreparation {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import Q = AssertionsPrimitiveScalar
  import M = BytecodeScanRepresentation
  import C = AssertionsControlCondStart
  import T = AssertionsControlCondTrue
  import F = AssertionsControlCondFalse
  function EmptyAssertion(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+32 < G.Modulus()
  { Store(Store(mem,64,free+32),free,0) }
  lemma AssertionObject(mem: seq<Byte>, free: Word)
    requires |mem|%32 == 0 && |mem| >= 96 && 128 <= free && free+64 < G.Modulus()
    ensures Load(EmptyAssertion(mem,free),64) == free+32
    ensures Load(EmptyAssertion(mem,free),free) == 0
    ensures |EmptyAssertion(mem,free)|%32 == 0
  {
    M.StoredWord(mem,64,free+32);
    var first := Store(mem,64,free+32);
    M.StoredWord(first,free,0);
    M.StoredFrame(first,free,0,64);
  }
  ghost method Condition(code: seq<Byte>, ret: Word, condition: Word, then_: Word, else_: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires C.Matches(code) && C.Admitted(code,ret,condition,then_,else_,0,0,0,free,prefix,mem)
    ensures state == Running(3393,prefix+[ret,condition,then_,else_,0,1770,condition,free,0,0],EmptyAssertion(mem,free))
    ensures E.Trace(code,C.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(1743,prefix+[ret,condition,then_,else_],mem) && trace[|trace|-1] == state
    ensures state.Running? && Load(state.memory,64) == free+32 && Load(state.memory,free) == 0
  {
    state,trace := C.Run(code,ret,condition,then_,else_,0,0,0,free,prefix,mem,value,data);
    assert C.Memory1(ret,condition,then_,else_,0,0,0,free,prefix,mem) == Store(mem,64,free+32);
    assert C.Memory2(ret,condition,then_,else_,0,0,0,free,prefix,mem) == EmptyAssertion(mem,free);
    AssertionObject(mem,free);
  }
  ghost method Selected(code: seq<Byte>, ret: Word, condition: Word, then_: Word, else_: Word, ptr: Word, word: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires T.Matches(code) && F.Matches(code)
    requires |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 128 <= free && free+64 < G.Modulus() && |prefix| <= 980
    ensures state == Running(3393,prefix+[ret,condition,then_,else_,ptr,0,if word == 0 then 1815 else 1017,if word == 0 then else_ else then_,free,0,if word == 0 then 2 else 1],EmptyAssertion(mem,free))
    ensures E.Trace(code,T.Destinations(ret)+F.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(1783,prefix+[ret,condition,then_,else_,ptr,0,0,word],mem) && trace[|trace|-1] == state
    ensures state.Running? && Load(state.memory,64) == free+32 && Load(state.memory,free) == 0
  {
    AssertionObject(mem,free);
    if word == 0 {
      state,trace := F.Run(code,ret,condition,then_,else_,ptr,0,word,free,prefix,mem,value,data);
      assert F.Memory1(ret,condition,then_,else_,ptr,0,word,free,prefix,mem) == Store(mem,64,free+32);
      assert F.Memory2(ret,condition,then_,else_,ptr,0,word,free,prefix,mem) == EmptyAssertion(mem,free);
      E.WidenTrace(code,F.Destinations(ret),T.Destinations(ret)+F.Destinations(ret),value,data,trace);
    } else {
      state,trace := T.Run(code,ret,condition,then_,else_,ptr,0,word,free,prefix,mem,value,data);
      assert T.Memory1(ret,condition,then_,else_,ptr,0,word,free,prefix,mem) == Store(mem,64,free+32);
      assert T.Memory2(ret,condition,then_,else_,ptr,0,word,free,prefix,mem) == EmptyAssertion(mem,free);
      E.WidenTrace(code,T.Destinations(ret),T.Destinations(ret)+F.Destinations(ret),value,data,trace);
    }
  }
}
