// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsWordFoldEntryReady {
  import opened AbiFrames
  import opened CollectionsWordFoldEntryModel
  import L = CollectionsWordFoldLoopModel
  import W = CollectionsWordWindowsModel
  import WP = CollectionsWordWindowsConnection
  import Call = CollectionsWordCallModel
  lemma Static(k: Config)
    requires Basic(k)
    ensures Admission(k).Accepted? ==> L.Static(LoopConfig(k))
  {
    WP.Specification(|k.template|,k.accOffset,k.offsets);
    if Admission(k).Accepted? {
      forall i {:trigger Call.DomainRoom(k.domain,i,if k.domain == Call.Range then [] else k.subject)} | 0 <= i < Count(k)
        ensures Call.DomainRoom(k.domain,i,if k.domain == Call.Range then [] else k.subject)
      {}
    }
  }
}
