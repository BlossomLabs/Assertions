// SPDX-License-Identifier: MIT
// Development reached copy extension. Fitting footprints and resources explicit.
include "Memory.dfy"
module BytecodeCopyMachine {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeCopyMemory
  predicate Fits(mem: seq<Byte>, dst: Word, src: Word, length: Word, memoryCopy: bool) {
    |mem| < G.Modulus() && (length == 0 ||
                            (S.Round32((dst as nat)+length) < G.Modulus() &&
                             (!memoryCopy || S.Round32((src as nat)+length) < G.Modulus())))
  }
  opaque function Step(code: seq<Byte>, destinations: set<nat>, state: State, value: Word, data: seq<Byte>): State {
    if !state.Running? || state.pc >= |code| then S.Step(code,destinations,state,value,data)
    else var ins := S.Fetch(code,state.pc);
         if ins.op !in {0x37,0x5e} then S.Step(code,destinations,state,value,data)
         else var s := state.stack;
              var n := |s|;
              if n < 3 || !Fits(state.memory,s[n-1],s[n-2],s[n-3],ins.op == 0x5e) then Bad
              else Running(ins.next,s[..n-3],
                           if ins.op == 0x37 then M.Calldata(state.memory,s[n-1],s[n-2],s[n-3],data)
                           else M.Memory(state.memory,s[n-1],s[n-2],s[n-3]))
  }
  lemma Delegate(code: seq<Byte>, destinations: set<nat>, state: State, value: Word, data: seq<Byte>)
    requires !state.Running? || state.pc >= |code| || S.Fetch(code,state.pc).op !in {0x37,0x5e}
    ensures Step(code,destinations,state,value,data) == S.Step(code,destinations,state,value,data)
  { reveal Step(); }
  lemma CalldataStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, dst: Word, src: Word, length: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x37 && Fits(mem,dst,src,length,false)
    ensures Step(code,{},Running(pc,prefix+[length,src,dst],mem),value,data) == Running(pc+1,prefix,M.Calldata(mem,dst,src,length,data))
  { reveal Step(); }
  lemma MemoryStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, dst: Word, src: Word, length: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x5e && Fits(mem,dst,src,length,true)
    ensures Step(code,{},Running(pc,prefix+[length,src,dst],mem),value,data) == Running(pc+1,prefix,M.Memory(mem,dst,src,length))
  { reveal Step(); }
  lemma ZeroStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, dst: Word, src: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] in {0x37,0x5e} && |mem| < G.Modulus()
    ensures Step(code,{},Running(pc,prefix+[0,src,dst],mem),value,data) == Running(pc+1,prefix,mem)
  { reveal Step(); M.ZeroLength(mem,dst,src,data); }
}
