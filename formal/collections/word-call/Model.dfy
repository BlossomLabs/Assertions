// SPDX-License-Identifier: MIT
include "../wire/Connection.dfy"
include "../../abi/source/BytesBody.generated.dfy"
module CollectionsWordCallModel {
  import opened AbiFrames
  import C = CollectionsCallsModel
  import R = CollectionsCallbackResultsModel
  import W = CollectionsWireModel
  datatype Domain = Range | Bytes | Words
  predicate DomainRoom(domain: Domain,index: nat,subject: seq<Byte>) {
    index < Pow256(32) && |subject| < Pow256(32) &&
    (domain == Bytes ==> index < |subject|) && (domain == Words ==> index < |subject|/32)
  }
  function Element(domain: Domain,index: nat,subject: seq<Byte>): nat
    requires DomainRoom(domain,index,subject)
  {
    if domain == Range then index else if domain == Bytes then subject[index]
    else ReadNat(subject[32*index..32*index+32])
  }
  datatype Answer = Word(value: nat) | Failure(reason: seq<Byte>)
  type Environment = (seq<C.Event>,nat,seq<Byte>)->C.Observation
  function Error(operation: seq<Byte>,index: nat,target: nat,data: seq<Byte>,observed: C.Observation): C.Error {
    if R.Reject(observed.gasBefore,observed.gasAfter,observed.data) then C.OutOfGas
    else C.CallbackFailed(operation,index,0,target,data,observed.data)
  }
  function Judge(operation: seq<Byte>,index: nat,target: nat,data: seq<Byte>,observed: C.Observation): Answer {
    if !observed.success then Failure(W.ErrorBytes(Error(operation,index,target,data,observed))) else
    if |observed.data| != 32 then Failure(R.InvalidBytes(R.Context(operation,index,0,target)))
    else Word(ReadNat(observed.data))
  }
  predicate Room(operation: seq<Byte>,index: nat,target: nat,data: seq<Byte>,observed: C.Observation) {
    R.Fits(R.Context(operation,index,0,target)) && |data| < Pow256(32) && |observed.data| < Pow256(32) &&
    observed.gasBefore < Pow256(32) && observed.gasAfter < Pow256(32) &&
    (!observed.success ==> W.ErrorFits(Error(operation,index,target,data,observed)))
  }
}
