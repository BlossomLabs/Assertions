// SPDX-License-Identifier: MIT
include "Source.generated.dfy"

module CollectionsValueLoopsConnection {
  import opened AbiFrames
  import opened CollectionsTraversalModel
  import S = CollectionsValueLoops
  import P = CollectionsTraversalProperties
  import C = CollectionsTraversalConnection

  ghost method Run(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, initial: seq<Byte>, c: Context, env: Environment)
    returns (out: Outcome, positions: seq<nat>, stop: nat)
    requires mode == Fold || initial == []
    requires mode != Filter || outputType == []
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
    if mode == Map { out := S.MapValues(inputType,outputType,values,c,env); }
    else if mode == Filter { out := S.FilterValues(inputType,values,c,env); }
    else { out := S.FoldValues(inputType,outputType,values,initial,c,env); }
    var admitted := Admission(mode,inputType,outputType,initial,c,env);
    C.AdmissionFacts(mode,inputType,outputType,initial,c,env);
    positions := [];
    stop := 0;
    if admitted.Failure? { return; }
    var reference: Outcome;
    reference,positions,stop := P.TailFacts(mode,inputType,outputType,values,0,initial,admitted.context,env);
  }
}
