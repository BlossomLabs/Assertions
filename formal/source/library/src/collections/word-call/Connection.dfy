// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsWordCallConnection {
  import opened AbiFrames
  import opened CollectionsWordCallModel
  import S = CollectionsWordCallSource
  import C = CollectionsCallsModel
  import R = CollectionsCallbackResultsModel
  import W = CollectionsWireModel
  ghost method Run(domain: Domain,index: nat,subject: seq<Byte>,operation: seq<Byte>,target: nat,data: seq<Byte>,h: seq<C.Event>,env: Environment)
    returns (element: nat,answer: Answer,after: seq<C.Event>)
    requires DomainRoom(domain,index,subject) && Room(operation,index,target,data,env(h,target,data))
    ensures element == Element(domain,index,subject) && element < Pow256(32)
    ensures answer == Judge(operation,index,target,data,env(h,target,data))
    ensures after == h+[C.External(target,data)]
    ensures answer.Word? == (env(h,target,data).success && |env(h,target,data).data| == 32)
    ensures answer.Word? ==> answer.value < Pow256(32) && AbiFrames.Word(answer.value) == env(h,target,data).data
    ensures !env(h,target,data).success && R.Reject(env(h,target,data).gasBefore,env(h,target,data).gasAfter,env(h,target,data).data) ==> answer == Failure(R.Signal())
    ensures !env(h,target,data).success && !R.Reject(env(h,target,data).gasBefore,env(h,target,data).gasAfter,env(h,target,data).data) ==> answer == Failure(W.ErrorBytes(C.CallbackFailed(operation,index,0,target,data,env(h,target,data).data)))
    ensures env(h,target,data).success && |env(h,target,data).data| != 32 ==> answer == Failure(R.InvalidBytes(R.Context(operation,index,0,target)))
  {
    element := S.DomainElement(domain,index,subject);
    answer,after := S.CallWord(operation,index,target,data,h,env);
    if answer.Word? { BytesNatRoundTrip(env(h,target,data).data); }
  }
}
