// SPDX-License-Identifier: MIT
include "../../../proof-tools/dafnyevm/src/dafny/execution.dfy"
include "../../source/assertions/resolution/Model.dfy"

// Source and ABI profile for complete public-call conformance checks. The native
// statements below do not prove that the dispatcher reaches RETURN for every
// payload. That obligation remains separate from concrete execution evidence.
module PublicResolve {
  import C = ConstraintModel
  import R = ResolutionModel
  import W = ResolutionWords
  import V = EvmValues

  function Selector(): seq<C.Byte> { [0x1f,0xa9,0x9b,0x32] }
  function RouteTag(route: R.Route): C.Word {
    match route
    case TARGET => 0
    case VALUE => 1
    case CALL_DATA => 2
  }
  function PaddingSize(length: nat): nat
    ensures PaddingSize(length) < 32
    ensures (length+PaddingSize(length)) % 32 == 0
  { (32-length%32)%32 }
  function Zeroes(length: nat): seq<C.Byte>
    ensures |Zeroes(length)| == length
    ensures forall i :: 0 <= i < length ==> Zeroes(length)[i] == 0
  { seq(length, i requires 0 <= i < length => 0) }

  function Calldata(route: R.Route, payload: seq<C.Byte>): seq<C.Byte>
    requires |payload|+PaddingSize(|payload|)+160 < W.Limit()
  {
    Selector()+W.EncodeWord(32)+W.EncodeWord(RouteTag(route))+W.EncodeWord(0)+
    W.EncodeWord(128)+W.EncodeWord(160+|payload|+PaddingSize(|payload|))+
    W.EncodeWord(|payload|)+payload+Zeroes(PaddingSize(|payload|))+W.EncodeWord(0)
  }

  lemma CanonicalLayout(route: R.Route, payload: seq<C.Byte>)
    requires |payload|+PaddingSize(|payload|)+160 < W.Limit()
    ensures |Calldata(route,payload)| == 228+|payload|+PaddingSize(|payload|)
    ensures Calldata(route,payload)[..4] == Selector()
    ensures C.Read(Calldata(route,payload)[4..36]) == 32
    ensures C.Read(Calldata(route,payload)[36..68]) == RouteTag(route)
    ensures C.Read(Calldata(route,payload)[68..100]) == 0
    ensures C.Read(Calldata(route,payload)[100..132]) == 128
    ensures C.Read(Calldata(route,payload)[132..164]) == 160+|payload|+PaddingSize(|payload|)
    ensures C.Read(Calldata(route,payload)[164..196]) == |payload|
    ensures Calldata(route,payload)[196..196+|payload|] == payload
    ensures C.Read(Calldata(route,payload)[196+|payload|+PaddingSize(|payload|)..]) == 0
  {
    reveal Calldata(); reveal Selector();
    var data := Calldata(route,payload);
    assert data[4..36] == W.EncodeWord(32);
    assert data[36..68] == W.EncodeWord(RouteTag(route));
    assert data[68..100] == W.EncodeWord(0);
    assert data[100..132] == W.EncodeWord(128);
    assert data[132..164] == W.EncodeWord(160+|payload|+PaddingSize(|payload|));
    assert data[164..196] == W.EncodeWord(|payload|);
    assert data[196+|payload|+PaddingSize(|payload|)..] == W.EncodeWord(0);
    W.EncodedWord(32); W.EncodedWord(RouteTag(route)); W.EncodedWord(0);
    W.EncodedWord(128); W.EncodedWord(160+|payload|+PaddingSize(|payload|));
    W.EncodedWord(|payload|);
  }

  lemma RawBytesSource(route: R.Route, payload: seq<C.Byte>, context: C.Context,
                       env: R.Environment, history: seq<R.Request>)
    ensures R.Resolve(R.Param(route,R.RAW_BYTES,payload,[]),context,env,history)
         == R.Outcome(R.Value(payload),history)
  {
    reveal R.Resolve(); reveal R.Fetch(); reveal C.Validate();
    reveal C.Scan(); reveal C.Execute();
  }
}
