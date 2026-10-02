// SPDX-License-Identifier: MIT
// Independent public RAW/no-constraints pick calldata, signed index and resource class.
include "Body.dfy"
include "Dispatch.generated.dfy"
include "Decoder.generated.dfy"
module AssertionsPickRawAdmission {
  import S = BytecodeScanMachine
  import Q = BytecodeScanRepresentation
  import D = AssertionsPickPublicSpec
  import R = AssertionsCondRawSpec
  import B = AssertionsPickPublicDispatch
  import N = AssertionsPickPublicDecoder
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Calldata(data: seq<Byte>,relative: Word,index: Word,operand: R.Operand) {
    D.Calldata(data,relative,index) && S.ShiftRight(S.DataWord(data,0),224) == D.Selector() &&
    operand.pointer == 4+relative && R.Span(data,operand) &&
    128+S.Round32(operand.length)+128 < 0x10000000000000000
  }
  lemma Initial(operand: R.Operand)
    requires 128+S.Round32(operand.length)+128 < 0x10000000000000000
    ensures R.Heap(D.Initial(),128,operand)
  { Q.StoredWord([],64,128); }
  lemma Caller(data: seq<Byte>,relative: Word,index: Word,operand: R.Operand)
    requires Calldata(data,relative,index,operand)
    ensures S.ShiftRight(S.DataWord(data,0),224) == D.Selector()
    ensures D.Calldata(data,relative,index)
    ensures B.Admitted(relative,index,[],[],data,0) && N.Admitted(relative,index,[],D.Initial(),data,0)
    ensures operand.pointer == 4+relative && R.Span(data,operand) && R.Heap(D.Initial(),128,operand)
  { reveal Calldata(); reveal B.Admitted(); reveal N.Admitted(); Initial(operand); }
}
