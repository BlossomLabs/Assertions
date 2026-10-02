// SPDX-License-Identifier: MIT
// Unverified candidate dynamic copy/frame support; no public credit.
include "Machine.dfy"
module OperationsHashBytesMemory {
  import opened OperationsHashBytesMachine

  function CalldataCopy(mem: seq<Byte>,data: seq<Byte>,target: nat,source: nat,count: nat): seq<Byte> {
    if count==0 then mem else
    var expanded := Grow(mem,target+count);
    expanded[..target]+seq(count,i => if source+i<|data| then data[source+i] else 0)+expanded[target+count..]
  }
  lemma CopySpan(mem: seq<Byte>,data: seq<Byte>,target: nat,source: nat,count: nat)
    requires source+count<=|data|
    ensures |CalldataCopy(mem,data,target,source,count)|>=target+count || count==0
    ensures count>0 ==> CalldataCopy(mem,data,target,source,count)[target..target+count]==data[source..source+count]
  {
    if count>0 {
      var fragment:=seq(count,i => if source+i<|data| then data[source+i] else 0);
      assert forall i:nat :: i<count ==> fragment[i]==data[source..source+count][i];
      assert fragment==data[source..source+count];
    }
  }
  lemma CopyPrefix(mem: seq<Byte>,data: seq<Byte>,target: nat,source: nat,count: nat,other: nat)
    requires other<=|mem| && other<=target
    ensures CalldataCopy(mem,data,target,source,count)[..other]==mem[..other]
  {
    if count>0 {
      var expanded:=Grow(mem,target+count);
      assert expanded[..|mem|]==mem;
    }
  }
  lemma ScratchPayload(mem: seq<Byte>,data: seq<Byte>,source: nat,count: nat)
    requires |mem|>=96 && source+count<=|data|
    ensures Store(CalldataCopy(mem,data,128,source,count),128+count,0)[128..128+count]==data[source..source+count]
    ensures Load(Store(CalldataCopy(mem,data,128,source,count),128+count,0),64)==Load(mem,64)
  {
    CopySpan(mem,data,128,source,count);
    CopyPrefix(mem,data,128,source,count,96);
    var copied:=CalldataCopy(mem,data,128,source,count);
    assert Load(copied,64)==Load(mem,64);
    StoreFrame(copied,128+count,0,64);
    var expanded:=Grow(copied,160+count);
    assert expanded[..|copied|]==copied;
    if count==0 { assert data[source..source+count]==[]; }
    else {
      assert |copied|>=128+count;
      assert expanded[128..128+count]==copied[128..128+count];
    }
  }
}
