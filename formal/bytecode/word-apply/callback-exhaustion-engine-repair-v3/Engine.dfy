// SPDX-License-Identifier: MIT
include "../callback-exhaustion-controls-repair-v2/OtherLengthExhausted.generated.dfy"
include "../callback-exhaustion-controls-repair-v2/FourLengthExhausted.generated.dfy"
include "../callback-exhaustion-controls-repair-v2/OtherLengthContinue.generated.dfy"
include "../callback-exhaustion-controls-repair-v2/FourLengthSignal.generated.dfy"
include "../callback-exhaustion-controls-repair-v2/FourLengthContinue.generated.dfy"
module BytecodeApplyCallbackExhaustionEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import H = BytecodeApplyCallbackExhaustionScalar
  import O = BytecodeApplyCallbackOutOfGasReturnMemory
  import OE = BytecodeApplyCallbackExhaustionOtherLengthExhausted
  import FE = BytecodeApplyCallbackExhaustionFourLengthExhausted
  import OC = BytecodeApplyCallbackExhaustionOtherLengthContinue
  import FS = BytecodeApplyCallbackExhaustionFourLengthSignal
  import FC = BytecodeApplyCallbackExhaustionFourLengthContinue
  predicate Matches(code: seq<Byte>) { OE.Matches(code) && FE.Matches(code) && OC.Matches(code) && FS.Matches(code) && FC.Matches(code) }
  function Destinations(): set<nat> { OE.Destinations()+FE.Destinations()+OC.Destinations()+FS.Destinations()+FC.Destinations() }
  function Refused(length: Word,head: Word,gasBefore: Word,gasAfter: Word): bool
  { gasAfter <= gasBefore/63 || (length == 4 && H.Masked(head) == O.Header()) }
  ghost method Run(code: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && H.Fits(mem,receipt,length,head) && X.Context(self) && |prefix| <= 1008
    requires cursor < |observations| && observations[cursor] == X.Gas(gasAfter)
    ensures frame == X.Frame(Running(if Refused(length,head,gasBefore,gasAfter) then 16171 else 17017,prefix+(if Refused(length,head,gasBefore,gasAfter) then [17017,gasBefore,receipt,if length == 4 then head else 0] else []),mem),returned,cursor+1)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures trace[0] == X.Frame(Running(16107,prefix+[17017,gasBefore,receipt],mem),returned,cursor) && trace[|trace|-1] == frame
  { hide G.BitAnd(); hide BitNot(); hide H.Masked(); hide E.Trace();
    if length != 4 && gasAfter <= gasBefore/63 {
      assert OE.Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) by { reveal OE.Admitted(); }
      frame,trace := OE.Run(code,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
      E.WidenTrace(code,OE.Destinations(),Destinations(),self,value,data,observations,trace);
    }
    else if length == 4 && gasAfter <= gasBefore/63 {
      assert FE.Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) by { reveal FE.Admitted(); }
      frame,trace := FE.Run(code,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
      E.WidenTrace(code,FE.Destinations(),Destinations(),self,value,data,observations,trace);
    }
    else if length != 4 {
      assert OC.Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) by { reveal OC.Admitted(); }
      frame,trace := OC.Run(code,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
      E.WidenTrace(code,OC.Destinations(),Destinations(),self,value,data,observations,trace);
    }
    else if H.Masked(head) == O.Header() {
      assert FS.Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) by { reveal FS.Admitted(); }
      frame,trace := FS.Run(code,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
      E.WidenTrace(code,FS.Destinations(),Destinations(),self,value,data,observations,trace);
    }
    else {
      assert FC.Admitted(mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations) by { reveal FC.Admitted(); }
      frame,trace := FC.Run(code,mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations);
      E.WidenTrace(code,FC.Destinations(),Destinations(),self,value,data,observations,trace);
    }
  }
}
