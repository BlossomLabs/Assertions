// SPDX-License-Identifier: MIT
include "../abi/Encoding.dfy"

module NavigationModel {
  import opened AbiFrames
  import opened AbiEncoding

  datatype Selection = Absent | Selected(selectedType: AbiType, selectedValue: Value)
  datatype Mode = ValueMode | LengthMode | PayloadMode
  datatype Answer = Refused | Returned(data: seq<Byte>)

  ghost predicate Aggregate(t: AbiType) {
    t.Tuple? || t.FixedArray? || t.Array?
  }

  // Tuple positions are nonnegative; arrays alone count backwards from the end.
  ghost predicate InRange(t: AbiType, v: Value, index: int)
    requires WellTyped(t,v)
  {
    Aggregate(t) &&
    (if t.Tuple? then 0 <= index < |v.values|
     else -(|v.values| as int) <= index < |v.values|)
  }

  function Position(index: int, count: nat): nat
    requires -(count as int) <= index < count
    ensures Position(index,count) < count
  { if index < 0 then count+index else index }

  ghost function Select(t: AbiType, v: Value, path: seq<int>): Selection
    requires WellTyped(t,v)
    ensures Select(t,v,path).Selected? ==>
              WellTyped(Select(t,v,path).selectedType,Select(t,v,path).selectedValue)
    decreases |path|
  {
    if |path| == 0 then Selected(t,v)
    else if !InRange(t,v,path[0]) then Absent
    else
      var i := Position(path[0],|v.values|);
      Select(Child(t,i),v.values[i],path[1..])
  }

  ghost predicate HasLength(t: AbiType) {
    t.Bytes? || t.String? || t.Array?
  }

  ghost function Length(t: AbiType, v: Value): nat
    requires WellTyped(t,v) && HasLength(t)
  { if t.Array? then |v.values| else |v.payload| }

  ghost function Terminal(t: AbiType, v: Value, mode: Mode): Answer
    requires WellTyped(t,v)
  {
    match mode
    case ValueMode => Returned(Encode(t,v))
    case LengthMode => if HasLength(t) then Returned(Word(Length(t,v))) else Refused
    case PayloadMode => if t.Bytes? || t.String? then Returned(v.payload) else Refused
  }

  // The root models a function's return-parameter tuple, so it starts at its
  // body, even when a dynamic child makes the tuple itself dynamic.
  ghost function Query(t: AbiType, v: Value, path: seq<int>, mode: Mode): Answer
    requires WellTyped(t,v) && t.Tuple?
  {
    if |path| == 0 then (if mode == ValueMode then Returned(Body(t,v)) else Refused)
    else
      var selected := Select(t,v,path);
      if selected.Absent? then Refused
      else Terminal(selected.selectedType,selected.selectedValue,mode)
  }

  lemma SelectionFits(t: AbiType, v: Value, path: seq<int>)
    requires WellTyped(t,v) && Fits(t,v)
    ensures Select(t,v,path).Selected? ==>
              Fits(Select(t,v,path).selectedType,Select(t,v,path).selectedValue)
    decreases |path|
  {
    if |path| > 0 && InRange(t,v,path[0]) {
      var i := Position(path[0],|v.values|);
      SelectionFits(Child(t,i),v.values[i],path[1..]);
    }
  }

  lemma SelectionCompose(t: AbiType, v: Value, first: seq<int>, rest: seq<int>)
    requires WellTyped(t,v)
    ensures Select(t,v,first+rest) ==
            (if Select(t,v,first).Absent? then Absent
             else Select(Select(t,v,first).selectedType,Select(t,v,first).selectedValue,rest))
    decreases |first|
  {
    if |first| > 0 {
      assert (first+rest)[0] == first[0];
      assert (first+rest)[1..] == first[1..]+rest;
      if InRange(t,v,first[0]) {
        var i := Position(first[0],|v.values|);
        SelectionCompose(Child(t,i),v.values[i],first[1..],rest);
        assert Select(t,v,first) == Select(Child(t,i),v.values[i],first[1..]);
        assert Select(t,v,first+rest) == Select(Child(t,i),v.values[i],first[1..]+rest);
      } else {
        assert Select(t,v,first) == Absent;
        assert Select(t,v,first+rest) == Absent;
      }
    } else {
      assert first == [] && first+rest == rest;
      assert Select(t,v,first) == Selected(t,v);
    }
  }

  lemma NegativeArrayIndex(t: AbiType, v: Value, index: int)
    requires WellTyped(t,v) && (t.Array? || t.FixedArray?)
    requires -(|v.values| as int) <= index < 0
    ensures Select(t,v,[index]) == Select(t,v,[|v.values|+index])
  {}

  lemma NegativeTupleIndex(t: AbiType, v: Value, index: int)
    requires WellTyped(t,v) && t.Tuple? && index < 0
    ensures Select(t,v,[index]) == Absent
  {}

  lemma TerminalRules(t: AbiType, v: Value)
    requires WellTyped(t,v) && Fits(t,v)
    ensures Terminal(t,v,ValueMode) == Returned(Encode(t,v))
    ensures Terminal(t,v,LengthMode).Returned? == HasLength(t)
    ensures Terminal(t,v,PayloadMode).Returned? == (t.Bytes? || t.String?)
    ensures HasLength(t) ==> ReadNat(Terminal(t,v,LengthMode).data) == Length(t,v)
  {
    if HasLength(t) {
      EncodedLengthsFit(t,v);
      NatBytesRoundTrip(Length(t,v),32);
    }
  }
}
