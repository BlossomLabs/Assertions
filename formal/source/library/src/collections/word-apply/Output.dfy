// SPDX-License-Identifier: MIT
include "Properties.dfy"
module CollectionsWordApplyOutput {
  import opened AbiFrames
  import opened CollectionsWordApplyModel
  import P = CollectionsWordApplyProperties
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  predicate Good(k: Config,rows: seq<Row>) {
    Static(k) && forall j :: 0 <= j < |rows| ==> rows[j].index < Count(k) && Checked(k,rows[j].index,rows[j].answer).Word?
  }
  function Selected(k: Config,rows: seq<Row>): seq<nat>
    requires Good(k,rows)
    decreases |rows|
  {
    if |rows| == 0 then [] else
    (if !k.filterMode || rows[0].answer.value == 1 then [rows[0].index] else [])+Selected(k,rows[1..])
  }
  function Values(k: Config,rows: seq<Row>): seq<nat>
    requires Good(k,rows)
    decreases |rows|
  {
    if |rows| == 0 then [] else
    Emit(k,rows[0].index,rows[0].answer.value)+Values(k,rows[1..])
  }
  lemma Success(k: Config,index: nat,h: seq<C.Event>)
    requires Static(k) && index <= Count(k) && Tail(k,index,h).Finished?
    ensures Good(k,Tail(k,index,h).rows)
    ensures Tail(k,index,h).values == Values(k,Tail(k,index,h).rows)
    decreases Count(k)-index
  {
    if index < Count(k) {
      var raw := Answer(k,index,h);
      assert Checked(k,index,raw).Word?;
      Success(k,index+1,After(k,index,h));
      var rest := Tail(k,index+1,After(k,index,h));
      var rows := Tail(k,index,h).rows;
      assert rows[1..] == rest.rows;
      forall j | 0 <= j < |rows|
        ensures rows[j].index < Count(k) && Checked(k,rows[j].index,rows[j].answer).Word?
      { if j > 0 { assert rows[j] == rest.rows[j-1]; } }
    }
  }
  lemma Membership(k: Config,rows: seq<Row>,i: nat)
    requires Good(k,rows)
    ensures (i in Selected(k,rows)) <==> (exists j :: 0 <= j < |rows| && rows[j].index == i && (!k.filterMode || rows[j].answer.value == 1))
    decreases |rows|
  {
    if |rows| > 0 {
      Membership(k,rows[1..],i);
      if exists j :: 0 <= j < |rows| && rows[j].index == i && (!k.filterMode || rows[j].answer.value == 1) {
        var j :| 0 <= j < |rows| && rows[j].index == i && (!k.filterMode || rows[j].answer.value == 1);
        if j > 0 { assert rows[1..][j-1] == rows[j]; }
      }
      if i in Selected(k,rows[1..]) {
        var j :| 0 <= j < |rows[1..]| && rows[1..][j].index == i && (!k.filterMode || rows[1..][j].answer.value == 1);
        assert rows[j+1] == rows[1..][j];
      }
    }
  }
  lemma Length(k: Config,rows: seq<Row>)
    requires Good(k,rows)
    ensures |Selected(k,rows)| == |Values(k,rows)| && |Selected(k,rows)| <= |rows|
    ensures !k.filterMode ==> |Selected(k,rows)| == |rows|
    decreases |rows|
  { if |rows| > 0 { Length(k,rows[1..]); } }
  lemma FilterAt(k: Config,rows: seq<Row>,j: nat)
    requires Good(k,rows) && k.filterMode && j < |Selected(k,rows)|
    ensures Selected(k,rows)[j] < Count(k)
    ensures j < |Values(k,rows)| && Values(k,rows)[j] == Element(k,Selected(k,rows)[j])
    decreases |rows|
  {
    assert |rows| > 0;
    Length(k,rows);
    if rows[0].answer.value == 1 {
      if j > 0 { FilterAt(k,rows[1..],j-1); }
    } else { FilterAt(k,rows[1..],j); }
  }
  lemma MapAt(k: Config,rows: seq<Row>,j: nat)
    requires Good(k,rows) && !k.filterMode && j < |rows|
    ensures j < |Values(k,rows)| && Values(k,rows)[j] == rows[j].answer.value
    ensures j < |Selected(k,rows)| && Selected(k,rows)[j] == rows[j].index
    decreases j
  {
    Length(k,rows);
    if j > 0 { MapAt(k,rows[1..],j-1); assert rows[1..][j-1] == rows[j]; }
  }
  lemma LowerBound(k: Config,rows: seq<Row>,lo: nat,j: nat)
    requires Good(k,rows) && j < |Selected(k,rows)|
    requires forall r :: 0 <= r < |rows| ==> lo <= rows[r].index
    ensures lo <= Selected(k,rows)[j]
  {
    Membership(k,rows,Selected(k,rows)[j]);
    var r :| 0 <= r < |rows| && rows[r].index == Selected(k,rows)[j] && (!k.filterMode || rows[r].answer.value == 1);
  }
  lemma Stable(k: Config,rows: seq<Row>,a: nat,b: nat)
    requires Good(k,rows) && a < b < |Selected(k,rows)|
    requires forall x,y :: 0 <= x < y < |rows| ==> rows[x].index < rows[y].index
    ensures Selected(k,rows)[a] < Selected(k,rows)[b]
    decreases |rows|
  {
    assert |rows| > 0;
    if !k.filterMode || rows[0].answer.value == 1 {
      if a == 0 {
        LowerBound(k,rows[1..],rows[0].index+1,b-1);
      } else { Stable(k,rows[1..],a-1,b-1); }
    } else { Stable(k,rows[1..],a,b); }
  }
}
