// SPDX-License-Identifier: MIT
// Private success-prefix adapter exposes exact decoded memory for canonical false composition.
include "../Loop.dfy"
include "../LoopFacts.dfy"
include "../LoopFrames.dfy"
include "../leaf/Connection.generated.dfy"
module AssertionsConstraintFalsePrefixCurrent {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import W = AssertionsConstraintLoopFrames
  import B = AssertionsConstraintLoopSegments
  import I = AssertionsConstraintInit
  import P = AssertionsConstraintPrepare
  import D = AssertionsConstraintDispatch
  import N = AssertionsConstraintIncrement
  import X = AssertionsConstraintExit
  import Z = AssertionsConstraintEmpty
  import C = AssertionsConstraintDecoder
  import H = AssertionsConstraintDecoderMemory
  import F = AssertionsConstraintDecoderFacts
  import V = AssertionsConstraintLoopFacts
  import L = AssertionsConstraintLoopSpec
  import J = AssertionsConstraintSpec
  import K = AssertionsConstraintConnection
  import KL = AssertionsConstraintLeafFrame
  import KE = AssertionsConstraintExecution
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>, ret: Word) {
    B.Matches(code,ret) && C.Matches(code,7723) && K.Matches(code,8035)
  }
  function Destinations(ret: Word): set<nat> {
    B.Destinations(ret)+C.Destinations(7723)+K.Destinations(8035)
  }
  lemma Binding(code: seq<Byte>, ret: Word)
    requires Matches(code,ret)
    ensures I.Matches(code,ret) && P.Matches(code,ret) && D.Matches(code,ret)
    ensures N.Matches(code,ret) && X.Matches(code,ret) && Z.Matches(code,ret)
    ensures C.Matches(code,7723) && K.Matches(code,8035)
  { reveal Matches(); reveal B.Matches(); }
  function Stack(ret: Word, base: Word, count: Word, ptr: Word, length: Word,
                 assertion: Word, entry: Word, param: Word, index: Word, prefix: seq<Word>): seq<Word> {
    prefix+[ret,base,count,ptr,assertion,entry,param,count,length/32,index]
  }
  ghost method RawTrace(code: seq<Byte>, small: set<nat>, ret: Word, self: Word, value: Word,
                        data: seq<Byte>, observations: seq<M.Observation>, returned: seq<Byte>, cursor: nat,
                        states: seq<S.State>) returns (frames: seq<E.Frame>)
    requires small <= Destinations(ret) && R.Trace(code,small,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states| ==> Q.Local(code,states[i])
    ensures Q.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(states[0],returned,cursor) && frames[|frames|-1] == E.Frame(states[|states|-1],returned,cursor)
  {
    W.LiftRaw(code,small,Destinations(ret),self,value,data,observations,returned,cursor,states);
    frames := Q.Lift(states,returned,cursor);
  }
  ghost method {:isolate_assertions} Iteration(code: seq<Byte>, ret: Word, base: Word, cs: seq<L.Constraint>, index: nat,
                                               ptr: Word, bytes: seq<Byte>, initial: Word, assertion: Word, entry: Word, param: Word,
                                               prefix: seq<Word>, mem: seq<Byte>, self: Word, value: Word, data: seq<Byte>,
                                               observations: seq<M.Observation>, returned: seq<Byte>, cursor: nat)
    returns (output: seq<Byte>, frames: seq<E.Frame>)
    requires Matches(code,ret) && |prefix| <= 950
    requires L.Layout(data,base,cs) && index < |cs| && |cs|*32 <= |bytes| &&
             J.Judge(cs[index].kind,cs[index].length,L.Actual(bytes,index),S.DataWord(data,L.Payload(base,cs[index])),S.DataWord(data,L.Payload(base,cs[index])+32)) == J.Holds
    requires (initial as nat)+L.Cost(cs)+160 < 0x10000000000000000
    requires L.Heap(mem,ptr,bytes,L.Free(initial,cs,index))
    ensures L.Heap(output,ptr,bytes,L.Free(initial,cs,index+1))
    ensures H.Fits(mem,L.Free(initial,cs,index),L.Payload(base,cs[index]),cs[index].length,data) ==>
            output == H.Construct(mem,L.Free(initial,cs,index),cs[index].kind,L.Payload(base,cs[index]),cs[index].length,data)
    ensures Q.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(7660,Stack(ret,base,|cs|,ptr,|bytes|,assertion,entry,param,index,prefix),mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Running(7660,Stack(ret,base,|cs|,ptr,|bytes|,assertion,entry,param,index+1,prefix),output),returned,cursor)
  {
    hide H.Construct();
    Binding(code,ret);
    V.Item(data,base,cs,index);
    L.FreeStep(initial,cs,index);
    L.PhysicalWord(mem,ptr,bytes,L.Free(initial,cs,index),index);
    var count: Word := |cs|;
    var length: Word := |bytes|;
    var i: Word := index;
    var c := cs[index];
    var free := L.Free(initial,cs,index);
    var actual := L.Actual(bytes,index);
    var stack := Stack(ret,base,count,ptr,length,assertion,entry,param,i,prefix);
    assert P.Admitted(ret,base,count,ptr,length,assertion,entry,param,i,actual,c.position,0,c.kind,prefix,mem,data);
    var state, states := P.Run(code,ret,base,count,ptr,length,assertion,entry,param,i,actual,c.position,0,c.kind,prefix,mem,data,value);
    frames := RawTrace(code,P.Destinations(ret),ret,self,value,data,observations,returned,cursor,states);
    assert state == S.Running(19377,stack+[actual,0,7723,L.Position(base,c)],mem);
    var decoderPrefix := stack+[actual,0];
    V.DecoderAdmission(data,base,cs,index,mem,ptr,bytes,initial,decoderPrefix);
    state, states := C.Run(code,7723,L.Position(base,c),c.kind,c.referenceRelative,c.length,free,decoderPrefix,mem,data,value);
    var segment := RawTrace(code,C.Destinations(7723),ret,self,value,data,observations,returned,cursor,states);
    W.Join(code,Destinations(ret),self,value,data,observations,frames,segment);
    frames := frames+segment[1..];
    var payload := L.Payload(base,c);
    output := H.Construct(mem,free,c.kind,payload,c.length,data);
    assert state == S.Running(7723,stack+[actual,0,free],output);
    H.Built(mem,free,c.kind,payload,c.length,data);
    V.AfterHeap(mem,ptr,bytes,free,c.kind,payload,c.length,data);
    assert L.Heap(output,ptr,bytes,L.Free(initial,cs,index+1));
    assert D.Admitted(ret,base,count,ptr,length,assertion,entry,param,i,actual,c.position,free,c.kind,prefix,output,data);
    state, states := D.Run(code,ret,base,count,ptr,length,assertion,entry,param,i,actual,c.position,free,c.kind,prefix,output,data,value);
    segment := RawTrace(code,D.Destinations(ret),ret,self,value,data,observations,returned,cursor,states);
    W.Join(code,Destinations(ret),self,value,data,observations,frames,segment);
    frames := frames+segment[1..];
    F.LeafMemory(mem,free,c.kind,payload,c.length,data);
    var lower := S.DataWord(data,payload);
    var higher := S.DataWord(data,payload+32);
    var leafPrefix := stack+[actual,free,0];
    assert K.Admitted(8035,c.kind,actual,free,free+64,H.NextFree(free,c.length),entry,param,i,c.length,lower,higher,leafPrefix,output);
    var leafStates: seq<S.State>;
    state, leafStates := K.Run(code,8035,c.kind,actual,free,free+64,H.NextFree(free,c.length),entry,param,i,c.length,lower,higher,leafPrefix,output,value,data);
    assert J.Judge(c.kind,c.length,actual,lower,higher) == J.Holds;
    assert state == S.Running(8035,leafPrefix+[1],output);
    W.LiftLeaf(code,K.Destinations(8035),Destinations(ret),self,value,data,observations,returned,cursor,leafStates);
    segment := KL.Lift(leafStates,returned,cursor);
    W.Join(code,Destinations(ret),self,value,data,observations,frames,segment);
    frames := frames+segment[1..];
    assert N.Admitted(ret,base,count,ptr,length,assertion,entry,param,i,actual,c.position,free,c.kind,prefix,output,data);
    state, states := N.Run(code,ret,base,count,ptr,length,assertion,entry,param,i,actual,c.position,free,c.kind,prefix,output,data,value);
    segment := RawTrace(code,N.Destinations(ret),ret,self,value,data,observations,returned,cursor,states);
    assert frames[|frames|-1] == E.Frame(S.Running(8035,leafPrefix+[1],output),returned,cursor);
    assert segment[0] == E.Frame(S.Running(8035,leafPrefix+[1],output),returned,cursor);
    W.Join(code,Destinations(ret),self,value,data,observations,frames,segment);
    frames := frames+segment[1..];
  }
}
