// SPDX-License-Identifier: MIT
include "../codec-errors/Encoding.dfy"
include "../scalars/Model.dfy"
include "../admission/Source.generated.dfy"
module ExpressionAdmissionErrors {
  import opened AbiFrames
  import opened AbiByteSemantics
  import A = ExpressionAdmission
  import Scalar = ExpressionScalarModel
  import Codec = ExpressionCodecErrorEncoding

  function Fields(error: A.Error): seq<nat> {
    match error
    case InvalidNode(index) => [index]
    case InvalidReference(index,reference) => [index,reference]
    case InvalidDescriptor(position) => [position]
    case Panic(code) => [code]
  }
  predicate Fits(error: A.Error) {
    forall i :: 0 <= i < |Fields(error)| ==> Uint(Fields(error)[i])
  }
  function Selector(error: A.Error): seq<Byte>
    ensures |Selector(error)| == 4
  {
    match error
    case InvalidNode(_) => Scalar.NodeSelector()
    case InvalidReference(_,_) => Scalar.ReferenceSelector()
    case InvalidDescriptor(_) => Codec.DescriptorSelector()
    case Panic(_) => Codec.PanicSelector()
  }
  function Spec(error: A.Error): seq<Byte> { Selector(error)+Frame(Codec.Pieces(Fields(error))) }
  function Encoded(error: A.Error): seq<Byte> {
    match error
    case InvalidNode(index) => Scalar.ErrorBytes(Scalar.BadNode(index))
    case InvalidReference(index,reference) => Scalar.ErrorBytes(Scalar.BadReference(index,reference))
    case InvalidDescriptor(position) => Codec.DescriptorSelector()+Word(position)
    case Panic(code) => Codec.PanicSelector()+Word(code)
  }
  lemma Exact(error: A.Error)
    requires Fits(error)
    ensures Encoded(error) == Spec(error)
    ensures |Encoded(error)| == 4+32*|Fields(error)| && Encoded(error)[..4] == Selector(error)
    ensures forall i :: 0 <= i < |Fields(error)| ==>
                          ReadNat(Encoded(error)[4+32*i..4+32*(i+1)]) == Fields(error)[i]
  {
    Codec.StaticFrame(Fields(error),0);
    assert Encoded(error) == Selector(error)+Codec.Words(Fields(error));
    forall i | 0 <= i < |Fields(error)|
      ensures ReadNat(Encoded(error)[4+32*i..4+32*(i+1)]) == Fields(error)[i]
    {
      Codec.WordAt(Fields(error),i);
      assert Encoded(error)[4+32*i..4+32*(i+1)] == Codec.Words(Fields(error))[32*i..32*(i+1)];
    }
  }
}
