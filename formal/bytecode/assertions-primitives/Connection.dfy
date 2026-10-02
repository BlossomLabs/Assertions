// SPDX-License-Identifier: MIT
// Independent byte-level outcomes for complete reached scalar helper executions.
include "FirstWord.generated.dfy"
include "FirstWordShort.generated.dfy"
include "AsAddress.generated.dfy"
include "AsAddressDirty.generated.dfy"
include "RawWordPositive.generated.dfy"
include "RawWordNegative.generated.dfy"
include "RawWordPositiveOob.generated.dfy"
include "RawWordNegativeOob.generated.dfy"
module AssertionsPrimitiveConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  import Q = AssertionsPrimitiveScalar
  import F = AssertionsPrimitiveFirstWord
  import FS = AssertionsPrimitiveFirstWordShort
  import A = AssertionsPrimitiveAsAddress
  import AD = AssertionsPrimitiveAsAddressDirty
  import RP = AssertionsPrimitiveRawWordPositive
  import RN = AssertionsPrimitiveRawWordNegative
  import RPO = AssertionsPrimitiveRawWordPositiveOob
  import RNO = AssertionsPrimitiveRawWordNegativeOob
  function BoundsError(index: Word, length: Word): seq<Byte> { G.Encode(0xd5cb8436,4)+G.Encode(index,32)+G.Encode(length,32) }
  function AddressError(index: Word, word: Word): seq<Byte> { G.Encode(0x57bf944b,4)+G.Encode(index,32)+G.Encode(word,32) }
  predicate MemoryFrame(code: seq<Byte>, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>) {
    |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 128 <= free && free+96 < G.Modulus() && ret in F.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b && |prefix| <= 980
  }
  predicate BytesFrame(code: seq<Byte>, ptr: Word, length: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>) {
    MemoryFrame(code,free,ret,prefix,mem) && ptr+32+length <= |mem| && Load(mem,ptr) == length
  }
  lemma ErrorImage(mem: seq<Byte>, free: Word, selector: Word, header: Word, first: Word, second: Word)
    requires |mem|%32 == 0 && free+68 < G.Modulus()
    requires header == (selector as nat)*0x100000000000000000000000000000000000000000000000000000000
    ensures var image := Store(Store(Store(mem,free,header),free+4,first),free+36,second);
            G.Grow(image,free+68)[free..free+68] == G.Encode(selector,4)+G.Encode(first,32)+G.Encode(second,32)
  {
    Q.TwoWordError(mem,free,selector,header,first,second);
    var image := Store(Store(Store(mem,free,header),free+4,first),free+36,second);
    assert |image| >= free+68;
    assert G.Grow(image,free+68) == image;
  }
  lemma FSImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+96 < G.Modulus()
    ensures FS.Memory3(ptr,length,word,0,free,ret,prefix,mem) == Store(Store(Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000),free+4,0),free+36,length)
  {
    assert FS.Memory1(ptr,length,word,0,free,ret,prefix,mem) == Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000);
    assert FS.Memory2(ptr,length,word,0,free,ret,prefix,mem) == Store(FS.Memory1(ptr,length,word,0,free,ret,prefix,mem),free+4,0);
    assert FS.Memory3(ptr,length,word,0,free,ret,prefix,mem) == Store(FS.Memory2(ptr,length,word,0,free,ret,prefix,mem),free+36,length);
  }
  lemma ADImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+96 < G.Modulus()
    ensures AD.Memory3(ptr,length,word,index,free,ret,prefix,mem) == Store(Store(Store(mem,free,0x57bf944b00000000000000000000000000000000000000000000000000000000),free+4,index),free+36,word)
  {
    assert AD.Memory1(ptr,length,word,index,free,ret,prefix,mem) == Store(mem,free,0x57bf944b00000000000000000000000000000000000000000000000000000000);
    assert AD.Memory2(ptr,length,word,index,free,ret,prefix,mem) == Store(AD.Memory1(ptr,length,word,index,free,ret,prefix,mem),free+4,index);
    assert AD.Memory3(ptr,length,word,index,free,ret,prefix,mem) == Store(AD.Memory2(ptr,length,word,index,free,ret,prefix,mem),free+36,word);
  }
  lemma RPOImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+96 < G.Modulus()
    ensures RPO.Memory3(ptr,length,word,index,free,ret,prefix,mem) == Store(Store(Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000),free+4,index),free+36,length)
  {
    assert RPO.Memory1(ptr,length,word,index,free,ret,prefix,mem) == Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000);
    assert RPO.Memory2(ptr,length,word,index,free,ret,prefix,mem) == Store(RPO.Memory1(ptr,length,word,index,free,ret,prefix,mem),free+4,index);
    assert RPO.Memory3(ptr,length,word,index,free,ret,prefix,mem) == Store(RPO.Memory2(ptr,length,word,index,free,ret,prefix,mem),free+36,length);
  }
  lemma RNOImage(ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires free+96 < G.Modulus()
    ensures RNO.Memory3(ptr,length,word,index,free,ret,prefix,mem) == Store(Store(Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000),free+4,index),free+36,length)
  {
    assert RNO.Memory1(ptr,length,word,index,free,ret,prefix,mem) == Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000);
    assert RNO.Memory2(ptr,length,word,index,free,ret,prefix,mem) == Store(RNO.Memory1(ptr,length,word,index,free,ret,prefix,mem),free+4,index);
    assert RNO.Memory3(ptr,length,word,index,free,ret,prefix,mem) == Store(RNO.Memory2(ptr,length,word,index,free,ret,prefix,mem),free+36,length);
  }
  ghost method FirstWord(code: seq<Byte>, ptr: Word, length: Word, word: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires F.Matches(code) && FS.Matches(code) && BytesFrame(code,ptr,length,free,ret,prefix,mem)
    requires length >= 32 ==> Load(mem,ptr+32) == word
    ensures if length < 32 then state == Reverted(BoundsError(0,length)) else state == Running(ret,prefix+[word],mem)
    ensures E.Trace(code,F.Destinations(ret)+FS.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(3975,prefix+[ret,ptr],mem) && trace[|trace|-1] == state
  {
    if length < 32 {
      state,trace := FS.Run(code,ptr,length,word,0,free,ret,prefix,mem,value,data);
      ErrorImage(mem,free,0xd5cb8436,0xd5cb843600000000000000000000000000000000000000000000000000000000,0,length);
      FSImage(ptr,length,word,0,free,ret,prefix,mem);
      E.WidenTrace(code,FS.Destinations(ret),F.Destinations(ret)+FS.Destinations(ret),value,data,trace);
    } else {
      state,trace := F.Run(code,ptr,length,word,0,free,ret,prefix,mem,value,data);
      E.WidenTrace(code,F.Destinations(ret),F.Destinations(ret)+FS.Destinations(ret),value,data,trace);
    }
  }
  ghost method AsAddress(code: seq<Byte>, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires A.Matches(code) && AD.Matches(code) && MemoryFrame(code,free,ret,prefix,mem)
    ensures if Q.CleanAddress(word) then state == Running(ret,prefix+[word],mem) else state == Reverted(AddressError(index,word))
    ensures E.Trace(code,A.Destinations(ret)+AD.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(4031,prefix+[ret,word,index],mem) && trace[|trace|-1] == state
  {
    if Q.CleanAddress(word) {
      state,trace := A.Run(code,0,0,word,index,free,ret,prefix,mem,value,data);
      E.WidenTrace(code,A.Destinations(ret),A.Destinations(ret)+AD.Destinations(ret),value,data,trace);
    } else {
      state,trace := AD.Run(code,0,0,word,index,free,ret,prefix,mem,value,data);
      ErrorImage(mem,free,0x57bf944b,0x57bf944b00000000000000000000000000000000000000000000000000000000,index,word);
      ADImage(0,0,word,index,free,ret,prefix,mem);
      E.WidenTrace(code,AD.Destinations(ret),A.Destinations(ret)+AD.Destinations(ret),value,data,trace);
    }
  }
  function RawDestinations(ret: Word): set<nat> { RP.Destinations(ret)+RN.Destinations(ret)+RPO.Destinations(ret)+RNO.Destinations(ret) }
  ghost method RawWord(code: seq<Byte>, ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires RP.Matches(code) && RN.Matches(code) && RPO.Matches(code) && RNO.Matches(code) && BytesFrame(code,ptr,length,free,ret,prefix,mem)
    requires Q.Inside(length,index) ==> Load(mem,Q.WordOffset(ptr,length,index)) == word
    ensures if Q.Inside(length,index) then state == Running(ret,prefix+[word],mem) else state == Reverted(BoundsError(index,length))
    ensures E.Trace(code,RawDestinations(ret),value,data,trace)
    ensures trace[0] == Running(7405,prefix+[ret,ptr,index],mem) && trace[|trace|-1] == state
  {
    if Q.Inside(length,index) {
      if G.Signed(index) >= 0 {
        state,trace := RP.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        E.WidenTrace(code,RP.Destinations(ret),RawDestinations(ret),value,data,trace);
      } else {
        state,trace := RN.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        E.WidenTrace(code,RN.Destinations(ret),RawDestinations(ret),value,data,trace);
      }
    } else {
      ErrorImage(mem,free,0xd5cb8436,0xd5cb843600000000000000000000000000000000000000000000000000000000,index,length);
      if G.Signed(index) >= 0 {
        state,trace := RPO.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        RPOImage(ptr,length,word,index,free,ret,prefix,mem);
        E.WidenTrace(code,RPO.Destinations(ret),RawDestinations(ret),value,data,trace);
      } else {
        state,trace := RNO.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        RNOImage(ptr,length,word,index,free,ret,prefix,mem);
        E.WidenTrace(code,RNO.Destinations(ret),RawDestinations(ret),value,data,trace);
      }
    }
  }
}
