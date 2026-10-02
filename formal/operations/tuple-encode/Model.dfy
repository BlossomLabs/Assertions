include "../../abi/construction/Endpoints.dfy"
module OperationsTupleEncodeModel {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiShapeSemantics
  import opened AbiConstructionModel
  import C = AbiConstructionContext
  datatype Receipt = Returned(wire: seq<Byte>) | Aborted(reason: C.Result)
  predicate Budget(t: seq<Byte>,values: seq<seq<Byte>>)
  {
    Uint(|t|) && Uint(|values|) && Uint(96+TotalBytes(values))
    && (forall i :: 0 <= i < |values| ==> Uint(|values[i]|))
  }
  ghost predicate Canonical(t: seq<Byte>,values: seq<seq<Byte>>,payload: seq<Byte>)
  {
    exists fs :: Admissible(Group(fs)) && t == Render(Group(fs)) && ValidInputs(fs,values)
                 && WellTyped(TypeOf(Group(fs)),Items(Decoded(fs,values)))
                 && payload == Body(TypeOf(Group(fs)),Items(Decoded(fs,values)))
  }
  function Envelope(payload: seq<Byte>): seq<Byte>
  { Word(32)+Word(|payload|)+Padded(payload) }
  ghost function Present(r: C.Result,payload: seq<Byte>,raw: bool): Receipt
  { if r.Success? then Returned(if raw then payload else Envelope(payload)) else Aborted(r) }
  lemma RawObject(payload: seq<Byte>)
    requires Uint(|payload|)
    ensures ReadNat((Word(|payload|)+payload)[..32]) == |payload|
    ensures (Word(|payload|)+payload)[32..32+|payload|] == payload
  { NatBytesRoundTrip(|payload|,32); }
  lemma Enveloped(payload: seq<Byte>)
    requires Uint(|payload|)
    ensures Envelope(payload) == Encode(Bytes,Buffer(payload))
  { }
}
