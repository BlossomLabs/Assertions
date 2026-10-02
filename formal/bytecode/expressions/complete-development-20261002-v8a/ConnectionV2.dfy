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
  opaque function ContextStep1(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { Store(mem,64,free+160) }
  lemma ContextStep1Definition(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus()
    ensures ContextStep1(mem,free) == Store(mem,64,free+160)
  { reveal ContextStep1(); }
  lemma ContextStep1Rounded(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus() && |mem|%32 == 0
    ensures |ContextStep1(mem,free)|%32 == 0
  {
    ContextStep1Definition(mem,free);
    R.StoredWord(mem,64,free+160);
  }
  opaque function ContextStep2(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { Store(ContextStep1(mem,free),free,0) }
  lemma ContextStep2Definition(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus()
    ensures ContextStep2(mem,free) == Store(ContextStep1(mem,free),free,0)
  { reveal ContextStep2(); }
  lemma ContextStep2Rounded(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus() && |mem|%32 == 0
    ensures |ContextStep2(mem,free)|%32 == 0
  {
    ContextStep1Rounded(mem,free);
    ContextStep2Definition(mem,free);
    R.StoredWord(ContextStep1(mem,free),free,0);
  }
  opaque function ContextStep3(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { Store(ContextStep2(mem,free),free+32,0) }
  lemma ContextStep3Definition(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus()
    ensures ContextStep3(mem,free) == Store(ContextStep2(mem,free),free+32,0)
  { reveal ContextStep3(); }
  lemma ContextStep3Rounded(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus() && |mem|%32 == 0
    ensures |ContextStep3(mem,free)|%32 == 0
  {
    ContextStep2Rounded(mem,free);
    ContextStep3Definition(mem,free);
    R.StoredWord(ContextStep2(mem,free),free+32,0);
  }
  opaque function ContextStep4(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { Store(ContextStep3(mem,free),free+64,0) }
  lemma ContextStep4Definition(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus()
    ensures ContextStep4(mem,free) == Store(ContextStep3(mem,free),free+64,0)
  { reveal ContextStep4(); }
  lemma ContextStep4Rounded(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus() && |mem|%32 == 0
    ensures |ContextStep4(mem,free)|%32 == 0
  {
    ContextStep3Rounded(mem,free);
    ContextStep4Definition(mem,free);
    R.StoredWord(ContextStep3(mem,free),free+64,0);
  }
  opaque function ContextStep5(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { Store(ContextStep4(mem,free),free+96,0) }
  lemma ContextStep5Definition(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus()
    ensures ContextStep5(mem,free) == Store(ContextStep4(mem,free),free+96,0)
  { reveal ContextStep5(); }
  lemma ContextStep5Rounded(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus() && |mem|%32 == 0
    ensures |ContextStep5(mem,free)|%32 == 0
  {
    ContextStep4Rounded(mem,free);
    ContextStep5Definition(mem,free);
    R.StoredWord(ContextStep4(mem,free),free+96,0);
  }
  opaque function ContextStep6(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { Store(ContextStep5(mem,free),free+128,0) }
  lemma ContextStep6Definition(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus()
    ensures ContextStep6(mem,free) == Store(ContextStep5(mem,free),free+128,0)
  { reveal ContextStep6(); }
  lemma ContextStep6Rounded(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus() && |mem|%32 == 0
    ensures |ContextStep6(mem,free)|%32 == 0
  {
    ContextStep5Rounded(mem,free);
    ContextStep6Definition(mem,free);
    R.StoredWord(ContextStep5(mem,free),free+128,0);
  }
  opaque function Context(mem: seq<Byte>, free: Word): seq<Byte>
    requires free+160 < G.Modulus()
  { ContextStep6(mem,free) }
  lemma ContextDefinition(mem: seq<Byte>, free: Word)
    requires free+160 < G.Modulus()
    ensures Context(mem,free) == ContextStep6(mem,free)
  { reveal Context(); }
  lemma ContextRounded(mem: seq<Byte>, free: Word)
    requires |mem|%32 == 0 && free+160 < G.Modulus()
    ensures |Context(mem,free)|%32 == 0
  { ContextDefinition(mem,free); ContextStep6Rounded(mem,free); }
  lemma DirtyStep1(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory1(ptr,length,word,index,free,ret,prefix,mem) == ContextStep1(mem,free)
  {
    D.Memory1Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep1Definition(mem,free);
  }
  lemma DirtyStep2(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory2(ptr,length,word,index,free,ret,prefix,mem) == ContextStep2(mem,free)
  {
    DirtyStep1(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory2Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep2Definition(mem,free);
  }
  lemma DirtyStep3(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory3(ptr,length,word,index,free,ret,prefix,mem) == ContextStep3(mem,free)
  {
    DirtyStep2(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory3Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep3Definition(mem,free);
  }
  lemma DirtyStep4(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory4(ptr,length,word,index,free,ret,prefix,mem) == ContextStep4(mem,free)
  {
    DirtyStep3(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory4Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep4Definition(mem,free);
  }
  lemma DirtyStep5(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory5(ptr,length,word,index,free,ret,prefix,mem) == ContextStep5(mem,free)
  {
    DirtyStep4(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory5Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep5Definition(mem,free);
  }
  lemma DirtyStep6(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory6(ptr,length,word,index,free,ret,prefix,mem) == ContextStep6(mem,free)
  {
    DirtyStep5(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory6Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep6Definition(mem,free);
  }
  lemma DirtyImageBase(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory6(ptr,length,word,index,free,ret,prefix,mem) == Context(mem,free)
  {
    DirtyStep6(ptr,length,word,index,free,ret,prefix,mem); ContextDefinition(mem,free);
  }
  lemma CleanFirstStep1(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory1(ptr,length,word,index,free,ret,prefix,mem) == ContextStep1(mem,free)
  {
    A.Memory1Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep1Definition(mem,free);
  }
  lemma CleanFirstStep2(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory2(ptr,length,word,index,free,ret,prefix,mem) == ContextStep2(mem,free)
  {
    CleanFirstStep1(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory2Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep2Definition(mem,free);
  }
  lemma CleanFirstStep3(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory3(ptr,length,word,index,free,ret,prefix,mem) == ContextStep3(mem,free)
  {
    CleanFirstStep2(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory3Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep3Definition(mem,free);
  }
  lemma CleanFirstStep4(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory4(ptr,length,word,index,free,ret,prefix,mem) == ContextStep4(mem,free)
  {
    CleanFirstStep3(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory4Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep4Definition(mem,free);
  }
  lemma CleanFirstStep5(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory5(ptr,length,word,index,free,ret,prefix,mem) == ContextStep5(mem,free)
  {
    CleanFirstStep4(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory5Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep5Definition(mem,free);
  }
  lemma CleanFirstStep6(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory6(ptr,length,word,index,free,ret,prefix,mem) == ContextStep6(mem,free)
  {
    CleanFirstStep5(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory6Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep6Definition(mem,free);
  }
  lemma CleanFirstImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory6(ptr,length,word,index,free,ret,prefix,mem) == Context(mem,free)
  {
    CleanFirstStep6(ptr,length,word,index,free,ret,prefix,mem); ContextDefinition(mem,free);
  }
  lemma CleanSecondStep1(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory7(ptr,length,word,index,free,ret,prefix,mem) == ContextStep1(Context(mem,free),free+160)
  {
    CleanFirstImage(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory7Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep1Definition(Context(mem,free),free+160);
  }
  lemma CleanSecondStep2(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory8(ptr,length,word,index,free,ret,prefix,mem) == ContextStep2(Context(mem,free),free+160)
  {
    CleanSecondStep1(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory8Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep2Definition(Context(mem,free),free+160);
  }
  lemma CleanSecondStep3(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory9(ptr,length,word,index,free,ret,prefix,mem) == ContextStep3(Context(mem,free),free+160)
  {
    CleanSecondStep2(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory9Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep3Definition(Context(mem,free),free+160);
  }
  lemma CleanSecondStep4(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory10(ptr,length,word,index,free,ret,prefix,mem) == ContextStep4(Context(mem,free),free+160)
  {
    CleanSecondStep3(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory10Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep4Definition(Context(mem,free),free+160);
  }
  lemma CleanSecondStep5(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory11(ptr,length,word,index,free,ret,prefix,mem) == ContextStep5(Context(mem,free),free+160)
  {
    CleanSecondStep4(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory11Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep5Definition(Context(mem,free),free+160);
  }
  lemma CleanSecondStep6(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory12(ptr,length,word,index,free,ret,prefix,mem) == ContextStep6(Context(mem,free),free+160)
  {
    CleanSecondStep5(ptr,length,word,index,free,ret,prefix,mem);
    A.Memory12Definition(ptr,length,word,index,free,ret,prefix,mem);
    ContextStep6Definition(Context(mem,free),free+160);
  }
  lemma DirtyImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures D.Memory6(ptr,length,word,index,free,ret,prefix,mem) == Context(mem,free)
    ensures D.Memory8(ptr,length,word,index,free,ret,prefix,mem) == Store(Store(Context(mem,free),free+160,0x64a4249300000000000000000000000000000000000000000000000000000000),free+164,index)
  {
    DirtyImageBase(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory7Definition(ptr,length,word,index,free,ret,prefix,mem);
    D.Memory8Definition(ptr,length,word,index,free,ret,prefix,mem);
  }
  lemma CleanImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+416 < G.Modulus()
    ensures A.Memory12(ptr,length,word,index,free,ret,prefix,mem) == Context(Context(mem,free),free+160)
  {
    CleanSecondStep6(ptr,length,word,index,free,ret,prefix,mem); ContextDefinition(Context(mem,free),free+160);
  }
  predicate Frame(code: seq<Byte>, ptr: Word, length: Word, word: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>) {
    |mem|%32 == 0 && 128 <= ptr && (ptr as nat)+32+(length as nat) <= |mem| < G.Modulus() && (ptr as nat)+32+(length as nat) <= free && (free as nat)+416 < G.Modulus() && Load(mem,ptr) == length && Load(mem,64) == free && ret in L.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b && |prefix| <= 980 && (length == 32 ==> Load(mem,ptr+32) == word)
  }
  function Destinations(ret: Word): set<nat> { A.Destinations(ret)+D.Destinations(ret)+L.Destinations(ret) }
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
