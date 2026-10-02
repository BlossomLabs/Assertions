// SPDX-License-Identifier: MIT
// Actual ordered last-word and unordered finite-scan decision traces.
include "Frames.dfy"
module BytecodeUniqueDecisionConnection {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import D = BytecodeUniqueEngineFrames
  import R = BytecodeWordUniqueMemory
  import P = BytecodeWordUniqueSelection
  import W = BytecodeUniqueOriginalWordRead
  import WH = BytecodeUniqueMemoryHelperWordAt
  import OP = BytecodeUniqueSegmentOrderedPrepare
  import OE = BytecodeUniqueSegmentOrderedEmpty
  import EQ = BytecodeUniqueSegmentOrderedEqual
  import NE = BytecodeUniqueSegmentOrderedDifferent
  import US = BytecodeUniqueSegmentUnorderedStart
  import UR = BytecodeUniqueSegmentUnorderedRead
  import UH = BytecodeUniqueSegmentUnorderedHit
  import UM = BytecodeUniqueSegmentUnorderedMiss
  import UD = BytecodeUniqueSegmentUnorderedDone
  import HB = BytecodeUniqueHelperSub1
  ghost method Unordered(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word,
                         ids: seq<nat>, index: Word, value: Word)
    returns (state: State, trace: seq<State>, seen: bool)
    requires D.Matches(code) && D.Fits(data,offset,length,0) && index < length/32 && |ids| <= index
    requires P.Bounds(D.Values(data,offset,length),ids)
    ensures seen <==> P.Seen(D.Values(data,offset,length),false,ids,index)
    ensures state == Running(6890,D.Frame(offset,length,0,|ids|,index)+[D.Values(data,offset,length)[index],if seen then 1 else 0],R.Heap(length/32,ids,offset,data,length/32))
    ensures E.Trace(code,D.Destinations(),value,data,trace)
    ensures trace[0] == Running(6847,D.Frame(offset,length,0,|ids|,index)+[D.Values(data,offset,length)[index],0,0],R.Heap(length/32,ids,offset,data,length/32)) && trace[|trace|-1] == state
  {
    D.Bounds(data,offset,length,0,ids,index);
    var mem := R.Heap(length/32,ids,offset,data,length/32);
    var kept: Word := |ids|;
    var word := D.Values(data,offset,length)[index];
    var frame := D.Frame(offset,length,0,kept,index);
    var j: Word := 0;
    seen := false;
    state := Running(6847,frame+[word,0,j],mem);
    trace := [state];
    while j < kept
      invariant j <= kept && kept == |ids| && !seen
      invariant forall k :: 0 <= k < j ==> D.Values(data,offset,length)[ids[k]] != word
      invariant state == Running(6847,frame+[word,0,j],mem)
      invariant E.Trace(code,D.Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(6847,frame+[word,0,0],mem)
      decreases kept-j
    {
      D.Load(data,offset,length,ids,index,j);
      var last := D.Values(data,offset,length)[ids[j]];
      var part: seq<State>;
      state,part := UR.Run(code,offset,length,0,kept,index,j,word,last,0,mem,value,data);
      trace := D.Append(code,value,data,trace,part,UR.Destinations());
      if last == word {
        state,part := UH.Run(code,offset,length,0,kept,index,j,word,last,0,mem,value,data);
        trace := D.Append(code,value,data,trace,part,UH.Destinations());
        seen := true;
        assert exists k :: 0 <= k < |ids| && D.Values(data,offset,length)[ids[k]] == word;
        return;
      }
      state,part := UM.Run(code,offset,length,0,kept,index,j,word,last,0,mem,value,data);
      trace := D.Append(code,value,data,trace,part,UM.Destinations());
      j := j+1;
    }
    var part: seq<State>;
    state,part := UD.Run(code,offset,length,0,kept,index,j,word,0,0,mem,value,data);
    trace := D.Append(code,value,data,trace,part,UD.Destinations());
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, offset: Word, length: Word,
                   ordered: Word, ids: seq<nat>, index: Word, value: Word)
    returns (state: State, trace: seq<State>, seen: bool)
    requires D.Matches(code) && D.Fits(data,offset,length,ordered) && index < length/32 && |ids| <= index
    requires P.Bounds(D.Values(data,offset,length),ids)
    ensures seen <==> P.Seen(D.Values(data,offset,length),ordered == 1,ids,index)
    ensures state == Running(6890,D.Frame(offset,length,ordered,|ids|,index)+[D.Values(data,offset,length)[index],if seen then 1 else 0],R.Heap(length/32,ids,offset,data,length/32))
    ensures E.Trace(code,D.Destinations(),value,data,trace)
    ensures trace[0] == Running(6801,D.Frame(offset,length,ordered,|ids|,index)+[0,D.Values(data,offset,length)[index]],R.Heap(length/32,ids,offset,data,length/32)) && trace[|trace|-1] == state
  {
    D.Bounds(data,offset,length,ordered,ids,index);
    var mem := R.Heap(length/32,ids,offset,data,length/32);
    var kept: Word := |ids|;
    var word := D.Values(data,offset,length)[index];
    var frame := D.Frame(offset,length,ordered,kept,index);
    state := Running(6801,frame+[0,word],mem);
    trace := [state];
    var part: seq<State>;
    if ordered == 1 {
      if kept == 0 {
        state,part := OE.Run(code,offset,length,ordered,kept,index,0,word,0,0,mem,value,data);
        E.WidenTrace(code,OE.Destinations(),D.Destinations(),value,data,part);
        trace := part; seen := false;
      } else {
        state,part := OP.Run(code,offset,length,ordered,kept,index,0,word,0,0,mem,value,data);
        E.WidenTrace(code,OP.Destinations(),D.Destinations(),value,data,part);
        trace := part;
        state,part := HB.Run(code,frame+[word,0,word,6836,128],kept,mem,value,data);
        trace := D.Append(code,value,data,trace,part,HB.Destinations());
        state,part := W.Run(code,length/32,ids,offset,data,kept-1,frame+[word,0,word],value);
        trace := D.Append(code,value,data,trace,part,WH.Destinations());
        var last := D.Values(data,offset,length)[ids[kept-1]];
        seen := last == word;
        if seen {
          state,part := EQ.Run(code,offset,length,ordered,kept,index,0,word,last,0,mem,value,data);
          trace := D.Append(code,value,data,trace,part,EQ.Destinations());
        } else {
          state,part := NE.Run(code,offset,length,ordered,kept,index,0,word,last,0,mem,value,data);
          trace := D.Append(code,value,data,trace,part,NE.Destinations());
        }
      }
    } else {
      state,part := US.Run(code,offset,length,0,kept,index,0,word,0,0,mem,value,data);
      E.WidenTrace(code,US.Destinations(),D.Destinations(),value,data,part);
      trace := part;
      state,part,seen := Unordered(code,data,offset,length,ids,index,value);
      trace := D.Append(code,value,data,trace,part,D.Destinations());
    }
  }
}
