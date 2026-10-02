// SPDX-License-Identifier: MIT
// Exact resolver continuation after constraint validation returns successfully.
include "../raw/Frame.dfy"
module AssertionsConstrainedRawAfter {
  import S = BytecodeScanMachine
  import M = AssertionsRawResolveMachine
  import C = BytecodeCopyMachine
  import A = AssertionsSignedMachine
  import Q = AssertionsRawResolveFrame
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>, ret: Word) {
    |code| == 20049 && ret < |code| && code[ret] == 91 &&
    code[3967] == 91 && code[3968] == 148 && code[3969] == 147 &&
    code[3970] == 80 && code[3971] == 80 && code[3972] == 80 && code[3973] == 80 && code[3974] == 86
  }
  function Destinations(ret: Word): set<nat> { {3967,ret} }
  function At(index: nat, ret: Word, paramPointer: Word, assertion: Word, entry: Word, param: Word,
              pointer: Word, prefix: seq<Word>, mem: seq<Byte>): S.State
    requires index <= 8
  {
    if index == 0 then S.Running(3967,prefix+[ret,paramPointer,assertion,entry,param,pointer],mem)
    else if index == 1 then S.Running(3968,prefix+[ret,paramPointer,assertion,entry,param,pointer],mem)
    else if index == 2 then S.Running(3969,prefix+[pointer,paramPointer,assertion,entry,param,ret],mem)
    else if index == 3 then S.Running(3970,prefix+[pointer,ret,assertion,entry,param,paramPointer],mem)
    else if index == 4 then S.Running(3971,prefix+[pointer,ret,assertion,entry,param],mem)
    else if index == 5 then S.Running(3972,prefix+[pointer,ret,assertion,entry],mem)
    else if index == 6 then S.Running(3973,prefix+[pointer,ret,assertion],mem)
    else if index == 7 then S.Running(3974,prefix+[pointer,ret],mem)
    else S.Running(ret,prefix+[pointer],mem)
  }
  lemma {:isolate_assertions} Step(index: nat, code: seq<Byte>, ret: Word, paramPointer: Word, assertion: Word,
                                   entry: Word, param: Word, pointer: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires index < 8 && Matches(code,ret) && |prefix| <= 980
    ensures M.Step(code,Destinations(ret),At(index,ret,paramPointer,assertion,entry,param,pointer,prefix,mem),value,data) ==
            At(index+1,ret,paramPointer,assertion,entry,param,pointer,prefix,mem)
    ensures Q.Local(code,At(index,ret,paramPointer,assertion,entry,param,pointer,prefix,mem))
    ensures Q.Local(code,At(index+1,ret,paramPointer,assertion,entry,param,pointer,prefix,mem))
  { reveal Matches(); reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step(); }
  ghost method Run(code: seq<Byte>, ret: Word, paramPointer: Word, assertion: Word, entry: Word, param: Word,
                   pointer: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (states: seq<S.State>)
    requires Matches(code,ret) && |prefix| <= 980
    ensures M.Trace(code,Destinations(ret),value,data,states)
    ensures forall i {:trigger states[i]} :: 0 <= i < |states| ==> Q.Local(code,states[i])
    ensures states[0] == S.Running(3967,prefix+[ret,paramPointer,assertion,entry,param,pointer],mem)
    ensures states[|states|-1] == S.Running(ret,prefix+[pointer],mem)
  {
    states := seq(9,i requires 0 <= i < 9 => At(i,ret,paramPointer,assertion,entry,param,pointer,prefix,mem));
    forall i {:trigger states[i]} | 0 <= i < 8
      ensures M.Step(code,Destinations(ret),states[i],value,data) == states[i+1]
      ensures Q.Local(code,states[i]) && Q.Local(code,states[i+1])
    { Step(i,code,ret,paramPointer,assertion,entry,param,pointer,prefix,mem,value,data); }
    Step(7,code,ret,paramPointer,assertion,entry,param,pointer,prefix,mem,value,data);
  }
}
