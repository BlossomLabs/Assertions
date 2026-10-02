// SPDX-License-Identifier: MIT
// Isolated reached XOR/BYTE/MSTORE8 extension; native verification pending.
include "../../external-calls/Machine.dfy"
module OperationsCaseFoldMachine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  function Xor(a:S.Word,b:S.Word):S.Word { ((a as bv256)^(b as bv256)) as nat }
  function Byte(value:S.Word,index:S.Word):S.Byte {
    if index>=32 then 0 else (value/G.Pow256(31-index))%256
  }
  function Store8(mem:seq<S.Byte>,offset:S.Word,value:S.Word):seq<S.Byte> {
    var expanded:=S.Expand(mem,(offset as nat)+1);
    expanded[..offset]+[value%256]+expanded[offset+1..]
  }
  predicate Fits(mem:seq<S.Byte>,offset:S.Word) {
    |mem|<G.Modulus() && S.Round32((offset as nat)+1)<G.Modulus()
  }
  opaque function Step(code:seq<S.Byte>,destinations:set<nat>,frame:M.Frame,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>):M.Frame {
    if !frame.state.Running? || frame.state.pc>=|code| then M.Step(code,destinations,frame,self,value,data,observations)
    else var ins:=S.Fetch(code,frame.state.pc);
         if ins.op !in {0x18,0x1a,0x53} then M.Step(code,destinations,frame,self,value,data,observations)
         else var stack:=frame.state.stack;var n:=|stack|;var mem:=frame.state.memory;
                                                          if n<2 || n>1024 then M.Frame(S.Bad,frame.returned,frame.cursor)
                                                          else if ins.op==0x18 then M.Frame(S.Running(ins.next,stack[..n-2]+[Xor(stack[n-1],stack[n-2])],mem),frame.returned,frame.cursor)
                                                          else if ins.op==0x1a then M.Frame(S.Running(ins.next,stack[..n-2]+[Byte(stack[n-2],stack[n-1])],mem),frame.returned,frame.cursor)
                                                          else if !Fits(mem,stack[n-1]) then M.Frame(S.Bad,frame.returned,frame.cursor)
                                                          else M.Frame(S.Running(ins.next,stack[..n-2],Store8(mem,stack[n-1],stack[n-2])),frame.returned,frame.cursor)
  }
  lemma Delegate(code:seq<S.Byte>,destinations:set<nat>,frame:M.Frame,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    requires !frame.state.Running? || frame.state.pc>=|code| || S.Fetch(code,frame.state.pc).op !in {0x18,0x1a,0x53}
    ensures Step(code,destinations,frame,self,value,data,observations)==M.Step(code,destinations,frame,self,value,data,observations)
  { reveal Step(); }
  lemma XorStep(code:seq<S.Byte>,pc:nat,prefix:seq<S.Word>,a:S.Word,b:S.Word,mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    requires pc<|code| && code[pc]==0x18 && |prefix|<=1022
    ensures Step(code,{},M.Frame(S.Running(pc,prefix+[b,a],mem),returned,cursor),self,value,data,observations)==M.Frame(S.Running(pc+1,prefix+[Xor(a,b)],mem),returned,cursor)
  { reveal Step(); }
  lemma ByteStep(code:seq<S.Byte>,pc:nat,prefix:seq<S.Word>,index:S.Word,a:S.Word,mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    requires pc<|code| && code[pc]==0x1a && |prefix|<=1022
    ensures Step(code,{},M.Frame(S.Running(pc,prefix+[a,index],mem),returned,cursor),self,value,data,observations)==M.Frame(S.Running(pc+1,prefix+[Byte(a,index)],mem),returned,cursor)
  { reveal Step(); }
  lemma Store8Step(code:seq<S.Byte>,pc:nat,prefix:seq<S.Word>,offset:S.Word,a:S.Word,mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)
    requires pc<|code| && code[pc]==0x53 && |prefix|<=1022 && Fits(mem,offset)
    ensures Step(code,{},M.Frame(S.Running(pc,prefix+[a,offset],mem),returned,cursor),self,value,data,observations)==M.Frame(S.Running(pc+1,prefix,Store8(mem,offset,a)),returned,cursor)
  { reveal Step(); }
}
