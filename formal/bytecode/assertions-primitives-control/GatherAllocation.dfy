// SPDX-License-Identifier: MIT
// Independent array allocation image composed with the actual arbitrary-count loop.
include "GatherStart.generated.dfy"
include "GatherStartZero.generated.dfy"
include "GatherHeaderExit.generated.dfy"
include "GatherInitialization.dfy"
module AssertionsGatherAllocation {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import E = BytecodeScanExecution
  import P = AssertionsControlGatherStart
  import Z = AssertionsControlGatherStartZero
  import H = AssertionsControlGatherHeaderExit
  import I = AssertionsGatherInitialization
  import F = AssertionsControlGatherFill
  import L = AssertionsControlGatherFillLast
  function End(free: Word, count: Word): nat { free+32+count*32 }
  predicate Space(mem: seq<Byte>, free: Word, count: Word) {
    |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && 128 <= free &&
    free+64 < G.Modulus() && End(free,count) < G.Modulus() &&
    Round32(End(free,count)) < G.Modulus()
  }
  function Header(mem: seq<Byte>, free: Word, count: Word): seq<Byte>
    requires End(free,count) < G.Modulus()
  { Store(Store(mem,free,count),64,End(free,count)) }
  lemma Offsets(free: Word, count: Word)
    requires End(free,count) < G.Modulus()
    ensures (32*(count as nat))%G.Modulus() == 32*count
    ensures (32+32*(count as nat))%G.Modulus() == 32+32*count
    ensures ((free as nat)+32+32*(count as nat))%G.Modulus() == End(free,count)
  {}
  lemma Images(mem: seq<Byte>, free: Word, count: Word, ret: Word, args: Word, prefix: seq<Word>)
    requires End(free,count) < G.Modulus()
    ensures P.Memory2(ret,args,0,0,0,count,0,free,prefix,mem) == Header(mem,free,count)
    ensures Z.Memory2(ret,args,0,0,0,count,0,free,prefix,mem) == Header(mem,free,count)
  {
    Offsets(free,count);
    assert P.Memory1(ret,args,0,0,0,count,0,free,prefix,mem) == Store(mem,free,count);
    assert Z.Memory1(ret,args,0,0,0,count,0,free,prefix,mem) == Store(mem,free,count);
  }
  lemma HeaderObject(mem: seq<Byte>, free: Word, count: Word)
    requires Space(mem,free,count)
    ensures I.Heap(Header(mem,free,count),free,count)
    ensures I.Done(Header(mem,free,count),free,0)
  {
    R.StoredWord(mem,free,count);
    var first := Store(mem,free,count);
    R.StoredWord(first,64,End(free,count));
    R.StoredFrame(first,64,End(free,count),free);
    assert Round32(free+32) <= Round32(End(free,count));
  }
  function Destinations(ret: Word): set<nat> {
    P.Destinations(ret)+Z.Destinations(ret)+H.Destinations(ret)+F.Destinations(ret)+L.Destinations(ret)
  }
  ghost method Run(code: seq<Byte>, ret: Word, args: Word, count: Word,
                   free: Word, prefix: seq<Word>, initial: seq<Byte>, value: Word,
                   data: seq<Byte>) returns (state: State, trace: seq<State>, mem: seq<Byte>)
    requires P.Matches(code) && Z.Matches(code) && H.Matches(code) && F.Matches(code) && L.Matches(code)
    requires Space(initial,free,count) && count <= 0xffffffffffffffff && Load(initial,64) == free && |prefix| <= 980
    ensures state == Running(2461,prefix+[ret,args,count,free,0],mem)
    ensures I.Heap(mem,free,count) && I.Done(mem,free,count)
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == Running(2379,prefix+[ret,args,count],initial) && trace[|trace|-1] == state
  {
    HeaderObject(initial,free,count);
    Images(initial,free,count,ret,args,prefix);
    mem := Header(initial,free,count);
    if count == 0 {
      state,trace := Z.Run(code,ret,args,0,0,0,count,0,free,prefix,initial,value,data);
      E.WidenTrace(code,Z.Destinations(ret),Destinations(ret),value,data,trace);
    } else {
      state,trace := P.Run(code,ret,args,0,0,0,count,0,free,prefix,initial,value,data);
      E.WidenTrace(code,P.Destinations(ret),Destinations(ret),value,data,trace);
      var part: seq<State>;
      state,part,mem := I.Run(code,ret,args,count,free,prefix,mem,value,data);
      E.WidenTrace(code,F.Destinations(ret)+L.Destinations(ret),Destinations(ret),value,data,part);
      E.Join(code,Destinations(ret),value,data,trace,part);
      trace := trace+part[1..];
      state,part := H.Run(code,ret,args,0,0,I.Slot(free,count),count,0,free,prefix,mem,value,data);
      E.WidenTrace(code,H.Destinations(ret),Destinations(ret),value,data,part);
      E.Join(code,Destinations(ret),value,data,trace,part);
      trace := trace+part[1..];
    }
  }
}
