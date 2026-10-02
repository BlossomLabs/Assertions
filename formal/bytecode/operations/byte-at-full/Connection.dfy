// SPDX-License-Identifier: MIT
// Prepared complete exact raw byteAt composition; retained evidence remains open.
include "../byte-at-success-prefix/Entry.generated.dfy"
include "../byte-at-index-controls/InvalidHighEntry.generated.dfy"
include "../byte-at-index-controls/InvalidLowEntry.generated.dfy"
include "../byte-at-index-controls/PositiveEntry.generated.dfy"
include "../byte-at-index-controls/NegativeEntry.generated.dfy"
include "../byte-at-serialization/ControlEntry.generated.dfy"
include "../byte-at-repair-v3/Nonzero.generated.dfy"
include "../byte-at-repair-v3/Short.generated.dfy"
include "../byte-at-repair-v3/Args.generated.dfy"
include "../byte-at-repair-v3/OffsetBound.generated.dfy"
include "../byte-at-repair-v3/LengthWindow.generated.dfy"
include "../byte-at-repair-v3/LengthBound.generated.dfy"
include "../byte-at-repair-v3/PayloadWindow.generated.dfy"
module OperationsByteAtFullConnection {
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import N = OperationsByteAtIndices
  import Prefix = OperationsByteAtSuccessPrefix
  import PrefixEntry = OperationsByteAtSuccessPrefixEntry
  import High = OperationsByteAtIndexInvalidHigh
  import HighEntry = OperationsByteAtIndexInvalidHighEntry
  import Low = OperationsByteAtIndexInvalidLow
  import LowEntry = OperationsByteAtIndexInvalidLowEntry
  import Positive = OperationsByteAtIndexPositive
  import PositiveEntry = OperationsByteAtIndexPositiveEntry
  import Negative = OperationsByteAtIndexNegative
  import NegativeEntry = OperationsByteAtIndexNegativeEntry
  import Serialization = OperationsByteAtSerialization
  import SerializationEntry = OperationsByteAtSerializationControlEntry
  import Nonzero = OperationsByteAtNonzero
  import Short = OperationsByteAtShort
  import Args = OperationsByteAtArgs
  import Offset = OperationsByteAtOffsetBound
  import Window = OperationsByteAtLengthWindow
  import Length = OperationsByteAtLengthBound
  import Payload = OperationsByteAtPayloadWindow
  predicate Matches(code:seq<Byte>) {
    Prefix.Matches(code) && High.Matches(code) && Low.Matches(code) &&
    Positive.Matches(code) && Negative.Matches(code) && Serialization.Matches(code) &&
    Nonzero.Matches(code) && Short.Matches(code) && Args.Matches(code) &&
    Offset.Matches(code) && Window.Matches(code) && Length.Matches(code) && Payload.Matches(code)
  }
  function Receipt(state:State):I.Receipt
    requires state.Returned? || state.Reverted?
  { if state.Returned? then I.Returned(state.data) else I.Reverted(state.data) }
  lemma BodyAdmission(value:Word,data:seq<Byte>)
    requires I.Frame(data) && I.Assigned(data,value)
    requires I.Admission(data,value) in {I.InvalidHigh,I.InvalidLow,I.Positive,I.Negative}
    ensures value==0 && I.Span(data)
  {}
  ghost method Run(code:seq<Byte>,value:Word,data:seq<Byte>) returns(state:State)
    requires Matches(code) && I.Frame(data) && I.Assigned(data,value)
    ensures state.Returned? || state.Reverted?
    ensures Receipt(state)==I.Intended(data,value)
  {
    var kind:=I.Admission(data,value);
    if kind==I.Nonzero { state:=Nonzero.Run(code,value,data); }
    else if kind==I.Short { state:=Short.Run(code,value,data); }
    else if kind==I.Args { state:=Args.Run(code,value,data); }
    else if kind==I.OffsetBound { state:=Offset.Run(code,value,data); }
    else if kind==I.LengthWindow { state:=Window.Run(code,value,data); }
    else if kind==I.LengthBound { state:=Length.Run(code,value,data); }
    else if kind==I.PayloadWindow { state:=Payload.Run(code,value,data); }
    else {
      BodyAdmission(value,data);var trace:seq<State>;
      state,trace:=PrefixEntry.Run(code,value,data);
      if kind==I.InvalidHigh { state,trace:=HighEntry.Run(code,state,value,data); }
      else if kind==I.InvalidLow { state,trace:=LowEntry.Run(code,state,value,data); }
      else {
        if kind==I.Positive { state,trace:=PositiveEntry.Run(code,state,value,data); }
        else { state,trace:=NegativeEntry.Run(code,state,value,data); }
        state,trace:=SerializationEntry.Run(code,state,value,data);
      }
    }
  }
}
