// SPDX-License-Identifier: MIT
// Unverified reached-opcode candidate over actual raw calldata and byte memory.
// Finite fitting reached windows, reviewed interpreter/extraction and sufficient
// actual execution resources remain explicit; no public theorem is supplied.
include "Inputs.dfy"
include "Memory.dfy"
module OperationsByteAtMachine {
  import I = OperationsByteAtInputs
  import N = OperationsByteAtIndices
  import B = OperationsByteAtMemory
  type Byte = I.Byte
  type Word = I.Word
  const M: nat := N.M
  const U64: nat := N.U64
  datatype State = Running(pc: nat,stack: seq<Word>,memory: seq<Byte>) |
                   Returned(data: seq<Byte>) | Reverted(data: seq<Byte>) | Bad
  datatype Instruction = Op(op: Byte,next: nat,immediate: Word)
  lemma PowerMonotone(a: nat,b: nat)
    requires a <= b
    ensures I.Power(a) <= I.Power(b)
    decreases b
  {
    if a < b { PowerMonotone(a,b-1); }
  }
  function Fetch(code: seq<Byte>,pc: nat): Instruction
    requires pc < |code|
  {
    var op := code[pc];
    if op == 0x5f then Op(op,pc+1,0)
    else if 0x60 <= op <= 0x7f then
      var width := op-0x5f;
      PowerMonotone(width,32); I.WordPower();
      Op(op,pc+1+width,I.Load(code,pc+1,width))
    else Op(op,pc+1,0)
  }
  function Bool(value: bool): Word { if value then 1 else 0 }
  opaque function BitAnd(a: Word,b: Word): Word { ((a as bv256)&(b as bv256)) as nat }
  opaque function BitOr(a: Word,b: Word): Word { ((a as bv256)|(b as bv256)) as nat }
  opaque function Left(a: Word,amount: Word): Word {
    if amount >= 256 then 0 else (((a as bv256) << amount) as nat)
  }
  function Power2(n: nat): nat
    ensures Power2(n) > 0
    decreases n
  { if n == 0 then 1 else 2*Power2(n-1) }
  function Right(a: Word,amount: Word): Word { if amount >= 256 then 0 else a/Power2(amount) }
  function Window(offset: Word,count: nat): bool { offset+count < U64 }
  function ReturnCell(memory: seq<Byte>,offset: Word,index: nat): Byte { B.Cell(memory,offset+index) }
  function ReturnedBytes(memory: seq<Byte>,offset: Word,count: Word): seq<Byte> {
    seq(count,(i: nat) requires i < count => ReturnCell(memory,offset,i))
  }
  opaque function Step(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires |data| < U64
  {
    if !state.Running? then state
    else if state.pc >= |code| then Bad
    else var ins := Fetch(code,state.pc); var s := state.stack; var n := |s|; var mem := state.memory;
                                                                              if ins.op == 0x5f || 0x60 <= ins.op <= 0x7f then
                                                                                if n < 1024 then Running(ins.next,s+[ins.immediate],mem) else Bad
                                                                              else if ins.op == 0x5b then Running(ins.next,s,mem)
                                                                              else if ins.op == 0x34 && n < 1024 then Running(ins.next,s+[value],mem)
                                                                              else if ins.op == 0x36 && n < 1024 then Running(ins.next,s+[|data|],mem)
                                                                              else if ins.op == 0x35 && n >= 1 then Running(ins.next,s[..n-1]+[I.DataWord(data,s[n-1])],mem)
                                                                              else if 0x80 <= ins.op <= 0x8f && n >= ins.op-0x7f && n < 1024 then
                                                                                Running(ins.next,s+[s[n-(ins.op-0x7f)]],mem)
                                                                              else if 0x90 <= ins.op <= 0x9f && n >= ins.op-0x8f+1 then
                                                                                var at := n-1-(ins.op-0x8f);
                                                                                Running(ins.next,s[at := s[n-1]][n-1 := s[at]],mem)
                                                                              else if ins.op == 0x50 && n >= 1 then Running(ins.next,s[..n-1],mem)
                                                                              else if ins.op == 0x15 && n >= 1 then Running(ins.next,s[..n-1]+[Bool(s[n-1]==0)],mem)
                                                                              else if ins.op == 0x19 && n >= 1 then Running(ins.next,s[..n-1]+[M-1-s[n-1]],mem)
                                                                              else if ins.op == 0x01 && n >= 2 then Running(ins.next,s[..n-2]+[(s[n-1]+s[n-2])%M],mem)
                                                                              else if ins.op == 0x02 && n >= 2 then Running(ins.next,s[..n-2]+[(s[n-1]*s[n-2])%M],mem)
                                                                              else if ins.op == 0x03 && n >= 2 then Running(ins.next,s[..n-2]+[(s[n-1]+M-s[n-2])%M],mem)
                                                                              else if ins.op == 0x04 && n >= 2 then Running(ins.next,s[..n-2]+[if s[n-2]==0 then 0 else s[n-1]/s[n-2]],mem)
                                                                              else if ins.op == 0x10 && n >= 2 then Running(ins.next,s[..n-2]+[Bool(s[n-1]<s[n-2])],mem)
                                                                              else if ins.op == 0x11 && n >= 2 then Running(ins.next,s[..n-2]+[Bool(s[n-1]>s[n-2])],mem)
                                                                              else if ins.op == 0x12 && n >= 2 then Running(ins.next,s[..n-2]+[Bool(N.Signed(s[n-1])<N.Signed(s[n-2]))],mem)
                                                                              else if ins.op == 0x14 && n >= 2 then Running(ins.next,s[..n-2]+[Bool(s[n-1]==s[n-2])],mem)
                                                                              else if ins.op == 0x16 && n >= 2 then Running(ins.next,s[..n-2]+[BitAnd(s[n-1],s[n-2])],mem)
                                                                              else if ins.op == 0x17 && n >= 2 then Running(ins.next,s[..n-2]+[BitOr(s[n-1],s[n-2])],mem)
                                                                              else if ins.op == 0x1b && n >= 2 then Running(ins.next,s[..n-2]+[Left(s[n-2],s[n-1])],mem)
                                                                              else if ins.op == 0x1c && n >= 2 then Running(ins.next,s[..n-2]+[Right(s[n-2],s[n-1])],mem)
                                                                              else if ins.op == 0x52 && n >= 2 && Window(s[n-1],32) then
                                                                                Running(ins.next,s[..n-2],B.Copy(mem,I.Encode(s[n-2],32),0,s[n-1],32))
                                                                              else if ins.op == 0x51 && n >= 1 && Window(s[n-1],32) then
                                                                                Running(ins.next,s[..n-1]+[I.DataWord(mem,s[n-1])],B.Grow(mem,s[n-1]+32))
                                                                              else if ins.op == 0x37 && n >= 3 && (s[n-3]==0 || Window(s[n-1],s[n-3])) then
                                                                                Running(ins.next,s[..n-3],B.Copy(mem,data,s[n-2],s[n-1],s[n-3]))
                                                                              else if ins.op == 0x5e && n >= 3 && (s[n-3]==0 || (Window(s[n-1],s[n-3]) && Window(s[n-2],s[n-3]))) then
                                                                                Running(ins.next,s[..n-3],B.Move(mem,s[n-2],s[n-1],s[n-3]))
                                                                              else if ins.op == 0x56 && n >= 1 then
                                                                                if s[n-1] in destinations && s[n-1]<|code| && code[s[n-1]]==0x5b
                                                                                then Running(s[n-1],s[..n-1],mem) else Bad
                                                                              else if ins.op == 0x57 && n >= 2 then
                                                                                if s[n-2]==0 then Running(ins.next,s[..n-2],mem)
                                                                                else if s[n-1] in destinations && s[n-1]<|code| && code[s[n-1]]==0x5b
                                                                                then Running(s[n-1],s[..n-2],mem) else Bad
                                                                              else if ins.op == 0xf3 && n >= 2 && (s[n-2]==0 || Window(s[n-1],s[n-2])) then
                                                                                Returned(ReturnedBytes(mem,s[n-1],s[n-2]))
                                                                              else if ins.op == 0xfd && n >= 2 && (s[n-2]==0 || Window(s[n-1],s[n-2])) then
                                                                                Reverted(ReturnedBytes(mem,s[n-1],s[n-2]))
                                                                              else Bad
  }
}
