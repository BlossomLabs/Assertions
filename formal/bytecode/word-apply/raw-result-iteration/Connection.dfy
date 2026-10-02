// SPDX-License-Identifier: MIT
include "../raw-callback-success/Connection.dfy"
include "../result-iteration/Map.generated.dfy"
include "../result-iteration/Keep.generated.dfy"
include "../result-iteration/Skip.generated.dfy"
include "Sequence.dfy"
module BytecodeApplyRawFirstResultIteration {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import T = BytecodeApplyRawFirstSuccessfulCallback
  import L = BytecodeApplyRawFirstElement
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import P = BytecodeApplyFirstElementPost
  import C = BytecodeApplyCallbackCopyMemory
  import S = BytecodeApplyCallbackSuccessMemory
  import B = BytecodeApplySuccessfulCallMemory
  import A = BytecodeApplyResultMap
  import K = BytecodeApplyResultKeep
  import D = BytecodeApplyResultSkip
  import Q = BytecodeApplyRawCallbackStackSequence
  import Z = BytecodeApplyFirstResultStackSequence
  predicate Fits(data: seq<Byte>) {
    I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0 &&
    W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  }
  predicate Matches(code: seq<Byte>) { T.Matches(code) && A.Matches(code) && K.Matches(code) && D.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+A.Destinations()+K.Destinations()+D.Destinations() }
  function Prefix(data: seq<Byte>,filter: bool): seq<Word>
  { [if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96] }
  function Receipt(data: seq<Byte>,returned: seq<Byte>): seq<Byte>
    requires Fits(data) && |returned| == 32
    ensures S.Fits(C.Packed(T.Template(data),O.Extent(I.SourceLength(data)/32),H.Free(O.Extent(I.SourceLength(data)/32),I.TemplateLength(data)),I.TemplateLength(data)),H.Free(O.Extent(I.SourceLength(data)/32),I.TemplateLength(data)))
  {
    var n: Word := I.SourceLength(data)/32;
    var ptr: Word := O.Extent(n);
    var free: Word := H.Free(ptr,I.TemplateLength(data));
    B.Fits(T.Template(data),ptr,free,I.TemplateLength(data));
    S.Complete(C.Packed(T.Template(data),ptr,free,I.TemplateLength(data)),free,returned)
  }
  function Output(data: seq<Byte>,filter: bool,returned: seq<Byte>): seq<Byte>
    requires Fits(data) && |returned| == 32
  { if filter && S.Result(returned) == 0 then Receipt(data,returned)
    else Store(Receipt(data,returned),160,if filter then P.Original(data) else S.Result(returned)) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,codeSize: Word,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Fits(data)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires X.Context(self) && 0 < codeSize && |returned| == 32 && (!filter || S.Result(returned) <= 1)
    requires cursor+3 < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    requires observations[cursor+1] == X.Gas(gasBefore) && observations[cursor+2] == X.Gas(requestedGas)
    requires observations[cursor+3] == X.StaticCall(self,requestedGas,I.Target(data),T.Template(data)[O.Extent(I.SourceLength(data)/32)+32..O.Extent(I.SourceLength(data)/32)+32+I.TemplateLength(data)],true,returned)
    ensures var n: Word := I.SourceLength(data)/32;
            frame == X.Frame(Running(12391,Prefix(data,filter)+[5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),if filter then 1 else 0,128,n,if filter && S.Result(returned) == 0 then 0 else 1,O.Extent(n),1],Output(data,filter,returned)),returned,cursor+4)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then (if S.Result(returned) == 0 then 900 else 932) else 913)+93*(I.Count(data) as nat)
  {
    hide G.BitAnd();
    var n: Word := I.SourceLength(data)/32;
    assert 0 < n < 0x800000000000000;
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var ptr: Word := O.Extent(n);
    var prefix := Prefix(data,filter);
    var mem := Receipt(data,returned);
    var result := S.Result(returned);
    var word := P.Original(data);
    frame,trace := T.Run(code,data,filter,self,oldReturn,returned,cursor,codeSize,observations,gasBefore,requestedGas);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    Q.Group([selector,518],R.Fields(data),[mode,128,n,0,ptr,0,word,0],result);
    Q.Nine(mode,128,n,0,ptr,0,word,0,result);
    Z.FieldsTail(prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,128,n,0,ptr,0,word,0,result);
    var state: State; var states: seq<State>; var small: set<nat>;
    if !filter {
      state,states := A.Run(code,data,mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),128,n,0,ptr,0,word,result,0);
      small := A.Destinations();
    } else if result == 1 {
      state,states := K.Run(code,data,mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),128,n,0,ptr,0,word,result,0);
      small := K.Destinations();
    } else {
      assert result == 0;
      state,states := D.Run(code,data,mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),128,n,0,ptr,0,word,result,0);
      small := D.Destinations();
    }
    L.Lift(code,small,data,states,self,returned,cursor+4,observations);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor+4));
    E.WidenTrace(code,small,Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];frame := part[|part|-1];
  }
}
