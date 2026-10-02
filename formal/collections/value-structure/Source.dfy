// SPDX-License-Identifier: MIT
include "Control.generated.dfy"
module CollectionsValueStructureSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened CollectionsValueStructureModel
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import Encoding = AbiEncoding
  import M = CollectionsValueStructureModel
  import Ctrl = CollectionsValueStructureControl
  import Parser = AbiParserSource
  import Validation = CollectionsValidationSource
  import V = CollectionsValidationModel
  import C = AbiConstructionContext
  import Errors = CollectionsCodecErrorEncoding

  ghost method RawShape(k: Config) returns (r: C.Result)
    requires Basic(k)
    ensures r == Shape(k)
    ensures Whole(k.t).Shaped? ==> Admissible(Whole(k.t).syntax) && Encoding.WellFormed(TypeOf(Whole(k.t).syntax))
  {
    var parsed := Parser.Shape(k.t);
    if parsed.Shaped? { ModelType(parsed.syntax); }
    r := if parsed.Shaped? then C.Success else if parsed.BadDescriptor? then C.InvalidDescriptor(parsed.at) else C.Panic(17);
  }
  lemma RemainderSmall(value: int,modulus: nat)
    requires 0 <= value < modulus
    ensures value%modulus == value
  {}
  lemma SignedCast(length: nat)
    requires length < SignedLimit()
    ensures Ctrl.ToSigned(length) == length
  {
    assert Pow256(32) == 2*SignedLimit();
    RemainderSmall(length+SignedLimit(),Pow256(32));
  }
  lemma UnsignedCast(value: int)
    requires 0 <= value < Pow256(32)
    ensures Ctrl.ToUnsigned(value) == value
  { RemainderSmall(value,Pow256(32)); }
  ghost method SliceIndex(index: int,length: nat) returns (r: nat)
    requires -(SignedLimit() as int) <= index < SignedLimit() && Uint(32*length)
    ensures r == Clamp(index,length) && r <= length
  {
    assert length < SignedLimit();
    SignedCast(length);
    if Ctrl.IndexNegative(index) {
      var result := Ctrl.NegativeResult(index,length);
      if index >= -(length as int) {
        assert 0 <= length+index < Pow256(32);
        UnsignedCast(length+index);
      }
      assert result == Clamp(index,length);
      r := result as nat;
    } else {
      assert 0 <= index < Pow256(32);
      UnsignedCast(index);
      r := Ctrl.PositiveResult(index,length) as nat;
    }
  }
  ghost method Reverse(k: Config) returns (r: M.Outcome)
    requires Basic(k) && Budget(k) && k.kind == M.Reverse
    ensures r == Judge(k)
  {
    var shape := RawShape(k);
    if !shape.Success? { r := Failed(Errors.Encode(shape),[]); return; }
    var length := |k.values|;
    var out: seq<seq<Byte>> := seq(length,i => []);
    var i: nat := 0;
    while Ctrl.ReverseLoop(i,length)
      invariant i <= length && |out| == length
      invariant forall p :: 0 <= p < i ==> Checked(k,Cells(k)[p]).Success?
      invariant forall p :: 0 <= p < i ==> out[length-p-1] == k.values[p]
      decreases length-i
    {
      assert Ctrl.ReverseValidate(i) == i;
      var input := k.values[Ctrl.ReverseValidate(i)];
      assert Cells(k)[i].value == input;
      var checked := Validation.Input(k.t,input);
      assert checked == Checked(k,Cells(k)[i]);
      if !checked.Success? {
        FirstInvalid(k,i); r := Failed(Errors.Encode(checked),Cells(k)[..i+1]); return;
      }
      assert Ctrl.ReverseDest(i,length) == length-i-1;
      assert Ctrl.ReverseValue(i) == i;
      assert Uint(length-i-1) && Uint(i+1);
      out := out[Ctrl.ReverseDest(i,length) := k.values[Ctrl.ReverseValue(i)]];
      i := i+1;
    }
    ValuesEqual(Cells(k),k.values);
    AllValid(k);
    assert out == Reversed(k.values);
    r := Returned(out,Cells(k));
  }
  ghost method Slice(k: Config) returns (r: M.Outcome)
    requires Basic(k) && Budget(k) && k.kind == M.Slice
    ensures r == Judge(k)
  {
    var shape := RawShape(k);
    if !shape.Success? { r := Failed(Errors.Encode(shape),[]); return; }
    var a := SliceIndex(k.start,|k.values|);
    var b := SliceIndex(k.end,|k.values|);
    var size := Ctrl.SliceSize(a,b);
    assert size == Size(k);
    assert a+size <= |k.values|;
    var out: seq<seq<Byte>> := seq(size,i => []);
    var i: nat := 0;
    while Ctrl.SliceLoop(i,|out|)
      invariant i <= size && |out| == size
      invariant forall p :: 0 <= p < i ==> Checked(k,Cells(k)[p]).Success?
      invariant forall p :: 0 <= p < i ==> out[p] == Cells(k)[p].value
      decreases size-i
    {
      assert Ctrl.SliceValidate(a,i) == a+i;
      var input := k.values[Ctrl.SliceValidate(a,i)];
      assert Cells(k)[i].value == input;
      var checked := Validation.Input(k.t,input);
      assert checked == Checked(k,Cells(k)[i]);
      if !checked.Success? {
        FirstInvalid(k,i); r := Failed(Errors.Encode(checked),Cells(k)[..i+1]); return;
      }
      assert Ctrl.SliceDest(i) == i && Ctrl.SliceValue(a,i) == a+i;
      assert Uint(a+i) && Uint(i+1);
      out := out[Ctrl.SliceDest(i) := k.values[Ctrl.SliceValue(a,i)]];
      i := i+1;
    }
    AllValid(k);
    ValuesEqual(Cells(k),out);
    r := Returned(out,Cells(k));
  }
  ghost method Flatten(k: Config) returns (r: M.Outcome)
    requires Basic(k) && Budget(k) && k.kind == M.Flatten
    ensures r == Judge(k)
  {
    var shape := RawShape(k);
    if !shape.Success? { r := Failed(Errors.Encode(shape),[]); return; }
    var length := |k.groups|;
    var count: nat := 0;
    var i: nat := 0;
    while Ctrl.CountLoop(i,length)
      invariant i <= length && count == PrefixCount(k.groups,i) && Uint(count)
      decreases length-i
    {
      var add := Ctrl.CountAdd(|k.groups[i]|);
      assert add == |k.groups[i]|;
      if count+add >= Pow256(32) {
        CountMonotone(k.groups,i+1,length);
        assert Size(k) >= Pow256(32);
        r := Failed(Errors.Encode(C.Panic(17)),[]); return;
      }
      count := count+add;
      i := i+1;
      assert Uint(i);
    }
    assert count == Size(k) && count < Pow256(32);
    var out: seq<seq<Byte>> := seq(count,p => []);
    var used: nat := 0;
    i := 0;
    while Ctrl.FlatLoop(i,length)
      invariant i <= length && |out| == count
      invariant used == PrefixCount(k.groups,i) && used <= count
      invariant forall p :: 0 <= p < used ==> Checked(k,Cells(k)[p]).Success?
      invariant forall p :: 0 <= p < used ==> out[p] == Cells(k)[p].value
      decreases length-i
    {
      var j: nat := 0;
      while Ctrl.RowLoop(j,|k.groups[i]|)
        invariant j <= |k.groups[i]| && |out| == count
        invariant used == PrefixCount(k.groups,i)+j && used <= count
        invariant forall p :: 0 <= p < used ==> Checked(k,Cells(k)[p]).Success?
        invariant forall p :: 0 <= p < used ==> out[p] == Cells(k)[p].value
        decreases |k.groups[i]|-j
      {
        FlatPosition(k.groups,i,j+1);
        assert Cells(k)[used] == Cell(i,j,k.groups[i][j]);
        assert Ctrl.FlatValidateRow(i) == i && Ctrl.FlatValidateCol(j) == j;
        var input := k.groups[Ctrl.FlatValidateRow(i)][Ctrl.FlatValidateCol(j)];
        var checked := Validation.Input(k.t,input);
        assert checked == Checked(k,Cells(k)[used]);
        if !checked.Success? {
          FirstInvalid(k,used); r := Failed(Errors.Encode(checked),Cells(k)[..used+1]); return;
        }
        assert Ctrl.FlatValueRow(i) == i && Ctrl.FlatValueCol(j) == j;
        assert Uint(used+1) && Uint(j+1);
        out := out[used := k.groups[Ctrl.FlatValueRow(i)][Ctrl.FlatValueCol(j)]];
        used := used+1;
        j := j+1;
      }
      assert j == |k.groups[i]|;
      i := i+1;
      assert Uint(i);
    }
    assert used == count;
    ValuesEqual(Cells(k),out);
    AllValid(k);
    r := Returned(out,Cells(k));
  }
  ghost method Run(k: Config) returns (r: M.Outcome)
    requires Basic(k) && Budget(k)
    ensures r == Judge(k)
  {
    if k.kind == M.Reverse { r := Reverse(k); }
    else if k.kind == M.Slice { r := Slice(k); }
    else { r := Flatten(k); }
  }
}
