// SPDX-License-Identifier: MIT
// Actual helper traces composed with both original-occurrence byte buffers.
include "../memory/Memory.dfy"
include "../word-at/WordAt.generated.dfy"
include "../set-word/SetWord.generated.dfy"
module BytecodeSortPhysicalHelperConnection {
  import opened BytecodeScanMachine
  import M = BytecodeWordSortMemory
  import A = BytecodeSortMemoryHelperWordAt
  import W = BytecodeSortMemoryHelperSetWord
  import E = BytecodeScanExecution
  ghost method Read(code: seq<Byte>, prefix: seq<Word>, n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>, which: bool, index: nat, value: Word) returns (state: State, trace: seq<State>)
    requires A.Matches(code) && |prefix| <= 1000
    requires M.Admitted(n,left,right,start,data) && index < n
    ensures state == Running(3847,prefix+[M.Cell(n,(if which then right else left)[index],start,data)],M.Heap(n,left,right,start,data))
    ensures E.Trace(code,A.Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == Running(3833,prefix+[3847,M.Base(n,which),index],M.Heap(n,left,right,start,data)) && trace[|trace|-1] == state
  {
    var mem := M.Heap(n,left,right,start,data);
    var base: Word := M.Base(n,which);
    var slot: Word := index;
    M.Rounded(n);
    M.Read(n,left,right,start,data,which,index);
    assert A.Admitted(prefix,base,slot) && A.MemoryAdmitted(mem,base,slot);
    state,trace := A.Run(code,prefix,base,slot,mem,value,data);
  }
  ghost method Write(code: seq<Byte>, prefix: seq<Word>, n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>, which: bool, index: nat, id: nat, value: Word) returns (state: State, trace: seq<State>)
    requires W.Matches(code) && |prefix| <= 1000
    requires M.Admitted(n,left,right,start,data) && index < n && id < n
    ensures M.Admitted(n,(if which then left else left[index := id]),(if which then right[index := id] else right),start,data)
    ensures state == Running(3860,prefix,M.Heap(n,(if which then left else left[index := id]),(if which then right[index := id] else right),start,data))
    ensures E.Trace(code,W.Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == Running(3847,prefix+[3860,M.Base(n,which),index,M.Cell(n,id,start,data)],M.Heap(n,left,right,start,data)) && trace[|trace|-1] == state
  {
    var mem := M.Heap(n,left,right,start,data);
    var base: Word := M.Base(n,which);
    var slot: Word := index;
    var written := M.Cell(n,id,start,data);
    M.Rounded(n);
    M.Write(n,left,right,start,data,which,index,id);
    assert W.Admitted(prefix,base,slot,written) && W.MemoryAdmitted(mem,base,slot);
    state,trace := W.Run(code,prefix,base,slot,written,mem,value,data);
  }
}
