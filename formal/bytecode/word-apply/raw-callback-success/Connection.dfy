// SPDX-License-Identifier: MIT
// Exact PC-zero first successful word callback, with actual raw admission and memory.
include "../raw-stamp/Connection.dfy"
include "../callback-invocation/Invoke.generated.dfy"
include "../callback-success-engine/Engine.dfy"
include "../raw-callback-memory/Memory.dfy"
include "Sequence.dfy"
module BytecodeApplyRawFirstSuccessfulCallback {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import T = BytecodeApplyRawFirstStamp
  import L = BytecodeApplyRawFirstElement
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import P = BytecodeApplyFirstElementPost
  import M = BytecodeApplyRawCallbackMemory
  import C = BytecodeApplyCallbackCopyMemory
  import V = BytecodeApplyCallbackInvoke
  import B = BytecodeApplySuccessfulCallEngine
  import S = BytecodeApplyCallbackSuccessMemory
  import Q = BytecodeApplyRawCallbackStackSequence
  predicate Matches(code: seq<Byte>) { T.Matches(code) && V.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+V.Destinations()+B.Destinations() }
  function Template(data: seq<Byte>): seq<Byte>
    requires I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures C.Fits(Template(data),O.Extent(I.SourceLength(data)/32),H.Free(O.Extent(I.SourceLength(data)/32),I.TemplateLength(data)),I.TemplateLength(data))
    ensures Load(Template(data),64) == H.Free(O.Extent(I.SourceLength(data)/32),I.TemplateLength(data))
    ensures Load(Template(data),O.Extent(I.SourceLength(data)/32)) == I.TemplateLength(data)
    ensures (H.Free(O.Extent(I.SourceLength(data)/32),I.TemplateLength(data)) as nat)+96 < G.Modulus()
  { M.Stamped(I.SourceLength(data)/32,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,P.Original(data)) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,codeSize: Word,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires X.Context(self) && 0 < codeSize && |returned| == 32
    requires cursor+3 < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    requires observations[cursor+1] == X.Gas(gasBefore) && observations[cursor+2] == X.Gas(requestedGas)
    requires observations[cursor+3] == X.StaticCall(self,requestedGas,I.Target(data),Template(data)[O.Extent(I.SourceLength(data)/32)+32..O.Extent(I.SourceLength(data)/32)+32+I.TemplateLength(data)],true,returned)
    ensures var n: Word := I.SourceLength(data)/32;
            S.Fits(C.Packed(Template(data),O.Extent(n),H.Free(O.Extent(n),I.TemplateLength(data)),I.TemplateLength(data)),H.Free(O.Extent(n),I.TemplateLength(data)))
    ensures var n: Word := I.SourceLength(data)/32;
            var free := H.Free(O.Extent(n),I.TemplateLength(data));
            frame == X.Frame(Running(12484,[if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,128,n,0,O.Extent(n),0,P.Original(data),0,S.Result(returned)],S.Complete(C.Packed(Template(data),O.Extent(n),free,I.TemplateLength(data)),free,returned)),returned,cursor+4)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 872 else 866)+93*(I.Count(data) as nat)
  {
    hide G.BitAnd();
    var n: Word := I.SourceLength(data)/32;
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var ptr: Word := O.Extent(n);
    var free: Word := H.Free(ptr,I.TemplateLength(data));
    var prefix := [selector,518]+R.Fields(data)+[96];
    var mem := Template(data);
    frame,trace := T.Run(code,data,filter,self,oldReturn,cursor,codeSize,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    var state: State; var states: seq<State>;
    state,states := V.Run(code,data,mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,128,n,0,ptr,0,P.Original(data),0);
    L.Lift(code,V.Destinations(),data,states,self,oldReturn,cursor+1,observations);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor+1));
    E.WidenTrace(code,V.Destinations(),Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var callPrefix := prefix+[5526]+R.Fields(data)+[mode,128,n,0,ptr,0,P.Original(data),0];
    frame,part := B.Run(code,data,mem,callPrefix,I.Target(data),ptr,0,free,I.TemplateLength(data),self,0,oldReturn,returned,cursor+1,observations,gasBefore,requestedGas);
    Q.Group([selector,518],R.Fields(data),[mode,128,n,0,ptr,0,P.Original(data),0],S.Result(returned));
    Q.Nine(mode,128,n,0,ptr,0,P.Original(data),0,S.Result(returned));
    assert callPrefix+[S.Result(returned)] == [selector,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[mode,128,n,0,ptr,0,P.Original(data),0,S.Result(returned)];
    E.WidenTrace(code,B.Destinations(),Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
  }
}
