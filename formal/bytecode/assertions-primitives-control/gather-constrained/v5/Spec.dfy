// SPDX-License-Identifier: MIT
// Independent public passing non-OR constrained RAW gather class and explicit allocation bounds.
include "Values.dfy"
include "../../gather-public/Dispatch.generated.dfy"
include "../../gather-public/Decoder.generated.dfy"
include "../../gather-public/serialization/Wrapper.dfy"
module AssertionsGatherConstrainedPublicSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import P = AssertionsGatherConstrainedLoopSpec
  import V = AssertionsGatherConstrainedValues
  import W = AssertionsGatherArrayWork
  import D = AssertionsGatherPublicSpec
  import A = AssertionsGatherAllocation
  import H = AssertionsGatherConstrainedAllocation
  import DS = AssertionsGatherCallerSpec
  import C = AssertionsGatherPublicDecoder
  import B = AssertionsGatherPublicDispatch
  import Z = AssertionsGatherSerializerBefore
  import X = AssertionsGatherSerializerWrapper
  type Word = S.Word
  type Byte = S.Byte
  function Start(items: seq<P.Item>): Word
    requires |items| < 0x10000000000000000
  { A.End(128,|items|) }
  function Base(items: seq<P.Item>): Word
    requires |items| < 0x10000000000000000 && P.Budget(Start(items),items)
  { Start(items)+P.Used(items,|items|) }
  opaque predicate Calldata(data: seq<Byte>, relative: Word, items: seq<P.Item>) {
    |items| < 0x10000000000000000 && D.Calldata(data,relative,|items|) &&
    S.ShiftRight(S.DataWord(data,0),224) == D.Selector() &&
    P.Calldata(data,D.Args(relative),items) && V.Layout(data,items) &&
    P.Budget(Start(items),items) &&
    W.Budget(Base(items),V.Values(data,items))
  }
  lemma Initial(count: Word)
    requires count < 0x10000000000000000 && A.End(128,count)+96 < 0x10000000000000000
    ensures H.Space(D.Initial(),128,count) && S.Load(D.Initial(),64) == 128
  { R.StoredWord([],64,128); }
  lemma Caller(code: seq<Byte>, data: seq<Byte>, relative: Word, items: seq<P.Item>)
    requires Calldata(data,relative,items) && X.Matches(code)
    ensures |data| < G.Modulus() && |items| < 0x10000000000000000
    ensures D.Calldata(data,relative,|items|) && P.Calldata(data,D.Args(relative),items) && V.Layout(data,items)
    ensures P.Budget(Start(items),items)
    ensures W.Budget(Base(items),V.Values(data,items))
    ensures B.Admitted(relative,|items|,[],[],data,0) && C.Admitted(relative,|items|,[],D.Initial(),data,0)
    ensures H.Space(D.Initial(),128,|items|) && S.Load(D.Initial(),64) == 128
    ensures 477 in DS.RuntimeDestinations() && 477 < |code| && code[477] == 0x5b
  {
    reveal Calldata(); Initial(|items|);
    reveal B.Admitted(); reveal C.Admitted();
    reveal DS.RuntimeDestinations(); reveal DS.Chunk0();
    reveal Z.Matches();
  }
}
