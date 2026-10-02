// SPDX-License-Identifier: MIT
// Raw decoder, signed byte positions, UTF8-first errors, and exact packet spec.
// Universal native instruction correspondence remains pending.
include "../utf8-shared/Spec.dfy"
module OperationsStringAtInputs {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import U = OperationsUtf8Inputs
  const U64:nat:=0x10000000000000000
  function Load(data:seq<S.Byte>,offset:nat):S.Word {
    G.Decode(S.Window(data,offset,32))%G.Modulus()
  }
  function Offset(data:seq<S.Byte>):S.Word { Load(data,4) }
  function IndexWord(data:seq<S.Byte>):S.Word { Load(data,36) }
  function Length(data:seq<S.Byte>):S.Word { Load(data,(Offset(data) as nat)+4) }
  function PayloadOffset(data:seq<S.Byte>):nat { (Offset(data) as nat)+36 }
  predicate Frame(data:seq<S.Byte>) { |data|<U64 }
  predicate Assigned(data:seq<S.Byte>,value:S.Word) {
    value!=0 || |data|<4 || S.ShiftRight(S.DataWord(data,0),224)==0xa1bc2139
  }
  predicate Span(data:seq<S.Byte>) {
    |data|>=68 && Offset(data)<U64 && PayloadOffset(data)<=|data| && Length(data)<U64 && PayloadOffset(data)+Length(data)<=|data|
  }
  datatype Case = Nonzero | Short | Args | OffsetBound | LengthWindow | LengthBound | PayloadWindow | Accepted
  function Admission(data:seq<S.Byte>,value:S.Word):Case {
    if value!=0 then Nonzero else if |data|<4 then Short else if |data|<68 then Args
    else if Offset(data)>=U64 then OffsetBound else if PayloadOffset(data)>|data| then LengthWindow
    else if Length(data)>=U64 then LengthBound else if PayloadOffset(data)+Length(data)>|data| then PayloadWindow else Accepted
  }
  function Payload(data:seq<S.Byte>):seq<S.Byte>
    requires Span(data)
  { data[PayloadOffset(data)..PayloadOffset(data)+Length(data)] }
  function Signed(word:S.Word):int { if word<G.Modulus()/2 then word else word-G.Modulus() }
  predicate InRange(word:S.Word,length:S.Word) { -(length as int)<=Signed(word)<length }
  function Position(word:S.Word,length:S.Word):nat
    requires InRange(word,length)
    ensures Position(word,length)<length
  { if Signed(word)<0 then length+Signed(word) else Signed(word) }
  datatype Outcome = Raw | InvalidUtf8(at:nat) | InvalidByteIndex(index:S.Word,length:S.Word) | Success(cell:S.Byte)
  function Intended(data:seq<S.Byte>,value:S.Word):Outcome
    requires Frame(data)
    ensures Intended(data,value).InvalidUtf8? ==> Intended(data,value).at<U64
  {
    if Admission(data,value)!=Accepted then Raw
    else var payload:=Payload(data);var utf8:=U.Check(payload,0);
                                    if utf8.Invalid? then InvalidUtf8(utf8.at)
                                    else if !InRange(IndexWord(data),Length(data)) then InvalidByteIndex(IndexWord(data),Length(data))
                                    else var position:=Position(IndexWord(data),Length(data));
                                         if payload[position]>=128 then InvalidUtf8(position) else Success(payload[position])
  }
  function Packet(outcome:Outcome):seq<S.Byte>
    requires outcome.InvalidUtf8? ==> outcome.at<G.Modulus()
  {
    if outcome.Raw? then []
    else if outcome.InvalidUtf8? then [0x41,0x97,0x20,0x36]+G.Encode(outcome.at,32)
    else if outcome.InvalidByteIndex? then [0xdf,0x75,0xcb,0xae]+G.Encode(outcome.index,32)+G.Encode(outcome.length,32)
    else G.Encode(32,32)+G.Encode(1,32)+[outcome.cell]+seq(31,i=>0)
  }
  lemma AdmissionSpan(data:seq<S.Byte>,value:S.Word)
    ensures Admission(data,value)==Accepted <==> value==0 && Span(data)
  {}
  lemma MachineSigned(word:S.Word)
    ensures G.Signed(word)==Signed(word)
  {}
  lemma Word(data:seq<S.Byte>,offset:S.Word)
    ensures S.DataWord(data,offset)==Load(data,offset)
  {}
  lemma OffsetAliases(data:seq<S.Byte>)
    ensures Offset(data)==0 ==> Length(data)==Offset(data)
    ensures Offset(data)==32 ==> Length(data)==IndexWord(data)
  {}
}
