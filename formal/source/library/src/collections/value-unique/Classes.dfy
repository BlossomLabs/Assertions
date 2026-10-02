// SPDX-License-Identifier: MIT
include "Connection.dfy"
module CollectionsValueUniqueClasses {
  import opened AbiFrames
  import opened AbiByteSemantics
  import Shape = AbiShapeSemantics
  import S = CollectionsValueUniqueSpec
  import F = CollectionsValueUniqueFlow
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import M = CollectionsValueUniqueEntryModel
  import Engine = CollectionsValueUniqueEngine
  import Public = CollectionsValueUniqueConnection
  ghost opaque predicate Coherent(k: S.Config,keys: seq<nat>,env: T.Environment) {
    |keys| == |k.values| && forall i: nat,kept: seq<nat>,j: nat,c: T.Context ::
      i < |k.values| && S.Indices(k,kept,i) && j < |kept| ==>
        var called := T.Ask(S.Query(k,i,kept,j),c,env);
        called.reply.Ok? ==> called.reply.truth == (keys[kept[j]] == keys[i])
  }
  function Prefix(keys: seq<nat>,ordered: bool,n: nat): seq<nat>
    requires n <= |keys|
    ensures forall j :: 0 <= j < |Prefix(keys,ordered,n)| ==> Prefix(keys,ordered,n)[j] < n
    decreases n
  {
    if n == 0 then [] else
    var previous := Prefix(keys,ordered,n-1);
    previous+(if (if ordered then n == 1 || keys[n-1] != keys[n-2] else forall j :: 0 <= j < n-1 ==> keys[j] != keys[n-1]) then [n-1] else [])
  }
  lemma BoundAt(keys: seq<nat>,ordered: bool,n: nat,j: nat)
    requires n <= |keys| && j < |Prefix(keys,ordered,n)|
    ensures Prefix(keys,ordered,n)[j] < n
    decreases n
  {
    assert n > 0;
    if j < |Prefix(keys,ordered,n-1)| { BoundAt(keys,ordered,n-1,j); }
  }
  lemma Last(keys: seq<nat>,n: nat)
    requires 0 < n <= |keys|
    ensures |Prefix(keys,true,n)| > 0
    ensures keys[Prefix(keys,true,n)[|Prefix(keys,true,n)|-1]] == keys[n-1]
    decreases n
  {
    if n > 1 { Last(keys,n-1); }
  }
  lemma Cover(keys: seq<nat>,ordered: bool,n: nat,i: nat)
    requires n <= |keys| && i < n
    ensures exists j :: 0 <= j < |Prefix(keys,ordered,n)| && keys[Prefix(keys,ordered,n)[j]] == keys[i]
    decreases n
  {
    var previous := Prefix(keys,ordered,n-1);
    if i < n-1 {
      Cover(keys,ordered,n-1,i);
      var j :| 0 <= j < |previous| && keys[previous[j]] == keys[i];
      assert Prefix(keys,ordered,n)[j] == previous[j];
      assert j < |Prefix(keys,ordered,n)| && keys[Prefix(keys,ordered,n)[j]] == keys[i];
    } else if |Prefix(keys,ordered,n)| > |previous| {
      assert Prefix(keys,ordered,n)[|previous|] == n-1;
    } else if ordered {
      assert n > 1; Last(keys,n-1);
      assert keys[previous[|previous|-1]] == keys[i];
      assert Prefix(keys,ordered,n)[|previous|-1] == previous[|previous|-1];
    } else {
      var earlier :| 0 <= earlier < n-1 && keys[earlier] == keys[i];
      Cover(keys,false,n-1,earlier);
      var j :| 0 <= j < |previous| && keys[previous[j]] == keys[earlier];
      assert Prefix(keys,false,n)[j] == previous[j];
      assert j < |Prefix(keys,false,n)| && keys[Prefix(keys,false,n)[j]] == keys[i];
    }
  }
  lemma Least(keys: seq<nat>,n: nat,j: nat)
    requires n <= |keys| && j < |Prefix(keys,false,n)|
    ensures Prefix(keys,false,n)[j] < n
    ensures forall i :: 0 <= i < Prefix(keys,false,n)[j] ==> keys[i] != keys[Prefix(keys,false,n)[j]]
    decreases n
  {
    assert n > 0;
    var previous := Prefix(keys,false,n-1);
    if j < |previous| { Least(keys,n-1,j); }
    else { assert j == |previous| && Prefix(keys,false,n)[j] == n-1; }
  }
  lemma Different(keys: seq<nat>,n: nat,a: nat,b: nat)
    requires n <= |keys| && a < b < |Prefix(keys,false,n)|
    ensures keys[Prefix(keys,false,n)[a]] != keys[Prefix(keys,false,n)[b]]
    decreases n
  {
    assert n > 0;
    var previous := Prefix(keys,false,n-1);
    if b < |previous| { Different(keys,n-1,a,b); }
    else {
      assert b == |previous| && Prefix(keys,false,n)[b] == n-1;
      BoundAt(keys,false,n-1,a);
    }
  }
  lemma Membership(keys: seq<nat>,n: nat,value: nat)
    requires n <= |keys|
    ensures (exists j :: 0 <= j < |Prefix(keys,false,n)| && keys[Prefix(keys,false,n)[j]] == value) == (exists i :: 0 <= i < n && keys[i] == value)
  {
    if exists i :: 0 <= i < n && keys[i] == value {
      var i :| 0 <= i < n && keys[i] == value;
      Cover(keys,false,n,i);
    }
    if exists j :: 0 <= j < |Prefix(keys,false,n)| && keys[Prefix(keys,false,n)[j]] == value {
      var j :| 0 <= j < |Prefix(keys,false,n)| && keys[Prefix(keys,false,n)[j]] == value;
      BoundAt(keys,false,n,j);
      assert keys[Prefix(keys,false,n)[j]] == value;
    }
  }
  lemma PrefixFacts(keys: seq<nat>,ordered: bool,n: nat)
    requires n <= |keys|
    ensures forall j :: 0 <= j < |Prefix(keys,ordered,n)| ==> Prefix(keys,ordered,n)[j] < n
    ensures ordered && n > 0 ==> |Prefix(keys,ordered,n)| > 0 && keys[Prefix(keys,ordered,n)[|Prefix(keys,ordered,n)|-1]] == keys[n-1]
    ensures !ordered ==> forall a,b :: 0 <= a < b < |Prefix(keys,ordered,n)| ==> keys[Prefix(keys,ordered,n)[a]] != keys[Prefix(keys,ordered,n)[b]]
    ensures !ordered ==> forall j :: 0 <= j < |Prefix(keys,ordered,n)| ==> forall i :: 0 <= i < Prefix(keys,ordered,n)[j] ==> keys[i] != keys[Prefix(keys,ordered,n)[j]]
  {
    forall j | 0 <= j < |Prefix(keys,ordered,n)|
      ensures Prefix(keys,ordered,n)[j] < n
    { BoundAt(keys,ordered,n,j); }
    if ordered { if n > 0 { Last(keys,n); } }
    else {
      forall a,b | 0 <= a < b < |Prefix(keys,false,n)|
        ensures keys[Prefix(keys,false,n)[a]] != keys[Prefix(keys,false,n)[b]]
      { Different(keys,n,a,b); }
      forall j | 0 <= j < |Prefix(keys,false,n)|
        ensures forall i :: 0 <= i < Prefix(keys,false,n)[j] ==> keys[i] != keys[Prefix(keys,false,n)[j]]
      { Least(keys,n,j); }
    }
  }
  lemma CompareKeys(k: S.Config,keys: seq<nat>,i: nat,kept: seq<nat>,j: nat,c: T.Context,env: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i) && j <= |kept| && |keys| == |k.values| && Coherent(k,keys,env)
    ensures S.Compare(k,i,kept,j,c,env).Compared? ==> S.Compare(k,i,kept,j,c,env).duplicate == (exists at :: j <= at < |kept| && keys[kept[at]] == keys[i])
    decreases |kept|-j
  {
    reveal Coherent();
    if j < |kept| {
      var called := T.Ask(S.Query(k,i,kept,j),c,env);
      if called.reply.Ok? {
        assert called.reply.truth == (keys[kept[j]] == keys[i]);
        if !called.reply.truth { CompareKeys(k,keys,i,kept,j+1,called.context,env); }
      }
    }
  }
  lemma Expected(k: S.Config,keys: seq<nat>,i: nat,c: T.Context,env: T.Environment)
    requires i <= |k.values| && |keys| == |k.values| && Coherent(k,keys,env) && S.Indices(k,Prefix(keys,k.ordered,i),i)
    ensures S.Tail(k,i,Prefix(keys,k.ordered,i),c,env).Returned? ==> S.Tail(k,i,Prefix(keys,k.ordered,i),c,env).kept == Prefix(keys,k.ordered,|keys|)
    decreases |k.values|-i
  {
    if i < |k.values| {
      var kept := Prefix(keys,k.ordered,i);
      PrefixFacts(keys,k.ordered,i);
      F.StepFacts(k,i,kept,c,env);
      var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
      if checked.reply.Ok? {
        CompareKeys(k,keys,i,kept,S.Start(k,kept),checked.context,env);
        var compared := S.Compare(k,i,kept,S.Start(k,kept),checked.context,env);
        if compared.Compared? {
          if k.ordered && i > 0 { assert S.Start(k,kept) == |kept|-1; }
          if !k.ordered {
            Membership(keys,i,keys[i]);
            assert (exists at :: 0 <= at < |kept| && keys[kept[at]] == keys[i]) == (exists at :: 0 <= at < i && keys[at] == keys[i]);
          }
          assert (if compared.duplicate then kept else kept+[i]) == Prefix(keys,k.ordered,i+1);
          S.Append(k,kept,i);
          Expected(k,keys,i+1,compared.context,env);
        }
      }
    }
  }
  predicate Grouped(keys: seq<nat>) {
    forall a,b,c :: 0 <= a < b < c < |keys| && keys[a] == keys[c] ==> keys[b] == keys[a]
  }
  lemma GroupedPrefix(keys: seq<nat>,n: nat)
    requires n <= |keys| && Grouped(keys)
    ensures Prefix(keys,true,n) == Prefix(keys,false,n)
    decreases n
  {
    if n > 0 {
      GroupedPrefix(keys,n-1);
      if n > 1 && keys[n-1] != keys[n-2] {
        forall j | 0 <= j < n-1
          ensures keys[j] != keys[n-1]
        { if j < n-2 && keys[j] == keys[n-1] { assert keys[n-2] == keys[j]; } }
      }
    }
  }
  ghost method Run(k: M.Config,keys: seq<nat>,c: T.Context,h: seq<C.Event>)
    returns (out: S.Outcome,values: seq<seq<Byte>>,env: T.Environment)
    requires M.Room(k) && M.Budget(k,h) && |keys| == |k.subject.values|
    ensures out == S.Run(k.subject,c,env)
    ensures out.Returned? ==> S.Indices(k.subject,out.kept,|k.subject.values|)
    ensures out.Returned? && Coherent(k.subject,keys,env) ==> out.kept == Prefix(keys,k.subject.ordered,|keys|)
    ensures out.Returned? && Coherent(k.subject,keys,env) && Grouped(keys) ==> out.kept == Prefix(keys,false,|keys|)
    ensures out.Returned? && Coherent(k.subject,keys,env) && !k.subject.ordered ==> forall j :: 0 <= j < |out.kept| ==> forall i :: 0 <= i < out.kept[j] ==> keys[i] != keys[out.kept[j]]
    ensures out.Returned? && Coherent(k.subject,keys,env) && !k.subject.ordered ==> forall a,b :: 0 <= a < b < |out.kept| ==> keys[out.kept[a]] != keys[out.kept[b]]
  {
    var prep; var fs; var records;
    out,values,env,prep,fs,records := Public.Run(k,c,h);
    if out.Returned? && Coherent(k.subject,keys,env) {
      F.AdmissionFacts(k.subject,c,env);
      Expected(k.subject,keys,0,F.Admission(k.subject,c,env).context,env);
      PrefixFacts(keys,k.subject.ordered,|keys|);
      if Grouped(keys) { GroupedPrefix(keys,|keys|); }
    }
  }
}
