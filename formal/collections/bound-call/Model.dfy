// SPDX-License-Identifier: MIT
include "../codec-errors/Connection.dfy"
module CollectionsBoundCallModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import P = CollectionsPreparationModel
  import C = CollectionsCallsModel
  import V = AbiConstructionContext
  import W = CollectionsCodecErrorEncoding
  import Wire = CollectionsWireModel

  function Query(fs: seq<Descriptor>, slot: nat, value: seq<Byte>): P.Request
    requires slot < |fs|
  { P.Validate(Render(fs[slot]),value,slot,Dyn(fs[slot]),Width(fs[slot])) }
  function Codec(q1: P.Request, r1: V.Result, q2: P.Request, r2: V.Result): P.Environment
    requires q1.Validate? && q2.Validate?
  { P.Environment((h,q) => if q == q1 then (if r1.Success? then P.Ok else P.Error(W.Encode(r1)))
                    else if q == q2 then (if r2.Success? then P.Ok else P.Error(W.Encode(r2))) else P.Error([])) }
  function Environment(base: C.Environment, q1: P.Request, r1: V.Result, q2: P.Request, r2: V.Result): C.Environment
    requires q1.Validate? && q2.Validate?
  { Wire.Environment(C.Environment(h => Codec(q1,r1,q2,r2),base.code,base.direct,base.expression,base.call)) }
  lemma Admitted(base: C.Environment, q1: P.Request, r1: V.Result, q2: P.Request, r2: V.Result)
    requires q1.Validate? && q2.Validate?
    ensures C.Admitted(Environment(base,q1,r1,q2,r2))
  {}
}
