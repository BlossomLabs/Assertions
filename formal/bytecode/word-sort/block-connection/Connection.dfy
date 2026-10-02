// SPDX-License-Identifier: MIT
// Actual min-range preparation and block progress, including all reached checked helpers.
include "../segments/BlockPrepare.generated.dfy"
include "../segments/MiddleClamp.generated.dfy"
include "../segments/MiddleRecompute.generated.dfy"
include "../segments/MiddleComputed.generated.dfy"
include "../segments/EndPrepare.generated.dfy"
include "../segments/EndAfterMul.generated.dfy"
include "../segments/EndClamp.generated.dfy"
include "../segments/EndRecompute.generated.dfy"
include "../segments/EndSecondMul.generated.dfy"
include "../segments/RangeStart.generated.dfy"
include "../segments/InnerExit.generated.dfy"
include "../segments/BlockAfterMul.generated.dfy"
include "../segments/BlockAfterAdd.generated.dfy"
include "../kernels/Add.generated.dfy"
include "../kernels/Mul2.generated.dfy"
module BytecodeSortBlockConnection {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import A = BytecodeSortHelperAdd
  import K = BytecodeSortHelperMul2
  import B = BytecodeSortSegmentBlockPrepare
  import MC = BytecodeSortSegmentMiddleClamp
  import MR = BytecodeSortSegmentMiddleRecompute
  import MP = BytecodeSortSegmentMiddleComputed
  import EP = BytecodeSortSegmentEndPrepare
  import EA = BytecodeSortSegmentEndAfterMul
  import EC = BytecodeSortSegmentEndClamp
  import ER = BytecodeSortSegmentEndRecompute
  import EM = BytecodeSortSegmentEndSecondMul
  import R = BytecodeSortSegmentRangeStart
  import IX = BytecodeSortSegmentInnerExit
  import BM = BytecodeSortSegmentBlockAfterMul
  import BA = BytecodeSortSegmentBlockAfterAdd
  predicate Matches(code: seq<Byte>) { B.Matches(code) && MC.Matches(code) && MR.Matches(code) && MP.Matches(code) && EP.Matches(code) && EA.Matches(code) && EC.Matches(code) && ER.Matches(code) && EM.Matches(code) && R.Matches(code) && IX.Matches(code) && BM.Matches(code) && BA.Matches(code) && A.Matches(code) && K.Matches(code) }
  function Destinations(): set<nat> { B.Destinations()+MC.Destinations()+MR.Destinations()+MP.Destinations()+EP.Destinations()+EA.Destinations()+EC.Destinations()+ER.Destinations()+EM.Destinations()+R.Destinations()+IX.Destinations()+BM.Destinations()+BA.Destinations()+A.Destinations()+K.Destinations() }
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, left: seq<State>, right: seq<State>, small: set<nat>) returns (trace: seq<State>)
    requires E.Trace(code,Destinations(),value,data,left) && E.Trace(code,small,value,data,right)
    requires small <= Destinations() && left[|left|-1] == right[0]
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace == left+right[1..] && trace[0] == left[0] && trace[|trace|-1] == right[|right|-1]
  { E.WidenTrace(code,small,Destinations(),value,data,right); E.Join(code,Destinations(),value,data,left,right); trace := left+right[1..]; }
  predicate Fits(n: Word, offset: Word, out: Word, scratch: Word, width: Word, start: Word) {
    n < 0x800000000000000 && offset < 0x10000000000000000 && out < 0x20000000000000000 && scratch < 0x20000000000000000 && 0 < width < n && start < n
  }
  ghost method Prepare(code: seq<Byte>, n: Word, offset: Word, out: Word, scratch: Word, width: Word, start: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    returns (state: State, trace: seq<State>, middle: Word, end: Word)
    requires Matches(code) && Fits(n,offset,out,scratch,width,start)
    ensures middle == (if start+width < n then start+width else n) && end == (if start+2*width < n then start+2*width else n)
    ensures start <= middle <= end <= n
    ensures state == Running(3726,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,start,middle,start],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3622,[785862473,518,offset,n*32,out,n,scratch,width,start],mem) && trace[|trace|-1] == state
  {
    var frame: seq<Word> := [785862473,518,offset,n*32,out,n,scratch,width,start];
    state,trace := B.Run(code,offset,n,out,scratch,width,start,0,0,0,0,0,0,0,0,mem,value,data);
    E.WidenTrace(code,B.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>;
    assert state == Running(23604,frame+[0,n,3642,width,start],mem);
    state,part := A.Run(code,frame+[0,n],width,start,3642,mem,value,data);
    trace := Append(code,value,data,trace,part,A.Destinations());
    if start+width >= n {
      middle := n;
      state,part := MC.Run(code,offset,n,out,scratch,width,start,0,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,MC.Destinations());
    } else {
      middle := start+width;
      state,part := MR.Run(code,offset,n,out,scratch,width,start,0,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,MR.Destinations());
      state,part := A.Run(code,frame+[0],width,start,3663,mem,value,data);
      trace := Append(code,value,data,trace,part,A.Destinations());
      state,part := MP.Run(code,offset,n,out,scratch,width,start,0,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,MP.Destinations());
    }
    state,part := EP.Run(code,offset,n,out,scratch,width,start,middle,0,0,0,0,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,EP.Destinations());
    state,part := K.Run(code,frame+[middle,0,n],width,3678,mem,value,data);
    trace := Append(code,value,data,trace,part,K.Destinations());
    state,part := EA.Run(code,offset,n,out,scratch,width,start,middle,0,0,0,0,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,EA.Destinations());
    state,part := A.Run(code,frame+[middle,0,n],2*width,start,3688,mem,value,data);
    trace := Append(code,value,data,trace,part,A.Destinations());
    if start+2*width >= n {
      end := n;
      state,part := EC.Run(code,offset,n,out,scratch,width,start,middle,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,EC.Destinations());
    } else {
      end := start+2*width;
      state,part := ER.Run(code,offset,n,out,scratch,width,start,middle,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,ER.Destinations());
      state,part := K.Run(code,frame+[middle,0],width,3710,mem,value,data);
      trace := Append(code,value,data,trace,part,K.Destinations());
      state,part := EM.Run(code,offset,n,out,scratch,width,start,middle,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,EM.Destinations());
      state,part := A.Run(code,frame+[middle,0],2*width,start,3720,mem,value,data);
      trace := Append(code,value,data,trace,part,A.Destinations());
    }
    state,part := R.Run(code,offset,n,out,scratch,width,start,middle,end,0,0,0,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,R.Destinations());
  }
  ghost method Finish(code: seq<Byte>, n: Word, offset: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    returns (state: State, trace: seq<State>)
    requires Matches(code) && Fits(n,offset,out,scratch,width,start) && start <= middle <= end <= n
    ensures start+2*width < 3*n
    ensures state == Running(3622,[785862473,518,offset,n*32,out,n,scratch,width,start+2*width],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3726,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,middle,end,end],mem) && trace[|trace|-1] == state
  {
    var frame: seq<Word> := [785862473,518,offset,n*32,out,n,scratch,width,start];
    state,trace := IX.Run(code,offset,n,out,scratch,width,start,middle,end,middle,end,end,0,0,0,mem,value,data);
    E.WidenTrace(code,IX.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>;
    state,part := K.Run(code,frame,width,3887,mem,value,data);
    trace := Append(code,value,data,trace,part,K.Destinations());
    state,part := BM.Run(code,offset,n,out,scratch,width,start,0,0,0,0,0,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,BM.Destinations());
    state,part := A.Run(code,frame,2*width,start,3897,mem,value,data);
    trace := Append(code,value,data,trace,part,A.Destinations());
    state,part := BA.Run(code,offset,n,out,scratch,width,start,0,0,0,0,0,0,0,0,mem,value,data);
    trace := Append(code,value,data,trace,part,BA.Destinations());
  }
}
