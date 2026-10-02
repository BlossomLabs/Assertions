// SPDX-License-Identifier: MIT
include "../word-memory/Connection.dfy"
module CollectionsWordUniqueModel {
  import opened AbiFrames
  import M = CollectionsWordMemoryModel
  datatype Config = Config(subject: seq<Byte>,ordered: bool)
  function Count(k: Config): nat { |k.subject|/32 }
  function Element(k: Config,i: nat): nat
    requires i < Count(k)
  { ReadNat(k.subject[32*i..32*i+32]) }
  // Independent first-occurrence/run-start specification, referring to the
  // original input prefix rather than the imperative retained output buffer.
  predicate Keep(k: Config,i: nat)
    requires i < Count(k)
  {
    if k.ordered then i == 0 || Element(k,i-1) != Element(k,i)
    else !(exists j :: 0 <= j < i && Element(k,j) == Element(k,i))
  }
  function Selected(k: Config,i: nat): seq<nat>
    requires i <= Count(k)
    decreases i
  { if i == 0 then [] else Selected(k,i-1)+(if Keep(k,i-1) then [i-1] else []) }
  function Project(k: Config,ids: seq<nat>): seq<nat>
    requires forall j :: 0 <= j < |ids| ==> ids[j] < Count(k)
    ensures |Project(k,ids)| == |ids|
    decreases |ids|
  { if |ids| == 0 then [] else [Element(k,ids[0])]+Project(k,ids[1..]) }
  function Bytes(values: seq<nat>): seq<Byte>
    decreases |values|
  { if |values| == 0 then [] else Word(values[0])+Bytes(values[1..]) }
  function Zero(n: nat): seq<Byte> { seq(n,i => 0 as Byte) }
  lemma SelectedBounds(k: Config,i: nat)
    requires i <= Count(k)
    ensures |Selected(k,i)| <= i
    ensures i > 0 ==> |Selected(k,i)| > 0
    ensures forall j :: 0 <= j < |Selected(k,i)| ==> Selected(k,i)[j] < i
    ensures forall a,b :: 0 <= a < b < |Selected(k,i)| ==> Selected(k,i)[a] < Selected(k,i)[b]
    decreases i
  {
    if i > 0 {
      SelectedBounds(k,i-1);
      if Keep(k,i-1) {
        var ids := Selected(k,i);
        forall a,b | 0 <= a < b < |ids| ensures ids[a] < ids[b]
        { if b < |ids|-1 { assert ids[a] == Selected(k,i-1)[a] && ids[b] == Selected(k,i-1)[b]; } }
      }
    }
  }
  lemma ProjectAt(k: Config,ids: seq<nat>,i: nat)
    requires forall j :: 0 <= j < |ids| ==> ids[j] < Count(k)
    requires i < |ids|
    ensures Project(k,ids)[i] == Element(k,ids[i])
    decreases i
  { if i > 0 { ProjectAt(k,ids[1..],i-1); } }
  lemma ProjectAppend(k: Config,ids: seq<nat>,i: nat)
    requires forall j :: 0 <= j < |ids| ==> ids[j] < Count(k)
    requires i < Count(k)
    ensures Project(k,ids+[i]) == Project(k,ids)+[Element(k,i)]
    decreases |ids|
  {
    if |ids| > 0 {
      assert (ids+[i])[1..] == ids[1..]+[i];
      ProjectAppend(k,ids[1..],i);
      assert Project(k,ids+[i]) == [Element(k,ids[0])]+Project(k,ids[1..]+[i]);
    }
  }
  lemma Member(k: Config,i: nat,value: nat)
    requires i <= Count(k) && !k.ordered
    ensures forall j :: 0 <= j < |Selected(k,i)| ==> Selected(k,i)[j] < Count(k)
    ensures value in Project(k,Selected(k,i)) <==> (exists j :: 0 <= j < i && Element(k,j) == value)
    decreases i
  {
    SelectedBounds(k,i);
    if i > 0 {
      SelectedBounds(k,i-1);
      Member(k,i-1,value); Member(k,i-1,Element(k,i-1));
      var previous := Project(k,Selected(k,i-1));
      if Keep(k,i-1) {
        assert Selected(k,i) == Selected(k,i-1)+[i-1];
        ProjectAppend(k,Selected(k,i-1),i-1);
        assert Project(k,Selected(k,i)) == previous+[Element(k,i-1)];
      } else {
        assert Selected(k,i) == Selected(k,i-1);
        assert Element(k,i-1) in previous;
      }
      if exists j :: 0 <= j < i && Element(k,j) == value {
        var j :| 0 <= j < i && Element(k,j) == value;
        if j < i-1 { assert exists j :: 0 <= j < i-1 && Element(k,j) == value; }
        else { assert value == Element(k,i-1); }
      }
      if value in previous { assert exists j :: 0 <= j < i && Element(k,j) == value; }
      if Element(k,i-1) == value { assert exists j :: 0 <= j < i && Element(k,j) == value; }
    }
  }
  lemma Last(k: Config,i: nat)
    requires i <= Count(k) && k.ordered && i > 0
    ensures |Selected(k,i)| > 0 && Selected(k,i)[|Selected(k,i)|-1] < Count(k)
    ensures forall j :: 0 <= j < |Selected(k,i)| ==> Selected(k,i)[j] < Count(k)
    ensures Project(k,Selected(k,i))[|Selected(k,i)|-1] == Element(k,i-1)
    decreases i
  {
    SelectedBounds(k,i);
    SelectedBounds(k,i-1);
    if i > 1 && !Keep(k,i-1) {
      Last(k,i-1);
      assert Selected(k,i) == Selected(k,i-1);
      assert Element(k,i-2) == Element(k,i-1);
    }
    else { assert Keep(k,i-1); ProjectAppend(k,Selected(k,i-1),i-1); }
  }
  lemma Selection(k: Config,n: nat,i: nat)
    requires n <= Count(k) && i < Count(k)
    ensures i in Selected(k,n) <==> i < n && Keep(k,i)
    decreases n
  { if n > 0 { Selection(k,n-1,i); SelectedBounds(k,n-1); } }
  lemma NoDuplicates(k: Config,n: nat,a: nat,b: nat)
    requires n <= Count(k) && !k.ordered && a < b < |Selected(k,n)|
    ensures forall j :: 0 <= j < |Selected(k,n)| ==> Selected(k,n)[j] < Count(k)
    ensures Project(k,Selected(k,n))[a] != Project(k,Selected(k,n))[b]
  {
    SelectedBounds(k,n); Selection(k,n,Selected(k,n)[b]);
    ProjectAt(k,Selected(k,n),a); ProjectAt(k,Selected(k,n),b);
    if Element(k,Selected(k,n)[a]) == Element(k,Selected(k,n)[b]) {
      assert exists j :: 0 <= j < Selected(k,n)[b] && Element(k,j) == Element(k,Selected(k,n)[b]);
    }
  }
  predicate Grouped(k: Config) {
    forall i :: 0 <= i < Count(k) && (exists j :: 0 <= j < i && Element(k,j) == Element(k,i)) ==> i > 0 && Element(k,i-1) == Element(k,i)
  }
  lemma GroupedEquivalent(k: Config,n: nat)
    requires n <= Count(k) && Grouped(k)
    ensures Selected(k,n) == Selected(Config(k.subject,!k.ordered),n)
    decreases n
  {
    if n > 0 {
      var other := Config(k.subject,!k.ordered);
      GroupedEquivalent(k,n-1);
      assert forall j :: 0 <= j < Count(k) ==> Element(other,j) == Element(k,j);
      if n > 1 {
        if exists j :: 0 <= j < n-1 && Element(k,j) == Element(k,n-1) {
          var j :| 0 <= j < n-1 && Element(k,j) == Element(k,n-1);
          assert Element(k,n-2) == Element(k,n-1);
        }
        if Element(k,n-2) == Element(k,n-1) {
          assert exists j :: 0 <= j < n-1 && Element(k,j) == Element(k,n-1);
        }
      }
      assert Keep(k,n-1) == Keep(other,n-1);
    }
  }

}
