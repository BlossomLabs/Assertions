// SPDX-License-Identifier: MIT
// Candidate physical calldata/hash extension. No native or public credit.
include "Memory.dfy"
module OperationsHashBytesExecution {
  import opened OperationsHashBytesMachine
  import B = OperationsHashBytesMemory

  function DataWord(data: seq<Byte>,offset: nat): Word {
    Decode(seq(32,i => if 0<=offset+i<|data| then data[offset+i] else 0))%Modulus()
  }

  // The actual world must supply faithful KECCAK256 observations for every
  // requested byte preimage. This map models observations, not the hash engine.
  opaque function Execute(code: seq<Byte>,destinations: set<nat>,state: State,
                          data: seq<Byte>,value: Word,a: Word,
                          hashes: map<seq<Byte>,Word>): State
    requires |data|<0x10000000000000000
  {
    if !state.Running? then state else if state.pc>=|code| then Bad else
    var ins:=Fetch(code,state.pc);
    var s:=state.stack; var n:=|s|; var mem:=state.memory;
                                    if ins.op==0x35 && n>=1 then
                                      Running(ins.next,s[..n-1]+[DataWord(data,s[n-1])],mem)
                                    else if ins.op==0x37 && n>=3 then
                                      Running(ins.next,s[..n-3],B.CalldataCopy(mem,data,s[n-1],s[n-2],s[n-3]))
                                    else if ins.op==0x20 && n>=2 then
                                      var expanded:=if s[n-2]==0 then mem else Grow(mem,(s[n-1] as nat)+(s[n-2] as nat));
                                      var preimage:=if s[n-2]==0 then [] else expanded[s[n-1]..(s[n-1] as nat)+(s[n-2] as nat)];
                                      if preimage in hashes then Running(ins.next,s[..n-2]+[hashes[preimage]],expanded) else Bad
                                    else Step(code,destinations,state,value,|data|,DataWord(data,0),a,DataWord(data,(a as nat)+4))
  }

  lemma CopyOpcode(code: seq<Byte>,destinations: set<nat>,mem: seq<Byte>,
                   data: seq<Byte>,value: Word,a: Word,hashes: map<seq<Byte>,Word>,
                   pc: nat,prefix: seq<Word>,target: Word,source: Word,count: Word)
    requires |data|<0x10000000000000000 && pc<|code| && code[pc]==0x37
    ensures Execute(code,destinations,Running(pc,prefix+[count,source,target],mem),data,value,a,hashes)==
            Running(pc+1,prefix,B.CalldataCopy(mem,data,target,source,count))
  { reveal Execute(); }

  lemma HashOpcode(code: seq<Byte>,destinations: set<nat>,mem: seq<Byte>,
                   data: seq<Byte>,value: Word,a: Word,hashes: map<seq<Byte>,Word>,
                   pc: nat,prefix: seq<Word>,offset: Word,count: Word)
    requires |data|<0x10000000000000000 && pc<|code| && code[pc]==0x20
    requires (offset as nat)+(count as nat)<=|mem|
    requires mem[offset..(offset as nat)+(count as nat)] in hashes
    ensures Execute(code,destinations,Running(pc,prefix+[count,offset],mem),data,value,a,hashes)==
            Running(pc+1,prefix+[hashes[mem[offset..(offset as nat)+(count as nat)]]],mem)
  {
    if count==0 { assert mem[offset..offset]==[]; }
    else { assert Grow(mem,(offset as nat)+(count as nat))==mem; }
    reveal Execute();
  }

  lemma CopiedPayloadHash(mem: seq<Byte>,data: seq<Byte>,source: nat,count: nat,
                          hashes: map<seq<Byte>,Word>)
    requires |mem|>=96 && source+count<=|data|
    requires data[source..source+count] in hashes
    ensures Store(B.CalldataCopy(mem,data,128,source,count),128+count,0)[128..128+count] in hashes
    ensures hashes[Store(B.CalldataCopy(mem,data,128,source,count),128+count,0)[128..128+count]]==
            hashes[data[source..source+count]]
  { B.ScratchPayload(mem,data,source,count); }

  // Lift the projected raw-admission controls only at the exact decoder loads
  // they model. The complete actual calldata, including arbitrary tail bytes,
  // remains the physical source of all three projected head words.
  lemma RawAgreement(code: seq<Byte>,destinations: set<nat>,state: State,
                     data: seq<Byte>,value: Word,a: Word,hashes: map<seq<Byte>,Word>)
    requires |data|<0x10000000000000000 && a==DataWord(data,4)
    requires state.Running? && state.pc<|code|
    requires code[state.pc]!=0x37 && code[state.pc]!=0x20
    requires code[state.pc]==0x35 && |state.stack|>=1 ==>
               state.stack[|state.stack|-1]==0 || state.stack[|state.stack|-1]==4 ||
               state.stack[|state.stack|-1]==(a as nat)+4
    ensures Execute(code,destinations,state,data,value,a,hashes)==
            Step(code,destinations,state,value,|data|,DataWord(data,0),a,DataWord(data,(a as nat)+4))
  {
    reveal Execute(); reveal Step();
  }
}
