// SPDX-License-Identifier: MIT
// Exhaustive address outcomes and independently specified default Context writes.
include "Address.generated.dfy"
include "AddressDirty.generated.dfy"
include "../AddressLength.generated.dfy"
include "../../scans/ErrorBytes.dfy"
module ExpressionsWholeAddressConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import B = BytecodeScanErrorBytes
  import R = BytecodeScanRepresentation
  import A = ExpressionsPrimitiveAddress
  import D = ExpressionsPrimitiveAddressDirty
  import L = ExpressionsPrimitiveAddressLength
  function AddressLimit(): nat { 0x10000000000000000000000000000000000000000 }
  function InvalidNode(index: Word): seq<Byte> { G.Encode(0x64a42493,4)+G.Encode(index,32) }
  function Context(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { Store(Store(Store(Store(Store(Store(mem,64,free+160),free,0),free+32,0),free+64,0),free+96,0),free+128,0) }
  lemma ContextRounded(mem: seq<Byte>, free: Word)
    requires |mem|%32 == 0 && free+160 < G.Modulus()
    ensures |Context(mem,free)|%32 == 0
  {
    R.StoredWord(mem,64,free+160);
    var m1 := Store(mem,64,free+160);
    R.StoredWord(m1,free,0);
    var m2 := Store(m1,free,0);
    R.StoredWord(m2,free+32,0);
    var m3 := Store(m2,free+32,0);
    R.StoredWord(m3,free+64,0);
    var m4 := Store(m3,free+64,0);
    R.StoredWord(m4,free+96,0);
    var m5 := Store(m4,free+96,0);
    R.StoredWord(m5,free+128,0);
  }
  predicate Frame(code: seq<Byte>, ptr: Word, length: Word, word: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>) {
    |mem|%32 == 0 && 128 <= ptr && (ptr as nat)+32+(length as nat) <= |mem| < G.Modulus() && (ptr as nat)+32+(length as nat) <= free && (free as nat)+416 < G.Modulus() && Load(mem,ptr) == length && Load(mem,64) == free && ret in L.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b && |prefix| <= 980 && (length == 32 ==> Load(mem,ptr+32) == word)
  }
  function Destinations(ret: Word): set<nat> { A.Destinations(ret)+D.Destinations(ret)+L.Destinations(ret) }
  lemma DirtyImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory6(ptr,length,word,index,free,ret,prefix,mem) == Context(mem,free)
    ensures D.Memory8(ptr,length,word,index,free,ret,prefix,mem) == Store(Store(Context(mem,free),free+160,0x64a4249300000000000000000000000000000000000000000000000000000000),free+164,index)
  {
    D.Memory1Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory2Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory3Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory4Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory5Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory6Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory7Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory8Definition(ptr,length,word,index,free,ret,prefix,mem);
  }
  lemma CleanImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory12(ptr,length,word,index,free,ret,prefix,mem) == Context(Context(mem,free),free+160)
  {
    A.Memory1Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory2Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory3Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory4Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory5Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory6Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory7Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory8Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory9Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory10Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory11Definition(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory12Definition(ptr,length,word,index,free,ret,prefix,mem);
  }
  ghost method Address(code: seq<Byte>, ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires A.Matches(code) && D.Matches(code) && L.Matches(code)
    requires Frame(code,ptr,length,word,free,ret,prefix,mem)
    ensures if length != 32 || word >= AddressLimit() then state == Reverted(InvalidNode(index)) else state == Running(ret,prefix+[word],Context(Context(mem,free),free+160))
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == Running(5440,prefix+[ret,ptr,index],mem) && trace[|trace|-1] == state
  {
    if length != 32 {
      state,trace := L.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
      var header: Word := 0x64a4249300000000000000000000000000000000000000000000000000000000;
      assert L.Memory2(ptr,length,word,index,free,ret,prefix,mem) == Store(Store(mem,free,header),free+4,index);
      B.PhysicalError(mem,free,0x64a42493,header,index);
      assert G.Grow(L.Memory2(ptr,length,word,index,free,ret,prefix,mem),free+36) == L.Memory2(ptr,length,word,index,free,ret,prefix,mem);
      E.WidenTrace(code,L.Destinations(ret),Destinations(ret),value,data,trace);
    } else if word >= AddressLimit() {
      state,trace := D.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
      DirtyImage(ptr,length,word,index,free,ret,prefix,mem);
      var header: Word := 0x64a4249300000000000000000000000000000000000000000000000000000000;
      ContextRounded(mem,free);
      B.PhysicalError(Context(mem,free),free+160,0x64a42493,header,index);
      assert G.Grow(D.Memory8(ptr,length,word,index,free,ret,prefix,mem),free+196) == D.Memory8(ptr,length,word,index,free,ret,prefix,mem);
      E.WidenTrace(code,D.Destinations(ret),Destinations(ret),value,data,trace);
    } else {
      state,trace := A.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
      CleanImage(ptr,length,word,index,free,ret,prefix,mem);
      E.WidenTrace(code,A.Destinations(ret),Destinations(ret),value,data,trace);
    }
  }
}
