// SPDX-License-Identifier: MIT
// Pure bridge to the unchanged retained byteAt signed-index arithmetic.
// Fresh native verification and exact stringAt controls remain pending.
include "../string-at-inputs/Inputs.dfy"
include "../byte-at-repair-v3/Indices.dfy"
module OperationsStringAtStrictIndex {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = OperationsStringAtInputs
  import N = OperationsByteAtIndices
  datatype Case = InvalidHigh | InvalidLow | Positive | Negative
  function Class(word:S.Word,length:S.Word):Case
    requires length<I.U64
  {
    if I.Signed(word)>=length then InvalidHigh
    else if I.Signed(word)< -(length as int) then InvalidLow
    else if I.Signed(word)<0 then Negative else Positive
  }
  lemma Bridge(word:S.Word,length:S.Word)
    requires length<I.U64
    ensures I.Signed(word)==N.Signed(word)==G.Signed(word)
    ensures I.InRange(word,length)==N.FitsIndex(word,length)
    ensures I.InRange(word,length) ==> I.Position(word,length)==N.Position(word,length)
  { I.MachineSigned(word); }
  lemma Partition(word:S.Word,length:S.Word)
    requires length<I.U64
    ensures Class(word,length)==InvalidHigh <==> I.Signed(word)>=length
    ensures Class(word,length)==InvalidLow <==> I.Signed(word)< -(length as int)
    ensures Class(word,length)==Positive <==> 0<=I.Signed(word)<length
    ensures Class(word,length)==Negative <==> -(length as int)<=I.Signed(word)<0
    ensures I.InRange(word,length) <==> Class(word,length) in {Positive,Negative}
  { Bridge(word,length);N.FittingGuards(word,length); }
  lemma NegatedLength(length:S.Word)
    requires length<I.U64
    ensures G.Signed((G.Modulus()-length)%G.Modulus())== -(length as int)
    ensures G.Modulus()/2+length<G.Modulus()
    ensures G.Modulus()/2+length!=0
  { N.NegativeLength(length);I.MachineSigned((G.Modulus()-length)%G.Modulus()); }
  lemma PositiveResult(word:S.Word,length:S.Word)
    requires length<I.U64 && Class(word,length)==Positive
    ensures I.InRange(word,length) && I.Position(word,length)==word
    ensures word<G.Modulus()/2 && word<length
  { Bridge(word,length);Partition(word,length);N.PositivePosition(word,length); }
  lemma NegativeResult(word:S.Word,length:S.Word)
    requires length<I.U64 && Class(word,length)==Negative
    ensures I.InRange(word,length) && I.Position(word,length)==(length+word)%G.Modulus()
    ensures G.Signed((length+word)%G.Modulus())==length+I.Signed(word)
    ensures 0<=length+I.Signed(word)<length<I.U64
    ensures word>=G.Modulus()/2
  { Bridge(word,length);Partition(word,length);N.NegativePosition(word,length);I.MachineSigned((length+word)%G.Modulus()); }
}
