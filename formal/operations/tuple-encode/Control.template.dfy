include "Model.dfy"
module OperationsTupleEncodeSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiShapeSemantics
  import opened AbiConstructionModel
  import E = AbiConstructionEndpoints
  import C = AbiConstructionContext
  import M = OperationsTupleEncodeModel
  function Descriptor(t: seq<Byte>): seq<Byte> { $BYTES_DESCRIPTOR$ }
  lemma DescriptorWitness()
  {
    var t: seq<Byte> := [40,98,121,116,101,115,41];
    assert Descriptor(t) == t;
  }
  ghost method RawReturn(payload: seq<Byte>) returns (wire: seq<Byte>)
    requires Uint(|payload|)
    ensures wire == payload
  {
    M.RawObject(payload);
    var memory := Word(|payload|)+payload;
    var size := ReadNat(memory[..32]);
    var offset := $RAW_OFFSET$;
    wire := memory[offset..offset+size];
  }
  ghost method Raw(t: seq<Byte>,values: seq<seq<Byte>>) returns (receipt: M.Receipt)
    requires M.Budget(t,values)
    ensures receipt.Returned? ==> M.Canonical(t,values,receipt.wire)
    ensures receipt.Aborted? ==> !receipt.reason.Success?
  {
    var payload,r := E.TupleEntrypoint(t,values);
    if !r.Success? { receipt := M.Aborted(r); return; }
    ghost var fs :| Admissible(Group(fs)) && t == Render(Group(fs)) && ValidInputs(fs,values)
                    && WellTyped(TypeOf(Group(fs)),Items(Decoded(fs,values)))
                    && payload == Body(TypeOf(Group(fs)),Items(Decoded(fs,values)));
    CanonicalPieces(fs,values); FrameBudget(fs,values); Sizes(Pieces(fs,values),0);
    ModelType(Group(fs)); TypesIndex(fs);
    assert Children(TypeOf(Group(fs)),|fs|) == TypesOf(fs);
    AggregateParts(TypeOf(Group(fs)),Decoded(fs,values));
    assert payload == Frame(Pieces(fs,values));
    var wire := RawReturn(payload);
    receipt := M.Returned(wire);
  }
  ghost method Bytes(t: seq<Byte>,values: seq<seq<Byte>>) returns (receipt: M.Receipt,payload: seq<Byte>)
    requires M.Budget(t,values)
    ensures receipt.Returned? ==> M.Canonical(t,values,payload) && receipt.wire == Encode(AbiType.Bytes,Buffer(payload))
    ensures receipt.Aborted? ==> !receipt.reason.Success?
  {
    var descriptor := Descriptor(t);
    var out,r := E.TupleEntrypoint(descriptor,values);
    payload := out;
    if !r.Success? { receipt := M.Aborted(r); return; }
    ghost var fs :| Admissible(Group(fs)) && descriptor == Render(Group(fs)) && ValidInputs(fs,values)
                    && WellTyped(TypeOf(Group(fs)),Items(Decoded(fs,values)))
                    && payload == Body(TypeOf(Group(fs)),Items(Decoded(fs,values)));
    CanonicalPieces(fs,values); FrameBudget(fs,values); Sizes(Pieces(fs,values),0);
    ModelType(Group(fs)); TypesIndex(fs);
    assert Children(TypeOf(Group(fs)),|fs|) == TypesOf(fs);
    AggregateParts(TypeOf(Group(fs)),Decoded(fs,values));
    assert payload == Frame(Pieces(fs,values));
    M.Enveloped(payload);
    receipt := M.Returned(M.Envelope(payload));
  }
  ghost method RawOffsetWitness()
  {
    var payload := Word(7);
    var memory := Word(|payload|)+payload;
    var offset := $RAW_OFFSET$;
    var wire := memory[offset..offset+32];
    assert wire == payload;
  }
}
