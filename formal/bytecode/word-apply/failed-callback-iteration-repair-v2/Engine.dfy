// SPDX-License-Identifier: MIT
include "../wrong-size-iteration-repair-v9/Engine.dfy"
include "../callback-failed-connection-repair-v2/Connection.dfy"
module BytecodeApplyOrdinaryFailedCallbackIteration {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import O = BytecodeIotaOutput
  import A = BytecodeApplyAddressMask
  import M = BytecodeApplyRepeatedIterationMemory
  import R = BytecodeApplyElementRead
  import W = BytecodeApplyWrongSizeIterationEngine
  import C = BytecodeApplyOrdinaryFailedCallbackConnection
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import D = BytecodeApplyCallbackExhaustionEngine
  import P = BytecodeApplyCallbackCopyMemory
  import Q = BytecodeApplyCallbackSuccessScalar
  import H = BytecodeApplyCallbackFailedMemory
  import DM = BytecodeApplyDynamicBytesCopyMemory
  import CL = BytecodeApplyCallbackLengthScalar
  predicate Matches(code: seq<Byte>) { W.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { W.Destinations()+C.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,n: Word,kept: Word,index: Word,filter: bool,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,gasAfter: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && R.Admitted(data,sourceOffset,sourceLength,n,index) && kept <= index && n < 0x800000000000000
    requires M.Fits(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data)
    requires X.Context(self) && target < A.Bound() && |prefix| <= 981
    requires CM.Fits(M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32)),O.Extent(n),Load(mem,64),templateLength,returned)
    requires var stamped := M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32));
             var after := CM.Final(stamped,O.Extent(n),Load(mem,64),templateLength,returned); var receipt := CM.Receipt(Load(mem,64),returned);
                                                                                              !D.Refused(|returned|,Load(after,receipt+32),gasBefore,gasAfter)
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(filter)
    requires var stamped := M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32));
             Load(CM.Final(stamped,O.Extent(n),Load(mem,64),templateLength,returned),64)+templateLength+|returned|+512 < DM.Bound()
    requires cursor+3 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas) && observations[cursor+3] == X.Gas(gasAfter)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32))[O.Extent(n)+32..O.Extent(n)+32+templateLength],false,returned)
    ensures var stamped := M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32));
            frame == X.Frame(Reverted(H.Packet(CL.Operation(filter),index,target,stamped[O.Extent(n)+32..O.Extent(n)+32+templateLength],returned)),returned,cursor+4)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == W.Initial(mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,n,kept,index,filter,oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide CM.Final();hide P.Packed();hide M.Stamped();hide E.Trace();hide H.Packet();
    var ptr: Word := O.Extent(n);var free := Load(mem,64);var mode: Word := if filter then 1 else 0;
    var word := DataWord(data,sourceOffset+index*32);
    var fields := [returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index];
    frame,trace := W.BeforeCall(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,n,kept,index,filter,self,oldReturn,cursor,observations);
    var stamped := M.Stamped(mem,ptr,free,templateLength,arrayOffset,count,data,word);
    var callPrefix := prefix+fields+[word,0];
    Q.Append(prefix,fields,[word,0]);Q.Append(prefix,fields+[word,0],[12484,target,ptr,index,0,0]);
    Q.Append(fields,[word,0],[12484,target,ptr,index,0,0]);Q.Append(prefix,fields,[word,0,12484,target,ptr,index,0,0]);
    var before := frame;
    assert before.state.Running? && before.state.pc == 16908 && before.state.memory == stamped;
    assert before.state.stack == callPrefix+[12484,target,ptr,index,0,0];
    assert before == X.Frame(Running(16908,callPrefix+[12484,target,ptr,index,0,0],stamped),oldReturn,cursor);
    assert trace[|trace|-1] == before;
    var part: seq<X.Frame>;
    frame,part := C.Run(code,data,stamped,callPrefix,filter,target,ptr,index,free,templateLength,stamped[ptr+32..ptr+32+templateLength],self,0,oldReturn,returned,cursor,observations,gasBefore,requestedGas,gasAfter);
    E.WidenTrace(code,W.Destinations(),Destinations(),self,0,data,observations,trace);
    E.WidenTrace(code,C.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
  }
}
