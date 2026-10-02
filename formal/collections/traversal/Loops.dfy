// SPDX-License-Identifier: MIT
include "Model.dfy"

module CollectionsTraversalLoops {
  import opened AbiFrames
  import opened CollectionsTraversalModel

  // Imperative traversal over projected helper observations. This is not yet
  // a source-connected Solidity adapter: helper and source gates come next.
  ghost method Run(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, initial: seq<Byte>, c: Context, env: Environment) returns (out: Outcome)
    ensures out == CollectionsTraversalModel.Run(mode,inputType,outputType,values,initial,c,env)
  {
    var admitted := Admission(mode,inputType,outputType,initial,c,env);
    if admitted.Failure? { out := admitted; return; }
    var current := admitted.context;
    var acc := initial;
    var result: seq<seq<Byte>> := [];
    var i: nat := 0;
    while i < |values|
      invariant i <= |values|
      invariant CollectionsTraversalModel.Run(mode,inputType,outputType,values,initial,c,env) ==
                Prepend(result,Tail(mode,inputType,outputType,values,i,acc,current,env))
      decreases |values|-i
    {
      var next := Step(mode,inputType,outputType,values[i],i,acc,current,env);
      if next.Failure? { out := next; return; }
      PrependAssociative(result,next.values,Tail(mode,inputType,outputType,values,i+1,next.accumulator,next.context,env));
      result := result+next.values;
      acc := next.accumulator;
      current := next.context;
      i := i+1;
    }
    out := Success(result,acc,current);
  }
}
