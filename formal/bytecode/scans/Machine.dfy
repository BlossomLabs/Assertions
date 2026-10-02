// SPDX-License-Identifier: MIT
// Calldata-aware reached EVM subset. Byte/memory helpers are imported from
// immutable retained getter evidence; general machine proofs remain development.
include "../getters/Machine.dfy"
module BytecodeScanMachine {
  import G = BytecodeGetterMachine
  type Byte = G.Byte
  type Word = G.Word
  datatype State = Running(pc: nat, stack: seq<Word>, memory: seq<Byte>)
                 | Returned(data: seq<Byte>) | Reverted(data: seq<Byte>) | Bad
  datatype Instruction = Op(op: nat, next: nat, immediate: Word)
  function Round32(n: nat): nat { ((n+31)/32)*32 }
  function Expand(mem: seq<Byte>, length: nat): seq<Byte> {
    G.Grow(mem,Round32(length))
  }
  function Window(data: seq<Byte>, offset: nat, width: nat): seq<Byte>
    ensures |Window(data,offset,width)| == width
  { seq(width,i requires 0 <= i < width => if offset+i < |data| then data[offset+i] else 0) }
  function DataWord(data: seq<Byte>, offset: Word): Word {
    G.Decode(Window(data,offset,32)) % G.Modulus()
  }
  function Store(mem: seq<Byte>, offset: Word, value: Word): seq<Byte> {
    G.Store(Expand(mem,(offset as nat)+32),offset,value)
  }
  function Load(mem: seq<Byte>, offset: Word): Word {
    G.Load(mem,offset)
  }
  function Fetch(code: seq<Byte>, pc: nat): Instruction
    requires pc < |code|
  {
    var op := code[pc];
    if 0x60 <= op <= 0x7f then
      var width := (op as nat)-0x5f;
      Op(op,pc+1+width,G.Decode(Window(code,pc+1,width)) % G.Modulus())
    else Op(op,pc+1,0)
  }
  function BitNot(a: Word): Word { (!(a as bv256)) as nat }
  opaque function ShiftLeft(a: Word, amount: Word): Word { G.Shift(a,amount) }
  function ShiftRight(a: Word, amount: Word): Word {
    if amount >= 256 then 0 else ((a as bv256) >> (amount as nat)) as nat
  }
  opaque function Step(code: seq<Byte>, destinations: set<nat>, state: State,
                       value: Word, data: seq<Byte>): State {
    if !state.Running? then state
    else if state.pc >= |code| then Bad
    else
      var ins := Fetch(code,state.pc);
      var s := state.stack;
      var n := |s|;
      var mem := state.memory;
      if (ins.op == 0x5f || 0x60 <= ins.op <= 0x7f) && n < 1024 then Running(ins.next,s+[ins.immediate],mem)
      else if ins.op == 0x5b then Running(ins.next,s,mem)
      else if ins.op == 0x34 && n < 1024 then Running(ins.next,s+[value],mem)
      else if ins.op == 0x36 && n < 1024 && |data| < G.Modulus() then Running(ins.next,s+[|data|],mem)
      else if 0x80 <= ins.op <= 0x8f && n >= ins.op-0x7f && n < 1024 then Running(ins.next,s+[s[n-(ins.op-0x7f)]],mem)
      else if 0x90 <= ins.op <= 0x9f && n >= ins.op-0x8f+1 then
        var k := ins.op-0x8f;
        Running(ins.next,s[n-1:=s[n-1-k]][n-1-k:=s[n-1]],mem)
      else if ins.op == 0x50 && n >= 1 then Running(ins.next,s[..n-1],mem)
      else if ins.op == 0x15 && n >= 1 then Running(ins.next,s[..n-1]+[if s[n-1] == 0 then 1 else 0],mem)
      else if ins.op == 0x35 && n >= 1 then Running(ins.next,s[..n-1]+[DataWord(data,s[n-1])],mem)
      else if ins.op == 0x1c && n >= 2 then Running(ins.next,s[..n-2]+[ShiftRight(s[n-2],s[n-1])],mem)
      else if ins.op == 0x1b && n >= 2 then Running(ins.next,s[..n-2]+[ShiftLeft(s[n-2],s[n-1])],mem)
      else if ins.op == 0x16 && n >= 2 then Running(ins.next,s[..n-2]+[G.BitAnd(s[n-1],s[n-2])],mem)
      else if ins.op == 0x17 && n >= 2 then Running(ins.next,s[..n-2]+[G.BitOr(s[n-1],s[n-2])],mem)
      else if ins.op == 0x19 && n >= 1 then Running(ins.next,s[..n-1]+[BitNot(s[n-1])],mem)
      else if ins.op == 0x01 && n >= 2 then Running(ins.next,s[..n-2]+[((s[n-1] as nat)+(s[n-2] as nat))%G.Modulus()],mem)
      else if ins.op == 0x02 && n >= 2 then Running(ins.next,s[..n-2]+[((s[n-1] as nat)*(s[n-2] as nat))%G.Modulus()],mem)
      else if ins.op == 0x03 && n >= 2 then Running(ins.next,s[..n-2]+[((s[n-1] as nat)+G.Modulus()-(s[n-2] as nat))%G.Modulus()],mem)
      else if ins.op == 0x04 && n >= 2 then Running(ins.next,s[..n-2]+[if s[n-2] == 0 then 0 else (s[n-1] as nat)/(s[n-2] as nat)],mem)
      else if ins.op == 0x06 && n >= 2 then Running(ins.next,s[..n-2]+[if s[n-2] == 0 then 0 else (s[n-1] as nat)%(s[n-2] as nat)],mem)
      else if ins.op in {0x10,0x11,0x12,0x14} && n >= 2 then
        var truth := if ins.op == 0x10 then s[n-1] < s[n-2]
                     else if ins.op == 0x11 then s[n-1] > s[n-2]
                     else if ins.op == 0x12 then G.Signed(s[n-1]) < G.Signed(s[n-2])
                     else s[n-1] == s[n-2];
        Running(ins.next,s[..n-2]+[if truth then 1 else 0],mem)
      else if ins.op == 0x52 && n >= 2 then Running(ins.next,s[..n-2],Store(mem,s[n-1],s[n-2]))
      else if ins.op == 0x51 && n >= 1 then Running(ins.next,s[..n-1]+[Load(mem,s[n-1])],Expand(mem,(s[n-1] as nat)+32))
      else if ins.op == 0x56 && n >= 1 then
        if s[n-1] in destinations && s[n-1] < |code| && code[s[n-1]] == 0x5b then Running(s[n-1],s[..n-1],mem) else Bad
      else if ins.op == 0x57 && n >= 2 then
        if s[n-2] == 0 then Running(ins.next,s[..n-2],mem)
        else if s[n-1] in destinations && s[n-1] < |code| && code[s[n-1]] == 0x5b then Running(s[n-1],s[..n-2],mem)
        else Bad
      else if ins.op in {0xf3,0xfd} && n >= 2 then
        var end := (s[n-1] as nat)+(s[n-2] as nat);
        var bytes := G.Grow(mem,end)[s[n-1]..end];
        if ins.op == 0xf3 then Returned(bytes) else Reverted(bytes)
      else Bad
  }
}
