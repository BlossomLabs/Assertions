// SPDX-License-Identifier: MIT
include "Control.generated.dfy"
module CollectionsValueSearchSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import S = CollectionsValueSearchSpec
  import T = CollectionsTraversalModel
  import Ctrl = CollectionsValueSearchControl

  ghost method Loop(k: S.Config,c: T.Context,env: T.Environment) returns (out: S.Outcome)
    requires Uint(|k.values|)
    ensures out == S.Tail(k,0,c,env)
  {
    var current := c;
    var i: nat := 0;
    while (if S.Binary(k) then Ctrl.IndexLoop(i,|k.values|) else Ctrl.FindLoop(i,|k.values|))
      invariant i <= |k.values|
      invariant S.Tail(k,0,c,env) == S.Tail(k,i,current,env)
      decreases |k.values|-i
    {
      var before := current;
      var inputIndex := if S.Binary(k) then Ctrl.IndexValidate(i) else Ctrl.FindValidate(i);
      assert inputIndex == i;
      var checked := T.Ask(T.Validate(k.inputType,k.values[inputIndex]),current,env);
      if checked.reply.Error? { out := S.Failed(checked.reply.reason,checked.context); return; }
      var called := T.Ask(S.Query(k,i),checked.context,env);
      if called.reply.Error? { out := S.Failed(called.reply.reason,called.context); return; }
      var matched := if S.Binary(k) then Ctrl.IndexMatch(called.reply.truth) else Ctrl.FindMatch(called.reply.truth,S.Wanted(k));
      assert matched == (called.reply.truth == S.Wanted(k));
      if matched {
        var result := if S.Binary(k) then Ctrl.IndexResult(i) else Ctrl.FindResult(i);
        assert result == i;
        out := S.Returned(result as nat,called.context); return;
      }
      assert S.Step(k,i,before,env) == S.Returned(S.Missing(),called.context);
      assert Uint(i+1);
      i := i+1;
      current := called.context;
    }
    assert i == |k.values|;
    var missing := if S.Binary(k) then Ctrl.IndexMissing() else Ctrl.FindMissing();
    assert missing == S.Missing();
    out := S.Returned(missing as nat,current);
  }
  ghost method Run(k: S.Config,c: T.Context,env: T.Environment) returns (out: S.Outcome)
    requires Uint(|k.values|)
    ensures out == S.Run(k,c,env)
  {
    var prepared := T.Ask(T.Prepare(S.Binary(k)),c,env);
    if prepared.reply.Error? { out := S.Failed(prepared.reply.reason,prepared.context); return; }
    var checked := T.Ask(if S.Binary(k) then T.Validate(k.inputType,k.needle) else T.Shape(k.inputType),prepared.context,env);
    if checked.reply.Error? { out := S.Failed(checked.reply.reason,checked.context); return; }
    out := Loop(k,checked.context,env);
  }
  lemma WrapperWanted(mode: S.Mode)
    ensures (if mode == S.Any then Ctrl.AnyWanted() else if mode == S.All then Ctrl.AllWanted() else Ctrl.FindWanted()) == (mode != S.All)
  {}
  lemma WrapperResult(k: S.Config,index: nat)
    requires k.mode == S.Any || k.mode == S.All
    ensures (if k.mode == S.Any then Ctrl.AnyResult(index) else Ctrl.AllResult(index)) == S.Bool(k,index)
  {}
}
