// SPDX-License-Identifier: MIT
// Isolated normatively interpreted arithmetic extension over reviewed external calls.
include "../../external-calls/Execution.dfy"
module OperationsModularPowerExecution {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import X = BytecodeExternalExecution
  type Byte = S.Byte
  type Word = S.Word
  type Frame = M.Frame
  type Observation = M.Observation
  function ProductModulo(a:Word,b:Word,modulus:Word):Word {
    if modulus==0 then 0 else ((a as nat)*(b as nat))%modulus
  }
  function SumModulo(a:Word,b:Word,modulus:Word):Word {
    if modulus==0 then 0 else ((a as nat)+(b as nat))%modulus
  }
  function Xor(a:Word,b:Word):Word { ((a as bv256) ^ (b as bv256)) as nat }
  // Unbounded mathematical integer power: no finite-word overflow or compiler trace.
  function Power(a:nat,n:nat):nat
    decreases n
  { if n==0 then 1 else a*Power(a,n-1) }
  predicate Packet(input:seq<Byte>) {
    |input|==192 && S.Load(input,0)==32 && S.Load(input,32)==32 && S.Load(input,64)==32
  }
  predicate Faithful(receipt:Observation) {
    if receipt.StaticCall? && receipt.target==5 && Packet(receipt.input) &&
       receipt.success && |receipt.returned|==32
    then var modulus:=S.Load(receipt.input,160);
         S.Load(receipt.returned,0)==(if modulus==0 then 0 else
                                      Power(S.Load(receipt.input,96),S.Load(receipt.input,128))%modulus)
    else true
  }
  predicate FaithfulHistory(observations:seq<Observation>) {
    forall i:nat :: i<|observations| ==> Faithful(observations[i])
  }
  function Opcodes():set<nat> { {0x08,0x09,0x18,0x13} }
  opaque function Execute(code:seq<Byte>,destinations:set<nat>,frame:Frame,self:Word,
                          value:Word,data:seq<Byte>,observations:seq<Observation>):Frame {
    var state:=frame.state;
    if !state.Running? || state.pc>=|code| || S.Fetch(code,state.pc).op !in Opcodes()
    then M.Step(code,destinations,frame,self,value,data,observations)
    else var ins:=S.Fetch(code,state.pc);var s:=state.stack;var n:=|s|;
                                                            var mem:=state.memory;
                                                            if n>1024 then M.Frame(S.Bad,frame.returned,frame.cursor)
                                                            else if ins.op==0x08 && n>=3 then
                                                              M.Frame(S.Running(ins.next,s[..n-3]+[SumModulo(s[n-1],s[n-2],s[n-3])],mem),frame.returned,frame.cursor)
                                                            else if ins.op==0x09 && n>=3 then
                                                              M.Frame(S.Running(ins.next,s[..n-3]+[ProductModulo(s[n-1],s[n-2],s[n-3])],mem),frame.returned,frame.cursor)
                                                            else if ins.op==0x18 && n>=2 then
                                                              M.Frame(S.Running(ins.next,s[..n-2]+[Xor(s[n-1],s[n-2])],mem),frame.returned,frame.cursor)
                                                            else if ins.op==0x13 && n>=2 then
                                                              M.Frame(S.Running(ins.next,s[..n-2]+[if G.Signed(s[n-1])>G.Signed(s[n-2]) then 1 else 0],mem),frame.returned,frame.cursor)
                                                            else M.Frame(S.Bad,frame.returned,frame.cursor)
  }
  lemma Delegate(code:seq<Byte>,destinations:set<nat>,frame:Frame,self:Word,value:Word,
                 data:seq<Byte>,observations:seq<Observation>)
    requires !frame.state.Running? || frame.state.pc>=|code| || S.Fetch(code,frame.state.pc).op !in Opcodes()
    ensures Execute(code,destinations,frame,self,value,data,observations)==M.Step(code,destinations,frame,self,value,data,observations)
  { reveal Execute(); }
  lemma AddModStep(code:seq<Byte>,destinations:set<nat>,pc:nat,prefix:seq<Word>,
                   mem:seq<Byte>,a:Word,b:Word,modulus:Word,returned:seq<Byte>,cursor:nat,
                   self:Word,value:Word,data:seq<Byte>,observations:seq<Observation>)
    requires pc<|code| && code[pc]==0x08 && |prefix|<=1021
    ensures Execute(code,destinations,M.Frame(S.Running(pc,prefix+[modulus,b,a],mem),returned,cursor),self,value,data,observations)==
            M.Frame(S.Running(pc+1,prefix+[SumModulo(a,b,modulus)],mem),returned,cursor)
  { reveal Execute(); assert S.Fetch(code,pc)==S.Op(0x08,pc+1,0); }
  lemma MultiplyModStep(code:seq<Byte>,destinations:set<nat>,pc:nat,prefix:seq<Word>,
                        mem:seq<Byte>,a:Word,b:Word,modulus:Word,returned:seq<Byte>,cursor:nat,
                        self:Word,value:Word,data:seq<Byte>,observations:seq<Observation>)
    requires pc<|code| && code[pc]==0x09 && |prefix|<=1021
    ensures Execute(code,destinations,M.Frame(S.Running(pc,prefix+[modulus,b,a],mem),returned,cursor),self,value,data,observations)==
            M.Frame(S.Running(pc+1,prefix+[ProductModulo(a,b,modulus)],mem),returned,cursor)
  {
    reveal Execute();
    assert S.Fetch(code,pc)==S.Op(0x09,pc+1,0);
    assert (prefix+[modulus,b,a])[..|prefix|]==prefix;
  }
  lemma XorStep(code:seq<Byte>,destinations:set<nat>,pc:nat,prefix:seq<Word>,mem:seq<Byte>,
                a:Word,b:Word,returned:seq<Byte>,cursor:nat,self:Word,value:Word,
                data:seq<Byte>,observations:seq<Observation>)
    requires pc<|code| && code[pc]==0x18 && |prefix|<=1022
    ensures Execute(code,destinations,M.Frame(S.Running(pc,prefix+[b,a],mem),returned,cursor),self,value,data,observations)==
            M.Frame(S.Running(pc+1,prefix+[Xor(a,b)],mem),returned,cursor)
  { reveal Execute(); assert S.Fetch(code,pc)==S.Op(0x18,pc+1,0); }
  predicate Trace(code:seq<Byte>,destinations:set<nat>,self:Word,value:Word,data:seq<Byte>,
                  observations:seq<Observation>,frames:seq<Frame>) {
    |frames|>0 && forall i {:trigger frames[i]} :: 0<=i<|frames|-1 ==>
                                                     Execute(code,destinations,frames[i],self,value,data,observations)==frames[i+1] && frames[i+1].state!=S.Bad
  }
  lemma Extend(code:seq<Byte>,destinations:set<nat>,self:Word,value:Word,data:seq<Byte>,
               observations:seq<Observation>,frames:seq<Frame>,next:Frame)
    requires Trace(code,destinations,self,value,data,observations,frames)
    requires next==Execute(code,destinations,frames[|frames|-1],self,value,data,observations) && next.state!=S.Bad
    ensures Trace(code,destinations,self,value,data,observations,frames+[next])
  {
    forall i {:trigger (frames+[next])[i]} | 0<=i<|frames|
      ensures Execute(code,destinations,(frames+[next])[i],self,value,data,observations)==(frames+[next])[i+1] && (frames+[next])[i+1].state!=S.Bad
    { if i<|frames|-1 { assert (frames+[next])[i]==frames[i]; assert (frames+[next])[i+1]==frames[i+1]; } }
  }
}
