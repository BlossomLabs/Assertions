// SPDX-License-Identifier: MIT
// Finite exact successful fold memory and truthful receipt schedule; no independent range count cap.
include "../successful-iteration-repair-v2/Connection.dfy"
include "../iteration-frame/Memory.dfy"
module BytecodeFoldLoopModelV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import I = BytecodeFoldSuccessfulIterationV2
  import D = BytecodeFoldDomainConnectionV3
  import F = BytecodeFoldIterationFrame
  import M = BytecodeFoldStampMemoryV2
  import P = BytecodeApplyCallbackCopyMemory
  import C = BytecodeFoldCallbackMemoryV2
  import H = BytecodeApplyCallbackSuccessMemory
  import R = BytecodeFoldResultMemoryV3
  import A = BytecodeApplyAddressMask
  datatype Configuration = Configuration(sourceOffset: Word,sourceLength: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,returnWord: Word,callPtr: Word,domain: Word,total: Word,accOffset: Word,exit: Word,target: Word)
  datatype Receipt = Receipt(returned: seq<Byte>,gasBefore: Word,requestedGas: Word)
  datatype Outcome = Outcome(memory: seq<Byte>,index: Word,used: nat,stopped: bool,word: Word)
  predicate Source(data: seq<Byte>,c: Configuration) {
    c.domain < 3 &&
    (c.domain == 0 || (c.sourceLength < 0x10000000000000000 && |data| < 0x10000000000000000 && (c.sourceOffset as nat)+c.sourceLength <= |data| &&
                       (if c.domain == 1 then c.total == c.sourceLength else c.sourceLength%32 == 0 && c.total == (c.sourceLength as nat)/32)))
  }
  predicate Ready(data: seq<Byte>,mem: seq<Byte>,c: Configuration) {
    Source(data,c) && R.Fits(mem) && c.exit <= 2 && c.target < A.Bound() && 320 <= c.callPtr &&
    M.Fits(mem,c.callPtr,c.templateLength,c.accOffset,c.arrayOffset,c.count,data) &&
    P.Fits(mem,c.callPtr,Load(mem,64),c.templateLength) && (Load(mem,64) as nat)+96 < G.Modulus() &&
    Load(mem,c.callPtr) == c.templateLength && Load(mem,128) == c.domain && Load(mem,160) == c.total &&
    Load(mem,192) == c.target && Load(mem,224) == c.accOffset && Load(mem,288) == c.exit
  }
  predicate StepReady(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word,r: Receipt) {
    Ready(data,mem,c) && index < c.total && |r.returned| == 32 &&
    D.Admitted(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength) &&
    F.Fits(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,c.arrayOffset,c.count,data,r.returned) &&
    R.Fits(F.Complete(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength),r.returned))
  }
  function Next(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word,r: Receipt): seq<Byte>
    requires StepReady(data,mem,c,index,r)
  { F.Next(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength),r.returned) }
  function Payload(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word,r: Receipt): seq<Byte>
    requires StepReady(data,mem,c,index,r)
  { F.Stamped(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength),r.returned)[c.callPtr+32..c.callPtr+32+c.templateLength] }
  lemma Reached(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word)
    requires Ready(data,mem,c) && index < c.total
    ensures D.Admitted(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength)
  {}
  lemma Readmission(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word,r: Receipt)
    requires StepReady(data,mem,c,index,r)
    ensures Ready(data,Next(data,mem,c,index,r),c)
    ensures Load(Next(data,mem,c,index,r),256) == H.Result(r.returned)
    ensures Load(Next(data,mem,c,index,r),64) == Load(mem,64)+64
  {
    hide F.Next(); hide F.Complete(); hide F.Stamped(); hide M.Stamped();
    var element := D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength);
    F.Fields(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned);
    F.Readmission(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned,r.returned);
    F.Header(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned);
    F.WordFrame(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned,128);
    assert Load(Next(data,mem,c,index,r),128) == Load(mem,128);
    F.WordFrame(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned,160);
    assert Load(Next(data,mem,c,index,r),160) == Load(mem,160);
    F.WordFrame(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned,192);
    assert Load(Next(data,mem,c,index,r),192) == Load(mem,192);
    F.WordFrame(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned,224);
    assert Load(Next(data,mem,c,index,r),224) == Load(mem,224);
    F.WordFrame(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned,288);
    assert Load(Next(data,mem,c,index,r),288) == Load(mem,288);
  }
  predicate Resources(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word,receipts: seq<Receipt>)
    decreases |receipts|
  {
    Ready(data,mem,c) && index <= c.total &&
    (if index == c.total then true else
     |receipts| > 0 && StepReady(data,mem,c,index,receipts[0]) &&
     (I.Stop(c.exit,H.Result(receipts[0].returned)) || Resources(data,Next(data,mem,c,index,receipts[0]),c,index+1,receipts[1..])))
  }
  predicate Truthful(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word,receipts: seq<Receipt>,self: Word,cursor: nat,observations: seq<X.Observation>)
    requires Resources(data,mem,c,index,receipts)
    decreases |receipts|
  {
    if index == c.total then true else
    cursor+2 < |observations| && observations[cursor] == X.Gas(receipts[0].gasBefore) && observations[cursor+1] == X.Gas(receipts[0].requestedGas) &&
    observations[cursor+2] == X.StaticCall(self,receipts[0].requestedGas,c.target,Payload(data,mem,c,index,receipts[0]),true,receipts[0].returned) &&
    (I.Stop(c.exit,H.Result(receipts[0].returned)) || Truthful(data,Next(data,mem,c,index,receipts[0]),c,index+1,receipts[1..],self,cursor+3,observations))
  }
  function Result(data: seq<Byte>,mem: seq<Byte>,c: Configuration,index: Word,receipts: seq<Receipt>): Outcome
    requires Resources(data,mem,c,index,receipts)
    ensures Result(data,mem,c,index,receipts).used <= |receipts|
    ensures index <= Result(data,mem,c,index,receipts).index <= c.total
    ensures if Result(data,mem,c,index,receipts).stopped then Result(data,mem,c,index,receipts).index < c.total else Result(data,mem,c,index,receipts).index == c.total
    ensures R.Fits(Result(data,mem,c,index,receipts).memory)
    ensures Load(Result(data,mem,c,index,receipts).memory,256) == Result(data,mem,c,index,receipts).word
    ensures if Result(data,mem,c,index,receipts).used == 0 then Result(data,mem,c,index,receipts).word == Load(mem,256) else |receipts[Result(data,mem,c,index,receipts).used-1].returned| == 32 && Result(data,mem,c,index,receipts).word == H.Result(receipts[Result(data,mem,c,index,receipts).used-1].returned)
    decreases |receipts|
  {
    if index == c.total then Outcome(mem,index,0,false,Load(mem,256)) else
    Readmission(data,mem,c,index,receipts[0]);
    var next := Next(data,mem,c,index,receipts[0]);
    var word := H.Result(receipts[0].returned);
    if I.Stop(c.exit,word) then Outcome(next,index,1,true,word) else
    var tail := Result(data,next,c,index+1,receipts[1..]);
    if tail.used == 0 then
      assert tail.word == word;
      Outcome(tail.memory,tail.index,1,tail.stopped,tail.word)
    else
      assert receipts[1..][tail.used-1] == receipts[tail.used];
      Outcome(tail.memory,tail.index,tail.used+1,tail.stopped,tail.word)
  }
  function LastReturn(receipts: seq<Receipt>,used: nat,oldReturn: seq<Byte>): seq<Byte>
    requires used <= |receipts|
  { if used == 0 then oldReturn else receipts[used-1].returned }
}
