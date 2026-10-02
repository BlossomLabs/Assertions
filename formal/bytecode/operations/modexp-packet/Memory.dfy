// SPDX-License-Identifier: MIT
// Physical six-word MODEXP request and overlapping exact 32-byte output.
include "../modexp-execution/Execution.dfy"
module OperationsModularPowerPacketMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import M = BytecodeExternalMemory
  import X = OperationsModularPowerExecution
  function Words(a:S.Word,e:S.Word,m:S.Word):seq<S.Word> { [32,32,32,a,e,m] }
  predicate Admitted(mem:seq<S.Byte>,heap:S.Word) {
    |mem|%32==0 && 96<=|mem|<G.Modulus() && 96<=heap && heap%32==0 &&
    (heap as nat)+192<G.Modulus() && S.Load(mem,64)==heap
  }
  function Write(mem:seq<S.Byte>,heap:S.Word,words:seq<S.Word>,count:nat):seq<S.Byte>
    requires count<=|words| && heap%32==0 && (heap as nat)+32*|words|<G.Modulus()
    requires |mem|%32==0
    ensures |Write(mem,heap,words,count)|%32==0
    ensures |Write(mem,heap,words,count)|>=|mem|
    decreases count
  {
    if count==0 then mem
    else var previous:=Write(mem,heap,words,count-1);
         var offset:S.Word:=heap+32*(count-1);
         R.StoredWord(previous,offset,words[count-1]);
         S.Store(previous,offset,words[count-1])
  }
  function Packet(mem:seq<S.Byte>,heap:S.Word,a:S.Word,e:S.Word,m:S.Word):seq<S.Byte>
    requires Admitted(mem,heap)
  { Write(mem,heap,Words(a,e,m),6) }
  lemma Size(mem:seq<S.Byte>,heap:S.Word,words:seq<S.Word>,count:nat)
    requires count<=|words| && heap%32==0 && (heap as nat)+32*|words|<G.Modulus()
    requires |mem|%32==0 && |mem|<G.Modulus()
    ensures |Write(mem,heap,words,count)|>=|mem|
    ensures count>0 ==> |Write(mem,heap,words,count)|>=heap+32*count
    ensures |Write(mem,heap,words,count)|<G.Modulus()
    decreases count
  {
    if count>0 {
      Size(mem,heap,words,count-1);
      var previous:=Write(mem,heap,words,count-1);
      var offset:S.Word:=heap+32*(count-1);
      R.StoredWord(previous,offset,words[count-1]);
      assert S.Round32(heap+32*count)==heap+32*count;
      assert S.Round32(heap+32*count)<=S.Round32(heap+32*|words|);

    }
  }
  lemma Slot(mem:seq<S.Byte>,heap:S.Word,words:seq<S.Word>,count:nat,index:nat)
    requires index<count<=|words| && heap%32==0 && (heap as nat)+32*|words|<G.Modulus()
    requires |mem|%32==0 && |mem|<G.Modulus()
    ensures S.Load(Write(mem,heap,words,count),heap+32*index)==words[index]
    decreases count
  {
    var previous:=Write(mem,heap,words,count-1);
    var offset:S.Word:=heap+32*(count-1);
    R.StoredWord(previous,offset,words[count-1]);
    if index<count-1 {
      Slot(mem,heap,words,count-1,index);
      Size(mem,heap,words,count-1);
      R.StoredFrame(previous,offset,words[count-1],heap+32*index);
    }
  }
  lemma Header(mem:seq<S.Byte>,heap:S.Word,words:seq<S.Word>,count:nat)
    requires count<=|words| && heap%32==0 && (heap as nat)+32*|words|<G.Modulus()
    requires |mem|%32==0 && 96<=|mem|<G.Modulus() && heap>=96
    ensures S.Load(Write(mem,heap,words,count),64)==S.Load(mem,64)
    decreases count
  {
    if count>0 {
      Header(mem,heap,words,count-1);
      var previous:=Write(mem,heap,words,count-1);
      var offset:S.Word:=heap+32*(count-1);
      R.StoredWord(previous,offset,words[count-1]);
      assert |previous|>=|mem|;
      R.StoredFrame(previous,offset,words[count-1],64);
    }
  }
  lemma Request(mem:seq<S.Byte>,heap:S.Word,a:S.Word,e:S.Word,m:S.Word)
    requires Admitted(mem,heap) && heap%32==0
    ensures X.Packet(M.Input(Packet(mem,heap,a,e,m),heap,192))
    ensures S.Load(M.Input(Packet(mem,heap,a,e,m),heap,192),96)==a
    ensures S.Load(M.Input(Packet(mem,heap,a,e,m),heap,192),128)==e
    ensures S.Load(M.Input(Packet(mem,heap,a,e,m),heap,192),160)==m
    ensures S.Load(Packet(mem,heap,a,e,m),64)==heap
    ensures M.Fits(Packet(mem,heap,a,e,m),heap,192,heap,32)
  {
    var words:=Words(a,e,m);var packet:=Packet(mem,heap,a,e,m);
    Size(mem,heap,words,6);Header(mem,heap,words,6);
    forall i:nat | i<6
      ensures S.Load(M.Input(packet,heap,192),32*i)==words[i]
    {
      Slot(mem,heap,words,6,i);
      R.WindowFits(packet,heap,192);
      assert S.Load(packet[heap..heap+192],32*i)==S.Load(packet,heap+32*i);
    }
  }
  lemma ExactReply(packet:seq<S.Byte>,heap:S.Word,returned:seq<S.Byte>)
    requires |returned|==32 && (heap as nat)+192<=|packet| && |packet|<G.Modulus()
    requires |packet|%32==0 && heap%32==0
    ensures S.Load(M.Output(packet,heap,192,heap,32,returned),heap)==S.Load(returned,0)
    ensures forall i:nat :: i<|packet| && (i<heap || heap+32<=i) ==>
                              M.Output(packet,heap,192,heap,32,returned)[i]==packet[i]
  {
    forall i:nat | i<32
      ensures M.Output(packet,heap,192,heap,32,returned)[heap+i]==returned[i]
    { M.OutputByte(packet,heap,192,heap,32,returned,i); }
    assert M.Output(packet,heap,192,heap,32,returned)[heap..heap+32]==returned;
    forall i:nat | i<|packet| && (i<heap || heap+32<=i)
      ensures M.Output(packet,heap,192,heap,32,returned)[i]==packet[i]
    { M.OutputFrame(packet,heap,192,heap,32,returned,i); }
  }
}
