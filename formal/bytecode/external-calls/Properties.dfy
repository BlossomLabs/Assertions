// SPDX-License-Identifier: MIT
// Receipt cursor and caller-local returndata invariants across the extended step.
include "Machine.dfy"
module BytecodeExternalProperties {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  type Byte = M.Byte
  type Word = M.Word
  type Frame = M.Frame
  type Observation = M.Observation
  lemma Cursor(code: seq<Byte>, destinations: set<nat>, frame: Frame, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>)
    requires frame.cursor <= |observations|
    ensures frame.cursor <= M.Step(code,destinations,frame,self,value,data,observations).cursor <= frame.cursor+1
    ensures M.Step(code,destinations,frame,self,value,data,observations).cursor <= |observations|
  { reveal M.Step(); }
  lemma ReturnedBound(code: seq<Byte>, destinations: set<nat>, frame: Frame, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>)
    requires |frame.returned| < G.Modulus()
    ensures |M.Step(code,destinations,frame,self,value,data,observations).returned| < G.Modulus()
  { reveal M.Step(); }
  lemma ReturnUnchanged(code: seq<Byte>, destinations: set<nat>, frame: Frame, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>)
    requires !frame.state.Running? || frame.state.pc >= |code| || S.Fetch(code,frame.state.pc).op != 0xfa
    ensures M.Step(code,destinations,frame,self,value,data,observations).returned == frame.returned
  { reveal M.Step(); }
  lemma CopyBoundsOverflow(source: Word, size: Word, returned: seq<Byte>)
    requires |returned| < G.Modulus()
    ensures ((source as nat)+size <= |returned|) == ((source as nat)+size < G.Modulus() && (source as nat)+size <= |returned|)
    ensures (source as nat)+size >= G.Modulus() ==> (source as nat)+size > |returned|
  {}
  lemma ZeroCopyBoundary(source: Word, returned: seq<Byte>)
    ensures (source as nat)+0 <= |returned| <==> source <= |returned|
  {}
}
