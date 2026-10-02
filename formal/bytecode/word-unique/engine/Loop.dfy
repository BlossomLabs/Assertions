// SPDX-License-Identifier: MIT
// Actual arbitrary finite uniqueness loop and final output-header shrink.
include "Decision.dfy"
module BytecodeUniqueLoopConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import D = BytecodeUniqueEngineFrames
  import Q = BytecodeUniqueDecisionConnection
  import R = BytecodeWordUniqueMemory
  import P = BytecodeWordUniqueSelection
  import ST = BytecodeUniqueSegmentStart
  import RP = BytecodeUniqueSegmentReadPrepare
  import AP = BytecodeUniqueSegmentAfterPosition
  import AO = BytecodeUniqueSegmentAfterOtherPosition
  import AE = BytecodeUniqueSegmentAfterEnd
  import AS = BytecodeUniqueSegmentAfterSlice
  import SP = BytecodeUniqueSegmentStorePrepare
  import TS = BytecodeUniqueSegmentStoreTail
  import SK = BytecodeUniqueSegmentSkip
  import EX = BytecodeUniqueSegmentExit
  import HD = BytecodeUniqueHelperDiv32
  import HP = BytecodeUniqueHelperMul32
  import HA = BytecodeUniqueHelperAdd
  import HS = BytecodeUniqueHelperSlice
  import HR = BytecodeUniqueHelperRead32
  import HI = BytecodeUniqueHelperInc1
  ghost method Read(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word,
                    ordered: Word, ids: seq<nat>, index: Word, value: Word)
    returns (state: State, trace: seq<State>)
    requires D.Matches(code) && D.Fits(data,offset,length,ordered) && index < length/32 && |ids| <= index
    requires P.Bounds(D.Values(data,offset,length),ids)
    ensures state == Running(6801,D.Frame(offset,length,ordered,|ids|,index)+[0,D.Values(data,offset,length)[index]],R.Heap(length/32,ids,offset,data,length/32))
    ensures E.Trace(code,D.Destinations(),value,data,trace)
    ensures trace[0] == Running(6724,D.Frame(offset,length,ordered,|ids|,index),R.Heap(length/32,ids,offset,data,length/32)) && trace[|trace|-1] == state
  {
    D.Bounds(data,offset,length,ordered,ids,index); D.Source(data,offset,length,index);
    var mem := R.Heap(length/32,ids,offset,data,length/32);
    var kept: Word := |ids|;
    var frame := D.Frame(offset,length,ordered,kept,index);
    var part: seq<State>;
    state,trace := ST.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    E.WidenTrace(code,ST.Destinations(),D.Destinations(),value,data,trace);
    state,part := HD.Run(code,frame,length,mem,value,data);
    trace := D.Append(code,value,data,trace,part,HD.Destinations());
    state,part := RP.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,RP.Destinations());
    state,part := HP.Run(code,frame+[0,offset,length],index,6756,mem,value,data);
    trace := D.Append(code,value,data,trace,part,HP.Destinations());
    state,part := AP.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,AP.Destinations());
    state,part := HP.Run(code,frame+[0,offset,index*32,length],index,6768,mem,value,data);
    trace := D.Append(code,value,data,trace,part,HP.Destinations());
    state,part := AO.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,AO.Destinations());
    state,part := HA.Run(code,frame+[0,offset,index*32,length],index*32,32,mem,value,data);
    trace := D.Append(code,value,data,trace,part,HA.Destinations());
    state,part := AE.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,AE.Destinations());
    state,part := HS.Run(code,frame+[0],offset,length,index*32,index*32+32,mem,value,data);
    trace := D.Append(code,value,data,trace,part,HS.Destinations());
    state,part := AS.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,AS.Destinations());
    state,part := HR.Run(code,frame+[0],offset+index*32,mem,value,data);
    trace := D.Append(code,value,data,trace,part,HR.Destinations());
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word,
                   ordered: Word, value: Word)
    returns (state: State, trace: seq<State>)
    requires D.Matches(code) && D.Fits(data,offset,length,ordered)
    ensures R.Admitted(length/32,P.Selected(D.Values(data,offset,length),ordered == 1,length/32),offset,data,|P.Selected(D.Values(data,offset,length),ordered == 1,length/32)|)
    ensures state == Running(518,[3045624246,128],R.Heap(length/32,P.Selected(D.Values(data,offset,length),ordered == 1,length/32),offset,data,|P.Selected(D.Values(data,offset,length),ordered == 1,length/32)|))
    ensures state.memory[160..160+|P.Selected(D.Values(data,offset,length),ordered == 1,length/32)|*32] == R.Payload(length/32,P.Selected(D.Values(data,offset,length),ordered == 1,length/32),offset,data)
    ensures E.Trace(code,D.Destinations(),value,data,trace)
    ensures trace[0] == Running(6724,D.Frame(offset,length,ordered,0,0),R.Heap(length/32,[],offset,data,length/32)) && trace[|trace|-1] == state
  {
    G.WordPower();
    var count: Word := length/32;
    var index: Word := 0;
    var values := D.Values(data,offset,length);
    var ids: seq<nat> := [];
    D.SelectedFrame(data,offset,length,ordered,index);
    var mem := R.Heap(count,ids,offset,data,count);
    state := Running(6724,D.Frame(offset,length,ordered,0,0),mem);
    trace := [state];
    while index < count
      invariant count == length/32 && count*32 == length && index <= count < 0x800000000000000
      invariant ids == P.Selected(values,ordered == 1,index) && |ids| <= index
      invariant P.Bounds(values,ids) && R.Admitted(count,ids,offset,data,count)
      invariant mem == R.Heap(count,ids,offset,data,count)
      invariant state == Running(6724,D.Frame(offset,length,ordered,|ids|,index),mem)
      invariant E.Trace(code,D.Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(6724,D.Frame(offset,length,ordered,0,0),R.Heap(count,[],offset,data,count))
      decreases count-index
    {
      var kept: Word := |ids|;
      var frame := D.Frame(offset,length,ordered,kept,index);
      var word := values[index];
      var part: seq<State>;
      state,part := Read(code,data,offset,length,ordered,ids,index,value);
      trace := D.Append(code,value,data,trace,part,D.Destinations());
      var seen: bool;
      state,part,seen := Q.Run(code,data,offset,length,ordered,ids,index,value);
      trace := D.Append(code,value,data,trace,part,D.Destinations());
      P.Decision(values,ordered == 1,index);
      if seen {
        state,part := SK.Run(code,offset,length,ordered,kept,index,0,word,0,1,mem,value,data);
        trace := D.Append(code,value,data,trace,part,SK.Destinations());
      } else {
        state,part := SP.Run(code,offset,length,ordered,kept,index,0,word,0,0,mem,value,data);
        trace := D.Append(code,value,data,trace,part,SP.Destinations());
        state,part := HI.Run(code,frame+[word,0,6925,128,kept],kept,mem,value,data);
        trace := D.Append(code,value,data,trace,part,HI.Destinations());
        R.Advance(count,ids,offset,data,index);
        assert TS.Target(kept) == 160+kept*32;
        state,part := TS.Run(code,offset,length,ordered,kept,index,0,word,0,0,mem,value,data);
        trace := D.Append(code,value,data,trace,part,TS.Destinations());
        ids := ids+[index];
        mem := R.Heap(count,ids,offset,data,count);
      }
      index := index+1;
      D.SelectedFrame(data,offset,length,ordered,index);
    }
    var kept: Word := |ids|;
    var frame := D.Frame(offset,length,ordered,kept,index);
    var part: seq<State>;
    state,part := ST.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,ST.Destinations());
    state,part := HD.Run(code,frame,length,mem,value,data);
    trace := D.Append(code,value,data,trace,part,HD.Destinations());
    R.Shrink(count,ids,offset,data);
    state,part := EX.Run(code,offset,length,ordered,kept,index,0,0,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,EX.Destinations());
    R.OriginalBytes(count,ids,offset,data,kept);
  }
}
