// SPDX-License-Identifier: MIT
// Collections.sol SHA256: $HASH
include "../traversal/Connection.dfy"

module CollectionsValueLoops {
  import opened AbiFrames
  import opened CollectionsTraversalModel

  lemma WritePrefix(buffer: seq<seq<Byte>>, index: nat, value: seq<Byte>)
    requires index < |buffer|
    ensures buffer[index := value][..index+1] == buffer[..index]+[value]
  {}

  ghost method MapValues(inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, c: Context, env: Environment) returns (out: Outcome)
    ensures out == CollectionsTraversalModel.Run(Map,inputType,outputType,values,[],c,env)
  {
    var prepared := Ask(Prepare($MAP_PREP_BINARY),c,env);
    if prepared.reply.Error? { out := Failure(prepared.reply.reason,prepared.context); return; }
    var shaped := Ask(Shape(inputType),prepared.context,env);
    if shaped.reply.Error? { out := Failure(shaped.reply.reason,shaped.context); return; }
    var admitted := Ask(Shape(outputType),shaped.context,env);
    if admitted.reply.Error? { out := Failure(admitted.reply.reason,admitted.context); return; }
    var current := admitted.context;
    var buffer: seq<seq<Byte>> := seq(|values|, j => []);
    var i: nat := 0;
    while $MAP_GUARD
      invariant i <= |values|
      invariant |buffer| == |values|
      invariant CollectionsTraversalModel.Run(Map,inputType,outputType,values,[],c,env) ==
                Prepend(buffer[..i],Tail(Map,inputType,outputType,values,i,[],current,env))
      decreases |values|-i
    {
      var before := current;
      var oldAcc := [];
      var prefix := buffer[..i];
      var input := Ask(Validate(inputType,values[i]),current,env);
      if input.reply.Error? { out := Failure(input.reply.reason,input.context); return; }
      var call := Ask(Call($MAP_A,$MAP_B,$MAP_BINARY,$MAP_INDEX,$MAP_OTHER),input.context,env);
      if call.reply.Error? { out := Failure(call.reply.reason,call.context); return; }
      WritePrefix(buffer,i,call.reply.value);
      buffer := buffer[i := call.reply.value];
      var checked := Ask(ValidateResult($MAP_RESULT_TYPE,$MAP_RESULT_VALUE,$MAP_RESULT_INDEX),call.context,env);
      if checked.reply.Error? { out := Failure(checked.reply.reason,checked.context); return; }
      current := checked.context;
      var next := Step(Map,inputType,outputType,values[i],i,oldAcc,before,env);
      assert next.Success? && next.context == current && next.accumulator == [];
      PrependAssociative(prefix,next.values,Tail(Map,inputType,outputType,values,i+1,[],current,env));
      i := i+1;
    }
    out := Success(buffer[..i],[],current);
  }

  ghost method FilterValues(inputType: seq<Byte>, values: seq<seq<Byte>>, c: Context, env: Environment) returns (out: Outcome)
    ensures out == CollectionsTraversalModel.Run(Filter,inputType,[],values,[],c,env)
  {
    var prepared := Ask(Prepare($FILTER_PREP_BINARY),c,env);
    if prepared.reply.Error? { out := Failure(prepared.reply.reason,prepared.context); return; }
    var shaped := Ask(Shape(inputType),prepared.context,env);
    if shaped.reply.Error? { out := Failure(shaped.reply.reason,shaped.context); return; }
    var current := shaped.context;
    var buffer: seq<seq<Byte>> := seq(|values|, j => []);
    var count: nat := 0;
    var i: nat := 0;
    while $FILTER_GUARD
      invariant i <= |values|
      invariant |buffer| == |values|
      invariant count <= i
      invariant CollectionsTraversalModel.Run(Filter,inputType,[],values,[],c,env) ==
                Prepend(buffer[..count],Tail(Filter,inputType,[],values,i,[],current,env))
      decreases |values|-i
    {
      var before := current;
      var oldAcc := [];
      var prefix := buffer[..count];
      var input := Ask(Validate(inputType,values[i]),current,env);
      if input.reply.Error? { out := Failure(input.reply.reason,input.context); return; }
      var call := Ask(Predicate($FILTER_A,$FILTER_B,$FILTER_BINARY,$FILTER_INDEX,$FILTER_OTHER),input.context,env);
      if call.reply.Error? { out := Failure(call.reply.reason,call.context); return; }
      if call.reply.truth {
        WritePrefix(buffer,count,values[i]);
        buffer := buffer[count := values[i]];
        count := count+1;
      }
      current := call.context;
      var next := Step(Filter,inputType,[],values[i],i,oldAcc,before,env);
      assert next.Success? && next.context == current && next.accumulator == [];
      PrependAssociative(prefix,next.values,Tail(Filter,inputType,[],values,i+1,[],current,env));
      i := i+1;
    }
    out := Success(buffer[..count],[],current);
  }

  ghost method FoldValues(inputType: seq<Byte>, accumulatorType: seq<Byte>, values: seq<seq<Byte>>, initial: seq<Byte>, c: Context, env: Environment) returns (out: Outcome)
    ensures out == CollectionsTraversalModel.Run(Fold,inputType,accumulatorType,values,initial,c,env)
  {
    var prepared := Ask(Prepare($FOLD_PREP_BINARY),c,env);
    if prepared.reply.Error? { out := Failure(prepared.reply.reason,prepared.context); return; }
    var shaped := Ask(Shape(inputType),prepared.context,env);
    if shaped.reply.Error? { out := Failure(shaped.reply.reason,shaped.context); return; }
    var admitted := Ask(Validate(accumulatorType,initial),shaped.context,env);
    if admitted.reply.Error? { out := Failure(admitted.reply.reason,admitted.context); return; }
    var current := admitted.context;
    var result := initial;
    var i: nat := 0;
    while $FOLD_GUARD
      invariant i <= |values|
      invariant CollectionsTraversalModel.Run(Fold,inputType,accumulatorType,values,initial,c,env) ==
                Prepend([],Tail(Fold,inputType,accumulatorType,values,i,result,current,env))
      decreases |values|-i
    {
      var before := current;
      var oldAcc := result;
      var prefix := [];
      var input := Ask(Validate(inputType,values[i]),current,env);
      if input.reply.Error? { out := Failure(input.reply.reason,input.context); return; }
      var call := Ask(Call($FOLD_A,$FOLD_B,$FOLD_BINARY,$FOLD_INDEX,$FOLD_OTHER),input.context,env);
      if call.reply.Error? { out := Failure(call.reply.reason,call.context); return; }
      result := call.reply.value;
      var checked := Ask(ValidateResult($FOLD_RESULT_TYPE,$FOLD_RESULT_VALUE,$FOLD_RESULT_INDEX),call.context,env);
      if checked.reply.Error? { out := Failure(checked.reply.reason,checked.context); return; }
      current := checked.context;
      var next := Step(Fold,inputType,accumulatorType,values[i],i,oldAcc,before,env);
      assert next.Success? && next.context == current && next.accumulator == result;
      PrependAssociative(prefix,next.values,Tail(Fold,inputType,accumulatorType,values,i+1,result,current,env));
      i := i+1;
    }
    out := Success([],result,current);
  }
}
