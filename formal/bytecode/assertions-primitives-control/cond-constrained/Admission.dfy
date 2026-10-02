// SPDX-License-Identifier: MIT
// Fresh public cond class: condition RAW and only the selected operand RAW.
include "Body.dfy"
include "../cond-class/Dispatch.generated.dfy"
include "../cond-class/Decoder.generated.dfy"
module AssertionsCondConstrainedAdmission {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = BytecodeScanRepresentation
  import D = AssertionsCondPublicSpec
  import R = AssertionsCondConstrainedSpec
  import C = AssertionsCondConstrainedBody
  import H = AssertionsCondConstrainedHeap
  import B = AssertionsCondPublicDispatch
  import N = AssertionsCondPublicDecoder
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Calldata(data: seq<Byte>, conditionRelative: Word, thenRelative: Word, elseRelative: Word, condition: R.Operand, selected: R.Operand) {
    D.Calldata(data,conditionRelative,thenRelative,elseRelative) &&
    S.ShiftRight(S.DataWord(data,0),224) == D.Selector() &&
    condition.pointer == 4+conditionRelative && R.Span(data,condition) &&
    R.Budget(128,condition) &&
    (condition.length >= 32 ==> R.Span(data,selected) &&
                                selected.pointer == (if H.First(R.Payload(data,condition)) == 0 then 4+elseRelative else 4+thenRelative) &&
                                R.Budget(C.ConditionFree(128,condition),selected))
  }
  lemma Initial(condition: R.Operand)
    requires R.Budget(128,condition)
    ensures R.Heap(D.Initial(),128,condition)
  { Q.StoredWord([],64,128); }
  lemma Caller(data: seq<Byte>, conditionRelative: Word, thenRelative: Word, elseRelative: Word, condition: R.Operand, selected: R.Operand)
    requires Calldata(data,conditionRelative,thenRelative,elseRelative,condition,selected)
    ensures S.ShiftRight(S.DataWord(data,0),224) == D.Selector()
    ensures D.Calldata(data,conditionRelative,thenRelative,elseRelative)
    ensures B.Admitted(conditionRelative,thenRelative,elseRelative,[],[],data,0)
    ensures N.Admitted(conditionRelative,thenRelative,elseRelative,[],D.Initial(),data,0)
    ensures condition.pointer == 4+conditionRelative && R.Span(data,condition) && R.Heap(D.Initial(),128,condition)
    ensures condition.length >= 32 ==> R.Span(data,selected) && selected.pointer == (if H.First(R.Payload(data,condition)) == 0 then 4+elseRelative else 4+thenRelative) && R.Budget(C.ConditionFree(128,condition),selected)
  {
    reveal Calldata(); reveal B.Admitted(); reveal N.Admitted(); Initial(condition);
  }
}
