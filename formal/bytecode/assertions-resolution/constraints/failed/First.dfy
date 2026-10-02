// SPDX-License-Identifier: MIT
// The first false non-OR leaf emits canonical ConstraintFailed after arbitrary successful prefixes.
include "CurrentFrame.dfy"
include "Tail.dfy"
include "../../constrained-raw/Widen.dfy"
module AssertionsConstraintFirstFalse {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import Q = AssertionsRawResolveFrame
  import W = AssertionsConstraintLoopFrames
  import I = AssertionsConstraintInit
  import L = AssertionsConstraintLoopSpec
  import J = AssertionsConstraintSpec
  import C = AssertionsConstraintFalsePrefixCurrent
  import T = AssertionsConstraintFirstFalseTail
  import H = AssertionsConstraintDecoderMemory
  import ZD = AssertionsConstraintFalseDecoderFrame
  import ZP = AssertionsConstraintFailedSpec
  import G = BytecodeGetterMachine
  import V = AssertionsConstrainedRawWiden
  import X = AssertionsConstraintLoopFacts
  type Word = S.Word
  type Byte = S.Byte
  function Verdict(bytes: seq<Byte>, data: seq<Byte>, base: Word, c: L.Constraint, index: nat): J.Verdict
    requires (index+1)*32 <= |bytes|
    requires c.kind <= 8 && c.kind != 6
    requires L.Payload(base,c) < 0x10000000000000000
  { J.Judge(c.kind,c.length,L.Actual(bytes,index),S.DataWord(data,L.Payload(base,c)),S.DataWord(data,L.Payload(base,c)+32)) }
  predicate First(bytes: seq<Byte>, data: seq<Byte>, base: Word, cs: seq<L.Constraint>, bad: nat)
    requires L.Layout(data,base,cs) && |cs|*32 <= |bytes|
  {
    bad < |cs| && Verdict(bytes,data,base,cs[bad],bad) == J.Fails &&
    forall i {:trigger cs[i]} :: 0 <= i < bad ==> Verdict(bytes,data,base,cs[i],i) == J.Holds
  }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, ret: Word, base: Word, cs: seq<L.Constraint>, bad: nat,
                                         ptr: Word, bytes: seq<Byte>, initial: Word, assertion: Word, assertionLength: Word, entry: Word, param: Word,
                                         prefix: seq<Word>, mem: seq<Byte>, self: Word, value: Word, data: seq<Byte>,
                                         observations: seq<M.Observation>, returned: seq<Byte>, cursor: nat)
    returns (frames: seq<E.Frame>)
    requires C.Matches(code,ret) && T.Matches(code,ret) && |prefix| <= 927
    requires L.Layout(data,base,cs) && |cs|*32 <= |bytes| && First(bytes,data,base,cs,bad)
    requires (initial as nat)+L.Cost(cs)+160 < 0x10000000000000000 && L.Heap(mem,ptr,bytes,initial)
    requires assertion >= 96 && assertion+32+assertionLength <= |mem| && assertion+32+assertionLength <= initial
    requires S.Load(mem,assertion) == assertionLength
    requires (initial as nat)+2*L.Cost(cs)+356+S.Round32(assertionLength) < 0x10000000000000000
    ensures Q.Trace(code,T.Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(7580,prefix+[ret,base,|cs|,ptr,assertion,entry,param],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Reverted(ZP.Error(mem[assertion+32..assertion+32+assertionLength],entry,param,bad,cs[bad].kind,L.Actual(bytes,bad),data[L.Payload(base,cs[bad])..L.Payload(base,cs[bad])+cs[bad].length])),returned,cursor)
  {
    hide H.Construct(); hide ZP.Error();
    C.Binding(code,ret);
    var count: Word := |cs|;
    var length: Word := |bytes|;
    assert I.Admitted(ret,base,count,ptr,length,assertion,entry,param,0,0,0,0,0,prefix,mem,data);
    var state, states := I.Run(code,ret,base,count,ptr,length,assertion,entry,param,0,0,0,0,0,prefix,mem,data,value);
    W.LiftRaw(code,I.Destinations(ret),T.Destinations(ret),self,value,data,observations,returned,cursor,states);
    frames := Q.Lift(states,returned,cursor);
    var current := mem;
    var index: nat := 0;
    assert L.Free(initial,cs,0) == initial;
    while index < bad
      invariant index <= bad && L.Heap(current,ptr,bytes,L.Free(initial,cs,index))
      invariant assertion+32+assertionLength <= |current| && S.Load(current,assertion) == assertionLength
      invariant current[assertion..assertion+32+assertionLength] == mem[assertion..assertion+32+assertionLength]
      invariant Q.Trace(code,T.Destinations(ret),self,value,data,observations,frames)
      invariant frames[0] == E.Frame(S.Running(7580,prefix+[ret,base,count,ptr,assertion,entry,param],mem),returned,cursor)
      invariant frames[|frames|-1] == E.Frame(S.Running(7660,C.Stack(ret,base,count,ptr,length,assertion,entry,param,index,prefix),current),returned,cursor)
      decreases bad-index
    {
      X.Item(data,base,cs,index); L.FreeStep(initial,cs,index);
      assert Verdict(bytes,data,base,cs[index],index) == J.Holds;
      assert H.Fits(current,L.Free(initial,cs,index),L.Payload(base,cs[index]),cs[index].length,data);
      var next, segment := C.Iteration(code,ret,base,cs,index,ptr,bytes,initial,assertion,entry,param,prefix,current,self,value,data,observations,returned,cursor);
      V.Trace(code,C.Destinations(ret),T.Destinations(ret),self,value,data,observations,segment);
      W.Join(code,T.Destinations(ret),self,value,data,observations,frames,segment);
      frames := frames+segment[1..];
      var c := cs[index];
      ZD.Constraint(current,L.Free(initial,cs,index),c.kind,L.Payload(base,c),c.length,data,assertion,32+assertionLength);
      ZD.Subspan(next,current,assertion,32+assertionLength,0,32);
      assert G.Grow(next,assertion+32) == next && G.Grow(current,assertion+32) == current;
      assert S.Load(next,assertion) == assertionLength;
      current := next;
      index := index+1;
    }
    ZD.Subspan(current,mem,assertion,32+assertionLength,32,assertionLength);
    var terminal, output, tail := T.Iteration(code,ret,base,cs,bad,ptr,bytes,initial,assertion,assertionLength,entry,param,prefix,current,self,value,data,observations,returned,cursor);
    W.Join(code,T.Destinations(ret),self,value,data,observations,frames,tail);
    frames := frames+tail[1..];
  }
}
