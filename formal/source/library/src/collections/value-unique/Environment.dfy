// SPDX-License-Identifier: MIT
include "Spec.dfy"
module CollectionsValueUniqueEnvironment {
  import opened AbiFrames
  import T = CollectionsTraversalModel
  import E = CollectionsEnvironmentModel
  import S = CollectionsValueUniqueSpec
  import Replay = CollectionsEnvironmentConnection
  lemma CompareLength(k: S.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,env: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i) && j <= |kept|
    ensures c.history <= S.Compare(k,i,kept,j,c,env).context.history
    ensures |S.Compare(k,i,kept,j,c,env).context.history| <= |c.history|+|kept|-j
    ensures j < |kept| ==> |S.Compare(k,i,kept,j,c,env).context.history| > |c.history|
    decreases |kept|-j
  {
    if j < |kept| {
      var called := T.Ask(S.Query(k,i,kept,j),c,env);
      if called.reply.Ok? && !called.reply.truth { CompareLength(k,i,kept,j+1,called.context,env); }
    }
  }
  lemma CompareReplay(k: S.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,a: T.Environment,b: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i) && j <= |kept|
    requires E.Window(a,b,|c.history|,|S.Compare(k,i,kept,j,c,a).context.history|)
    ensures S.Compare(k,i,kept,j,c,a) == S.Compare(k,i,kept,j,c,b)
    decreases |kept|-j
  {
    CompareLength(k,i,kept,j,c,a);
    if j < |kept| {
      var called := T.Ask(S.Query(k,i,kept,j),c,a);
      Replay.AskSame(S.Query(k,i,kept,j),c,a,b);
      if called.reply.Ok? && !called.reply.truth {
        CompareReplay(k,i,kept,j+1,called.context,a,b);
      }
    }
  }
  lemma CompareJoin(k: S.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,a: T.Environment,b: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i) && j < |kept|
    ensures S.Compare(k,i,kept,j,c,E.Splice(a,b,|T.Ask(S.Query(k,i,kept,j),c,a).context.history|)) ==
            (if T.Ask(S.Query(k,i,kept,j),c,a).reply.Error? then S.CompareFailed(T.Ask(S.Query(k,i,kept,j),c,a).reply.reason,T.Ask(S.Query(k,i,kept,j),c,a).context)
             else if T.Ask(S.Query(k,i,kept,j),c,a).reply.truth then S.Compared(true,T.Ask(S.Query(k,i,kept,j),c,a).context)
             else S.Compare(k,i,kept,j+1,T.Ask(S.Query(k,i,kept,j),c,a).context,b))
  {
    var called := T.Ask(S.Query(k,i,kept,j),c,a);
    var env := E.Splice(a,b,|called.context.history|);
    E.Before(a,b,|c.history|,|called.context.history|);
    Replay.AskSame(S.Query(k,i,kept,j),c,a,env);
    if called.reply.Ok? && !called.reply.truth {
      E.After(a,b,|called.context.history|);
      CompareLength(k,i,kept,j+1,called.context,b);
      assert E.Window(b,env,|called.context.history|,|S.Compare(k,i,kept,j+1,called.context,b).context.history|);
      CompareReplay(k,i,kept,j+1,called.context,b,env);
    }
  }
}
