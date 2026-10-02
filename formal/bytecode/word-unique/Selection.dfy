// SPDX-License-Identifier: MIT
// Independent original-input selection specification and finite retained-word search.
include "Memory.dfy"
module BytecodeWordUniqueSelection {
  import M = BytecodeWordUniqueMemory
  type Word = M.Word
  predicate Bounds(values: seq<Word>, ids: seq<nat>) {
    forall j :: 0 <= j < |ids| ==> ids[j] < |values|
  }
  predicate Keep(values: seq<Word>, ordered: bool, i: nat)
    requires i < |values|
  {
    if ordered then i == 0 || values[i-1] != values[i]
    else !(exists j :: 0 <= j < i && values[j] == values[i])
  }
  function Selected(values: seq<Word>, ordered: bool, i: nat): seq<nat>
    requires i <= |values|
    decreases i
  { if i == 0 then [] else Selected(values,ordered,i-1)+(if Keep(values,ordered,i-1) then [i-1] else []) }
  lemma SelectedBounds(values: seq<Word>, ordered: bool, i: nat)
    requires i <= |values|
    ensures |Selected(values,ordered,i)| <= i
    ensures i > 0 ==> |Selected(values,ordered,i)| > 0
    ensures Bounds(values,Selected(values,ordered,i))
    ensures forall j :: 0 <= j < |Selected(values,ordered,i)| ==> Selected(values,ordered,i)[j] < i
    ensures forall a,b :: 0 <= a < b < |Selected(values,ordered,i)| ==> Selected(values,ordered,i)[a] < Selected(values,ordered,i)[b]
    decreases i
  {
    if i > 0 {
      SelectedBounds(values,ordered,i-1);
      if Keep(values,ordered,i-1) {
        var ids := Selected(values,ordered,i);
        forall a,b | 0 <= a < b < |ids| ensures ids[a] < ids[b]
        { if b < |ids|-1 { assert ids[a] == Selected(values,ordered,i-1)[a] && ids[b] == Selected(values,ordered,i-1)[b]; } }
      }
    }
  }
  lemma Member(values: seq<Word>, i: nat, word: Word)
    requires i <= |values|
    ensures Bounds(values,Selected(values,false,i))
    ensures (exists j :: 0 <= j < |Selected(values,false,i)| && values[Selected(values,false,i)[j]] == word)
       <==> (exists j :: 0 <= j < i && values[j] == word)
    decreases i
  {
    SelectedBounds(values,false,i);
    if i > 0 {
      SelectedBounds(values,false,i-1);
      Member(values,i-1,word); Member(values,i-1,values[i-1]);
      if Keep(values,false,i-1) {
        assert Selected(values,false,i) == Selected(values,false,i-1)+[i-1];
      } else {
        assert Selected(values,false,i) == Selected(values,false,i-1);
        assert exists j {:trigger values[Selected(values,false,i-1)[j]]} :: 0 <= j < |Selected(values,false,i-1)| && values[Selected(values,false,i-1)[j]] == values[i-1];
      }
      if exists j :: 0 <= j < i && values[j] == word {
        var j :| 0 <= j < i && values[j] == word;
        if j < i-1 {
          assert exists j :: 0 <= j < i-1 && values[j] == word;
          var retained :| 0 <= retained < |Selected(values,false,i-1)| && values[Selected(values,false,i-1)[retained]] == word;
          assert retained < |Selected(values,false,i)|;
          assert Selected(values,false,i)[retained] == Selected(values,false,i-1)[retained];
          assert exists k :: 0 <= k < |Selected(values,false,i)| && values[Selected(values,false,i)[k]] == word;
        } else if Keep(values,false,i-1) {
          assert Selected(values,false,i)[|Selected(values,false,i)|-1] == i-1;
          assert values[Selected(values,false,i)[|Selected(values,false,i)|-1]] == word;
          assert exists k :: 0 <= k < |Selected(values,false,i)| && values[Selected(values,false,i)[k]] == word;
        } else {
          var retained :| 0 <= retained < |Selected(values,false,i-1)| && values[Selected(values,false,i-1)[retained]] == values[i-1];
          assert values[Selected(values,false,i)[retained]] == word;
          assert exists k :: 0 <= k < |Selected(values,false,i)| && values[Selected(values,false,i)[k]] == word;
        }
      }
      if exists j :: 0 <= j < |Selected(values,false,i)| && values[Selected(values,false,i)[j]] == word {
        var j :| 0 <= j < |Selected(values,false,i)| && values[Selected(values,false,i)[j]] == word;
        assert Selected(values,false,i)[j] < i;
        assert exists k :: 0 <= k < i && values[k] == word;
      }
    }
  }
  lemma Last(values: seq<Word>, i: nat)
    requires 0 < i <= |values|
    ensures |Selected(values,true,i)| > 0
    ensures Bounds(values,Selected(values,true,i))
    ensures values[Selected(values,true,i)[|Selected(values,true,i)|-1]] == values[i-1]
    decreases i
  {
    SelectedBounds(values,true,i); SelectedBounds(values,true,i-1);
    if i > 1 && !Keep(values,true,i-1) {
      Last(values,i-1);
      assert Selected(values,true,i) == Selected(values,true,i-1);
      assert values[i-2] == values[i-1];
    } else {
      assert Keep(values,true,i-1);
      assert Selected(values,true,i)[|Selected(values,true,i)|-1] == i-1;
    }
  }
  predicate Seen(values: seq<Word>, ordered: bool, ids: seq<nat>, i: nat)
    requires Bounds(values,ids) && i < |values|
  {
    if ordered then |ids| != 0 && values[ids[|ids|-1]] == values[i]
    else exists j :: 0 <= j < |ids| && values[ids[j]] == values[i]
  }
  lemma Decision(values: seq<Word>, ordered: bool, i: nat)
    requires i < |values|
    ensures Bounds(values,Selected(values,ordered,i))
    ensures Seen(values,ordered,Selected(values,ordered,i),i) <==> !Keep(values,ordered,i)
    ensures Selected(values,ordered,i+1) == Selected(values,ordered,i)+(if Seen(values,ordered,Selected(values,ordered,i),i) then [] else [i])
  {
    SelectedBounds(values,ordered,i);
    if ordered { if i > 0 { Last(values,i); } }
    else { Member(values,i,values[i]); }
  }
  lemma Inclusion(values: seq<Word>, ordered: bool, n: nat, i: nat)
    requires n <= |values| && i < |values|
    ensures i in Selected(values,ordered,n) <==> i < n && Keep(values,ordered,i)
    decreases n
  { if n > 0 { Inclusion(values,ordered,n-1,i); SelectedBounds(values,ordered,n-1); } }
  lemma NoDuplicates(values: seq<Word>, n: nat, a: nat, b: nat)
    requires n <= |values| && a < b < |Selected(values,false,n)|
    ensures Bounds(values,Selected(values,false,n))
    ensures values[Selected(values,false,n)[a]] != values[Selected(values,false,n)[b]]
  {
    SelectedBounds(values,false,n);
    var ids := Selected(values,false,n);
    Inclusion(values,false,n,ids[b]);
    if values[ids[a]] == values[ids[b]] {
      assert exists j :: 0 <= j < ids[b] && values[j] == values[ids[b]];
    }
  }
  ghost method Search(values: seq<Word>, ids: seq<nat>, word: Word)
    returns (seen: bool, index: nat)
    requires Bounds(values,ids)
    ensures index <= |ids|
    ensures seen <==> (exists j :: 0 <= j < |ids| && values[ids[j]] == word)
    ensures seen ==> index < |ids| && values[ids[index]] == word
    ensures forall j :: 0 <= j < index ==> values[ids[j]] != word
    ensures !seen ==> index == |ids|
  {
    index := 0; seen := false;
    while index < |ids|
      invariant index <= |ids| && !seen
      invariant forall j :: 0 <= j < index ==> values[ids[j]] != word
      decreases |ids|-index
    {
      if values[ids[index]] == word { seen := true; break; }
      index := index+1;
    }
  }
}
