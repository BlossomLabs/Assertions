// SPDX-License-Identifier: MIT
include "../validation/Connection.dfy"
module CollectionsValueStructureModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiParserSpec
  import V = CollectionsValidationModel
  import C = AbiConstructionContext
  import Errors = CollectionsCodecErrorEncoding
  datatype Kind = Reverse | Slice | Flatten
  datatype Config = Config(kind: Kind,t: seq<Byte>,values: seq<seq<Byte>>,groups: seq<seq<seq<Byte>>>,start: int,end: int)
  datatype Cell = Cell(index: nat,sub: nat,value: seq<Byte>)
  datatype Outcome = Returned(values: seq<seq<Byte>>,visited: seq<Cell>) | Failed(reason: seq<Byte>,visited: seq<Cell>)
  function SignedLimit(): nat { Pow256(32)/2 }
  predicate Basic(k: Config) {
    Uint(|k.t|) && Uint(32*|k.values|) && Uint(32*|k.groups|) &&
    -(SignedLimit() as int) <= k.start < SignedLimit() && -(SignedLimit() as int) <= k.end < SignedLimit() &&
    (forall i :: 0 <= i < |k.values| ==> Uint(|k.values[i]|)) &&
    (forall i :: 0 <= i < |k.groups| ==> Uint(32*|k.groups[i]|) && (forall j :: 0 <= j < |k.groups[i]| ==> Uint(|k.groups[i][j]|)))
  }
  function Clamp(index: int,length: nat): nat
    ensures Clamp(index,length) <= length
  {
    if index < 0 then (if index < -(length as int) then 0 else (length+index) as nat) else
    if index > length then length else index as nat
  }
  function PrefixCount(groups: seq<seq<seq<Byte>>>,i: nat): nat
    requires i <= |groups|
    decreases i
  { if i == 0 then 0 else PrefixCount(groups,i-1)+|groups[i-1]| }
  function FlatCount(groups: seq<seq<seq<Byte>>>): nat { PrefixCount(groups,|groups|) }
  function Start(k: Config): nat { Clamp(k.start,|k.values|) }
  function End(k: Config): nat { Clamp(k.end,|k.values|) }
  function Size(k: Config): nat {
    if k.kind == Reverse then |k.values| else if k.kind == Flatten then FlatCount(k.groups) else
    if End(k) > Start(k) then End(k)-Start(k) else 0
  }
  function RowCells(row: seq<seq<Byte>>,index: nat): seq<Cell> { seq(|row|,j requires 0 <= j < |row| => Cell(index,j as nat,row[j])) }
  function FlatPrefix(groups: seq<seq<seq<Byte>>>,i: nat,index: nat): seq<Cell>
    requires i <= |groups|
    ensures |FlatPrefix(groups,i,index)| == PrefixCount(groups,i)
    decreases i
  { if i == 0 then [] else FlatPrefix(groups,i-1,index)+RowCells(groups[i-1],index+i-1) }
  function FlatCells(groups: seq<seq<seq<Byte>>>,index: nat): seq<Cell> { FlatPrefix(groups,|groups|,index) }
  function Cells(k: Config): seq<Cell>
    ensures |Cells(k)| == Size(k)
  {
    if k.kind == Flatten then FlatCells(k.groups,0) else
    if k.kind == Reverse then seq(|k.values|,i requires 0 <= i < |k.values| => Cell(i as nat,0,k.values[i])) else
    seq(Size(k),i requires 0 <= i < Size(k) => Cell(Start(k)+i,0,k.values[Start(k)+i]))
  }
  ghost function Shape(k: Config): C.Result
    requires Uint(|k.t|)
  {
    if Whole(k.t).Shaped? then C.Success else
    if Whole(k.t).BadDescriptor? then C.InvalidDescriptor(Whole(k.t).at) else C.Panic(17)
  }
  ghost function Checked(k: Config,cell: Cell): C.Result
    requires Uint(|k.t|)
  { V.Checked(k.t,cell.value,C.Context(C.ValueKind,0,0,0,0)) }
  ghost predicate Budget(k: Config)
    requires Basic(k)
  {
    Shape(k).Success? && Size(k) < Pow256(32) ==>
      Uint(32*Size(k)) && (forall i :: 0 <= i < |Cells(k)| ==> V.Room(k.t,Cells(k)[i].value))
  }
  function Values(cells: seq<Cell>): seq<seq<Byte>>
    ensures |Values(cells)| == |cells|
    decreases |cells|
  { if |cells| == 0 then [] else [cells[0].value]+Values(cells[1..]) }
  lemma ValuesAt(cells: seq<Cell>,i: nat)
    requires i < |cells|
    ensures Values(cells)[i] == cells[i].value
    decreases i
  { if i > 0 { ValuesAt(cells[1..],i-1); } }
  lemma ValuesEqual(cells: seq<Cell>,values: seq<seq<Byte>>)
    requires |cells| == |values|
    requires forall i :: 0 <= i < |cells| ==> cells[i].value == values[i]
    ensures Values(cells) == values
  {
    forall i | 0 <= i < |cells| ensures Values(cells)[i] == values[i] { ValuesAt(cells,i); }
  }
  lemma FlatPosition(groups: seq<seq<seq<Byte>>>,i: nat,j: nat)
    requires i < |groups| && j <= |groups[i]|
    ensures PrefixCount(groups,i)+j <= FlatCount(groups)
    ensures FlatPrefix(groups,i,0)+RowCells(groups[i],i)[..j] == FlatCells(groups,0)[..PrefixCount(groups,i)+j]
    decreases |groups|-i
  {
    if i+1 < |groups| {
      FlatPosition(groups,i+1,0);
      assert FlatPrefix(groups,i+1,0) == FlatPrefix(groups,i,0)+RowCells(groups[i],i);
      assert FlatPrefix(groups,i+1,0)[..PrefixCount(groups,i)+j] == FlatPrefix(groups,i,0)+RowCells(groups[i],i)[..j];
    }
  }
  lemma CountMonotone(groups: seq<seq<seq<Byte>>>,i: nat,j: nat)
    requires i <= j <= |groups|
    ensures PrefixCount(groups,i) <= PrefixCount(groups,j)
    decreases j-i
  { if i < j { CountMonotone(groups,i,j-1); } }
  function Reversed(values: seq<seq<Byte>>): seq<seq<Byte>> { seq(|values|,i requires 0 <= i < |values| => values[|values|-1-i]) }
  ghost function Tail(k: Config,cells: seq<Cell>,i: nat): Outcome
    requires Uint(|k.t|) && i <= |cells|
    decreases |cells|-i
  {
    if i == |cells| then Returned([],[]) else
    var checked := Checked(k,cells[i]);
    if !checked.Success? then Failed(Errors.Encode(checked),[cells[i]]) else
    var rest := Tail(k,cells,i+1);
    if rest.Failed? then Failed(rest.reason,[cells[i]]+rest.visited)
    else Returned([cells[i].value]+rest.values,[cells[i]]+rest.visited)
  }
  ghost function Judge(k: Config): Outcome
    requires Basic(k)
  {
    if !Shape(k).Success? then Failed(Errors.Encode(Shape(k)),[]) else
    if k.kind == Flatten && Size(k) >= Pow256(32) then Failed(Errors.Encode(C.Panic(17)),[]) else
    var checked := Tail(k,Cells(k),0);
    if checked.Failed? then checked else
    Returned(if k.kind == Reverse then Reversed(checked.values) else checked.values,checked.visited)
  }
  lemma GoodSuffix(k: Config,cells: seq<Cell>,start: nat)
    requires Uint(|k.t|) && start <= |cells|
    requires forall j :: start <= j < |cells| ==> Checked(k,cells[j]).Success?
    ensures Tail(k,cells,start) == Returned(Values(cells[start..]),cells[start..])
    decreases |cells|-start
  {
    if start < |cells| {
      GoodSuffix(k,cells,start+1);
      assert cells[start..] == [cells[start]]+cells[start+1..];
    }
  }
  lemma BadSuffix(k: Config,cells: seq<Cell>,start: nat,bad: nat)
    requires Uint(|k.t|) && start <= bad < |cells|
    requires forall j :: start <= j < bad ==> Checked(k,cells[j]).Success?
    requires !Checked(k,cells[bad]).Success?
    ensures Tail(k,cells,start) == Failed(Errors.Encode(Checked(k,cells[bad])),cells[start..bad+1])
    decreases bad-start
  {
    if start < bad {
      BadSuffix(k,cells,start+1,bad);
      assert cells[start..bad+1] == [cells[start]]+cells[start+1..bad+1];
    }
  }
  lemma AllValid(k: Config)
    requires Basic(k) && Shape(k).Success? && Size(k) < Pow256(32)
    requires forall j :: 0 <= j < |Cells(k)| ==> Checked(k,Cells(k)[j]).Success?
    ensures Judge(k) == Returned(if k.kind == Reverse then Reversed(Values(Cells(k))) else Values(Cells(k)),Cells(k))
  { GoodSuffix(k,Cells(k),0); }
  lemma FirstInvalid(k: Config,bad: nat)
    requires Basic(k) && Shape(k).Success? && Size(k) < Pow256(32) && bad < |Cells(k)|
    requires forall j :: 0 <= j < bad ==> Checked(k,Cells(k)[j]).Success?
    requires !Checked(k,Cells(k)[bad]).Success?
    ensures Judge(k) == Failed(Errors.Encode(Checked(k,Cells(k)[bad])),Cells(k)[..bad+1])
  { BadSuffix(k,Cells(k),0,bad); }

  lemma TailFacts(k: Config,cells: seq<Cell>,start: nat)
    requires Uint(|k.t|) && start <= |cells|
    ensures Tail(k,cells,start).Returned? ==> Tail(k,cells,start) == Returned(Values(cells[start..]),cells[start..]) &&
                                              (forall j :: start <= j < |cells| ==> Checked(k,cells[j]).Success?)
    ensures Tail(k,cells,start).Failed? ==> exists bad :: start <= bad < |cells| &&
                                                          Tail(k,cells,start) == Failed(Errors.Encode(Checked(k,cells[bad])),cells[start..bad+1]) &&
                                                          !Checked(k,cells[bad]).Success? && (forall j :: start <= j < bad ==> Checked(k,cells[j]).Success?)
    decreases |cells|-start
  {
    if start < |cells| && Checked(k,cells[start]).Success? {
      TailFacts(k,cells,start+1);
      var rest := Tail(k,cells,start+1);
      if rest.Returned? {
        assert cells[start..] == [cells[start]]+cells[start+1..];
      } else {
        var bad :| start+1 <= bad < |cells| && rest == Failed(Errors.Encode(Checked(k,cells[bad])),cells[start+1..bad+1]) &&
                   !Checked(k,cells[bad]).Success? && (forall j :: start+1 <= j < bad ==> Checked(k,cells[j]).Success?);
        assert cells[start..bad+1] == [cells[start]]+cells[start+1..bad+1];
        assert Tail(k,cells,start) == Failed(Errors.Encode(Checked(k,cells[bad])),cells[start..bad+1]);
        assert forall j :: start <= j < bad ==> Checked(k,cells[j]).Success?;
      }
    } else if start < |cells| {
      assert cells[start..start+1] == [cells[start]];
    }
  }

}
