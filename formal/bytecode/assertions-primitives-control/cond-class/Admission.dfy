// SPDX-License-Identifier: MIT
// Fresh public cond class: condition RAW and only the selected operand RAW.
include "Condition.dfy"
include "Selected.dfy"
include "Dispatch.generated.dfy"
include "Decoder.generated.dfy"
module AssertionsCondRawAdmission {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = BytecodeScanRepresentation
  import D = AssertionsCondPublicSpec
  import R = AssertionsCondRawSpec
  import C = AssertionsCondRawCondition
  import B = AssertionsCondPublicDispatch
  import N = AssertionsCondPublicDecoder
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Calldata(data: seq<Byte>, conditionRelative: Word, thenRelative: Word, elseRelative: Word, condition: R.Operand, selected: R.Operand) {
    D.Calldata(data,conditionRelative,thenRelative,elseRelative) &&
    S.ShiftRight(S.DataWord(data,0),224) == D.Selector() &&
    condition.pointer == 4+conditionRelative && R.Span(data,condition) &&
    128+S.Round32(condition.length)+128 < 0x10000000000000000 &&
    (condition.length >= 32 ==> R.Span(data,selected) &&
                                selected.pointer == (if C.First(data,condition) == 0 then 4+elseRelative else 4+thenRelative) &&
                                C.Free(128,condition)+S.Round32(selected.length)+128 < 0x10000000000000000)
  }
  lemma Initial(condition: R.Operand)
    requires 128+S.Round32(condition.length)+128 < 0x10000000000000000
    ensures R.Heap(D.Initial(),128,condition)
  { Q.StoredWord([],64,128); }
  lemma Caller(data: seq<Byte>, conditionRelative: Word, thenRelative: Word, elseRelative: Word, condition: R.Operand, selected: R.Operand)
    requires Calldata(data,conditionRelative,thenRelative,elseRelative,condition,selected)
    ensures S.ShiftRight(S.DataWord(data,0),224) == D.Selector()
    ensures D.Calldata(data,conditionRelative,thenRelative,elseRelative)
    ensures B.Admitted(conditionRelative,thenRelative,elseRelative,[],[],data,0)
    ensures N.Admitted(conditionRelative,thenRelative,elseRelative,[],D.Initial(),data,0)
    ensures condition.pointer == 4+conditionRelative && R.Span(data,condition) && R.Heap(D.Initial(),128,condition)
    ensures condition.length >= 32 ==> R.Span(data,selected) && selected.pointer == (if C.First(data,condition) == 0 then 4+elseRelative else 4+thenRelative) && C.Free(128,condition)+S.Round32(selected.length)+128 < 0x10000000000000000
  {
    reveal Calldata(); reveal B.Admitted(); reveal N.Admitted(); Initial(condition);
  }
}
