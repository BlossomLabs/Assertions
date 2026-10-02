// SPDX-License-Identifier: MIT
// Current reached graph and original-input/memory frames for both uniqueness modes.
include "../segments/Start.generated.dfy"
include "../segments/ReadPrepare.generated.dfy"
include "../segments/AfterPosition.generated.dfy"
include "../segments/AfterOtherPosition.generated.dfy"
include "../segments/AfterEnd.generated.dfy"
include "../segments/AfterSlice.generated.dfy"
include "../segments/OrderedPrepare.generated.dfy"
include "../segments/OrderedEmpty.generated.dfy"
include "../segments/OrderedEqual.generated.dfy"
include "../segments/OrderedDifferent.generated.dfy"
include "../segments/UnorderedStart.generated.dfy"
include "../segments/UnorderedRead.generated.dfy"
include "../segments/UnorderedHit.generated.dfy"
include "../segments/UnorderedMiss.generated.dfy"
include "../segments/UnorderedDone.generated.dfy"
include "../segments/StorePrepare.generated.dfy"
include "../segments/StoreTail.generated.dfy"
include "../segments/Skip.generated.dfy"
include "../segments/Exit.generated.dfy"
include "../kernels/Div32.generated.dfy"
include "../kernels/Mul32.generated.dfy"
include "../kernels/Add.generated.dfy"
include "../kernels/Slice.generated.dfy"
include "../kernels/Read32.generated.dfy"
include "../kernels/Sub1.generated.dfy"
include "../kernels/Inc1.generated.dfy"
include "../word-at/Connection.dfy"
include "../Selection.dfy"
module BytecodeUniqueEngineFrames {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import R = BytecodeWordUniqueMemory
  import P = BytecodeWordUniqueSelection
  import W = BytecodeUniqueOriginalWordRead
  import WH = BytecodeUniqueMemoryHelperWordAt
  import ST = BytecodeUniqueSegmentStart
  import RP = BytecodeUniqueSegmentReadPrepare
  import AP = BytecodeUniqueSegmentAfterPosition
  import AO = BytecodeUniqueSegmentAfterOtherPosition
  import AE = BytecodeUniqueSegmentAfterEnd
  import AS = BytecodeUniqueSegmentAfterSlice
  import OP = BytecodeUniqueSegmentOrderedPrepare
  import OE = BytecodeUniqueSegmentOrderedEmpty
  import EQ = BytecodeUniqueSegmentOrderedEqual
  import NE = BytecodeUniqueSegmentOrderedDifferent
  import US = BytecodeUniqueSegmentUnorderedStart
  import UR = BytecodeUniqueSegmentUnorderedRead
  import UH = BytecodeUniqueSegmentUnorderedHit
  import UM = BytecodeUniqueSegmentUnorderedMiss
  import UD = BytecodeUniqueSegmentUnorderedDone
  import SP = BytecodeUniqueSegmentStorePrepare
  import TS = BytecodeUniqueSegmentStoreTail
  import SK = BytecodeUniqueSegmentSkip
  import EX = BytecodeUniqueSegmentExit
  import HD = BytecodeUniqueHelperDiv32
  import HP = BytecodeUniqueHelperMul32
  import HA = BytecodeUniqueHelperAdd
  import HS = BytecodeUniqueHelperSlice
  import HR = BytecodeUniqueHelperRead32
  import HB = BytecodeUniqueHelperSub1
  import HI = BytecodeUniqueHelperInc1
  predicate Matches(code: seq<Byte>) { ST.Matches(code) && RP.Matches(code) && AP.Matches(code) && AO.Matches(code) && AE.Matches(code) && AS.Matches(code) && OP.Matches(code) && OE.Matches(code) && EQ.Matches(code) && NE.Matches(code) && US.Matches(code) && UR.Matches(code) && UH.Matches(code) && UM.Matches(code) && UD.Matches(code) && SP.Matches(code) && TS.Matches(code) && SK.Matches(code) && EX.Matches(code) && HD.Matches(code) && HP.Matches(code) && HA.Matches(code) && HS.Matches(code) && HR.Matches(code) && HB.Matches(code) && HI.Matches(code) && WH.Matches(code) }
  function Destinations(): set<nat> { ST.Destinations()+RP.Destinations()+AP.Destinations()+AO.Destinations()+AE.Destinations()+AS.Destinations()+OP.Destinations()+OE.Destinations()+EQ.Destinations()+NE.Destinations()+US.Destinations()+UR.Destinations()+UH.Destinations()+UM.Destinations()+UD.Destinations()+SP.Destinations()+TS.Destinations()+SK.Destinations()+EX.Destinations()+HD.Destinations()+HP.Destinations()+HA.Destinations()+HS.Destinations()+HR.Destinations()+HB.Destinations()+HI.Destinations()+WH.Destinations() }
  predicate Fits(data: seq<Byte>, offset: Word, length: Word, ordered: Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data| && length%32 == 0 && ordered <= 1
  }
  function Values(data: seq<Byte>, offset: Word, length: Word): seq<Word>
    requires Fits(data,offset,length,0)
  { seq(length/32,i requires 0 <= i < length/32 => R.Source(length/32,i,offset,data)) }
  function Frame(offset: Word, length: Word, ordered: Word, kept: Word, index: Word): seq<Word>
  { [3045624246,518,offset,length,ordered,128,kept,index] }
  lemma Bounds(data: seq<Byte>, offset: Word, length: Word, ordered: Word,
               ids: seq<nat>, index: Word)
    requires Fits(data,offset,length,ordered) && index <= length/32 && |ids| <= index
    requires P.Bounds(Values(data,offset,length),ids)
    ensures R.Admitted(length/32,ids,offset,data,length/32)
    ensures |ids| <= index <= length/32 < 0x800000000000000
    ensures length/32*32 == length
  { G.WordPower(); }
  lemma SelectedFrame(data: seq<Byte>, offset: Word, length: Word, ordered: Word, index: Word)
    requires Fits(data,offset,length,ordered) && index <= length/32
    ensures P.Bounds(Values(data,offset,length),P.Selected(Values(data,offset,length),ordered == 1,index))
    ensures |P.Selected(Values(data,offset,length),ordered == 1,index)| <= index
    ensures R.Admitted(length/32,P.Selected(Values(data,offset,length),ordered == 1,index),offset,data,length/32)
  {
    P.SelectedBounds(Values(data,offset,length),ordered == 1,index);
    Bounds(data,offset,length,ordered,P.Selected(Values(data,offset,length),ordered == 1,index),index);
  }
  lemma Source(data: seq<Byte>, offset: Word, length: Word, index: Word)
    requires Fits(data,offset,length,0) && index < length/32
    ensures Values(data,offset,length)[index] == DataWord(data,offset+index*32)
    ensures RP.Position(index) == index*32 && AO.Position(index) == index*32
    ensures AE.Position(index) == index*32 && AE.NextPosition(index) == index*32+32
    ensures AS.WordOffset(offset,index) == offset+index*32
    ensures AE.NextPosition(index) <= length
  { G.WordPower(); }
  lemma Load(data: seq<Byte>, offset: Word, length: Word, ids: seq<nat>, index: Word, j: Word)
    requires Fits(data,offset,length,0) && index < length/32 && |ids| <= index
    requires P.Bounds(Values(data,offset,length),ids) && j < |ids|
    ensures UR.MemoryAdmitted(R.Heap(length/32,ids,offset,data,length/32),j,Values(data,offset,length)[ids[j]])
    ensures SLoad(R.Heap(length/32,ids,offset,data,length/32),160+j*32) == Values(data,offset,length)[ids[j]]
  {
    Bounds(data,offset,length,0,ids,index);
    R.WordAt(length/32,ids,offset,data,length/32,j);
    assert Round32(R.Extent(length/32)) == R.Extent(length/32);
    G.WordPower();
  }
  function SLoad(mem: seq<Byte>, at: Word): Word { S.Load(mem,at) }
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, trace: seq<State>, part: seq<State>, small: set<nat>) returns (combined: seq<State>)
    requires E.Trace(code,Destinations(),value,data,trace) && E.Trace(code,small,value,data,part)
    requires small <= Destinations() && trace[|trace|-1] == part[0]
    ensures E.Trace(code,Destinations(),value,data,combined)
    ensures combined[0] == trace[0] && combined[|combined|-1] == part[|part|-1]
  {
    E.WidenTrace(code,small,Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    combined := trace+part[1..];
  }
}
