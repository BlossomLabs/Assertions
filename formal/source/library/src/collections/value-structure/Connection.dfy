// SPDX-License-Identifier: MIT
include "Source.dfy"
module CollectionsValueStructureConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened CollectionsValueStructureModel
  import M = CollectionsValueStructureModel
  import Source = CollectionsValueStructureSource
  import V = CollectionsValidationModel
  import Validation = CollectionsValidationConnection
  import Encoding = AbiEncoding
  import Canonical = AbiValidation
  import C = AbiConstructionContext
  import Errors = CollectionsCodecErrorEncoding

  ghost method Run(k: Config) returns (r: M.Outcome)
    requires Basic(k) && Budget(k)
    ensures r == Judge(k)
    ensures !Shape(k).Success? ==> r == Failed(Errors.Encode(Shape(k)),[])
    ensures Shape(k).Success? && k.kind == Flatten && Size(k) >= Pow256(32) ==> r == Failed(Errors.Encode(C.Panic(17)),[])
    ensures r.Returned? ==> r.visited == Cells(k) && |r.values| == Size(k)
    ensures r.Returned? ==> r.values == (if k.kind == Reverse then Reversed(Values(Cells(k))) else Values(Cells(k)))
    ensures Whole(k.t).Shaped? ==> Encoding.WellFormed(TypeOf(Whole(k.t).syntax))
    ensures r.Returned? ==> Whole(k.t).Shaped? && (forall j :: 0 <= j < |r.values| ==> Canonical.Validate(TypeOf(Whole(k.t).syntax),r.values[j]).Parsed?)
    ensures r.Returned? ==> forall j :: 0 <= j < |Cells(k)| ==> Checked(k,Cells(k)[j]).Success?
    ensures r.Failed? && |r.visited| > 0 ==> exists bad :: 0 <= bad < |Cells(k)| &&
                                                           r == Failed(Errors.Encode(Checked(k,Cells(k)[bad])),Cells(k)[..bad+1]) && !Checked(k,Cells(k)[bad]).Success? &&
                                                           (forall j :: 0 <= j < bad ==> Checked(k,Cells(k)[j]).Success?)
    ensures Shape(k).Success? && k.kind == Slice && End(k) <= Start(k) ==> r == Returned([],[])
  {
    var shape := Source.RawShape(k);
    r := Source.Run(k);
    if Shape(k).Success? && Size(k) < Pow256(32) {
      TailFacts(k,Cells(k),0);
      if r.Returned? {
        var j: nat := 0;
        while j < |r.values|
          invariant j <= |r.values|
          invariant forall p :: 0 <= p < j ==> Canonical.Validate(TypeOf(Whole(k.t).syntax),r.values[p]).Parsed?
          decreases |r.values|-j
        {
          var index := if k.kind == Reverse then Size(k)-j-1 else j;
          ValuesAt(Cells(k),index);
          assert r.values[j] == Cells(k)[index].value;
          var checked := Validation.Verdict(k.t,r.values[j],C.Context(C.ValueKind,0,0,0,0));
          j := j+1;
        }
      }
    }
  }
  ghost method SlicePosition(k: Config,i: nat) returns (r: M.Outcome)
    requires Basic(k) && Budget(k) && k.kind == Slice && i < Size(k)
    ensures r == Judge(k)
    ensures r.Returned? ==> |r.values| == Size(k) && r.visited == Cells(k)
    ensures r.Returned? ==> r.values[i] == k.values[Start(k)+i] && r.visited[i] == Cell(Start(k)+i,0,k.values[Start(k)+i])
  { r := Run(k); if r.Returned? { ValuesAt(Cells(k),i); } }
  ghost method FlattenPosition(k: Config,i: nat,j: nat) returns (r: M.Outcome)
    requires Basic(k) && Budget(k) && k.kind == Flatten && i < |k.groups| && j < |k.groups[i]|
    ensures r == Judge(k)
    ensures PrefixCount(k.groups,i)+j < Size(k)
    ensures r.Returned? ==> |r.values| == Size(k) && r.visited == Cells(k)
    ensures r.Returned? ==> r.values[PrefixCount(k.groups,i)+j] == k.groups[i][j] &&
                            r.visited[PrefixCount(k.groups,i)+j] == Cell(i,j,k.groups[i][j])
  {
    FlatPosition(k.groups,i,j+1);
    r := Run(k);
    if r.Returned? {
      var pos := PrefixCount(k.groups,i)+j;
      assert FlatPrefix(k.groups,i,0)+RowCells(k.groups[i],i)[..j+1] == Cells(k)[..pos+1];
      assert RowCells(k.groups[i],i)[j] == Cell(i,j,k.groups[i][j]);
      assert Cells(k)[pos] == Cell(i,j,k.groups[i][j]);
      ValuesAt(Cells(k),pos);
    }
  }
}
