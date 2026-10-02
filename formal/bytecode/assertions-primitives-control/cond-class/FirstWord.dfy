// SPDX-License-Identifier: MIT
// Both actual first-word branches, lifted into full observations/frame semantics.
include "FirstWord.generated.dfy"
include "FirstWordShort.generated.dfy"
include "../gather-composition/Frame.dfy"
module AssertionsCondFirstWord {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import F = AssertionsCondFirstWordSuccess
  import B = AssertionsCondFirstWordShort
  import Q = AssertionsPrimitiveScalar
  import H = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  import D = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  function Error(length: Word): seq<Byte> { G.Encode(0xd5cb8436,4)+G.Encode(0,32)+G.Encode(length,32) }
  predicate Heap(code: seq<Byte>, ret: Word, prefix: seq<Word>, mem: seq<Byte>, ptr: Word, length: Word, word: Word, free: Word) {
    |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && ptr+32+length <= |mem| && S.Load(mem,ptr) == length &&
    S.Load(mem,64) == free && 128 <= free && free+96 < G.Modulus() && |prefix| <= 960 &&
    ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b && (length >= 32 ==> S.Load(mem,ptr+32) == word)
  }
  predicate Matches(code: seq<Byte>) { F.Matches(code) && B.Matches(code) }
  function Destinations(ret: Word): set<nat> { F.Destinations(ret)+B.Destinations(ret) }
  lemma ErrorImage(ptr: Word, length: Word, word: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>)
    requires |mem|%32 == 0 && free+96 < G.Modulus()
    ensures G.Grow(B.Memory3(ptr,length,word,0,free,ret,prefix,mem),free+68)[free..free+68] == Error(length)
  {
    var image := S.Store(S.Store(S.Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000),free+4,0),free+36,length);
    Q.TwoWordError(mem,free,0xd5cb8436,0xd5cb843600000000000000000000000000000000000000000000000000000000,0,length);
    assert B.Memory1(ptr,length,word,0,free,ret,prefix,mem) == S.Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000);
    assert B.Memory2(ptr,length,word,0,free,ret,prefix,mem) == S.Store(B.Memory1(ptr,length,word,0,free,ret,prefix,mem),free+4,0);
    assert B.Memory3(ptr,length,word,0,free,ret,prefix,mem) == image;
    assert G.Grow(image,free+68) == image;
  }
  ghost method Run(code: seq<Byte>, ret: Word, prefix: seq<Word>, mem: seq<Byte>, ptr: Word, length: Word, word: Word, free: Word,
                   data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code) && Heap(code,ret,prefix,mem,ptr,length,word,free)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(3975,prefix+[ret,ptr],mem),returned,cursor) && frames[|frames|-1] == frame
    ensures if length < 32 then frame == E.Frame(S.Reverted(Error(length)),returned,cursor)
            else frame == E.Frame(S.Running(ret,prefix+[word],mem),returned,cursor)
  {
    var state: S.State;
    var states: seq<S.State>;
    if length < 32 {
      state,states := B.Run(code,ptr,length,word,0,free,ret,prefix,mem,value,data);
      ErrorImage(ptr,length,word,free,ret,prefix,mem);
      frames := H.Lift(code,B.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    } else {
      state,states := F.Run(code,ptr,length,word,0,free,ret,prefix,mem,value,data);
      frames := H.Lift(code,F.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    }
    frame := E.Frame(state,returned,cursor);
  }
}
