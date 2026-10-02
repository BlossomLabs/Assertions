// SPDX-License-Identifier: MIT
// Independent raw byte-set specification; native verification is pending.
include "../../scans/Machine.dfy"
module OperationsCharsetInputs {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  const U64:nat:=0x10000000000000000
  function Load(data:seq<S.Byte>,offset:nat):S.Word {
    G.Decode(S.Window(data,offset,32))%G.Modulus()
  }
  function Offset(data:seq<S.Byte>):S.Word { Load(data,4) }
  function Mask(data:seq<S.Byte>):S.Word { Load(data,36) }
  function Length(data:seq<S.Byte>):S.Word { Load(data,(Offset(data) as nat)+4) }
  function Payload(data:seq<S.Byte>):nat { (Offset(data) as nat)+36 }
  predicate Frame(data:seq<S.Byte>) { |data|<U64 }
  predicate Assigned(data:seq<S.Byte>,value:S.Word) {
    value!=0 || |data|<4 || S.ShiftRight(S.DataWord(data,0),224)==0x3e8c97e3
  }
  predicate Span(data:seq<S.Byte>) {
    |data|>=68 && Offset(data)<U64 && Payload(data)<=|data| && Length(data)<U64 && Payload(data)+Length(data)<=|data|
  }
  datatype Case = Nonzero | Short | Args | OffsetBound | LengthWindow | LengthBound | PayloadWindow | Accepted
  function Admission(data:seq<S.Byte>,value:S.Word):Case {
    if value!=0 then Nonzero else if |data|<4 then Short else if |data|<68 then Args
    else if Offset(data)>=U64 then OffsetBound else if Payload(data)>|data| then LengthWindow
    else if Length(data)>=U64 then LengthBound else if Payload(data)+Length(data)>|data| then PayloadWindow else Accepted
  }
  predicate Member(mask:S.Word,cell:S.Byte) {
    ((mask as bv256)&((1 as bv256)<<(cell as nat)))!=0
  }
  predicate All(data:seq<S.Byte>,offset:nat,length:nat,mask:S.Word)
    requires offset+length<=|data|
  { forall i:nat {:trigger data[offset+i]} :: i<length ==> Member(mask,data[offset+i]) }
  function Result(data:seq<S.Byte>):S.Word
    requires Span(data)
  { if All(data,Payload(data),Length(data),Mask(data)) then 1 else 0 }
  lemma AdmissionSpan(data:seq<S.Byte>,value:S.Word)
    ensures Admission(data,value)==Accepted <==> value==0 && Span(data)
  {}
  lemma Word(data:seq<S.Byte>,offset:S.Word)
    ensures S.DataWord(data,offset)==Load(data,offset)
  {}
  lemma OffsetAliases(data:seq<S.Byte>)
    ensures Offset(data)==0 ==> Length(data)==Offset(data)
    ensures Offset(data)==32 ==> Length(data)==Mask(data)
  {}
}
