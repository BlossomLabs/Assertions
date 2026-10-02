// SPDX-License-Identifier: MIT
// Independent ASCII-only original-byte specification; native pending.
include "../charset-inputs/Inputs.dfy"
module OperationsCaseFoldInputs {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = OperationsCharsetInputs
  const U64:nat:=0x10000000000000000
  function Selector(lower:bool):S.Word { if lower then 0xc1459c04 else 0xfeec0cff }
  function Low(lower:bool):S.Byte { if lower then 65 else 97 }
  function High(lower:bool):S.Byte { if lower then 90 else 122 }
  function Fold(lower:bool,cell:S.Byte):S.Byte {
    if Low(lower)<=cell<=High(lower) then ((cell as bv8)^(32 as bv8)) as nat else cell
  }
  function Offset(data:seq<S.Byte>):S.Word { I.Load(data,4) }
  function Length(data:seq<S.Byte>):S.Word { I.Load(data,(Offset(data) as nat)+4) }
  function Payload(data:seq<S.Byte>):nat { (Offset(data) as nat)+36 }
  predicate Frame(data:seq<S.Byte>) { |data|<U64 }
  predicate Assigned(data:seq<S.Byte>,value:S.Word,lower:bool) {
    value!=0 || |data|<4 || S.ShiftRight(S.DataWord(data,0),224)==Selector(lower)
  }
  predicate Span(data:seq<S.Byte>) {
    |data|>=36 && Offset(data)<U64 && Payload(data)<=|data| && Length(data)<U64 && Payload(data)+Length(data)<=|data|
  }
  datatype Case = Nonzero | Short | Args | OffsetBound | LengthWindow | LengthBound | PayloadWindow | Accepted
  function Admission(data:seq<S.Byte>,value:S.Word):Case {
    if value!=0 then Nonzero else if |data|<4 then Short else if |data|<36 then Args
    else if Offset(data)>=U64 then OffsetBound else if Payload(data)>|data| then LengthWindow
    else if Length(data)>=U64 then LengthBound else if Payload(data)+Length(data)>|data| then PayloadWindow else Accepted
  }
  function Result(data:seq<S.Byte>,lower:bool):seq<S.Byte>
    requires Span(data)
  { seq(Length(data),i requires 0<=i<Length(data) => Fold(lower,data[Payload(data)+i])) }
  lemma AdmissionSpan(data:seq<S.Byte>,value:S.Word)
    ensures Admission(data,value)==Accepted <==> value==0 && Span(data)
  {}
  lemma Word(data:seq<S.Byte>,offset:S.Word)
    ensures I.Load(data,offset)==S.DataWord(data,offset)
  { I.Word(data,offset); }
}
