// SPDX-License-Identifier: MIT
// Complete signed raw-word helper cases in the full observations/frame semantics.
include "RawWordPositive.generated.dfy"
include "RawWordNegative.generated.dfy"
include "RawWordPositiveOob.generated.dfy"
include "RawWordNegativeOob.generated.dfy"
include "../gather-composition/Frame.dfy"
module AssertionsPickWord {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import P = AssertionsPickRawWordPositive
  import N = AssertionsPickRawWordNegative
  import B = AssertionsPickRawWordPositiveOob
  import C = AssertionsPickRawWordNegativeOob
  import Q = AssertionsPrimitiveScalar
  import D = AssertionsGatherCallerSpec
  import H = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  function Error(index: Word,length: Word): seq<Byte> { G.Encode(0xd5cb8436,4)+G.Encode(index,32)+G.Encode(length,32) }
  predicate Heap(code: seq<Byte>,ret: Word,prefix: seq<Word>,mem: seq<Byte>,ptr: Word,length: Word,word: Word,index: Word,free: Word) {
    |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && ptr+32+length <= |mem| && S.Load(mem,ptr) == length &&
    S.Load(mem,64) == free && 128 <= free && free+96 < G.Modulus() && |prefix| <= 960 &&
    ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b &&
    (Q.Inside(length,index) ==> S.Load(mem,Q.WordOffset(ptr,length,index)) == word)
  }
  predicate Matches(code: seq<Byte>) { P.Matches(code) && N.Matches(code) && B.Matches(code) && C.Matches(code) }
  function Destinations(ret: Word): set<nat> { P.Destinations(ret)+N.Destinations(ret)+B.Destinations(ret)+C.Destinations(ret) }
  lemma ErrorImage(ptr: Word,length: Word,word: Word,index: Word,free: Word,ret: Word,prefix: seq<Word>,mem: seq<Byte>)
    requires |mem|%32 == 0 && free+96 < G.Modulus()
    ensures G.Grow(B.Memory3(ptr,length,word,index,free,ret,prefix,mem),free+68)[free..free+68] == Error(index,length)
    ensures G.Grow(C.Memory3(ptr,length,word,index,free,ret,prefix,mem),free+68)[free..free+68] == Error(index,length)
  {
    Q.TwoWordError(mem,free,0xd5cb8436,0xd5cb843600000000000000000000000000000000000000000000000000000000,index,length);
    var image := S.Store(S.Store(S.Store(mem,free,0xd5cb843600000000000000000000000000000000000000000000000000000000),free+4,index),free+36,length);
    assert B.Memory3(ptr,length,word,index,free,ret,prefix,mem) == image;
    assert C.Memory3(ptr,length,word,index,free,ret,prefix,mem) == image;
    assert G.Grow(image,free+68) == image;
  }
  ghost method Run(code: seq<Byte>,ret: Word,prefix: seq<Word>,mem: seq<Byte>,ptr: Word,length: Word,word: Word,index: Word,free: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,self: Word,value: Word,observations: seq<A.Observation>) returns (frame: E.Frame,frames: seq<E.Frame>)
    requires Matches(code) && Heap(code,ret,prefix,mem,ptr,length,word,index,free)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(7405,prefix+[ret,ptr,index],mem),returned,cursor) && frames[|frames|-1] == frame
    ensures if Q.Inside(length,index) then frame == E.Frame(S.Running(ret,prefix+[word],mem),returned,cursor)
            else frame == E.Frame(S.Reverted(Error(index,length)),returned,cursor)
  {
    var state: S.State;
    var states: seq<S.State>;
    if Q.Inside(length,index) {
      if G.Signed(index) >= 0 {
        state,states := P.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        frames := H.Lift(code,P.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
      } else {
        state,states := N.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        frames := H.Lift(code,N.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
      }
    } else {
      ErrorImage(ptr,length,word,index,free,ret,prefix,mem);
      if G.Signed(index) >= 0 {
        state,states := B.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        frames := H.Lift(code,B.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
      } else {
        state,states := C.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
        frames := H.Lift(code,C.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
      }
    }
    frame := E.Frame(state,returned,cursor);
  }
}
