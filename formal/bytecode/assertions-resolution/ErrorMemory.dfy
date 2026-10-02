// SPDX-License-Identifier: MIT
include "Spec.dfy"
include "../scans/ErrorBytes.dfy"
module AssertionsConstraintErrorMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import E = BytecodeScanErrorBytes
  type Byte = S.Byte
  type Word = S.Word
  lemma Append(mem: seq<Byte>, offset: Word, selector: Word, args: seq<Word>, word: Word)
    requires |mem|%32 == 0 && (offset as nat)+4+32*|args|+32 < G.Modulus()
    requires (offset as nat)+4+32*|args| <= |mem|
    requires mem[offset..offset+4+32*|args|] == G.Encode(selector,4)+Encoded(args)
    ensures S.Store(mem,offset+4+32*|args|,word)[offset..offset+4+32*(|args|+1)] == G.Encode(selector,4)+Encoded(args+[word])
    ensures |S.Store(mem,offset+4+32*|args|,word)|%32 == 0
  {
    var position: Word := offset+4+32*|args|;
    R.StoredWord(mem,position,word);
    var expanded := S.Expand(mem,(position as nat)+32);
    assert expanded[..|mem|] == mem;
    var stored := S.Store(mem,position,word);
    assert stored[offset..position] == mem[offset..position];
    assert stored[offset..position+32] == stored[offset..position]+stored[position..position+32];
    assert Encoded(args+[word]) == Encoded(args)+G.Encode(word,32);
  }
  function Encoded(args: seq<Word>): seq<Byte>
    ensures |Encoded(args)| == 32*|args|
    decreases |args|
  { if |args| == 0 then [] else Encoded(args[..|args|-1])+G.Encode(args[|args|-1],32) }
  lemma EncodedAppend(args: seq<Word>, word: Word)
    ensures Encoded(args+[word]) == Encoded(args)+G.Encode(word,32)
  {
    assert (args+[word])[..|args|] == args;
    assert (args+[word])[|args|] == word;
  }
  function Range(mem: seq<Byte>, free: Word, entry: Word, param: Word, index: Word): seq<Byte>
    requires (free as nat)+100 < G.Modulus()
  {
    S.Store(S.Store(S.Store(S.Store(mem,free,0x295a41c5*0x100000000000000000000000000000000000000000000000000000000),free+4,entry),free+36,param),free+68,index)
  }
  function Data(mem: seq<Byte>, free: Word, entry: Word, param: Word, index: Word, length: Word): seq<Byte>
    requires (free as nat)+132 < G.Modulus()
  { S.Store(RangeWithSelector(mem,free,0xe70ce766,entry,param,index),free+100,length) }
  function RangeWithSelector(mem: seq<Byte>, free: Word, selector: Word, entry: Word, param: Word, index: Word): seq<Byte>
    requires selector < 0x100000000 && (free as nat)+100 < G.Modulus()
  {
    S.Store(S.Store(S.Store(S.Store(mem,free,selector*0x100000000000000000000000000000000000000000000000000000000),free+4,entry),free+36,param),free+68,index)
  }
  lemma Three(mem: seq<Byte>, free: Word, selector: Word, entry: Word, param: Word, index: Word)
    requires |mem|%32 == 0 && selector < 0x100000000 && (free as nat)+100 < G.Modulus()
    ensures RangeWithSelector(mem,free,selector,entry,param,index)[free..free+100] == G.Encode(selector,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32)
    ensures |RangeWithSelector(mem,free,selector,entry,param,index)|%32 == 0
  {
    var header: Word := selector*0x100000000000000000000000000000000000000000000000000000000;
    E.PhysicalError(mem,free,selector,header,entry);
    R.StoredWord(mem,free,header);
    R.StoredWord(S.Store(mem,free,header),free+4,entry);
    var first := S.Store(S.Store(mem,free,header),free+4,entry);
    Append(first,free,selector,[entry],param);
    var second := S.Store(first,free+36,param);
    Append(second,free,selector,[entry,param],index);
  }
  lemma Four(mem: seq<Byte>, free: Word, entry: Word, param: Word, index: Word, length: Word)
    requires |mem|%32 == 0 && (free as nat)+132 < G.Modulus()
    ensures Data(mem,free,entry,param,index,length)[free..free+132] == G.Encode(0xe70ce766,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32)+G.Encode(length,32)
  {
    Three(mem,free,0xe70ce766,entry,param,index);
    EncodedAppend([],entry);
    EncodedAppend([entry],param);
    EncodedAppend([entry,param],index);
    assert []+[entry] == [entry];
    assert [entry]+[param] == [entry,param];
    assert [entry,param]+[index] == [entry,param,index];
    assert Encoded([]) == [];
    assert Encoded([entry,param,index]) == G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32);
    assert G.Encode(0xe70ce766,4)+Encoded([entry,param,index]) == G.Encode(0xe70ce766,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32);
    Append(RangeWithSelector(mem,free,0xe70ce766,entry,param,index),free,0xe70ce766,[entry,param,index],length);
  }
}
