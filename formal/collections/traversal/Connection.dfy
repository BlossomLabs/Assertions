// SPDX-License-Identifier: MIT
include "Properties.dfy"

module CollectionsTraversalConnection {
  import opened AbiFrames
  import opened CollectionsTraversalModel
  import P = CollectionsTraversalProperties
  import L = CollectionsTraversalLoops

  lemma AdmissionFacts(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, initial: seq<Byte>, c: Context, env: Environment)
    ensures c.history <= Admission(mode,inputType,outputType,initial,c,env).context.history
    ensures P.Calls(Admission(mode,inputType,outputType,initial,c,env).context.history) == P.Calls(c.history)
  {
    var first := Ask(Prepare(mode == Fold),c,env);
    P.AppendCall(c.history,Prepare(mode == Fold));
    if first.reply.Error? { return; }
    var second := Ask(Shape(inputType),first.context,env);
    P.AppendCall(first.context.history,Shape(inputType));
    if second.reply.Error? || mode == Filter { return; }
    P.AppendCall(second.context.history,if mode == Map then Shape(outputType) else Validate(outputType,initial));
  }
  ghost method Run(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, initial: seq<Byte>, c: Context, env: Environment)
    returns (out: Outcome, positions: seq<nat>, stop: nat)
    ensures out == CollectionsTraversalModel.Run(mode,inputType,outputType,values,initial,c,env)
    ensures stop <= |values| && c.history <= out.context.history
    ensures P.Calls(out.context.history) == P.Calls(c.history)+P.Range(0,stop)
    ensures out.Success? ==> stop == |values|
    ensures out.Success? && mode == Map ==> |out.values| == |values|
    ensures out.Success? && mode == Fold ==> out.values == []
    ensures out.Success? && mode != Fold ==> out.accumulator == initial
    ensures out.Success? && mode == Filter ==> |positions| == |out.values| &&
                                               (forall j :: 0 <= j < |positions| ==> positions[j] < |values| && out.values[j] == values[positions[j]]) &&
                                               (forall j :: 0 <= j < |positions|-1 ==> positions[j] < positions[j+1])
    ensures |values| == 0 && out.Success? ==> out.values == [] && out.accumulator == initial
  {
    out := L.Run(mode,inputType,outputType,values,initial,c,env);
    var admitted := Admission(mode,inputType,outputType,initial,c,env);
    AdmissionFacts(mode,inputType,outputType,initial,c,env);
    positions := [];
    stop := 0;
    if admitted.Failure? { return; }
    var reference: Outcome;
    reference,positions,stop := P.TailFacts(mode,inputType,outputType,values,0,initial,admitted.context,env);
  }
}
